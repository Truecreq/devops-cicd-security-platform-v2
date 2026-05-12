#!/usr/bin/env bash
# Deployment Rollback Script
set -euo pipefail

DEPLOYMENT_NAME="${1:-sample-app}"
NAMESPACE="${2:-default}"

echo "======================================="
echo " Deployment Rollback"
echo "======================================="
echo "Deployment : $DEPLOYMENT_NAME"
echo "Namespace  : $NAMESPACE"
echo "Time       : $(date)"
echo ""

echo "Executing: kubectl rollout undo deployment/$DEPLOYMENT_NAME -n $NAMESPACE"
kubectl rollout undo deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE"

echo ""
echo "Rollback executed for $DEPLOYMENT_NAME in namespace $NAMESPACE"
echo "Verifying rollout status..."
kubectl rollout status deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE"
