#!/bin/bash

# Parameters: {user} {project_name} {path_from_~} {path_to_venv_from_~} {do_ip}

if [ "$#" -ne 5 ]; then
    echo "Arguments must be: user project_name path_to_wsgi_from_root path_to_venv_from_root box_ip"
    exit 1
fi


sudo touch /etc/systemd/system/$2.service

echo -n "[Unit]
Description=Gunicorn instance to serve $2
After=network.target

[Service]
User=$1
Group=www-data
WorkingDirectory=/home/$1/$3
Environment=\"PATH=/home/$1/$4/bin\"
ExecStart=/home/$1/$4/bin/gunicorn --workers 3 --bind unix:$2.sock -m 007 wsgi:app

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/$2.service

sudo systemctl start $2
sudo systemctl enable $2

sudo touch /etc/nginx/sites-available/$2

echo -n "server {
    listen 80;
    server_name $5;

    location / {
        include proxy_params;
        proxy_pass http://unix:/home/$1/$3/$2.sock;
    }
}
" > /etc/nginx/sites-available/$2

sudo ln -s /etc/nginx/sites-available/$2 /etc/nginx/sites-enabled

sudo nginx -t

sudo systemctl restart $2
sudo systemctl restart nginx
sudo service nginx reload