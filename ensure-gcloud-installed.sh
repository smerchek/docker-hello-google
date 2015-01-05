#! /bin/bash

pip install pyopenssl
if [ ! -d ~/google-cloud-sdk ]; then
    curl https://sdk.cloud.google.com | bash;
    ~/google-cloud-sdk/bin/gcloud components update preview
fi

