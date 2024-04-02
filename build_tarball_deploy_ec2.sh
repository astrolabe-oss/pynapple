#!/bin/bash

# Set variables
INCLUDED_FILES="pynapple/*.py pynapple/requirements.txt deploy"
TARBALL_NAME="backup_$(date +%Y%m%d_%H%M%S).tar.gz"
LATEST_TARBALL_NAME="deploy_latest.tar.gz"
S3_BUCKET="s3://guruai-sandbox1-pynapple1-deploy"
REFRESH_ASG_INSTANCES=false
ASG_NAME="sandbox1-pynapple1-2024033120142773680000000c"

# Parse command-line options
usage() {
    echo "Usage: $0 [-r] [-h]"
    echo "  -r,    Conditionally refresh the ASG."
    echo "  -h,    Display this help message and exit."
}
while getopts ":rh" opt; do
  case ${opt} in
    r )
      REFRESH_ASG_INSTANCES=true
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

# Create a tarball with only the specified files and directories
tar --exclude '._*' -czvf "$TARBALL_NAME" $(echo $INCLUDED_FILES | sed 's/ / /g')

# Upload the tarball to S3
aws s3 cp "$TARBALL_NAME" "$S3_BUCKET/$TARBALL_NAME"
aws s3 cp "$TARBALL_NAME" "$S3_BUCKET/$LATEST_TARBALL_NAME"

# Optional: Remove the tarball after upload
rm "$TARBALL_NAME"

echo "Backup completed and uploaded to $S3_BUCKET"

# Conditional redeployment based on the -r flag
if [ "$REFRESH_ASG_INSTANCES" = true ] ; then
  echo "Refreshing ASG instances the service..."
  aws autoscaling start-instance-refresh --auto-scaling-group-name $ASG_NAME
fi
