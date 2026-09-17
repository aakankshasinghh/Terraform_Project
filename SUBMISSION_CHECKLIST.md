# Submission Checklist

- [x] One GitHub repository contains all assessment parts.
- [x] Terraform modules: network, ECS/ALB, and RDS.
- [x] Separate dev and prod Terraform environments.
- [x] Public ALB with private ECS/Fargate tasks.
- [x] Private RDS accessible through the ECS security group only.
- [x] Environment-specific RDS sizing, retention, Multi-AZ, and deletion protection.
- [x] Local PostgreSQL Docker Compose setup.
- [x] Required database tables and foreign key.
- [x] 120 seeded bookings across multiple cities, organizations, and statuses.
- [x] Booking events with JSONB payloads.
- [x] Composite `(city, created_at)` query index.
- [x] Timestamped PostgreSQL backup script.
- [x] Fresh-database restore script.
- [x] GitHub Actions Terraform validation and plan artifacts.
- [x] README contains setup, verification, and design decisions.
- [x] No AWS credentials, Terraform state, or generated database dumps are committed.
