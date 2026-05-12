#!/usr/bin/env bash
# OPA/Conftest Policy Validation Script
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPORT_DIR="$PROJECT_DIR/reports"
POLICY_DIR="$PROJECT_DIR/policies"
DEPLOYMENT_FILE="$PROJECT_DIR/deployments/deployment.yaml"

mkdir -p "$REPORT_DIR/opa"

echo "======================================="
echo " OPA Policy Validation"
echo "======================================="

if ! command -v conftest >/dev/null 2>&1; then
  echo "ERROR: Conftest not found. Install:"
  echo "  curl -L https://github.com/open-policy-agent/conftest/releases/download/v0.56.0/conftest_0.56.0_Linux_x86_64.tar.gz | tar xz"
  echo "  sudo mv conftest /usr/local/bin/"
  exit 1
fi

echo "Validating: $DEPLOYMENT_FILE"
echo ""

# Run all policies together
echo "[1/4] Running all policies combined..."
set +e
conftest test "$DEPLOYMENT_FILE" -p "$POLICY_DIR" -o json > "$REPORT_DIR/opa/opa-full-report.json" 2>&1
FULL_STATUS=$?
set -e

# Run individual policy reports
echo "[2/4] Deployment policy validation..."
conftest test "$DEPLOYMENT_FILE" -p "$POLICY_DIR/deployment.rego" -o json > "$REPORT_DIR/opa/deployment-report.json" 2>&1 || true

echo "[3/4] Security policy validation..."
conftest test "$DEPLOYMENT_FILE" -p "$POLICY_DIR/security.rego" -o json > "$REPORT_DIR/opa/security-report.json" 2>&1 || true

echo "[4/4] Container policy validation..."
conftest test "$DEPLOYMENT_FILE" -p "$POLICY_DIR/container.rego" -o json > "$REPORT_DIR/opa/container-report.json" 2>&1 || true

echo ""
echo "Reports saved to: $REPORT_DIR/opa/"
ls -la "$REPORT_DIR/opa/"

if [ $FULL_STATUS -ne 0 ]; then
  echo ""
  echo "POLICY VIOLATIONS DETECTED - Deployment blocked!"
  cat "$REPORT_DIR/opa/opa-full-report.json"
  exit 1
fi

echo ""
echo "All policies PASSED - Deployment allowed."
