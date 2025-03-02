[Unit]
Description=Gunicorn instance to serve myapp
After=network.target

[Service]
User=ec2-user
Group=nginx
WorkingDirectory=/home/ec2-user/{{APP_NAME}}/pynapple
Environment=PYTHONPATH=/home/ec2-user/{{APP_NAME}}
EnvironmentFile=/home/ec2-user/sandbox_app.env
ExecStart=/home/ec2-user/{{APP_NAME}}/venv/bin/gunicorn --workers 2 --bind 0.0.0.0:8000 run:app

[Install]
WantedBy=multi-user.target