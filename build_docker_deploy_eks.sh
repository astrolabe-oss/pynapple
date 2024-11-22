#!/bin/bash -ex

# APP CONFIG
APP_NAME1="pynapple1"
APP_NAME2="pynapple2"
REPOSITORY1="sandbox1-pynapple1"
REPOSITORY2="sandbox1-pynapple2"

# SANDBOX ENV CONFIG
AWS_ACCOUNT=$(aws sts get-caller-identity --query "Account" --output text)
AWS_REGION="us-east-1"
TIMESTAMP=$(date +%Y%m%d_%H_%M_%S)

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
