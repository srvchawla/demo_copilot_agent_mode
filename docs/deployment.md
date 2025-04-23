# Azure Container Apps Deployment Plan for OctoCAT Supply Chain Management

This document outlines the deployment plan for the OctoCAT Supply Chain Management application to Azure Container Apps, focusing on cost-effectiveness and maintainability.

## 1. Bicep Infrastructure Plan

### File Structure
```
infra/
├── main.bicep                 # Main orchestration file
├── modules/
│   ├── webapps.bicep          # Web Apps (Sites) connected to ACR for running containers
│   ├── logAnalytics.bicep     # Log Analytics workspace
├── parameters/
│   ├── staging.parameters.json # Staging environment parameters
│   └── production.parameters.json # Production environment parameters
```

#### Parameters must include:
- location
- environmentName
- appName
- acrName
- imageTag

The ACR resource ID must be correctly calculated in the `main.bicep` file and passed to the `webapps.bicep` file along with the `acrName`, `imageTag` and other necessary variables.

#### Managed Identity

Configure the Web Apps to use Managed Identity (SystemAssigned) to authenticate to the ACR.

### Key Resources to Include

1. **Logging**
   - Log Analytics integration for monitoring

2. **Container Registry**
   - Use AZCR.io for container registry (the configuration script will create one)
   - builds that push images must push to this Container Registry

3. **Two Azure Web Apps (Sites)**
   - both running on B1 SKU
   - API web app running API container
   - Frontend web app running Frontend container
   - Configured to point to ACR
     - use respective API or Frontend image and tag
     - ensure frontend URL is allowed in CORS for API
   - Use `uniqueString()` to add a unique post-fix to the web app names
   - ensure that API_HOST and API_PORT are correctly configured for the frontend deployment

## 2. Important Configuration Points & Gotchas

### CORS Configuration
- Configure CORS in the API container app to allow requests from the Frontend container app
- Use environment variables for dynamic CORS origins based on environment
```
API_CORS_ORIGINS=https://${frontendAppFqdn},https://${stagingFrontendAppFqdn}
```
- Ensure that the Web App for the frontend has these env vars:
```
API_HOST=<url_of_API_web_app>
API_PORT=80
```

## 3. GitHub Actions Workflow Plan

### Workflow Structure
```
.github/workflows/
├── build-test.yml   # CI workflow for PRs
├── deploy.yml       # CD workflow for deploying to staging on PR and approval for PROD
```

### CI Workflow (build-test.yml)
- Triggered on push to any branch
- Build both API and Frontend
- Run unit tests
- Lint code
- Build Docker images but don't push them

### Deployment (deploy.yml)
- Build
  - Triggered on PR
  - Build and run tests
  - 2 jobs that run in parallel: one for API and one for Frontend
     - Build and push Docker image to GHCR - use the short SHA of the commit to version the image
- Staging Job
  - requires both build jobs
  - Deploy Bicep templates with staging parameters to Staging environment
- Prod Job
  - requires Staging job
  - wait for approval (configured on Environment)
  - Deploy Bicep templates with staging parameters to Prod environment

## 4. Deployment Process

1. **Setup Prereqs**
   - `az cli` (use `brew install az`) and then run `az login` to log in to your Azure subscription
   - `gh cli` (use `brew install gh`) and then run `gh login` to log in to your GitHub account

2. **CI/CD Pipeline Configuration**
   - Use OIDC for authentication from workflows:
      - Run [this script](../infra/create-sp-oidc.sh) to create a service principal and configure OIDC for the repo.
      - The script sets up:
         - a Service Principal configured with OIDC
         - Resource Groups for staging and prod
         - An Azure Container Registry for hosting the images
         - Actions Variables needed for workflows
            - AZURE_CLIENT_ID: ID of the SP
            - AZURE_TENANT_ID: ID of the tenant
            - AZURE_SUBSCRIPTION_ID: ID of the subscription
            - AZURE_RESOURCE_GROUP: Stating Resource Group
            - AZURE_RESOURCE_GROUP_PROD: Prod Resource Group
            - AZURE_ACR_NAME: Name of the AZCR
         - 2 environments in the repo: Staging and Prod, with a manual approval on Prod
         - use the step output of the deply step to update the frontend URL as the URL of the enviroment

3. **Deployment Strategy**
   - for any push, execute the CI build
   - for PRs and pushes to `main`:
     - build and test the code
     - create the docker images using the short SHA for the version tag
     - use AZ login to get the credentials for the AZCR from the AZURE_ACR_NAME and AZURE_RESOURCE_GROUP_PROD vars
     - push the images to the AZCR
     - deploy to Staging first using the Staging environment
     - wait for approval for Prod (configured on Prod environment)
     - deploy to Prod using the Prod environment
   - ensure that you use the following format for the environments so that the URL is populated in the workflow view:
      ```yml
      environment:
        name: Staging|Production
        url: ${{ steps.deploy.outputs.frontendUrl }}
      ```

This plan provides a solid foundation for deploying the OctoCAT Supply Chain Management application to Azure Web Apps using infrastructure as code with Bicep and automated CI/CD with GitHub Actions.