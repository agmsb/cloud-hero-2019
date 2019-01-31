
# Copyright 2018, Google, Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#!/bin/bash

source ./options.sh

printf "\n Welcome to the best way to score on Cloud Hero!"

sleep 2

printf "\n Task 1: Creating GCS Bucket  \n"

gsutil mb gs://cloud-hero-$PROJECT_ID
sleep 15
gsutil acl ch -u AllUsers:R gs://$PROJECT_ID
touch test.txt
sleep 10
gsutil cp test.txt gs://cloud-hero-$PROJECT_ID

sleep 3

printf "\n Task 2: Creating GKE Cluster  \n"

gcloud container clusters create cloudhero-web --zone us-central1-a --scopes=https://www.googleapis.com/auth/cloud-platform

printf "\n Task 3: Fetching GKE Credentials  \n"

gcloud container clusters get-credentials cloudhero-web --zone us-central1-a --project $PROJECT_ID

sleep 3

printf "\n Task 3: Deploying hello-hero deployment"

kubectl run hello-hero --image=nginx --replicas=3 

sleep 3

printf "\n Task 3: Exposing hello-hero deployment"

kubectl expose deploy hello-hero --type=LoadBalancer --port=80

sleep 2

printf "\n Task 4: Creating Cloud PubSub topic"

gcloud pubsub topics create cloud-hero-topic

printf "\n Task 5: Downloading GCF files from GCS"

mkdir gcf
cd gcf
wget https://storage.googleapis.com/cloudhero-content/pubSubListener/index.js
wget https://storage.googleapis.com/cloudhero-content/pubSubListener/package.json

sleep 2

printf "\n Task 5: Edit index.js"

sed -i 's,www.example.com,us-central1-cloudhero-test.cloudfunctions.net/cloudFunctionChallenge_verifyCallback,g' index.js

sleep 2

printf "\n Task 5: Deploy Cloud Function"

gcloud functions deploy pubSubListener --runtime nodejs6 --trigger-topic cloud-hero-topic --region  us-central1

sleep 2 

printf "\n Task 6: Create CSR"

gcloud source repos create cloudhero-challenge
git clone https://github.com/GoogleCloudPlatform/getting-started-python.git
cd getting-started-python
git config --global user.email $USER_ID@qwiklabs.net
git config --global user.name $USER_ID

printf "\n Task 6: Add CSR as remote"

git remote add google \
https://source.developers.google.com/p/$PROJECT_ID/r/cloudhero-challenge
git push --all google

printf "\n Task 7: Creating automated build in GCR"

cd optional-kubernetes-engine
sed -i s,CLOUD_STORAGE_BUCKET\s=\s'your-project-id',CLOUD_STORAGE_BUCKET\s=\sgs://cloud-hero-$PROJECT_ID,g config.py
sed -i s,PROJECT_ID\s=\s'your-project-id',PROJECT_ID\s=\s$PROJECT_ID,g config.py

# TODO
# Task 7: Build Trigger
# Task 8: Deploy Multi-Container Application
# Task 9: Configure CI/CD Application
