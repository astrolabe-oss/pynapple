#!/bin/bash -x

# install rpms
sudo yum -y install nginx
sudo yum -y install python-pip

# install python packages
sudo pip install -r pynapple/requirements.txt  # install binaries globally

# install and start pynapple gunicorn/flask
sudo sed "s/{{APP_NAME}}/$SANDBOX_APP_NAME/g" deploy/pynapple.service.tpl | sudo tee /etc/systemd/system/pynapple.service > /dev/null
sudo systemctl start pynapple

# install and start pynapple nginx site
sudo cp deploy/pynapple.conf /etc/nginx/conf.d
sudo systemctl reload nginx || sudo systemctl start nginx

