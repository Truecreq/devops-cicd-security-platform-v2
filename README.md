# DevOps CI/CD Security Platform

[![CI](https://github.com/Truecreq/devops-cicd-security-platform-v2/actions/workflows/ci.yml/badge.svg)](https://github.com/Truecreq/devops-cicd-security-platform-v2/actions)

## Project Name
**devops-cicd-security-platform**

## Objective
Design and implement a DevOps workflow focusing on Linux administration, Git & GitHub collaboration, CI/CD automation, SonarQube integration, and Open Policy Agent (OPA) policy enforcement.

---

## 1. Linux Administration & User Management

### Directory Structure
```
company-devops-platform/
├── configs/          # Configuration files
├── deployments/      # Deployment manifests
├── policies/         # OPA/Rego policy files
├── reports/          # SonarQube and OPA validation reports
├── artifacts/        # Build and deployment artifacts
├── scripts/          # Automation scripts
└── backups/          # Timestamped backups of configuration files
```

### Users and Groups
| User | Group | Permissions |
|---|---|---|
| developer | developers | read/write |
| tester | developers | read/write |
| devopsadmin | operations | full sudo/admin |

### Execution
```bash
bash scripts/linux_setup.sh
```
This script:
- Creates all directories (configs, deployments, policies, reports, artifacts, backups)
- Creates users: `developer`, `tester`, `devopsadmin`
- Creates groups: `developers`, `operations`
- Assigns users to groups with correct permissions
- Creates config files: `deployment.yaml`, `pipeline.yaml`, `security.conf`
- Backs up configs with timestamps (`filename_YYYYMMDD_HHMMSS.bak`)
- Displays project structure via `tree`
- Creates and terminates a background process
- Shows running processes with parent-child relationships (`ps -f --forest`)
- Creates compressed archive of entire project

---

## 2. Git & GitHub Workflow

### Branching Strategy
```
main
├── development   ← CI pipeline triggers here
├── staging       ← pre-production validation
└── production    ← production deploy triggers here
```

### Five Separate Commits
1. `Linux setup` — users, groups, permissions configured
2. `Git workflow` — branching strategy and version control
3. `CI/CD configuration` — GitHub Actions workflows
4. `SonarQube integration` — quality gates and scanning
5. `OPA policies` — Rego rules for security enforcement

### Git Operations Demonstrated (`scripts/git_workflow.sh`)
| Operation | Description |
|---|---|
| `stash` | Save uncommitted changes temporarily, then pop them back |
| `cherry-pick` | Apply a specific commit from development onto production |
| `rebase` | Reapply commits on top of another branch |
| `revert` | Undo a commit while preserving history |
| `reset --soft` | Undo commits but keep changes staged |
| Merge conflict | Simulate conflict between development/staging, resolve it |
| File restore | Delete a file then recover it with `git restore` |

### Graphical Commit History
```bash
git log --oneline --graph --all --decorate
```

### Execution
```bash
bash scripts/git_workflow.sh
```

---

## 3. CI/CD Pipeline Implementation

### Development Pipeline (`ci.yml`)
**Trigger**: Push to `development` branch

| Stage | Job Name | Description |
|---|---|---|
| Source Checkout | build | `actions/checkout@v4` |
| Build | build | Compile code, create artifacts |
| Test | test | Unit + integration tests |
| Security Validation | security-opa | OPA/Conftest policy validation |
| Code Quality | sonarqube | ShellCheck + YAML lint + reports |
| Deployment | deploy | Deploy to dev environment |

### Production Pipeline (`production-deploy.yml`)
**Trigger**: Push to `production` branch
- Build → Pre-validation → Deploy → Rollback on failure

### Secrets Required
Configure in GitHub → Settings → Secrets → Actions:
- `SONAR_TOKEN` — SonarQube authentication token
- `SONAR_HOST_URL` — SonarQube server URL

### Environment Variables
- `APP_ENV`: `development` or `production`
- `KUBE_NAMESPACE`: `production`

### Artifacts
- `artifacts/build.log` — build output
- `artifacts/test.log` — test results
- `artifacts/deploy.log` — deployment log
- `reports/sonarqube/` — code quality reports
- `reports/opa/` — policy validation reports

### Rollback
```bash
bash scripts/rollback.sh <deployment-name> <namespace>
```

---

## 4. SonarQube Integration

### Configuration (`sonar-project.properties`)
- Project Key: `devops-cicd-security-platform`
- Scans: `*.yml`, `*.yaml`, `*.sh`, `*.rego`
- Excludes: `reports/`, `artifacts/`, `.github/`

### Reports Generated
| Report | File | Description |
|---|---|---|
| Shell script issues | `shellcheck-report.txt` | Bugs & code smells in .sh files |
| YAML analysis | `yaml-analysis.log` | YAML file scan results |
| Security findings | `security-findings.txt` | Vulnerabilities (hardcoded secrets) |
| Code smells | `code-smells.txt` | TODO/FIXME/HACK patterns |
| Duplicates | `duplication-report.txt` | Duplicate code detection |
| Quality gate | `quality-gate.log` | Pass/fail verdict |
| Summary | `summary.txt` | Full analysis summary |

### Quality Gate
- Fails pipeline if critical shell errors > 5
- Fails pipeline if credential patterns found > 10
- Reports saved to `reports/sonarqube/`

---

## 5. Open Policy Agent (OPA)

### Install Conftest
```bash
curl -L https://github.com/open-policy-agent/conftest/releases/download/v0.56.0/conftest_0.56.0_Linux_x86_64.tar.gz | tar xz
sudo mv conftest /usr/local/bin/
```

### Policy Files
| File | Package | Enforces |
|---|---|---|
| `policies/deployment.rego` | deployment | No empty images, no `:latest` tag, explicit versioning |
| `policies/security.rego` | security | `runAsNonRoot: true`, no UID 0 |
| `policies/container.rego` | container | `privileged: false`, `allowPrivilegeEscalation: false` |

### Validation
```bash
bash scripts/opa_validate.sh
# Reports saved to reports/opa-report.json
```

### Failure
- Deployment blocked if any policy is violated
- CI pipeline fails automatically

---

## Quick Start
```bash
# 1. Linux setup
bash scripts/linux_setup.sh

# 2. Git workflow demo
bash scripts/git_workflow.sh

# 3. OPA validation
bash scripts/opa_validate.sh
```

---

## Requirements Met
✅ Linux Administration & User Management (all 13 tasks)
✅ Git & GitHub Workflow (all 10 tasks including merge conflict, stash, cherry-pick, rebase, revert, reset, file restore, graphical history)
✅ CI/CD Pipeline - GitHub Actions (all 9 tasks)
✅ SonarQube Integration (all 7 tasks - bugs, vulnerabilities, code smells, duplicates, quality gate)
✅ Open Policy Agent / Conftest (all 7 tasks)
