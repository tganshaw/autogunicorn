#!/bin/bash

# Parameters: {user} {project_name} {path_from_~} {path_to_venv_from_~} {do_ip}

# Checks to make sure there are exactly 5 parameters passed in
if [ "$#" -ne 5 ]; then 
    echo "Arguments must be: user project_name path_to_wsgi_from_root path_to_venv_from_root box_ip"
    exit 1
fi

# Creates the .service file with name of {project_name}
sudo touch /etc/systemd/system/$2.service

# Puts the text into the .service file after filling in based on parameters
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


# Starts the app and opens it. Daemon-reload is there because sometimes it says to run. Not 100% sure if it's only required when starting an app that already exists.
sudo systemctl start $2
sudo systemctl daemon-reload
sudo systemctl enable $2

# Makes the config file in sites-available with name of {project_name}
sudo touch /etc/nginx/sites-available/$2

# Puts the text into the config file after filling in based on parameters
echo -n "server {
    listen 80;
    server_name $5;

    location / {
        include proxy_params;
        proxy_pass http://unix:/home/$1/$3/$2.sock;
    }
}
" > /etc/nginx/sites-available/$2

# Creates a link to the config file in sites-enabled so nginx can run it
sudo ln -s /etc/nginx/sites-available/$2 /etc/nginx/sites-enabled

# Checks to confirm syntax
sudo nginx -t

# Restarts the app, restarts nginx, and reloads nginx. Not 100% if all of these are needed; reload & app restart might not be necessary but restart nginx is
sudo systemctl restart $2
sudo systemctl restart nginx
sudo service nginx reload