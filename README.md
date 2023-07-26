cloud-run-102
==
A Google Cloud Run starter project
--

This package was created as a gloud run demo.

This is an update to my older, now outdated demo (cloud-run-101).

## Installation

    $ git clone https://github.com/mitchallen/cloud-run-102.git
  
* * *

## Create a Google Cloud Platform account

* https://cloud.google.com

* * *

## Note about billing

Please note that this demo shows how to use services that Google will bill you for.  New users are given a credit and some services are offered for free, below a minimal use.

Be sure to keep an eye on billing and delete test resources when no longer needed.

See: https://console.cloud.google.com/billing

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

```
gcloud config set run/region us-central1
```

* * *

## Create the Docker image in GCP

Substitute __PROJECT-ID__ with your current gcloud project id:

```
gcloud builds submit --tag gcr.io/PROJECT-ID/hello
```

Select Y, if you get a warning like this:

```
API [cloudbuild.googleapis.com] not enabled on project [############].
 Would you like to enable and retry (this will take a few minutes)? 
(y/N)?
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

* https://console.cloud.google.com/gcr

* * *

## Deploy to Cloud Run

Substitute __PROJECT-ID__ with your current gcloud project id:

```
gcloud run deploy hello-web --image gcr.io/PROJECT-ID/hello
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
* https://console.cloud.google.com/gcr

To delete the service using the command line, run this command:

```sh
gcloud run services delete hello-web
```

To delete the image using the command line (substitute PROJECT-ID with your Google cloud Project ID):

```sh
gcloud container images delete gcr.io/PROJECT-ID/hello
```

To monitor billing:

* https://console.cloud.google.com/billing

* * * 

## References

* https://console.cloud.google.com
* https://cloud.google.com/run/docs/tutorials/system-packages#follow-cloud-run
* https://github.com/GoogleCloudPlatform/nodejs-docs-samples/tree/master/run/system-package
* https://tapendradev.medium.com/how-to-install-gcloud-sdk-on-the-macos-and-start-managing-gcp-through-cli-d14d2c3a8869


