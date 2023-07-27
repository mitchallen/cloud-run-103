#!/usr/bin/env bash

# Reference: https://gist.github.com/mitchallen/9fa95aa7f08614be40c3f850382b5a0e

export PROJECT_ID=$(gcloud config get-value project)
echo "Project ID: $PROJECT_ID"

export PROJECT_USER=$(gcloud config get-value core/account) # set current user
echo "Project User: $PROJECT_USER"

export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
echo "Project Number: $PROJECT_NUMBER"

export IDNS=${PROJECT_ID}.svc.id.goog # workflow identity domain

export GCP_REGION="us-central1" # CHANGEME (OPT)
export GCP_ZONE="us-central1-a" # CHANGEME (OPT)
export NETWORK_NAME="default"

export REPO_NAME="demo-repo"
export IMAGE_NAME="hello"
export SERVICE_NAME="hello-web"
export DOCKER_URI="$GCP_REGION-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/$IMAGE_NAME"

init() {
    echo "initializing ..."
    # enable some services
    gcloud services enable \
        artifactregistry.googleapis.com \
        cloudbuild.googleapis.com \
        run.googleapis.com

    # set region / location
    gcloud config set run/region $GCP_REGION
    gcloud config set artifacts/location $GCP_REGION
}


build() {

    init

    # create a Docker repo
    gcloud artifacts repositories create $REPO_NAME \
        --repository-format=docker \
        --description="Docker repo"

    # list the repo
    gcloud artifacts repositories list

    # authorize docker
    gcloud auth configure-docker $GCP_REGION-docker.pkg.dev

    # build the docker image
    gcloud builds submit --tag $DOCKER_URI

    # deploy the service
    gcloud run deploy $SERVICE_NAME --image $DOCKER_URI

    # confirm service is running
    gcloud run services list \
        --platform managed \
        --region $GCP_REGION

    # test URL
    export SVC_URL=$(gcloud run services describe $SERVICE_NAME --platform managed --region $GCP_REGION --format="value(status.url)")

    curl -X GET $SVC_URL
}

destroy() {

    init

    # delete service
    gcloud run services delete $SERVICE_NAME

    # delete image
    gcloud artifacts docker images delete $DOCKER_URI

    # delete repo
    gcloud artifacts repositories delete $REPO_NAME
}

main() {

    echo "---------------------------------------------------------"
    echo " REGION: $GCP_REGION, SERVICE: $SERVICE_NAME "
    echo "---------------------------------------------------------"

    # Start Menu
    PS3='Please enter your choice: '
    options=("Build" "Destroy" "Quit")
    select opt in "${options[@]}"

     do 
        case $opt in
            "Build")
                echo "Build!"
                build
                break;
                ;;
            "Destroy")
                echo "Destroy!"
                destroy
                break;
                ;;
            "Quit")
                # End script but don't kill terminal window
                return
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done
}

# run main
main



