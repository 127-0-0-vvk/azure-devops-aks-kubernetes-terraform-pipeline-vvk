# azure-devops-aks-kubernetes-terraform-pipeline-vvk
Provision AKS Cluster using Azure DevOps Pipeline &amp; Terraform

## Architecture Flow

<img width="8032" alt="Project Flow Diagram" src="https://github.com/127-0-0-vvk/azure-devops-aks-kubernetes-terraform-pipeline-vvk/assets/41470324/75be1790-caa6-4782-a7aa-114ae9848002">

## Website Preiview


<img width="1800" alt="Website-home" src="https://github.com/127-0-0-vvk/azure-devops-aks-kubernetes-terraform-pipeline-vvk/assets/41470324/de215a40-bf48-4e12-980d-8ee3c46cbf4e">


## Step-01: Introduction
- Create Azure DevOps Pipeline to create AKS cluster using Terraform
- We are going to create two environments Dev and QA using single pipeline. 
- Terraform Manifests Validate
- Provision Dev AKS Cluster
- Provision QA AKS Cluster
- Provision Prod AKS Cluster

<img width="1800" alt="AKS-workloads" src="https://github.com/127-0-0-vvk/azure-devops-aks-kubernetes-terraform-pipeline-vvk/assets/41470324/7dd4a438-2bec-40c2-be61-c91b3bb162e9">

## Step-02: Review Terraform Manifests
### 01-main.tf
- Comment Terraform Backend, because we are going to configure that in Azure DevOps

### 02-variables.tf
- Two variables we will define in Azure DevOps and use it
  - Environment 
  - SSH Public Key
- Just comment the default values here (ideally not needed but we will do that)  

### 03-resource-group.tf
- We are going to create resource groups for each environment with **terraform-aks-envname**

### 04-aks-versions-datasource.tf
- We will get the latest version of AKS using this datasource. 
- `include_preview = false` will ensure that preview versions are not listed

### 05-aks-administrators-azure-ad.tf
- We are going to create Azure AD Group per environment for AKS Admins
- To create this group we need to ensure Azure AD Directory Write permission is there for our Service Principal (Service Connection) created in Azure DevOps
- We will see that in detail in upcoming steps. 
- VERY VERY IMPORTANT FIX TO MAKE THIS WORK

### 06-aks-cluster.tf
- Name of the AKS Cluster going to be **ResourceGroupName-Cluster**
-  Node Lables and Tags will have a environment with respective environment name  

### 07-outputs.tf  
- We will put out output values very simple
- Resource Group 
  - Location
  - Name
  - ID
- AKS Cluster 
  - AKS Versions
  - AKS Latest Version
  - AKS Cluster ID
  - AKS Cluster Name
  - AKS Cluster Kubernetes Version
- AD Group
  - ID
  - Object ID
 
 ### 08-aks-cluster-linux-user-nodepools.tf
 - We will comment this file and leave it that way.
 - If you need to provision the new nodepool , uncomment all lines except first line and check-in code and new nodepool will be created
 -  Node Lables and Tags will have a environment with respective environment name

<img width="373" alt="Terraform-manifest" src="https://github.com/127-0-0-vvk/azure-devops-aks-kubernetes-terraform-pipeline-vvk/assets/41470324/d299729b-b4e2-4663-83bf-bdcc70dd7aeb">


## Step-04: Create Github Repository

### Create Github Repository in Github
- Create Repository in your github
- Name: azure-devops-aks-kubernetes-terraform-pipeline
- Descritpion: Provision AKS Cluster using Azure DevOps Pipelines
- Repository Type: Public or Private (Your Choice)
- Click on **Create Repository**

https://github.com/127-0-0-vvk/azure-devops-aks-kubernetes-terraform-pipeline-vvk/

<img width="1800" alt="Github-Repo" src="https://github.com/127-0-0-vvk/azure-devops-aks-kubernetes-terraform-pipeline-vvk/assets/41470324/ea3893bc-3f2a-44d4-8195-d4fcf9790f1a">

## Step-05: Create New Azure DevOps Project for IAC
- Go to -> Azure DevOps -> Select Organization -> vivekvannavada(Your Orgnaization) ->  Create New Project
- Project Name: terraform-azure-aks
- Project Descritpion: Provision Azure AKS Cluster using Azure DevOps & Terraform
- Visibility: Private
- Click on **Create**


## Step-06: Create Azure RM Service Connection for Terraform Commands
- This is a pre-requisite step required during Azure Pipelines
- We can create from Azure Pipelines -> Terraform commands screen but just to be in a orderly manner we are creating early.
- Go to -> Azure DevOps -> Select Organization -> Select project **terraform-azure-aks**
- Go to **Project Settings**
- Go to Pipelines -> Service Connections -> Create Service Connection
- Choose a Service Connection type: Azure Resource Manager
- Authentication Method: Service Princiapl (automatic)
- Scope Level: Subscription
- Subscription: Pay-As-You-Go
- Resource Group: LEAVE EMPTY
- Service Connection Name: terraform-aks-azurerm-svc-con
- Description: Azure RM Service Connection for provisioning AKS Cluster using Terraform on Azure DevOps
- Security: Grant access permissions to all pipelines (check it - leave to default)
- Click on **SAVE**

## Step-07: VERY IMPORTANT FIX: Provide Permission to create Azure AD Groups
- Provide permission for Service connection created in previous step to create Azure AD Groups
- Go to -> Azure DevOps -> Select Organization -> Select project **terraform-azure-aks**
- Go to **Project Settings** -> Pipelines -> Service Connections 
- Open **terraform-aks-azurerm-svc-con**
- Click on **Manage Service Principal**, new tab will be opened 
- Click on **View API Permissions**
- Click on **Add Permission**
- Select an API: Microsoft APIs
- Commonly used Microsoft APIs: Supported legacy APIs: **Azure Active Directory Graph-DEPRECATING**  Use **Microsoft Graph**
- Click on **Application Permissions**
- Check **Directory.ReadWrite.All** and click on **Add Permission**
- Click on **Grant Admin consent for Default Directory**

## Step-08: Create SSH Public Key for Linux VMs
- Create this out of your git repository 
- **Important Note:**  We should not have these files in our git repos for security Reasons
```
# Create Folder
mkdir $HOME/ssh-keys-teerraform-aks-devops

# Create SSH Keys
ssh-keygen \
    -m PEM \
    -t rsa \
    -b 4096 \
    -C "azureuser@myserver" \
    -f ~/ssh-keys-teerraform-aks-devops/aks-terraform-devops-ssh-key-ububtu \

Note: We will have passphrase as : empty when asked

# List Files
ls -lrt $HOME/ssh-keys-teerraform-aks-devops
Private File: aks-terraform-devops-ssh-key-ububtu (To be stored safe with us)
Public File: aks-terraform-devops-ssh-key-ububtu.pub (To be uploaded to Azure DevOps)
```

## Step-09: Upload file to Azure DevOps as Secure File
- Go to Azure DevOps -> (organization name) -> terraform-azure-aks..etc -> Pipelines -> Library
- Secure File -> Upload file named **aks-terraform-devops-ssh-key-ububtu.pub**
- Open the file and click on **Pipeline permissions -> Authorize for use in all pipelines**
- Click on **SAVE**


## Step-10: Create Azure Pipeline to Provision AKS Cluster
- Go to -> Azure DevOps -> Select Organization -> Select project **terraform-azure-aks**
- Go to Pipelines -> Pipelines -> Create Pipeline
### Where is your Code?
- Github
- Select a Repository: stacksimplify/azure-devops-aks-kubernetes-terraform-pipeline
- Provide your github password
- Click on **Approve and Install** on Github
### Configure your Pipeline
- Select Pipeline: Starter Pipeline  
- Design your Pipeline
- Pipeline Name: 01-terraform-provision-aks-cluster-pipeline.yml
### Stage-1: Validate Stage
- **Stage-1:** Terraform Validate Stage
  - **Step-1:** Publish Artifacts to Pipeline (Pipeline artifacts provide a way to share files between stages in a pipeline or between different pipelines. )
  - **Step-2:** Install Latest Terraform (0.13.5) (Ideally not needed if we use default Agents)
  - **Step-3:** Validate Terraform Manifests

### Stage-11: Deployment-1: Deploy Dev AKS Cluster
```yaml
# Stage-2: Deploy Stages for Dev & QA
# Deployment-1: Deploy Dev AKS Cluster
## Step-1: Define Variables for environments
## Step-2: Download SSH Secure File
## Step-3: Terraform Initialize (State Storage to store in Azure Storage Account for Dev AKS Cluster)
## Step-4: Terraform Plan (Create Plan)
## Step-5: Terraform Apply (Use the plan created in previous step)
```
## Step-12: Build And package you Application
- Using Dockerfile. Copy the file and install dependencies and Push the Artifact to ACR and Drop Folder

## Step-13: Verify all the resources created 
### Verify Pipeline logs
- Verify Pipeline logs for all the tasks
- 
<img width="1036" alt="Build-Pipeline3" src="https://github.com/127-0-0-vvk/azure-devops-aks-kubernetes-terraform-pipeline-vvk/assets/41470324/10af9969-d897-4afb-8fb4-f0481694dad2"><img width="1019" alt="Build-pipeline2" src="https://github.com/127-0-0-vvk/azure-devops-aks-kubernetes-terraform-pipeline-vvk/assets/41470324/b6377dec-4759-4b3d-ac4e-1050267baf51">

## Step-14: Verify Published Artifacts
### Verify Drop Folder and ACR container

<img width="1800" alt="ACR-contatiner" src="https://github.com/127-0-0-vvk/azure-devops-aks-kubernetes-terraform-pipeline-vvk/assets/41470324/db45916d-17ec-422f-b3ed-c10edee3aa54">


## Step-15: Release Pipeline - Create Dev Stage
- Go to Pipelines -> Releases
- Create new **Release Pipeline**
### Create Dev, QA and Prod
- Stage Name: Dev
- Create Task 
- Agent Job: Change to Ubunut Linux (latest)
- 
### Add Task: Create Secret
- Display Name: Create Secret to allow image pull from ACR
- Action: create secret
- Kubernetes service connection: dev-ns-k8s-aks-svc-conn
- Namespace: dev
- Type of secret: dockerRegistry
- Secret name: dev-aksdevopsacr-secret
- Docker registry service connection: manual-aksdevopsacr-svc
- Rest all leave to defaults
- Click on **SAVE** to save release
- Comment: Dev k8s Create Secret task added

<img width="1800" alt="pre-approval deployments" src="https://github.com/127-0-0-vvk/azure-devops-aks-kubernetes-terraform-pipeline-vvk/assets/41470324/1e193ca7-2a18-477c-9934-897281a44d96">

## Setup Service connections for Every Namespace

<img width="1014" alt="svc-connections" src="https://github.com/127-0-0-vvk/azure-devops-aks-kubernetes-terraform-pipeline-vvk/assets/41470324/89c20729-1c34-4cdd-864d-7469338ab7ef">

### Add Task: Deploy to Kubernetes
- Display Name: Deploy to AKS
- Action: deploy
- Kubernetes Service Connection: aks-nextapp-dev-svc-con
- Namespace: dev
- Strategy: None
- Manifest: Select 01-Deployment.yml and Service.yml  from build artifacts
```
# Sample Value for Manifest after adding it
Manifest: $(System.DefaultWorkingDirectory)/kube-manifests/Deployment.yml and Service.yml
```
- Container: aksdevopsacr.azurecr.io/(Appname):$(Build.BuildId)
- ImagePullSecrets: dev-aksdevopsacr-secret
- Rest all leave to defaults
- Click on **SAVE** to save release
- Comment: Dev k8s Deploy task added

<img width="1800" alt="Release-pipeline" src="https://github.com/127-0-0-vvk/azure-devops-aks-kubernetes-terraform-pipeline-vvk/assets/41470324/d519cd02-fa7f-4ddb-bef5-0a4676f7e2b5">

## Step-16: View Your Application.
<img width="1800" alt="Website-home" src="https://github.com/127-0-0-vvk/azure-devops-aks-kubernetes-terraform-pipeline-vvk/assets/41470324/336a37ce-5066-4717-b147-3e4b0890cb69">


<img width="1800" alt="Website-template" src="https://github.com/127-0-0-vvk/azure-devops-aks-kubernetes-terraform-pipeline-vvk/assets/41470324/0b82dc47-d726-4b9a-ae61-ceb7be6a9a38">
