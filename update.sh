#!/bin/bash
MESSAGE="$@"

# Build the Docker image
docker build -t ricoharsono/huatah-data:latest . || { echo "Docker build failed"; exit 1; }

# Push the Docker image to Docker Hub
docker push ricoharsono/huatah-data:latest || { echo "Docker push failed"; exit 1; }

# Restart Kubernetes deployment
CHECKCONTEXT=$(kubectl config current-context | grep do-sgp1-k8s)

if [ -z "$CHECKCONTEXT" ]; then
    echo "Current context is not correct. Exiting."
    exit 1
else
    kubectl rollout restart deployment huatah-data-deployment || { echo "Kubernetes rollout restart failed"; exit 1; }
fi

#push to github
git add .
git commit -m "edit"
git push

#Send text message
if [ -n "$MESSAGE" ]; then
    curl -s -X POST https://api.telegram.org/bot902467435:AAGGJ695Sy_EWiFyJszxTkwTJqbxPwiNsG4/sendMessage -d chat_id=795308339 -d text="$MESSAGE"
    curl -s -X POST https://api.telegram.org/bot902467435:AAGGJ695Sy_EWiFyJszxTkwTJqbxPwiNsG4/sendMessage -d chat_id=362851348 -d text="$MESSAGE"
fi