#!/bin/bash -x
# CONFIG
AWS_ACCOUNT_CR=517988372097
AWS_REGION="us-east-1"
REPOSITORY=sandbox1-pynapple
TIMESTAMP=$(date +%Y%m%d_%H_%M_%S)
PYNAPPLE_CONTEXT="arn:aws:eks:${AWS_REGION}:517988372097:cluster/sandbox1-eks"

# ENSURE AWS ACCOUNT
CURRENT_AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
if [ "${CURRENT_AWS_ACCOUNT_ID}" != "${AWS_ACCOUNT_CR}" ]; then
    echo "Error: please be logged in to the CR AWS Account:${EXPECTED_AWS_ACCOUNT_ID}... currently: ${CURRENT_AWS_ACCOUNT_ID}."
    exit 1
fi

# ENSURE KUBECTL CLUSTER
CURRENT_CONTEXT=$(kubectl config current-context)
if [ "${CURRENT_CONTEXT}" != "${PYNAPPLE_CONTEXT}" ]; then
    echo "Error: please configure kubectl for context: ${PYNAPPLE_CONTEXT}, got ${CURRENT_CONTEXT}."
    exit 1
fi

# LOGIN DOCKER/ECR
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_CR}.dkr.ecr.${AWS_REGION}.amazonaws.com

# BUILD
docker build --no-cache -t pynapple:${TIMESTAMP} .

# TAG/PUSH VERSION
docker tag pynapple:${TIMESTAMP} ${AWS_ACCOUNT_CR}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPOSITORY}:${TIMESTAMP}
docker push ${AWS_ACCOUNT_CR}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPOSITORY}:${TIMESTAMP}

# TAG/PUSH LATEST
docker tag pynapple:${TIMESTAMP} ${AWS_ACCOUNT_CR}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPOSITORY}:latest
docker push ${AWS_ACCOUNT_CR}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPOSITORY}:latest

# UPDATE SECRETS 
AWS_SECRET_NAME="sandbox1/pynapple/app_db_pw"
K8S_SECRET_NAME="pynapple-env"
SECRET_KEY_IN_K8S="PYNAPPLE_DATABASE_URI"
SECRET_VALUE=$(aws secretsmanager get-secret-value --secret-id ${AWS_SECRET_NAME} --region ${AWS_REGION} --query SecretString --output text)
SECRET_CONFIG_VALUE="postgresql://pynapple:${SECRET_VALUE}@sandbox1-pynapple-db.chqoygiays09.us-east-1.rds.amazonaws.com:5432/pynapple"
kubectl delete secret ${K8S_SECRET_NAME}
kubectl create secret generic ${K8S_SECRET_NAME} --from-literal=${SECRET_KEY_IN_K8S}="${SECRET_CONFIG_VALUE}"

# TRIGGER DEPLOY
kubectl rollout restart deployment/pynapple
