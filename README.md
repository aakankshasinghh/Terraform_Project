# DevOps Assessment — Terraform + Database Reliability

A single repository implementing the requested AWS infrastructure design and local database reliability exercise.

## Architecture

```text
Internet
   |
   v
 ALB (public subnets)
   |
   v
 ECS/Fargate (private subnets)
   |
   v
 RDS PostgreSQL (private subnets)
```

The security-group flow is:

```text
0.0.0.0/0 -> ALB SG -> ECS SG -> RDS SG:5432
```

RDS is private and has no public IP. ECS tasks run with `assign_public_ip = false`. NAT gateways provide outbound connectivity from private subnets without making those resources directly reachable from the internet.

See [docs/architecture.md](docs/architecture.md) for the detailed diagram.

## Assessment Coverage

| Part | Requirement | Implementation |
|---|---|---|
| 1 | AWS infrastructure | `infra/modules/` |
| 2 | Dev + prod environments | `infra/envs/dev`, `infra/envs/prod` |
| 3 | Terraform CI | `.github/workflows/terraform.yml` |
| 4 | Local PostgreSQL | `docker-compose.yml`, `db/migrations/` |
| 5 | Seed data + query optimization | `db/seed/`, `003_add_booking_query_index.sql` |
| 6 | Backup + restore | `scripts/backup.sh`, `scripts/restore.sh` |

## Repository Structure

```text
.
├── .github/workflows/terraform.yml
├── docs/architecture.md
├── infra/
│   ├── modules/
│   │   ├── network/
│   │   ├── ecs/
│   │   └── rds/
│   └── envs/
│       ├── dev/
│       └── prod/
├── db/
│   ├── migrations/
│   └── seed/
├── scripts/
│   ├── backup.sh
│   └── restore.sh
├── docker-compose.yml
├── .gitignore
├── README.md
└── SUBMISSION_CHECKLIST.md
```

## Part 1 — Terraform Infrastructure

The Terraform is split into reusable modules:

- `network`: VPC, two public subnets, two private subnets, internet gateway, NAT gateways, and route tables.
- `ecs`: public ALB, target group, listener, ECS cluster, Fargate task definition/service, IAM roles, and CloudWatch logs.
- `rds`: private DB subnet group and encrypted RDS instance.
- Environment roots: security groups and module composition for dev/prod.

### Security model

- ALB accepts HTTP on port 80 from the internet.
- ECS accepts the application port only from the ALB security group.
- RDS accepts the database port only from the ECS security group.
- RDS uses `publicly_accessible = false`.
- ECS uses private subnets and no public IP.

### Terraform validation

No AWS deployment is required for this assessment.

From `infra/envs/dev`:

```bash
terraform init -backend=false
terraform validate
terraform plan -refresh=false -var-file=dev.tfvars
```

From `infra/envs/prod`:

```bash
terraform init -backend=false
terraform validate
terraform plan -refresh=false -var-file=prod.tfvars
```

From the repository root:

```bash
terraform fmt -check -recursive infra
```

The environment `backend.tf` files show a production-style S3 backend pattern with separate state keys. The placeholder bucket/table names are intentionally not tied to an AWS account; `-backend=false` is sufficient for assessment validation.

## Part 2 — Dev and Prod Handling

| Setting | Dev | Prod |
|---|---:|---:|
| ECS desired count | 1 | 2 |
| RDS instance | `db.t3.micro` | `db.t3.small` |
| Storage | 20 GB | 50 GB |
| Backup retention | 3 days | 14 days |
| Multi-AZ | false | true |
| Deletion protection | false | true |
| CloudWatch log retention | 7 days | 30 days |

`dev.tfvars` and `prod.tfvars` contain assessment-safe placeholder passwords. For real usage, prefer:

```bash
export TF_VAR_db_password='use-a-secret-here'
```

and do not commit credentials.

## Part 3 — GitHub Actions

`.github/workflows/terraform.yml` runs for Terraform changes on pull requests and pushes to `main`.

It performs:

1. `terraform fmt -check -recursive infra`
2. `terraform init -backend=false`
3. `terraform validate`
4. `terraform plan -refresh=false`
5. Uploads the rendered plan as a workflow artifact.

The workflow uses a CI-only placeholder database password and does not deploy AWS resources.

## Part 4 — Local PostgreSQL

Prerequisites:

- Docker Desktop with Compose
- Bash shell for the backup/restore scripts (Git Bash, WSL, or Linux/macOS shell)

Start from a clean database:

```bash
docker compose down -v
docker compose up -d
docker compose ps
```

The PostgreSQL service uses:

```text
Database: hotel
User:     appuser
Password: localdev
Host:     localhost
Port:     5432
```

The migration creates:

- `hotel_bookings`
- `booking_events`

The seed file creates 120 bookings across multiple cities, organizations, and statuses, plus booking events with JSONB payloads.

Verify the data:

```bash
docker compose exec -T db psql -U appuser -d hotel -c "SELECT COUNT(*) FROM hotel_bookings;"
docker compose exec -T db psql -U appuser -d hotel -c "SELECT city, COUNT(*) FROM hotel_bookings GROUP BY city ORDER BY city;"
docker compose exec -T db psql -U appuser -d hotel -c "SELECT status, COUNT(*) FROM hotel_bookings GROUP BY status ORDER BY status;"
docker compose exec -T db psql -U appuser -d hotel -c "SELECT COUNT(*) FROM booking_events;"
```

## Part 5 — Query Optimization

Assessment query:

```sql
SELECT org_id, status, COUNT(*), SUM(amount)
FROM hotel_bookings
WHERE city = 'delhi'
  AND created_at >= NOW() - INTERVAL '30 days'
GROUP BY org_id, status;
```

Index:

```sql
CREATE INDEX idx_hotel_bookings_city_created_at
    ON hotel_bookings (city, created_at);
```

### Why this index?

The query filters on `city` with an equality predicate and `created_at` with a range predicate. The composite index puts the equality predicate first and the range predicate second, allowing PostgreSQL to narrow the candidate rows before performing the aggregation.

To inspect the actual planner decision locally:

```bash
docker compose exec -T db psql -U appuser -d hotel -c "EXPLAIN (ANALYZE, BUFFERS) SELECT org_id, status, COUNT(*), SUM(amount) FROM hotel_bookings WHERE city = 'delhi' AND created_at >= NOW() - INTERVAL '30 days' GROUP BY org_id, status;"
```

Because the seed table is intentionally small, PostgreSQL may still choose a sequential scan. The index is designed for the filtering pattern and becomes more useful as the table grows.

## Part 6 — Backup and Restore

Create a timestamped dump:

```bash
./scripts/backup.sh
```

Example:

```text
backups/hotel_20260917_084500.sql
```

Generated SQL dumps are ignored by Git.

Restore into a separate fresh database:

```bash
./scripts/restore.sh backups/hotel_20260917_084500.sql
```

The restore script recreates `hotel_restore`, restores the dump, and prints row counts.

Verify the restored database directly:

```bash
docker compose exec -T db psql -U appuser -d hotel_restore -c "SELECT COUNT(*) FROM hotel_bookings;"
docker compose exec -T db psql -U appuser -d hotel_restore -c "SELECT COUNT(*) FROM booking_events;"
```

For a full verification, compare these counts with the source `hotel` database. The counts should match for a successful logical backup/restore test.

## Reviewer Quick Start

### 1. Terraform

```bash
terraform fmt -check -recursive infra

cd infra/envs/dev
terraform init -backend=false
terraform validate
terraform plan -refresh=false -var-file=dev.tfvars

cd ../prod
terraform init -backend=false
terraform validate
terraform plan -refresh=false -var-file=prod.tfvars
```

### 2. Database

```bash
cd ../../..
docker compose down -v
docker compose up -d
docker compose ps
```

### 3. Backup / restore

```bash
./scripts/backup.sh
./scripts/restore.sh backups/$(ls -t backups/*.sql | head -1 | xargs basename)
```

## Design Decisions

- **One repository:** all assessment parts are related and can be reviewed as one cohesive DevOps project.
- **Reusable Terraform modules:** network, ECS/ALB, and RDS concerns are isolated so dev/prod environments can reuse the same implementation.
- **Private application/data tiers:** only the ALB is public; ECS and RDS remain private.
- **PostgreSQL:** selected because the supplied schema/query uses PostgreSQL-specific `JSONB` and `INTERVAL` features.
- **Logical backup:** `pg_dump` is appropriate for the local database exercise and can be restored into a separate database without affecting the source.
- **No deployment:** the assessment explicitly does not require AWS deployment, so the repository focuses on plan/validation and local database execution.

## Security Notes

Do not commit real AWS credentials, database passwords, Terraform state, or generated backup dumps. The repository contains only assessment-safe placeholders.
