# Contributing

Thanks for your interest in improving this project!

## Workflow
1. Fork the repository.
2. Create a feature branch: `git checkout -b feat/your-change`.
3. Make your changes. Keep commits small and focused.
4. Validate:
   ```bash
   make fmt validate
   ```
5. Push and open a pull request. The CI workflow will run `terraform plan` and
   post a comment on the PR.

## Conventions
- **Terraform** — files are `lower_snake_case.tf`; one concern per file; use
  `var.project_name` in all resource names; merge user tags with `merge(var.tags, {...})`.
- **Bash scripts** — `set -euo pipefail`, `bash` not `sh`, quote variables.
- **Markdown** — wrap at 100 cols, headings `#`-first, fenced code blocks with
  language hints.
- **No secrets in the repo** — use TF variables, Secrets Manager, or env vars.

## Reporting bugs
Open a GitHub issue with:
- Steps to reproduce
- Expected vs actual behavior
- `terraform version` and `terraform validate` output

## Security
See [SECURITY.md](SECURITY.md) for how to report vulnerabilities privately.
