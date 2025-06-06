# argocd

A Helm chart for Kubernetes

![Version: 0.4.3](https://img.shields.io/badge/Version-0.4.3-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

## Installing the Chart

To access charts from this from the cli repository add it:

```sh
helm repo add redhat-ai-services https://redhat-ai-services.github.io/helm-charts/
helm repo update redhat-ai-services
helm upgrade -i [release-name] redhat-ai-services/argocd
```

To include a chart from this repository in an umbrella chart, include it in your dependencies in your `Chart.yaml` file.

```yaml
apiVersion: v2
name: example-chart
description: A Helm chart for Kubernetes
type: application

version: 0.1.0

appVersion: "1.16.0"

dependencies:
  - name: "argocd"
    version: "0.4.3"
    repository: "https://redhat-ai-services.github.io/helm-charts/"
```

## Requirements

Kubernetes: `>= 1.19.0`

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| applicationSet.resources | object | `{"limits":{"cpu":"2","memory":"1Gi"},"requests":{"cpu":"250m","memory":"512Mi"}}` | Resource requests and limits for the applicationSet pod |
| controller.resources | object | `{"limits":{"cpu":"2000m","memory":"2048Mi"},"requests":{"cpu":"250m","memory":"1024Mi"}}` | Resource requests and limits for the controller pod |
| extraConfig | object | `{}` | Extra config options |
| fullnameOverride | string | `""` | String to fully override fullname template |
| grafana.enabled | bool | `false` | Enable grafana instance |
| grafana.ingress.enabled | bool | `false` | Enable access via ingress |
| grafana.route.enabled | bool | `false` | Enable access via OpenShift route |
| ha.enabled | bool | `false` |  |
| ha.resources | object | `{"limits":{"cpu":"500m","memory":"256Mi"},"requests":{"cpu":"250m","memory":"128Mi"}}` | Resource requests and limits |
| nameOverride | string | `""` | String to partially override fullname template (will maintain the release name) |
| notifications.enabled | bool | `true` | Enable notifications plugin |
| pipelineAccounts | string | `nil` | Create pipeline accounts and generate a token in the designated namespace |
| projects | array/object | `[{"clusterResourceWhitelist":[],"description":"","destinations":[],"name":"default","sourceRepos":[]}]` | An array of projects objects to be configured within ArgoCD |
| prometheus.enabled | bool | `false` | Enable prometheus instance |
| prometheus.ingress.enabled | bool | `false` | Enable access via ingress |
| prometheus.route.enabled | bool | `false` | Enable access via OpenShift route |
| rbac.policy | string | `"g, system:cluster-admins, role:admin"` | RBAC mapping for roles within ArgoCD |
| rbac.scopes | string | `"[groups]"` | RBAC objects that can be utilized within the policy mapping |
| redis.resources | object | `{"limits":{"cpu":"500m","memory":"256Mi"},"requests":{"cpu":"250m","memory":"128Mi"}}` | Resource requests and limits for the redis pods |
| repo.resources | object | `{"limits":{"cpu":"1","memory":"1Gi"},"requests":{"cpu":"250m","memory":"256Mi"}}` | Resource requests and limits for the repo pod |
| repos | array/object | `[]` | An array of repos objects to be configured within ArgoCD |
| resourceCustomizations | object | `{"machinelearning.seldon.io/SeldonDeployment":{"health.lua":"health_status = {}\nif obj.status ~= nil then\n  if obj.status.conditions ~= nil then\n    numConditions = 0\n    numTrue = 0\n    numFalse = 0\n    message = \"\"\n    for _, condition in pairs(obj.status.conditions) do\n      numConditions = numConditions + 1\n      if condition.status == \"False\" then\n        numFalse = numFalse + 1\n        message = message .. \" \" .. condition.type .. \": \" .. condition.reason .. \";\"\n      elseif condition.status == \"True\" then\n        numTrue = numTrue + 1\n      end\n    end\n    if numTrue == numConditions then\n      health_status.status = \"Healthy\"\n      health_status.message = \"SeldonDeployment is healthy\"\n      return health_status\n    else numFalse > 0 then\n      health_status.status = \"Progressing\"\n      health_status.message = message\n      return health_status\n    end\n  end\nend\n\nhealth_status.status = \"Progressing\"\nhealth_status.message = \"Waiting for SeldonDeployment\"\nreturn health_status\n"}}` | Resource customizations for ArgoCD instance resourceCustomizations: {} |
| resourceExclusions | list | `[{"apiGroups":["tekton.dev"],"clusters":["*"],"kinds":["TaskRun","PipelineRun"]}]` | Resource exclusion list for ArgoCD instance |
| server.autoscale.enabled | bool | `false` | Enable autoscaling for server pod |
| server.grpc.ingress.enabled | bool | `false` | Enable grpc ingress option |
| server.ingress.enabled | bool | `false` | Enable access via ingress |
| server.resources | object | `{"limits":{"cpu":"500m","memory":"256Mi"},"requests":{"cpu":"125m","memory":"128Mi"}}` | Resource requests and limits for the server pod |
| server.route.enabled | bool | `true` | Enable access via OpenShift route |
| server.route.tls.insecureEdgeTerminationPolicy | string | `"Redirect"` | Insecure policy behavior for accessing ArgoCD Route |
| server.route.tls.termination | string | `"reencrypt"` | TLS cert termination policy for accessing ArgoCD Route |
| server.service.type | string | `""` |  |
| sso.dex.openShiftOAuth | bool | `true` | Enable login via OpenShiftOAuth |
| sso.dex.resources | object | `{"limits":{"cpu":"500m","memory":"256Mi"},"requests":{"cpu":"250m","memory":"128Mi"}}` | Resource requests and limits for the dex pod |
| sso.provider | string | `"dex"` | SSO provider |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
