package deployment

# Rule 1: Prevent insecure deployments - image must be specified
deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  container.image == ""
  msg := "Insecure deployment: Container image must be specified (empty image not allowed)"
}

# Rule 2: Enforce image version tagging - disallow :latest tag
deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  image := container.image
  endswith(image, ":latest")
  msg := sprintf("Image version tagging: Image '%s' uses :latest tag. Use specific version tags (e.g., :1.0.0)", [image])
}

# Rule 3: Image must have an explicit tag
deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  image := container.image
  not contains(image, ":")
  msg := sprintf("Image version tagging: Image '%s' must have an explicit version tag.", [image])
}

# Rule 4: Replicas must be at least 1
deny[msg] {
  input.kind == "Deployment"
  input.spec.replicas < 1
  msg := "Insecure deployment: Replicas must be at least 1"
}
