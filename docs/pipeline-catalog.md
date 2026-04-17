# Pipeline Catalog

This document lists all ADF pipelines, their purpose, frequency, and owners.

> Update this file whenever a pipeline is added, modified, or retired.

---

## Naming Convention

| Prefix | Object Type |
|--------|-------------|
| `PL_`  | Pipeline |
| `DS_`  | Dataset |
| `LS_`  | Linked Service |
| `TR_`  | Trigger |
| `DF_`  | Data Flow |
| `IR_`  | Integration Runtime |

---

## Ingestion Pipelines

| Pipeline Name | Source | Destination | Schedule | Owner | Status |
|---------------|--------|-------------|----------|-------|--------|
| `PL_Ingest_Example` | SQL Server | ADLS Raw | Daily 02:00 UTC | @mojiTMJ | ✅ Active |

---

## Transformation Pipelines

| Pipeline Name | Input Layer | Output Layer | Schedule | Owner | Status |
|---------------|-------------|--------------|----------|-------|--------|
| `PL_Transform_Example` | ADLS Raw | ADLS Curated | Daily 04:00 UTC | @mojiTMJ | ✅ Active |

---

## Serving / Export Pipelines

| Pipeline Name | Source | Destination | Schedule | Owner | Status |
|---------------|--------|-------------|----------|-------|--------|
| `PL_Serve_Example` | ADLS Curated | Synapse DW | Daily 06:00 UTC | @mojiTMJ | ✅ Active |

---

## Retired Pipelines

| Pipeline Name | Retired Date | Reason |
|---------------|--------------|--------|
| _(none yet)_  |              |        |

---

## How to Add a New Pipeline

1. Create the pipeline JSON under `pipeline/` via the ADF UI on the `dev` branch
2. Add an entry to this catalog
3. Update `environments/*.json` if new parameters are introduced
4. Open a PR against `dev` following the PR template
