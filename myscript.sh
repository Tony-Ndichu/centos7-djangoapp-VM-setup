#!/usr/bin/env bash
# Sample bash script to deploy django app

function install_dependencies(){
# enable EPEL repository since some of the software is in it
echo  installing EPEL...
sudo yum install epel-release -y

# install necessary components e.g pip, python and postgresql
echo installing pip, python and postgresql...
sudo yum install python-pip python-devel gcc postgresql-server postgresql-devel postgresql-contrib -y
}

function setup_postgres(){
# initialize postgreSQL database
echo initializing postgresql...
sudo postgresql-setup initdb

# start postresql
echo starting postgresql...
sudo systemctl start postgresql

# replace user permissions
sudo sed -i 's/peer/trust/g' /var/lib/pgsql/data/pg_hba.conf
sudo sed -i 's/ident/trust/g' /var/lib/pgsql/data/pg_hba.conf

# restart postgresql
sudo systemctl restart postgresql

# enable postgresql to start automatically on boot
echo enabling postgresql to start on boot...
sudo systemctl enable postgresql

# createdb -U postgres firstdb if it doesnt exist
echo  creating database firstdb if doesnt exist
psql -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = 'djangodb'" | grep -q 1 || psql -U postgres -c "CREATE DATABASE djangodb"

# create user tony  
echo creating user tony if doesnt exist
psql -h localhost -U postgres -tc "SELECT 1 FROM pg_roles WHERE rolname = 'tony'" | grep -q 1 || psql -h localhost -U postgres -c "CREATE USER tony WITH PASSWORD 'jw8s0F4';"

# alter some roles
psql -U postgres -c "ALTER ROLE tony SET client_encoding TO 'utf8';"
psql -U postgres -c "ALTER ROLE tony SET default_transaction_isolation TO 'read committed';"
psql -U postgres -c "ALTER ROLE tony SET timezone TO 'UTC';"
psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE djangodb TO tony;"
psql -U postgres firstdb -c "GRANT ALL ON ALL TABLES IN SCHEMA public to tony;"
psql -U postgres firstdb -c "GRANT ALL ON ALL SEQUENCES IN SCHEMA public to tony;"
psql -U postgres firstdb -c "GRANT ALL ON ALL FUNCTIONS IN SCHEMA public to tony;"
}

function setup_app(){
# install virtualenv
sudo pip install virtualenv

# remove folder if it exists otherwise create folder for project to be cloned
rm -rf ~/projectfolder
mkdir ~/projectfolder

# cd into the folder
cd ~/projectfolder

# install git to clone repo
sudo yum install git -y

if [[ -d djangoapp ]]; then
	cd djangoapp;
	git pull;
else
	
	# clone the repo
	git clone https://github.com/Tony-Ndichu/djangoapp.git

	# cd into the django app
	cd djangoapp
fi

# create virtualenv for project to be cloned
virtualenv myvenv

# activate the virtual environment
source myvenv/bin/activate

# install django and psycopg2
pip install django psycopg2
}

function run_app(){
# export environment variables
export DB_NAME="firstdb"
export DB_USER="tony"
export HOST="localhost"
export DB_PASSWORD="jw8s0F4"

# make migrations
python manage.py makemigrations

# run migrations
python manage.py migrate

# create superuser antony
cat <<EOF | python manage.py shell
from django.contrib.auth import get_user_model

User = get_user_model()  # get the currently active user model,

User.objects.filter(username='antony').exists() or \
    User.objects.create_superuser('antony', 'antony@example.com', 'password')
EOF

# install lsof kill any processes running on port 8000
sudo yum install lsof
sudo kill -9 $(sudo lsof -t -i:8000)

# edit allowed hosts to include the vm private network
sed -i '28s/.*/ALLOWED_HOSTS = ["192.168.33.10", "localhost", "127.0.0.1"]/' ~/projectfolder/djangoapp/myproject/settings.py

# run server
python manage.py runserver 0.0.0.0:8000
}

function main(){
install_dependencies
setup_postgres
setup_app
run_app
}

main





















 




















