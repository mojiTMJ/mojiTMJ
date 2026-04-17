# Architecture Overview

## Solution Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     SOURCE SYSTEMS                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │  On-Prem DB  │  │  REST APIs   │  │  Blob / ADLS     │  │
│  └──────┬───────┘  └──────┬───────┘  └────────┬─────────┘  │
└─────────┼─────────────────┼───────────────────┼────────────┘
          │                 │                   │
          ▼                 ▼                   ▼
┌─────────────────────────────────────────────────────────────┐
│              AZURE DATA FACTORY (Orchestration)             │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Integration Runtime (Self-hosted / Azure IR)       │   │
│  └──────────────────────────┬──────────────────────────┘   │
│                             │                               │
│  ┌──────────────────────────▼──────────────────────────┐   │
│  │  Pipelines  →  Data Flows  →  Datasets              │   │
│  │  (Ingest)      (Transform)    (Schema)              │   │
│  └──────────────────────────┬──────────────────────────┘   │
│                             │                               │
│  ┌──────────────────────────▼──────────────────────────┐   │
│  │  Linked Services (Key Vault-backed credentials)     │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────┬───────────────────────────────┘
                              │
          ┌───────────────────┼───────────────────┐
          ▼                   ▼                   ▼
  ┌──────────────┐  ┌──────────────────┐  ┌────────────────┐
  │  Raw Zone    │  │  Curated / Silver│  │  Gold / Serving│
  │  (ADLS Gen2) │  │  (ADLS Gen2)     │  │  (Synapse/PBI) │
  └──────────────┘  └──────────────────┘  └────────────────┘
```

## Data Flow Layers

| Layer | Description | Storage |
|-------|-------------|---------|
| **Raw (Bronze)** | Ingested as-is from source | ADLS Gen2 – `raw/` container |
| **Curated (Silver)** | Cleansed, deduplicated, typed | ADLS Gen2 – `curated/` container |
| **Serving (Gold)** | Aggregated, business-ready datasets | Azure Synapse / Power BI |

## Key Components

### Integration Runtime
- **Azure IR** – used for cloud-to-cloud data movement
- **Self-hosted IR** – used for on-premises source connectivity

### Security
- All credentials stored in **Azure Key Vault**
- Linked services reference Key Vault secrets (never hardcoded)
- Managed Identity used where supported
- Private endpoints for ADLS Gen2 and SQL

### Parameterization Strategy
- All environment-specific values (resource names, paths, connection strings) are externalized as ARM parameters
- Override files per environment: `environments/{env}-parameters.json`

## Environments

| Environment | Purpose | ADF Name | Resource Group |
|-------------|---------|----------|----------------|
| **Dev** | Active development & unit testing | `adf-dev-yourproject` | `rg-adf-dev` |
| **QA** | Integration & regression testing | `adf-qa-yourproject` | `rg-adf-qa` |
| **Prod** | Production workloads | `adf-prod-yourproject` | `rg-adf-prod` |

## Diagram Updates
Update the ASCII diagram above and add a Visio/draw.io export to this folder when architecture changes occur.
