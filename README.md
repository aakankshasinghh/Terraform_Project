# Terraform + Database Reliability

This repo contains my solution for the DevOps assessment.

The Terraform part is structured into reusable modules with separate
dev and prod environments. The database part runs locally using
PostgreSQL and Docker Compose.

AWS resources are not deployed as part of this assignment. Terraform
is only validated and planned locally/GitHub Actions.# DevOps Assessment — Terraform + Database Reliability

A single repository implementing the requested AWS infrastructure design and local database reliability exercise.

## Architecture

Internet ---> ALB --> ECS/Fargate --> PostgreSQL
ALB------Public subnets
ECS/Fargate -----Private Subnets
RDS PostgreSQL ----- Private Subnets


-> Running ECS tasks run with `assign_public_ip = false`. NAT gateways will provide outbound connectivity from private subnets with no inbound connectivity.

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
Environments

infra/envs/dev and infra/envs/prod have their own variables, tfvars
and backend configuration.

The main differences are:

Setting

Dev

Prod

RDS instance

db.t3.micro

db.t3.small

ECS tasks

1

2

Backup retention

3 days

14 days

Deletion protection

Disabled

Enabled

RDS Multi-AZ

Disabled

Enabled

The ECS container uses nginx:latest by default and listens on port 80.

Terraform checks

From the repository root:

terraform fmt -check -recursive infra

For dev:

cd infra/envs/dev
terraform init -backend=false
terraform validate
terraform plan -refresh=false -var-file=dev.tfvars

For prod:

cd ../prod
terraform init -backend=false
terraform validate
terraform plan -refresh=false -var-file=prod.tfvars

The backend configuration uses placeholder S3/DynamoDB values. No AWS
credentials or Terraform state files are included in the repository.

Local database

The local database uses PostgreSQL 16.

Start it with:

docker compose up -d

The database is named hotel and uses the local development credentials
defined in docker-compose.yml.

The migrations create:

hotel_bookings

booking_events

The seed file contains more than 100 bookings across multiple cities,
organisations and booking statuses, along with booking events for a
subset of the bookings.

To stop the database:

docker compose down

Query optimization

The assessment query filters bookings by city and created_at:

SELECT org_id, status, COUNT(*), SUM(amount)
FROM hotel_bookings
WHERE city = 'delhi'
  AND created_at >= NOW() - INTERVAL '30 days'
GROUP BY org_id, status;

The following index is added for these filters:

CREATE INDEX idx_hotel_bookings_city_created_at
ON hotel_bookings (city, created_at);

city is the equality filter and created_at is the range filter, so the
index follows the same order as the main filtering conditions.

Backup and restore

The backup script creates a timestamped SQL dump under backups/.

Run:

./scripts/backup.sh

A backup file will look similar to:

backups/hotel_YYYYMMDD_HHMMSS.sql

To restore a backup into a fresh database:

./scripts/restore.sh backups/hotel_YYYYMMDD_HHMMSS.sql

The restore script creates a separate hotel_restore database so the
original local database is not overwritten.

A simple way to check the restored database is:

docker exec -it hotel-postgres psql -U appuser -d hotel_restore

Then:

SELECT COUNT(*) FROM hotel_bookings;
SELECT COUNT(*) FROM booking_events;

The booking count should match the source database after a successful
restore.

GitHub Actions

The repository includes a Terraform workflow at:

.github/workflows/terraform.yml

It runs Terraform formatting, initialization, validation and planning
for pull requests and pushes to main.

The workflow does not deploy anything to AWS.
