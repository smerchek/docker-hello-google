#! /bin/bash

echo $GCLOUD_KEY | base64 --decode > gcloud.p12
gcloud auth activate-service-account 484500905059-bb55pm9ophqkbhkd1vrront20ati766f@developer.gserviceaccount.com --key-file gcloud.p12
ssh-keygen -f ~/.ssh/google_compute_engine -N ""
