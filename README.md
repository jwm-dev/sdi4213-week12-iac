# SDI 4213 Week 12 - Infrastructure as Code Student Starter

This repository is the starter for the Week 12 individual exercise. You will use OpenTofu and the local Docker provider to provision, change, repair, and destroy a small local service stack.

## What the starter already provides
- OpenTofu provider/version configuration
- Docker provider pinned to version 4.6.0
- a Docker network
- an Nginx status portal managed by OpenTofu
- starter input variables and output
- GitHub Actions checks for `tofu fmt` and `tofu validate`
- TODO markers for PostgreSQL, persistent storage, Adminer, variables, and outputs

## Prerequisites
- Docker Desktop / Docker Engine running
- OpenTofu installed
- Git and GitHub
- VS Code or another editor

Verify:

```text
tofu -version
docker version
```

## Start
1. Copy `terraform.tfvars.example` to `terraform.tfvars`.
2. Run `tofu fmt -recursive`.
3. Run `tofu init`.
4. Run `tofu validate`.
5. Run `tofu plan`.
6. Review the plan before running `tofu apply`.

After the starter apply, open the `portal_url` shown by OpenTofu.

## Important
- Never commit `terraform.tfvars` or local state files.
- State may contain sensitive data even when variables are marked `sensitive`.
- Do not use `tofu apply -auto-approve` for this exercise; you are expected to review each plan.
- Complete the work on a branch and finish with a pull request.

See `docs/Week12_Individual_Exercise.docx` for the complete assignment.

## Week 12 completion notes
- Full stack: Docker network, Nginx status portal, PostgreSQL 18 (`postgres:18.6-alpine`) with a named volume, and Adminer 5.5.1, all managed by OpenTofu.
- New variables: `adminer_port`, `postgres_db`, `postgres_user`, `postgres_password` (sensitive, no default; set it in your local, git-ignored `terraform.tfvars`).
- Outputs: `portal_url`, `adminer_url`, `database_server` (use it as the Adminer "Server"), `postgres_volume`.
- **postgres 18 note:** the volume is mounted at `/var/lib/postgresql`, not `/var/lib/postgresql/data`. Starting with 18, the official image stores data in `/var/lib/postgresql/18/docker` and exits if a volume is mounted at the legacy path.
- Evidence screenshots are in `evidence/`; the reflection is in `REFLECTION.md`.
