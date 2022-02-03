#!/bin/bash

/usr/bin/curl -O https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh

sudo apt-get update

sudo apt install default-jre -y

sudo bash InstallHalyard.sh --user $USER

. /home/$USER/.bashrc

BUCKET_NAME=spin-hal-bucket-demo

#export $BUCKET_NAME

gsutil ls | grep $BUCKET_NAME

result=$?
if [ $result -eq 0 ]
then
    echo "exists"
    /usr/local/bin/hal config storage gcs edit --bucket $BUCKET_NAME --project cybage-devops
    /usr/local/bin/hal config storage edit --type gcs
else
    echo "not exists"
    /snap/bin/gsutil mb -l us-central1 -p cybage-devops gs://$BUCKET_NAME/
    /usr/local/bin/hal config storage gcs edit --bucket $BUCKET_NAME --project cybage-devops
    /usr/local/bin/hal config storage edit --type gcs
fi


SPINNAKER_VERSION=1.26.6

set -e

if [ -z "${SPINNAKER_VERSION}" ] ; then

  echo "SPINNAKER_VERSION not set"
  exit
fi

hal config version edit --version $SPINNAKER_VERSION

hal deploy apply