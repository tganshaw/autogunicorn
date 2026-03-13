# autogunicorn

Automatically makes .service and nginx config files for a given app.

## Parameters:

``` sudo ./autogunicorn.sh {user} {project_name} {path_to_wsgi_from_root} {path_to_venv_from_root} {box_ip} ```

Because the script needs sudo permissions to make the files and do things like start the app or reload nginx, it must be ran as sudo.

## Explanations:

{user} - User where the paths exist and that you want the new config files to exist on.

{project_name} - The name you want for your project. Does NOT have to be the same as your Python file name. Cannot include periods.

{path_to_wsgi_from_root} - Path to the folder containing your wsgi.py file from root. Do NOT include a slash at the start or the end. Do NOT include wsgi.py at the end.

{path_to_venv_from_root} - Path to your virtual environment folder. Do NOT include a slash at the start or the end.

{box_ip} - The ip of the Digital Ocean module that the server will run on.

## How To Use:

### PREREQUISITES:

Before you run the script, you must first set up your wsgi.py file. Below will be a brief description on how to do that. For more in depth details, find somewhere else.

- First, activate the virtual environment that you'll use for your project.
- Cd into the directory containing your main Python file.
- In said directory, make a file called wsgi.py.
- Open wsgi.py with the text editor of your choice.
- Enter the following in wsgi.py, making sure to replace the values in {} with your specific names.

```

from {main_python_file_name_without_extension} import {app_name}

if __name__ == "__main__":
    app.run()

```

- Note: {app_name} means the variable you set to equal Flask(__name__) in your main Python file.
- Once you've entered this into your wsgi.py, save and close.
- In the same directory, enter the following command:

```

gunicorn --bind 0.0.0.0:5000 wsgi:{app_name}

```

- After you've pasted this, it should open a console for your app. If you wish, you can go to http://{droplet_ip}:5000 to check if it's working properly. This might not be possible if you don't have port 5000 allowed via your firewall.
- To exit the console, press ctrl + c.
- After you've set up wsgi.py, you must remove all other config files from nginx's sites-enabled folder.
- To access the folder and see its contents, execute the following:

```

cd ~
cd /etc/nginx/sites-enabled
ls

```

- This will show you a list of files that are in the folder. You must then use sudo rm to use every file that ISN'T default. Keep the default file (I'm unsure if it breaks anything if you remove it, try at your own risk).
- Do NOT do this in the sites-available folder. The sites-enabled folder only contains links to config files, so you can still renable them later. If you delete them from the sites-available folder, it will not only delete that config file permanently but it will also likely cause nginx to throw an error unless you remove the correspond file from the sites-enabled folder.
- You're now ready to run the script.

### How to Run the Script:

- Cd into the directory containing the script.
- The first time you clone the script onto your machine, you have to use chmod to give it the proper permissions to run.
- Execute the following command:

```

chmod 0744 autogunicorn.sh

```
- This command will give the user running it the permission to read, write, and execute autogunicorn.sh, and allows other users on the system to read the file.
- After this, execute the script, filling in the proper arguments. It is below again for your convenience.

```

sudo ./autogunicorn.sh {user} {project_name} {path_to_wsgi_from_root} {path_to_venv_from_root} {box_ip}

```

- This should have now set up your nginx to show your Flask app. If the script shows text saying to run "systemctl daemon-reload", you can ignore that, as it's already taken care of within the script.
- If any red text appears in the script, it's an error and you likely either filled out the parameters wrong or made an error in your wsgi.py, binding, or Python app. The same applies for if you get a 502 error on nginx after running the script.

For any other questions, there will probably be a QAF post about this, so reply there.
