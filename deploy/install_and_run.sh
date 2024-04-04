#!/bin/bash -x

# install rpms
sudo yum -y install nginx
sudo yum -y install python-pip

# install python packages
python3 -m venv venv
source venv/bin/activate
pip install -r pynapple/requirements.txt  # install binaries globally
sudo chown ec2-user:ec2-user venv

# install and start pynapple gunicorn/flask
sudo sed "s/{{APP_NAME}}/$SANDBOX_APP_NAME/g" deploy/pynapple.service.tpl | sudo tee /etc/systemd/system/pynapple.service > /dev/null
sudo systemctl start pynapple

# install and start pynapple nginx site
sudo cp deploy/pynapple.conf /etc/nginx/conf.d
sudo systemctl reload nginx || sudo systemctl start nginx

