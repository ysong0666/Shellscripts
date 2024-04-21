#!/bin/bash
# --------------------------------------------------------------------------------------
#          USASpendingAPI
#
#          Bash script to build the entire docker container for querying the API locally.
#          Source: https://github.com/fedspendingtransparency/usaspending-api
#
# --------------------------------------------------------------------------------------


# --------------------------------------------------------------------------------------
#                         Creating a Development Environment
# --------------------------------------------------------------------------------------

# Checking requirements for dependencies
# --------------------------------------------------------------------------------------
## Check for operating system and dependencies
## Install homebrew for MacOS/Linux
if [[ "$OSTYPE" == "cygwin" ]]; then
    echo "Please install Windows Subsystem for Linux and run this script there."
elif [[ "$OSTYPE" == "linux-gnu"* || "$OSTYPE" == "darwin"* ]]; then
    echo "You are on MacOS/Linux. Checking for Homebrew..."
    if [[ $(which brew) && $(command -v brew) ]]; then
        echo "Updating Brew..."
        brew update
    else
        echo "Installing Brew..."
        curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
    fi
else
    echo "You are on an incompatible OS: $OSTYPE."
fi  

## docker
if [[ $(which docker) && $(docker --version) ]]; then
    echo "Docker exists."

  else
    echo "Installing docker..."
    brew install docker 

fi

## docker-compose
if [[ $(which docker-compose) && $(docker-compose --version) ]]; then
    echo "Docker-compose exists."
else
    echo "Installing docker-compose..."
    brew install docker-compose
fi

## bash
if [[ $(which bash) && $(bash --version) ]]; then
	echo "Bash exists."
else
	echo "Intalling bash..."
	# ignore since we are assuming WSL
    
fi

## git
if [[ $(which git) && $(git --version) ]]; then
    echo "Git exists."
else
    echo "Installing git..."
    apt-get install git

fi

## make
if [[ $(which make) && $(make --version) ]]; then
    echo "Make exists."
else
    echo "Installing make..."
    brew install make
fi

## install DBBeaver
## https://dbeaver.io/download/
brew install --cask dbeaver-community


# Cloning the repo
# --------------------------------------------------------------------------------------
mkdir -p usaspending && cd usaspending
git clone https://github.com/fedspendingtransparency/usaspending-api.git
cd usaspending-api


# Environment variables
# --------------------------------------------------------------------------------------
## create your own .env file using the copied template here, change as needed
cp .env.template .env

## export environment variables
export DATABASE_URL=postgres://usaspending:usaspender@localhost:5432/data_store_api
export ES_HOSTNAME=http://localhost:9200
export DATA_BROKER_DATABASE_URL=postgres://admin:root@localhost:5435/data_broker

## optional: .envrc file
### 	Create a .envrc file in the repo root, which will be ignored by git. 
### 	Change credentials and ports as-needed for your local dev environment.


# Build docker image
# --------------------------------------------------------------------------------------
docker-compose --profile usaspending build
## Note: Re-run this command if any python package dependencies change (in requirements/
##       requirements-app.txt), since they are baked into the docker image at build-time.


# Database setup
# --------------------------------------------------------------------------------------
## method1: using docker to run PostgreSQL
docker-compose --profile usaspending up usaspending-db
## bring schema uptodate
docker-compose run --rm usaspending-manage python3 -u manage.py migrate
docker-compose run --rm usaspending-manage python3 -u manage.py matview_runner \
--dependencies

## method2: run PostgreSQL locally with DBBeaver
## https://files.usaspending.gov/database_download/usaspending-db-setup.pdf


# Elasticsearch Setup
# --------------------------------------------------------------------------------------
## Some of the API endpoints reach into Elasticsearch for data.
docker-compose --profile usaspending up usaspending-es
## The cluster should be reachable via at http://localhost:9200
## Optionally, to see log output, use docker-compose logs usaspending-es 
## (these logs are stored by docker even if you don't use this).

## generate elasticsearch indexes
docker-compose run --rm usaspending-manage python3 -u manage.py elasticsearch_indexer \
--create-new-index --index-name 01-26-2022-transactions --load-type transaction
docker-compose run --rm usaspending-manage python3 -u manage.py elasticsearch_indexer \
--create-new-index --index-name 01-26-2022-awards --load-type award


# --------------------------------------------------------------------------------------
#                                   Running the API
# --------------------------------------------------------------------------------------
docker-compose --profile usaspending up usaspending-api
## You can update environment variables in settings.py (buckets, elasticsearch, local 
## paths) and they will be mounted and used when you run this.
## The application will now be available at http://localhost:8000.
## In your local development environment, available API endpoints may be found at 
## http://localhost:8000/docs/endpoints.

