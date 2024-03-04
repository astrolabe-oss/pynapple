#!/bin/bash -x
AWS_ACCOUNT_CR=517988372097
REPOSITORY=sandbox1-pynapple
TIMESTAMP=$(date +%Y%m%d_%H_%M_%S)

# LOGIN DOCKER/ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${AWS_ACCOUNT_CR}.dkr.ecr.us-east-1.amazonaws.com

# BUILD
docker build --no-cache -t pynapple:${TIMESTAMP} .

# TAG/PUSH VERSION
docker tag pynapple:${TIMESTAMP} ${AWS_ACCOUNT_CR}.dkr.ecr.us-east-1.amazonaws.com/${REPOSITORY}:${TIMESTAMP}
docker push ${AWS_ACCOUNT_CR}.dkr.ecr.us-east-1.amazonaws.com/${REPOSITORY}:${TIMESTAMP}

# TAG/PUSH LATEST
docker tag pynapple:${TIMESTAMP} ${AWS_ACCOUNT_CR}.dkr.ecr.us-east-1.amazonaws.com/${REPOSITORY}:latest
docker push ${AWS_ACCOUNT_CR}.dkr.ecr.us-east-1.amazonaws.com/${REPOSITORY}:latest
