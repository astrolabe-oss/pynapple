#!/bin/bash -x

# Set variables
INCLUDED_FILES="pynapple/app.py pynapple/requirements.txt pynapple/files pynapple/scripts"
TARBALL_NAME="backup_$(date +%Y%m%d_%H%M%S).tar.gz"
S3_BUCKET="s3://guruai-pynapple-deploy"

# Create a tarball with only the specified files and directories
tar --exclude '._*' -czvf "$TARBALL_NAME" $(echo $INCLUDED_FILES | sed 's/ / /g')

# Upload the tarball to S3
aws s3 cp "$TARBALL_NAME" "$S3_BUCKET/$TARBALL_NAME"
aws s3 cp "$TARBALL_NAME" "$S3_BUCKET/pynapple_latest.tar.gz"

# Optional: Remove the tarball after upload
rm "$TARBALL_NAME"

echo "Backup completed and uploaded to $S3_BUCKET"
