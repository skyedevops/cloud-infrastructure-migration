# Phase 1: Assessment & Discovery

## Objectives
- Inventory current infrastructure (servers, databases, network, dependencies).
- Identify workloads suitable for rehost (lift & shift), replatform, or refactor.
- Establish baseline metrics (cost, performance, availability).
- Define success criteria and KPIs.

## Activities

### 1. Application Inventory
Catalog each application/component:
- Name and business purpose
- Owner / team
- Tech stack (language, runtime, framework)
- Data stores and volumes
- Network dependencies (internal services, APIs)
- Compliance / regulatory requirements

### 2. Dependency Mapping
Build a dependency graph (CSV/JSON or a tool like AWS Application Discovery Service).
Identify:
- Hard dependencies (DB connections, queues)
- Soft dependencies (DNS, monitoring)
- Latency-sensitive paths

### 3. Cost & Performance Baseline
Capture:
- Current monthly spend per workload
- Average and peak CPU, memory, IOPS
- Network ingress/egress
- Backup sizes and retention

### 4. Migration Strategy Selection
For each workload, choose:
| Strategy  | When to use                                           | Risk  | Time |
|-----------|-------------------------------------------------------|-------|------|
| Rehost    | Quick win, low complexity                             | Low   | Days |
| Replatform| Lift + minor optimizations (RDS, managed cache)       | Med   | Wks  |
| Refactor  | Heavy cloud-native re-architecture                    | High  | Mos  |

### 5. Success Criteria
Examples (also tracked in `docs/01-project-overview.md`):
- Availability > 99.9%
- p95 latency < 500 ms
- 30%+ cost reduction
- MTTR < 15 minutes

## Deliverables
- `inventory/spreadsheet.csv` — application catalog
- `diagrams/current-architecture.png` — as-is architecture
- `docs/assessment-report.md` — written findings and recommendations
- Risk register (high/medium/low) per workload
