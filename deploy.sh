#!/bin/bash
source .env
./bin/hugo.exe
swa deploy ./public --deployment-token $AZURE_DEPLOYMENT_TOKEN --env production
