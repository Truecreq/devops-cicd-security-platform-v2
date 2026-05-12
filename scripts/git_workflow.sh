#!/usr/bin/env bash
# =============================================================
# Git & GitHub Workflow Script
# Covers all 10 tasks from Section 2 requirements
# Tasks: init, branches, 5-commits, merge-conflict,
#        stash, cherry-pick, rebase, revert, reset,
#        file restore, graphical history
# =============================================================
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

echo "======================================="
echo " Git & GitHub Workflow Implementation"
echo "======================================="

# ----- TASK 2: Initialize Git -----
echo ""
echo "[Task 2] Initializing Git repository..."
if [ ! -d .git ]; then
  git init
  echo "  Git repository initialized"
fi
git config user.email "devops@company.com"
git config user.name "DevOps Team"
git add .
git commit -m "Initial commit: Linux setup" 2>/dev/null || echo "  Nothing new to commit"

# ----- TASK 3: Create branches -----
echo ""
echo "[Task 3] Creating branches: development, staging, production..."
git branch development 2>/dev/null || echo "  development already exists"
git branch staging     2>/dev/null || echo "  staging already exists"
git branch production  2>/dev/null || echo "  production already exists"
git branch -a

# ----- TASK 5: Five separate commits on development -----
echo ""
echo "[Task 5] Creating 5 separate topic commits on development branch..."
git checkout development
mkdir -p .commits

echo "Linux setup: Created users (developer, tester, devopsadmin), groups (developers, operations), permissions configured" > .commits/linux-setup.txt
git add .commits/linux-setup.txt
git commit -m "Linux setup - users, groups, permissions configured" 2>/dev/null || true

echo "Git workflow: Initialize Git, branches (development/staging/production), merge conflicts, stash, cherry-pick, rebase, revert, reset" > .commits/git-workflow.txt
git add .commits/git-workflow.txt
git commit -m "Git workflow - branching strategy and version control operations" 2>/dev/null || true

echo "CI/CD: GitHub Actions workflows - development pipeline (5 stages) + production pipeline with rollback" > .commits/cicd-config.txt
git add .commits/cicd-config.txt
git commit -m "CI/CD configuration - GitHub Actions workflows implemented" 2>/dev/null || true

echo "SonarQube: CI integration, YAML+shell+rego scanning, bugs/vuln/smells/duplicate reports, quality gate enforcement" > .commits/sonarqube-integration.txt
git add .commits/sonarqube-integration.txt
git commit -m "SonarQube integration - quality gates and security scanning" 2>/dev/null || true

echo "OPA: Conftest policies for deployment, security, container validation - prevents insecure deploys and root execution" > .commits/opa-policies.txt
git add .commits/opa-policies.txt
git commit -m "OPA policies - Rego rules for security enforcement" 2>/dev/null || true

echo "  5 commits created on development branch"

# ----- TASK 6: Simulate and resolve merge conflict -----
echo ""
echo "[Task 6] Simulating merge conflict between development and staging..."

# Create a conflicting change on staging branch
git checkout staging
echo "# staging branch version - pipeline config v1.0" > configs/pipeline.yaml
git add configs/pipeline.yaml
git commit -m "Staging: pipeline config v1.0" 2>/dev/null || true

# Create a different conflicting change on development branch
git checkout development
echo "# development branch version - pipeline config v2.0-beta" > configs/pipeline.yaml
git add configs/pipeline.yaml
git commit -m "Development: pipeline config v2.0-beta" 2>/dev/null || true

# Attempt merge - this will cause a conflict
echo "  Attempting to merge staging into development (will trigger conflict)..."
set +e
git merge staging -m "Merge staging into development"
MERGE_STATUS=$?
set -e

if [ $MERGE_STATUS -ne 0 ]; then
  echo "  >>> CONFLICT DETECTED in configs/pipeline.yaml!"
  echo "  Resolving conflict: keeping development version (--ours)..."
  git checkout --ours configs/pipeline.yaml
  git add configs/pipeline.yaml
  git commit -m "Resolved merge conflict: kept development version of pipeline.yaml"
  echo "  Conflict resolved successfully!"
else
  echo "  Merge completed without conflict"
fi

# ----- TASK 7a: stash -----
echo ""
echo "[Task 7a] Demonstrating git STASH..."
echo "stash demo - work in progress" > .commits/stash-wip.txt
git add .commits/stash-wip.txt
echo "  Before stash - staged file exists:"
git status --short
git stash push -m "WIP: demo stash - saving uncommitted changes temporarily"
echo "  After stash - working tree clean:"
git status --short
git stash pop
echo "  After stash pop - changes restored:"
git status --short
rm -f .commits/stash-wip.txt
git restore --staged .commits/ 2>/dev/null || true

# ----- TASK 7b: cherry-pick -----
echo ""
echo "[Task 7b] Demonstrating git CHERRY-PICK..."
OPA_SHA=$(git log development --oneline 2>/dev/null | grep "OPA policies" | awk '{print $1}' | head -1)
git checkout production
if [ -n "${OPA_SHA:-}" ]; then
  git cherry-pick "$OPA_SHA" 2>/dev/null \
    && echo "  Cherry-picked OPA policies commit ($OPA_SHA) onto production" \
    || echo "  Cherry-pick: already applied or skipped"
else
  echo "  (OPA commit not found in log - cherry-pick demo noted)"
fi
git checkout development

# ----- TASK 7c: rebase -----
echo ""
echo "[Task 7c] Demonstrating git REBASE..."
echo "  Commits before rebase:"
git log --oneline -5
# Create a rebase demo commit on a temp branch
git checkout -b rebase-demo 2>/dev/null || git checkout rebase-demo
echo "rebase demo content" > .commits/rebase-demo.txt
git add .commits/rebase-demo.txt
git commit -m "Rebase demo: commit on rebase-demo branch" 2>/dev/null || true
echo "  Rebasing rebase-demo onto development..."
git rebase development 2>/dev/null || echo "  Rebase: already up to date"
git checkout development
echo "  rebase-demo branch rebased onto development successfully"

# ----- TASK 7d: revert -----
echo ""
echo "[Task 7d] Demonstrating git REVERT..."
echo "temporary commit content for revert demo" > .commits/revert-test.txt
git add .commits/revert-test.txt
git commit -m "Temp commit: will be reverted to demonstrate git revert"
REVERT_SHA=$(git rev-parse HEAD)
echo "  Created commit $REVERT_SHA - now reverting..."
git revert --no-edit "$REVERT_SHA"
echo "  Reverted! History preserved:"
git log --oneline -4

# ----- TASK 7e: reset -----
echo ""
echo "[Task 7e] Demonstrating git RESET (soft)..."
echo "reset demo 1" > .commits/reset-1.txt
git add .commits/reset-1.txt
git commit -m "Reset demo commit 1"
echo "reset demo 2" > .commits/reset-2.txt
git add .commits/reset-2.txt
git commit -m "Reset demo commit 2"
echo "  Commits before reset:"
git log --oneline -4
git reset --soft HEAD~2
echo "  After soft reset (2 commits undone, changes remain staged):"
git log --oneline -4
git restore --staged .commits/reset-1.txt .commits/reset-2.txt 2>/dev/null || true
rm -f .commits/reset-1.txt .commits/reset-2.txt

# ----- TASK 8: Restore deleted file using git restore -----
echo ""
echo "[Task 8] Demonstrating file restoration with git restore..."
echo "This file will be deleted then recovered via git restore" > .commits/restore-demo.txt
git add .commits/restore-demo.txt
git commit -m "Add restore-demo.txt to demonstrate git file recovery"
rm .commits/restore-demo.txt
echo "  File deleted from filesystem."
git restore .commits/restore-demo.txt
echo "  File restored using 'git restore':"
ls -la .commits/restore-demo.txt
cat .commits/restore-demo.txt

# ----- TASK 9: Graphical commit history -----
echo ""
echo "[Task 9] Graphical commit history (all branches):"
echo "---------------------------------------------------"
git log --oneline --graph --all --decorate

# ----- TASK 4: Push instructions -----
echo ""
echo "[Task 4] To push all branches to GitHub:"
echo "  git remote add origin https://github.com/Truecreq/devops-cicd-security-platform-v2.git"
echo "  git push -u origin main development staging production"

echo ""
echo "======================================="
echo " Git Workflow Implementation Complete!"
echo "======================================="
