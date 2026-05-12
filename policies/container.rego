package container

# Rule 1: Privileged containers not allowed
deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  container.securityContext.privileged == true
  msg := sprintf("Privileged container: '%s' has privileged: true. Not allowed.", [container.name])
}

# Rule 2: privileged must be explicitly false
deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  not container.securityContext.privileged == false
  msg := sprintf("Privileged container: '%s' must explicitly set privileged: false", [container.name])
}

# Rule 3: No privilege escalation
deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  container.securityContext.allowPrivilegeEscalation == true
  msg := sprintf("Privilege escalation: '%s' has allowPrivilegeEscalation: true. Not allowed.", [container.name])
}

# Rule 4: allowPrivilegeEscalation must be explicitly false
deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  not container.securityContext.allowPrivilegeEscalation == false
  msg := sprintf("Privilege escalation: '%s' must set allowPrivilegeEscalation: false", [container.name])
}
