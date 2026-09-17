# AWS Architecture

```text
                         Internet
                            |
                            v
                     +-------------+
                     |     ALB     |
                     | Public      |
                     +-------------+
                            |
                      ALB Security SG
                            |
                            v
                  +-------------------+
                  |   ECS Fargate     |
                  | Private Subnets   |
                  +-------------------+
                            |
                       ECS Security SG
                            |
                            v
                  +-------------------+
                  |   RDS PostgreSQL   |
                  | Private Subnets   |
                  +-------------------+
                       RDS Security SG
```

Traffic is constrained to:

`Internet -> ALB -> ECS/Fargate -> RDS:5432`

The ALB is placed in public subnets. ECS tasks and RDS are placed in private subnets. Private subnets use NAT gateways for outbound access when required, while security groups prevent direct inbound access to ECS and RDS from the public internet.
