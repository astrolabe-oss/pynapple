#!/bin/bash

# install rpms
sudo yum -y install nginx
sudo yum -y install python-pip

# install python packages
sudo pip install -r requirements.txt  # install binaries globally

# install and start pynapple gunicorn/flask
sudo cp files/pynapple.service /etc/systemd/system/pynapple.service
sudo systemctl start pynapple

# install and start pynapple nginx site
sudo cp files/pynapple.conf /etc/nginx/conf.d
sudo systemctl reload nginx || sudo systemctl start nginx

