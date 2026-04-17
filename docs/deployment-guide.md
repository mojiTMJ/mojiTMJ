# Deployment Guide

## Prerequisites

| Tool | Minimum Version | Install |
|------|----------------|---------|
| Azure CLI | 2.50+ | [docs.microsoft.com/cli/azure/install](https://docs.microsoft.com/cli/azure/install) |
| Azure PowerShell (`Az` module) | 10.0+ | `Install-Module -Name Az -AllowClobber` |
| Git | 2.40+ | [git-scm.com](https://git-scm.com) |

---

## 1. First-Time Setup

### 1.1 Clone the Repository
```bash
git clone https://github.com/<your-org>/adf-development.git
cd adf-development
```

### 1.2 Connect ADF to This Repository (Azure Portal)
1. Open your Azure Data Factory instance → **Manage** → **Git configuration**
2. Select **GitHub** as the repository type
3. Authenticate and select this repository
4. Set **Collaboration branch** → `dev`
5. Set **Publish branch** → `adf_publish`
6. Set **Root folder** → `/`
7. Click **Apply**

### 1.3 Configure GitHub Repository Secrets
Navigate to **Settings → Secrets and variables → Actions** and add:

| Secret Name | Description |
|-------------|-------------|
| `AZURE_CREDENTIALS` | Service principal JSON (`az ad sp create-for-rbac --sdk-auth`) |
| `AZURE_SUBSCRIPTION_ID` | Azure Subscription ID |
| `ADF_RESOURCE_GROUP_DEV` | Dev resource group name |
| `ADF_RESOURCE_GROUP_QA` | QA resource group name |
| `ADF_RESOURCE_GROUP_PROD` | Production resource group name |
| `ADF_FACTORY_NAME_DEV` | Dev ADF instance name |
| `ADF_FACTORY_NAME_QA` | QA ADF instance name |
| `ADF_FACTORY_NAME_PROD` | Production ADF instance name |

### 1.4 Create a Service Principal
```bash
az ad sp create-for-rbac \
  --name "sp-adf-cicd" \
  --role "Data Factory Contributor" \
  --scopes "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RESOURCE_GROUP>" \
  --sdk-auth
```
Copy the JSON output and store it as the `AZURE_CREDENTIALS` secret.

---

## 2. Branching & Development Workflow

```
feature/my-pipeline
       │
       ▼ PR → review → merge
      dev  ──────────────────► auto-deploy to Dev ADF
       │
       ▼ PR → review → merge
       qa   ─────────────────► auto-deploy to QA ADF
       │
       ▼ PR → review → manual approval → merge
      main  ────────────────► auto-deploy to Prod ADF + version tag
```

1. Create a feature branch from `dev`:
   ```bash
   git checkout dev
   git pull
   git checkout -b feature/<ticket>-description
   ```
2. Make changes in ADF Studio (UI will commit JSON files to your branch)
3. Open a PR → `dev` using the PR template
4. Wait for the **ADF Validate** check to pass
5. After merge → GitHub Actions deploys to Dev automatically

---

## 3. Manual Deployment (Local)

```powershell
# Login
az login
Connect-AzAccount

# Deploy to Dev
.\scripts\deploy-adf.ps1 `
    -SubscriptionId    "<SUBSCRIPTION_ID>" `
    -ResourceGroupName "rg-adf-dev" `
    -DataFactoryName   "adf-dev-yourproject" `
    -Environment       "dev"
```

---

## 4. Environment Promotion

| From | To | Trigger |
|------|----|---------|
| feature/* | dev | PR merge |
| dev | qa | PR merge (after QA sign-off) |
| qa | main | PR merge + manual approval in GitHub Environments |

---

## 5. Rollback

To roll back a production deployment:
```bash
# Find the previous release tag
git tag -l | sort -V | tail -5

# Deploy the previous tag manually
git checkout <previous-tag>
.\scripts\deploy-adf.ps1 -Environment prod ...
```

---

## 6. Troubleshooting

| Issue | Possible Cause | Resolution |
|-------|---------------|------------|
| ARM validation fails | Incorrect parameter values | Check `environments/*.json` overrides |
| Trigger restart fails | Trigger in error state | Check ADF Monitor → fix source issue → restart manually |
| Linked service auth error | Key Vault access policy missing | Grant ADF managed identity `Get` permission on Key Vault secrets |
| Pipeline runs differ across envs | Missing parameter override | Add override to `environments/<env>-parameters.json` |
