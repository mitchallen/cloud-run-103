#!/usr/bin/env bash

# Reference: https://gist.github.com/mitchallen/9fa95aa7f08614be40c3f850382b5a0e

export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_USER=$(gcloud config get-value core/account) # set current user
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
export IDNS=${PROJECT_ID}.svc.id.goog # workflow identity domain

export GCP_REGION="us-central1" # CHANGEME (OPT)
export GCP_ZONE="us-central1-a" # CHANGEME (OPT)
export NETWORK_NAME="default"

export REPO_NAME="demo-repo"
export DOCKER_IMAGE_NAME="hello"

# set region / location
gcloud config set run/region $GCP_REGION
gcloud config set artifacts/location $GCP_ZONE

# create a Docker repo
gcloud artifacts repositories create $REPO_NAME \
    --repository-format=docker \
    --description="Docker repo"

# list the repo
gcloud artifacts repositories list

# authorize docker
gcloud auth configure-docker $GCP_REGION-docker.pkg.dev

# build the docker image
gcloud builds submit --tag $GCP_REGION-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/$DOCKER_IMAGE_NAME

# deploy the service
gcloud run deploy hello-web --image $GCP_REGION-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/$DOCKER_IMAGE_NAME




