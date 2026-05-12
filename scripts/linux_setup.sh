#!/usr/bin/env bash
# =============================================================
# Linux Administration & User Management Setup Script
# Covers all 13 tasks from Section 1 requirements
# =============================================================
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$PROJECT_DIR/backups"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

echo "======================================="
echo " Linux Administration Setup"
echo "======================================="

# ----- TASK 1-2: Create project directory and subdirectories -----
echo "[Task 1-2] Creating project directory structure..."
mkdir -p "$PROJECT_DIR"/{configs,deployments,policies,reports,artifacts,backups}
echo "  Created: configs/ deployments/ policies/ reports/ artifacts/ backups/"

# ----- TASK 3: Create three users -----
echo ""
echo "[Task 3] Creating users: developer, tester, devopsadmin..."
for u in developer tester devopsadmin; do
  if ! id "$u" >/dev/null 2>&1; then
    sudo useradd -m "$u"
    echo "  Created user: $u"
  else
    echo "  User already exists: $u"
  fi
done

# ----- TASK 4: Create two groups -----
echo ""
echo "[Task 4] Creating groups: developers, operations..."
sudo groupadd -f developers
sudo groupadd -f operations
echo "  Created groups: developers, operations"

# ----- TASK 5: Add users to groups -----
echo ""
echo "[Task 5] Adding users to groups..."
sudo usermod -aG developers developer
sudo usermod -aG developers tester
sudo usermod -aG operations devopsadmin
echo "  developer  -> developers"
echo "  tester     -> developers"
echo "  devopsadmin -> operations"

# ----- TASK 6: Assign permissions -----
echo ""
echo "[Task 6] Assigning permissions..."
sudo chown -R :developers "$PROJECT_DIR"
sudo chmod -R g+rw "$PROJECT_DIR"
sudo usermod -aG sudo devopsadmin
echo "  developers group: read/write on $PROJECT_DIR"
echo "  devopsadmin: full sudo/admin permissions"

# ----- TASK 7: Create configuration files -----
echo ""
echo "[Task 7] Creating configuration files..."

cat > "$PROJECT_DIR/configs/deployment.yaml" <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: sample-app
  template:
    metadata:
      labels:
        app: sample-app
    spec:
      containers:
        - name: sample-app
          image: nginx:1.27.1
          ports:
            - containerPort: 80
          securityContext:
            runAsNonRoot: true
            allowPrivilegeEscalation: false
            privileged: false
      securityContext:
        runAsNonRoot: true
YAML

cat > "$PROJECT_DIR/configs/pipeline.yaml" <<'YAML'
pipeline:
  stages:
    - checkout
    - build
    - test
    - security
    - deploy
YAML

cat > "$PROJECT_DIR/configs/security.conf" <<'CONF'
ENFORCE_NON_ROOT=true
ALLOW_PRIVILEGED=false
REQUIRE_IMAGE_TAG=true
FAIL_ON_POLICY_VIOLATION=true
CONF

echo "  Created: configs/deployment.yaml"
echo "  Created: configs/pipeline.yaml"
echo "  Created: configs/security.conf"

# ----- TASK 8-9: Backup configs with timestamps -----
echo ""
echo "[Task 8-9] Backing up config files with timestamps..."
mkdir -p "$BACKUP_DIR"
for f in "$PROJECT_DIR/configs"/*; do
  base="$(basename "$f")"
  dest="$BACKUP_DIR/${base%.*}_${TIMESTAMP}.bak"
  cp "$f" "$dest"
  echo "  Backed up: $base -> $(basename $dest)"
done

# ----- TASK 10: Display complete project structure -----
echo ""
echo "[Task 10] Complete project structure:"
echo "--------------------------------------"
if command -v tree >/dev/null 2>&1; then
  tree "$PROJECT_DIR" -a --dirsfirst
else
  find "$PROJECT_DIR" -not -path '*/.git/*' | sort | sed -e 's/[^-][^\/]*\// /g' -e 's/ \([^ ]\)/└─ \1/'
fi

# ----- TASK 11: Create background process and terminate -----
echo ""
echo "[Task 11] Background process demo..."
sleep 300 &
BG_PID=$!
echo "  Started background process: sleep 300 (PID=$BG_PID)"
kill "$BG_PID" 2>/dev/null && echo "  Terminated PID $BG_PID successfully"

# ----- TASK 12: Display running processes + parent-child -----
echo ""
echo "[Task 12] Running processes (with parent-child relationships):"
echo "--------------------------------------------------------------"
ps -f --forest 2>/dev/null || ps -ef

# ----- TASK 13: Compressed archive of project directory -----
echo ""
echo "[Task 13] Creating compressed archive..."
ARCHIVE="$PROJECT_DIR/../company-devops-platform_${TIMESTAMP}.tar.gz"
tar -czf "$ARCHIVE" -C "$(dirname $PROJECT_DIR)" "$(basename $PROJECT_DIR)"
echo "  Archive created: company-devops-platform_${TIMESTAMP}.tar.gz"
echo "  Size: $(du -sh $ARCHIVE | cut -f1)"

echo ""
echo "======================================="
echo " Linux setup complete!"
echo "======================================="
