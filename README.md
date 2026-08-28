# COB
## What is COB 
COB is an internal infrastructure provisioning platform built by the Platform Engineering team. It provides reusable Terraform modules that other engineering teams can consume to provision standardised AWS infrastructure  without writing raw resource blocks themselves.
---
## The Problem It Solves
Standing up a data pipeline on AWS typically requires coordinating networking, storage, cataloguing, querying, compute, and IAM  each with its own Terraform resource blocks scattered across files. COB solves this by:
- Encapsulating each concern in a self-contained module with clear inputs and outputs
- Letting each environment (`dev`, `stag`, `prod`) override only what it needs via a `.tfvars` file
- Keeping cost-sensitive resources (e.g. NAT Gateways) configurable so staging doesn't pay for production-grade redundancy
---
## Network Architecture
![image alt](https://github.com/Raymondafuye/terraform_module_project/blob/56efbc15d90656a7fa5cb26ba4e6ca05520d99e8/myfiles/snowflakes-Page-6.jpg)

> In `dev` and `stag`, `single_nat_gateway = true`  both private subnets share one NAT Gateway in AZ-A to reduce cost. In `prod`, each AZ has its own NAT Gateway for high availability.
---
## Data Pipeline Architecture

![image alt](https://github.com/Raymondafuye/terraform_module_project/blob/56efbc15d90656a7fa5cb26ba4e6ca05520d99e8/myfiles/snowflakes-Page-7.jpg)

> IAM: The Glue crawler assumes the `{workspace}-glue-crawler-role`, which has least-privilege `s3:GetObject`, `s3:PutObject`, and `s3:ListBucket` access scoped to the raw bucket ARN only.
---
## Available Capabilities
| Module | What it provisions |
|---|---|
| `aws_vpc` | VPC, public/private subnets per AZ, Internet Gateway, NAT Gateway(s), route tables, security groups (web, RDS, ECS) |
| `aws_iam_roles` | EC2 instance role + SSM policy, ECS task execution role, Glue crawler role with scoped S3 access |
| `aws_s3_bucket` | S3 bucket with SSE-AES256, public access block, optional versioning, optional local file upload |
| `aws_glue` | Glue Data Catalog database + crawler pointed at the raw S3 bucket |
| `aws_athena` | Athena workgroup with enforced result location and SSE encryption |
| `aws_rds` | RDS instance (module present, wired on demand) |
| `aws_ec2_instances` | EC2 instances (module present, wired on demand) |
| `aws_ecs` | ECS cluster/service (module present, wired on demand) |

---

## How Modules Are Consumed

All modules live under `./modules/` and are called from the root `main.tf`:

```hcl
module "aws_vpc" {
  source               = "./modules/aws_vpc"
  vpc_name             = var.vpc_name
  vpc_cidr_block       = var.vpc_cidr_block
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  single_nat_gateway   = var.single_nat_gateway
  ssh_allowed_cidrs    = var.ssh_allowed_cidrs
}
```

Each environment is deployed by passing its `.tfvars` file and selecting the matching Terraform workspace:

```bash
terraform workspace select dev
terraform apply -var-file="env/dev/dev.tfvars"
```

---

## Required Inputs

### Root-level (all environments)

| Variable | Type | Description |
|---|---|---|
| `vpc_name` | `string` | Base name for VPC resources |
| `vpc_cidr_block` | `string` | VPC CIDR, e.g. `10.0.0.0/16` |
| `azs` | `list(string)` | Availability zones to deploy into |
| `public_subnet_cidrs` | `list(string)` | One CIDR per AZ for public subnets |
| `private_subnet_cidrs` | `list(string)` | One CIDR per AZ for private subnets |
| `single_nat_gateway` | `bool` | `true` = one shared NAT GW; `false` = one per AZ |
| `ssh_allowed_cidrs` | `list(string)` | CIDRs allowed to reach port 22 on web instances |
| `bucket_name` | `string` | Base name for the general-purpose S3 bucket |
| `enable_bucket_versioning` | `bool` | Enable S3 versioning on the app bucket |
| `raw_bucket_name` | `string` | Base name for the raw data S3 bucket |
| `athena_results_bucket_name` | `string` | Base name for the Athena results bucket |
| `raw_data_prefix` | `string` | S3 key prefix the Glue crawler scans, e.g. `data/` |
| `glue_database_name` | `string` | Glue Catalog database name |
| `glue_crawler_name` | `string` | Glue crawler name |
| `glue_crawler_schedule` | `string` | Cron expression or `""` for on-demand only |
| `athena_workgroup_name` | `string` | Athena workgroup name |
| `upload_sample_data` | `bool` | Upload local sample files to the raw bucket |
| `sample_data_dir` | `string` | Local path to upload (used when `upload_sample_data = true`) |

---

## Outputs

| Output | Source module | Description |
|---|---|---|
| `vpc_id` | `aws_vpc` | ID of the created VPC |
| `s3_bucket_id` | `aws_s3_bucket` | ID of the general-purpose bucket |
| `raw_bucket_id` | `raw_data_bucket` | ID of the raw data bucket |
| `glue_database_name` | `aws_glue` | Full name of the Glue Catalog database |
| `glue_crawler_name` | `aws_glue` | Full name of the Glue crawler |
| `athena_workgroup_name` | `aws_athena` | Full name of the Athena workgroup |

Additional outputs available directly from each module:

- `aws_vpc`: `public_subnet_ids`, `private_subnet_ids`, `nat_gateway_ids`, `nat_gateway_public_ips`, `web_security_group_id`, `rds_security_group_id`, `ecs_security_group_id`
- `aws_iam_roles`: `ec2_role_arn`, `ec2_instance_profile_name`, `ecs_task_execution_role_arn`, `glue_crawler_role_arn`
- `aws_s3_bucket`: `bucket_id`, `bucket_arn`

---

## Supported Environments

| Environment | `env/` file | CIDR block | NAT Gateway | Notes |
|---|---|---|---|---|
| `dev` | `env/dev/dev.tfvars` | `10.0.0.0/16` | Single (shared) | Sample data upload enabled |
| `stag` | `env/stag/stag.tfvars` | `10.1.0.0/16` | Single (shared) | Cost-optimised; pipeline optional |
| `prod` | `env/prod/prod.tfvars` | `10.2.0.0/16` | One per AZ | Crawler on daily schedule |

All resource names are automatically prefixed with the Terraform workspace name (e.g. `dev-raw-data`, `prod-raw-data`), so all three environments can coexist in the same AWS account without name collisions.

---

## Security Considerations

- All S3 buckets have public access fully blocked and AES-256 server-side encryption enabled by default.
- Athena query results are written to a dedicated bucket with SSE-S3 encryption enforced at the workgroup level.
- The RDS security group only allows inbound traffic on the database port from within the VPC CIDR — no public exposure.
- The Glue crawler IAM role is granted least-privilege S3 access (`GetObject`, `PutObject`, `ListBucket`) scoped to the raw bucket ARN only.
- EC2 instances use an IAM instance profile with `AmazonSSMManagedInstanceCore`, enabling Session Manager access without opening SSH to the internet. Restrict `ssh_allowed_cidrs` to known IPs in production.
- State is stored in S3 with encryption enabled and state locking via a lock file (`use_lockfile = true`).

---

## Important Assumptions

- Terraform workspaces are used as the environment discriminator. The workspace name must match the intended environment (`dev`, `stag`, `prod`) before applying.
- The number of entries in `azs`, `public_subnet_cidrs`, and `private_subnet_cidrs` must be equal — one subnet pair is created per AZ.
- `upload_sample_data = true` requires `sample_data_dir` to point to a valid local directory. The directory must exist before `terraform apply`.
- The S3 backend bucket (`rmd01-module-terraform-state`) must exist before running `terraform init`.
- Modules for `aws_rds`, `aws_ec2_instances`, and `aws_ecs` are present but not wired in `main.tf` by default. Add module blocks to activate them.

---

## Known Limitations
- The `aws_s3_bucket` module uses `fileset` for uploads, which is evaluated at plan time. Large local directories will slow down `terraform plan`.
- Glue crawler schedule is a raw cron string with no validation — an invalid expression will fail at apply time, not plan time.
- All environments share the same AWS region (`us-east-1`). Cross-region deployments are not currently supported.

---

## Architectural Decisions

### 1. Public + private subnet in every AZ

Each AZ gets one public and one private subnet. Public subnets host internet-facing resources (load balancers, NAT Gateways) while private subnets isolate sensitive workloads (RDS, ECS tasks, Glue). This gives every environment the flexibility to place resources at the right network tier without restructuring the VPC later.

### 2. `single_nat_gateway` flag for cost control

In production, each private subnet routes outbound traffic through its own NAT Gateway and Elastic IP  one per AZ so that an AZ failure doesn't take down outbound connectivity for the others. In staging and dev, `single_nat_gateway = true` collapses this to one shared NAT Gateway and one EIP, cutting NAT costs significantly for non-production workloads where high availability is not required.

### 3. Per-environment `env/` folder with `.tfvars` files

Rather than using a single `terraform.tfvars` or relying on environment variables, each environment has its own `.tfvars` file under `env/<env>/`. This makes environment-specific values explicit, version-controlled, and easy to diff. It also allows each environment to independently toggle features (e.g. disabling the data pipeline in staging) or use different resource names without touching shared code.

### 4. Terraform workspaces as the environment discriminator

All resource names are prefixed with `terraform.workspace`. This means the same module code produces `dev-raw-data` in dev and `prod-raw-data` in prod, allowing all environments to coexist in one AWS account. Workspaces are the single source of truth for the environment name — no separate variable needed.

### 5. Shared IAM module across compute services

EC2, ECS, and Glue all need IAM roles with different trust policies and permission sets. Rather than defining roles inside each service module (which would scatter IAM across the codebase), a single `aws_iam_roles` module owns all role definitions and exposes ARNs as outputs. Other modules consume those ARNs, keeping IAM auditable in one place.

### 6. S3 module reused for all buckets

The same `aws_s3_bucket` module is called three times (app bucket, raw data bucket, Athena results bucket) with different inputs. Reuse avoids duplicating encryption, versioning, and public-access-block configuration. The optional `upload_source_dir` input lets the raw bucket seed itself with sample data at apply time without requiring a separate script.

