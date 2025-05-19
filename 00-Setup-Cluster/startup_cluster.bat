eksctl create cluster --name=eksdemo1 ^
                      --region=us-east-1 ^
                      --zones=us-east-1a,us-east-1b ^
                      --without-nodegroup 


eksctl utils associate-iam-oidc-provider ^
    --region us-east-1 ^
    --cluster eksdemo1 ^
    --approve


eksctl create nodegroup --cluster=eksdemo1 ^
                        --region=us-east-1 ^
                        --name=eksdemo1-ng-public1 ^
                        --node-type=t3.medium ^
                        --nodes=2 ^
                        --nodes-min=2 ^
                        --nodes-max=4 ^
                        --node-volume-size=20 ^
                        --ssh-access ^
                        --ssh-public-key=kube-demo ^
                        --managed ^
                        --asg-access ^
                        --external-dns-access ^
                        --full-ecr-access ^
                        --appmesh-access ^
                        --alb-ingress-access 

:: Set cluster and node group name
@REM set CLUSTER_NAME=eksdemo1
@REM set NODEGROUP_NAME=eksdemo1-ng-public1
@REM set POLICY_ARN=arn:aws:iam::381492111228:policy/Amazon_EBS_CSI_Driver

@REM :: Get the node role ARN
@REM for /f "delims=" %%i in ('aws eks describe-nodegroup --cluster-name %CLUSTER_NAME% --nodegroup-name %NODEGROUP_NAME% --query "nodegroup.nodeRole" --output text') do (
@REM     set ROLE_ARN=%%i
@REM )

@REM :: Extract the role name from the ARN
@REM for %%i in (%ROLE_ARN%) do (
@REM     for /f "tokens=6 delims=/" %%a in ("%%i") do set ROLE_NAME=%%a
@REM )

@REM echo Attaching policy to role: %ROLE_NAME%
@REM aws iam attach-role-policy --role-name %ROLE_NAME% --policy-arn %POLICY_ARN%
@REM aws eks describe-nodegroup ^
@REM     --cluster-name eksdemo1 ^
@REM     --nodegroup-name eksdemo1-ng-public1 ^
@REM     --query "nodegroup.nodeRole"   ^
@REM     --output text

@REM kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"