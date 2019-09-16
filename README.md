# Create a Server
 
##  Creating a centos server to run my django app using postgresql database

To achieve this, I followed the following steps:

Setting up vagrant which I did by installing vagrant on my local machine and running `vagrant init` in a folder to generate a Vagrant file


Editing vagrant file `config.vm.box` and adding  `CENTOS 7`


Editing my private network in `config.vm.network` to add the address `192.168.33.10`


Adding a script called `myscript.sh` which I shall add the bash commands to run the software in my VM. The line edited here was `config.vm.provision "shell", path: "myscript.sh"`
I then edited my script.sh in the following steps:


Enabling EPEL repository since some of the software is in it with the command `sudo yum install epel-release -y`
Installing necessary components e.g pip, python and postgresql using the command `sudo yum install python-pip python-devel gcc postgresql-server postgresql-devel postgresql-contrib -y`


Initializing postgreSQL database using the  command `sudo postgresql-setup initdb`
Starting postresql using the command `sudo systemctl start postgresql`
Editing the user’s permissions in `pg_hba.conf` file to disable peer authentication using the commands


 ```sudo sed -i 's/peer/trust/g' /var/lib/pgsql/data/pg_hba.conf 
sudo sed -i 's/ident/trust/g' /var/lib/pgsql/data/pg_hba.conf```


Restoring postgresql using the command ` sudo systemctl restart postgresql `


Enabling postgresql to start automatically on boot using the command `sudo systemctl enable postgresql`
creating database `djangodb` if doesn’t exist using the command `psql -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = 'djangodb'" | grep -q 1 || psql -U postgres -c "CREATE DATABASE djangodb"`


Creating a user(Tony) if he doesn’t exist using the command `psql -h localhost -U postgres -tc "SELECT 1 FROM pg_roles WHERE rolname = 'tony'" | grep -q 1 || psql -h localhost -U postgres -c "CREATE USER tony WITH PASSWORD 'jw8s0F4';"`


Altering some of the user roles to give them full permissions to the database `djangoapp` just created using the following commands:


```psql -U postgres -c "ALTER ROLE tony SET client_encoding TO 'utf8';"
 psql -U postgres -c "ALTER ROLE tony SET default_transaction_isolation TO 'read committed';"
 psql -U postgres -c "ALTER ROLE tony SET timezone TO 'UTC';"
 psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE djangodb TO tony;"
 psql -U postgres firstdb -c "GRANT ALL ON ALL TABLES IN SCHEMA public to tony;"
 psql -U postgres firstdb -c "GRANT ALL ON ALL SEQUENCES IN SCHEMA public to tony;"
 psql -U postgres firstdb -c "GRANT ALL ON ALL FUNCTIONS IN SCHEMA public to tony;"```
Install virtualenv using the command `sudo pip install virtualenv`


Remove folder called `projectfolder` if it exists then creating and one to clone the app into using the commands:


```rm -rf ~/projectfolder
mkdir ~/projectfolder```


Cd into the folder to run commands using: `cd ~/projectfolder`


installing git to clone repo using the command `sudo yum install git -y`


Checking if the project Djangoapp exists and pulling it if it exists while cloning it if it doesn’t exist using the if statement:


```if [[ -d djangoapp ]]; then
          cd djangoapp;
          git pull;
  else
 
          # clone the repo
          git clone https://github.com/Tony-Ndichu/djangoapp.git
 
          # cd into the django app
          cd djangoapp
  fi```
 

Creating virtualenv for project to be cloned using the command `virtualenv myvenv`
Activating the virtual environment using `source myvenv/bin/activate`
Installing django and psycopg2 using `pip install django psycopg2`
Exporting the environment variables that the app needs using the following commands
```export DB_NAME="djangob"
export DB_USER="tony"
export HOST="localhost"
export DB_PASSWORD="jw8s0F4"```
Making migrations using the command: `python manage.py makemigrations`
Running migrations using: `python manage.py migrate`
Creating a superuser to test that the app will actually run and have a superuser with the credentials I’ll specify: 
```cat <<EOF | python manage.py shell
 from django.contrib.auth import get_user_model

 User = get_user_model()  # get the currently active user model,
  User.objects.filter(username='antony').exists() or \
     User.objects.create_superuser('antony', 'antony@example.com', 'password')
EOF```
kill any processes running on port 8000 which is the port our app will use.To do this, I had to install lsof…..the commands for this step are therefore:
```sudo yum install lsof
sudo kill -9 $(sudo lsof -t -i:8000)```
edit allowed hosts to include the vm private network in the django app by editing settings.py by line number(28): 
```sed -i '28s/.*/ALLOWED_HOSTS = ["192.168.33.10", "localhost", "127.0.0.1"]/' ~/projectfolder/djangoapp/myproject/settings.py```
Then finally I ran the server using the command:
```python manage.py runserver 0.0.0.0:8000```





