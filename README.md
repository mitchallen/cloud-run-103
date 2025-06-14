cloud-run-103
==
A Google Cloud Run starter project

[![Ko-fi](https://img.shields.io/badge/Ko--fi-F16061?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/mitchallen)
[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/mitchallen)
[![PayPal](https://img.shields.io/badge/PayPal-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/virtualmitch)

--

## Note about billing

Please note that this demo shows how to use services that Google will bill you for.  
New users are given a credit and some services are offered for free, below a minimal use.

Be sure to keep an eye on billing and delete test resources when no longer needed.

See: https://console.cloud.google.com/billing

### Container Registry Vulnerability Scanning Charges

Be sure to review this:

* https://cloud.google.com/artifact-analysis/docs/controlling-costs

While testing this repo I received a small bill for **Container Registry Vulnerability Scanning**.

It seems that every time I cleaned my artifacts and started over with a fresh container for demo purposes - I was getting charged **$0.26 USD**

* * *

This package was created as a gcloud run demo.

This is an update to my older, now outdated demos (cloud-run-101, cloud-run-102).

## Installation

    $ git clone https://github.com/mitchallen/cloud-run-103.git
  
* * *

## Create a Google Cloud Platform account

* https://cloud.google.com

* * *



## Create a GCP (Google Cloud Platform) project

* https://cloud.google.com

## Install the gcloud CLI (command line interface)

### Mac OS

```sh
brew install --cask google-cloud-sdk
```

* * *

## Initialize a project

```sh
gcloud init
```

* * *

## Initialize components

Run this command to update the components

```sh
gcloud components update
```

* * *

## Set the region

For example, I chose __us-central1__.

```sh
gcloud config set run/region us-central1
```

* * *

## Enable some services

```sh
gcloud services enable \
    artifactregistry.googleapis.com \
    cloudbuild.googleapis.com \
    run.googleapis.com
```

## Auth Docker

```sh
gcloud auth configure-docker YOUR_REGION-docker.pkg.dev
```

* * * 

## Using a Makefile

* If you are set up on Google Cloud Console you can use **make** to build, deploy and remove the demo project.
* If you want to walk through the steps, see the next section.

### Make help

To get help from **make** simply run:

```sh
make
```

### Build and Deploy

**NOTE**: This will deploy services that you may be billed for. Be sure to run **cleanup** step below when finished testing.

```sh
make up
```

* Browse and refresh the service and artifacts: 
    * https://console.cloud.google.com/run
    * https://console.cloud.google.com/artifacts/
* Make sure that the package is not showing any vulnerabilities (if it is, resolve them)

### Cleanup

```sh
make down
```

* Browse and refresh the service and artifacts: 
    * https://console.cloud.google.com/run
    * https://console.cloud.google.com/artifacts/
* Verify the package has been deleted (so you don't rack up any bills)


* * *

## Create a repo to hold Docker images

```sh
gcloud artifacts repositories create demo-repo \
    --repository-format=docker \
    --location=YOUR_REGION \
    --description="Docker repo"
```


* * *

## Create the Docker image in GCP

Substitute __PROJECT-ID__ with your current gcloud project id:

```sh
gcloud builds submit --tag YOUR_REGION-docker.pkg.dev/PROJECT-ID/demo-repo/hello
```

For the region of us-central1:

```sh
gcloud builds submit --tag us-central1-docker.pkg.dev/PROJECT-ID/demo-repo/hello
```

If you forgot your project ID:

```sh
gcloud projects list
```

You can also check the state of things with:

```sh
gcloud info
```

To see and manage the container image, browse to:

* https://console.cloud.google.com/artifacts

**If you have multiple project ids, switch to the one associated with this project.**

* * *

## Deploy to Cloud Run

Substitute __PROJECT-ID__ with your current gcloud project id:

```
gcloud run deploy hello-web --image REGION-docker.pkg.dev/PROJECT-ID/demo-repo/hello
```

Assuming you don't care if anyone runs your app (as in making it public):

```
Allow unauthenticated invocations to [hello-web] (y/N)?
```

If you are concerned about billing, no one will know the URL address if you don't publicly post it anywhere.  And you can immediately kill the service when done testing to avoid any unauthorized access or billing.

The command line will then give you the URL of your app, with a message like this (with your own unique URL):

```
Service [hello-web] revision [hello-web-abcd] has been deployed and is serving 100 percent of traffic at https://hello-web-SOME-RANDOM-ID.a.run.app
```

Copy the URL and paste the address into a browser or use `curl`.

## See the service in the console

To see and manage the service in the Google Cloud Platform console, browse to:

* https://console.cloud.google.com/run

* * *

## Cleanup

To save money you should consider taking down private and test resources when not in use.  To use them again, be sure to document how to recreate them.

Visit the following console pages to delete test resources:

* https://console.cloud.google.com/run
* https://console.cloud.google.com/artifacts

To delete the service using the command line, run this command:

```sh
gcloud run services delete hello-web
```

To delete the image using the command line (substitute PROJECT-ID with your Google cloud Project ID):

```sh
gcloud artifacts docker images delete REGION-docker.pkg.dev/PROJECT-ID/demo-repo/hello
```

To delete the repo:

```sh
gcloud artifacts repositories delete demo-repo
```

To monitor billing:

* https://console.cloud.google.com/billing

* * * 

## References

* https://console.cloud.google.com
* https://cloud.google.com/run/docs/tutorials/system-packages#follow-cloud-run
* https://github.com/GoogleCloudPlatform/nodejs-docs-samples/tree/master/run/system-package
* https://tapendradev.medium.com/how-to-install-gcloud-sdk-on-the-macos-and-start-managing-gcp-through-cli-d14d2c3a8869


