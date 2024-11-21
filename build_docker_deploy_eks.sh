#!/bin/bash -e
RESTART_DEPLOYMENTS=false

# Parse command-line options
usage() {
    echo "Usage: $0 [-r] [-h]"
    echo "  -r,    Conditionally restart the k8s deployments."
    echo "  -h,    Display this help message and exit."
}

while getopts ":rh" opt; do
  case ${opt} in
    r )
      RESTART_DEPLOYMENTS=true
      ;;
    h )
      usage
      exit
      ;;
    \? )
      usage
      exit 1
      ;;
  esac
done

# APP CONFIG
APP_NAME1="pynapple1"
APP_NAME2="pynapple2"
REPOSITORY1=sandbox1-pynapple1
REPOSITORY2=sandbox1-pynapple2

# SANDBOX ENV CONFIG
AWS_ACCOUNT=112795234683
AWS_REGION="us-east-1"
TIMESTAMP=$(date +%Y%m%d_%H_%M_%S)

# ENSURE AWS ACCOUNT
CURRENT_AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
if [ "${CURRENT_AWS_ACCOUNT_ID}" != "${AWS_ACCOUNT}" ]; then
    echo "Error: please be logged in to the CR AWS Account:${EXPECTED_AWS_ACCOUNT_ID}... currently: ${CURRENT_AWS_ACCOUNT_ID}."
    exit 1
fi

# LOGIN DOCKER/ECR
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com

# BUILD
docker build --no-cache -t ${APP_NAME1}:${TIMESTAMP} .
docker build --no-cache -t ${APP_NAME2}:${TIMESTAMP} .

# TAG/PUSH VERSION
docker tag ${APP_NAME1}:${TIMESTAMP} ${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPOSITORY1}:${TIMESTAMP}
docker push ${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPOSITORY1}:${TIMESTAMP}
docker tag ${APP_NAME2}:${TIMESTAMP} ${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPOSITORY2}:${TIMESTAMP}
docker push ${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPOSITORY2}:${TIMESTAMP}

# TAG/PUSH LATEST
docker tag ${APP_NAME1}:${TIMESTAMP} ${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPOSITORY1}:latest
docker push ${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPOSITORY1}:latest
docker tag ${APP_NAME2}:${TIMESTAMP} ${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPOSITORY2}:latest
docker push ${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPOSITORY2}:latest

if [ "$RESTART_DEPLOYMENTS" = false ] ; then
  echo "Not restarting deployments..."
  exit 0
fi

echo "Restarting deployments"
# ENSURE KUBECTL CLUSTER
KUBERCTL_CONTEXT="arn:aws:eks:${AWS_REGION}:112795234683:cluster/sandbox1-eks"
CURRENT_CONTEXT=$(kubectl config current-context)
if [ "${CURRENT_CONTEXT}" != "${KUBERCTL_CONTEXT}" ]; then
    echo "Error: please configure kubectl for context: ${KUBERCTL_CONTEXT}, got ${CURRENT_CONTEXT}."
    exit 1
fi

# TRIGGER DEPLOY
kubectl rollout restart deployment/${APP_NAME1}
kubectl rollout restart deployment/${APP_NAME2}
