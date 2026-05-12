package security

# Rule 1: Pod must run as non-root
deny[msg] {
  input.kind == "Deployment"
  pod_ctx := input.spec.template.spec.securityContext
  pod_ctx.runAsNonRoot != true
  msg := "Root user prevention (Pod): securityContext.runAsNonRoot must be true"
}

# Rule 2: Container must run as non-root
deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  container.securityContext.runAsNonRoot != true
  msg := sprintf("Root user prevention (Container): '%s' must have runAsNonRoot: true", [container.name])
}

# Rule 3: Pod must not run as UID 0
deny[msg] {
  input.kind == "Deployment"
  input.spec.template.spec.securityContext.runAsUser == 0
  msg := "Root user prevention: Pod cannot run as UID 0 (root)"
}

# Rule 4: Container must not run as UID 0
deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  container.securityContext.runAsUser == 0
  msg := sprintf("Root user prevention: Container '%s' cannot run as UID 0", [container.name])
}
