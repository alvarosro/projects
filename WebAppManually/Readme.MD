# Title

## Overview

This project contains a bootstrap web template downloaded from the internet, specifically structured to demonstrate deployment to Azure App Service. It provides a practical example of how a typical web application can be deployed and hosted on Azure.

## Project Structure

project-root/
│
├── css/            # CSS stylesheets
├── font/           # Font files
├── images/         # Image assets
├── js/             # JavaScript files
├── index.html      # Main HTML file
├── LICENSE.txt     # License information
└── README.md       # This file

## Deploying to Azure App Service with Az CLI

### Prerequisites

- An Azure account with an active subscription
- Azure CLI installed on your local machine
- Git (optional, for deployment via Git)

### Deployment Steps

1. Create an App Service Plan

az appservice plan create --name myAppServicePlan --resource-group myResourceGroup --sku F1
2. Create an App Service Plan

az webapp create --name myWebApp --resource-group myResourceGroup --plan myAppServicePlan
3. Deploy Web App

az webapp deployment source config --name myWebApp --resource-group myResourceGroup --repo-url <repository-url> --branch main --manual-integration

az webapp deployment source config-zip --resource-group myResourceGroup --name myWebApp --src myWebApp.zip
4. Configure for static HTML

az webapp config set --resource-group myResourceGroup --name myWebApp --web-sockets-enabled false
5. Access Your Web App Your web app will be available at https://myWebApp.azurewebsites.net