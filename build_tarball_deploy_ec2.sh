#!/bin/bash -ex

# Set variables
INCLUDED_FILES="pynapple/*.py pynapple/requirements.txt deploy"
TARBALL_NAME="backup_$(date +%Y%m%d_%H%M%S).tar.gz"
LATEST_TARBALL_NAME="deploy_latest.tar.gz"

# Validate that at least one bucket is provided
if [[ $# -eq 0 ]]; then
    echo "Error: At least one S3 bucket must be specified."
    echo "Usage: $0 <s3_bucket1> [<s3_bucket2> ...]"
    exit 1
fi

# Create a tarball with only the specified files and directories
tar --exclude '._*' -czvf "$TARBALL_NAME" $(echo $INCLUDED_FILES | sed 's/ / /g')

# Loop through all arguments and upload to each bucket
for S3_BUCKET in "$@"; do
    echo "Uploading to $S3_BUCKET..."
    aws s3 cp "$TARBALL_NAME" "s3://$S3_BUCKET/$TARBALL_NAME"
    aws s3 cp "$TARBALL_NAME" "s3://$S3_BUCKET/$LATEST_TARBALL_NAME"
done

# Optional: Remove the tarball after upload
rm "$TARBALL_NAME"

echo "Backup completed and uploaded to all specified buckets."
