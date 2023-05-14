export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
# not working. just a remainder
eksctl create iamidentitymapping --cluster cluster-may --arn arn:aws:iam::$ACCOUNT_ID:role/eks-user-role --username dev-user