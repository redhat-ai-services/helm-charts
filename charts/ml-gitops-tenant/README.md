# ml-gitops-tenant

A Helm chart to manage a multi-tiered gitops structure for a data science project.

![Version: 0.3.5](https://img.shields.io/badge/Version-0.3.5-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

## Resources Created

This helm chart deploys the following namespaces:

| Namespace | Description | Default Permissions |
| ----------- | ----------- | ----------- |
| my-tenant-gitops | This namespace will contain an ArgoCD instance that manages deploying resources to all of the other namespaces. | Admin |
| my-tenant-pipelines   | This namespace will host Tekton / OpenShift Pipeline resources. | Admin |
| my-tenant-datascience   | This namespace will host data science related resources used for model training, such as Jupyter notebooks, distributed training resources, model registries, etc. | Admin |
| my-tenant-dev   | This namespace is the development namespace used for application components. | Admin |
| my-tenant-test   | This namespace is the test namespace used for application components. | View |
| my-tenant-prod   | This namespace is the production namespace used for application components. | View |

This helm chart will create the following group to grant permissions to the various namespaces:

| Group |
| ----- |
| my-tenant-admins |

## Installing the Chart

To access charts from this from the cli repository add it:

```sh
helm repo add redhat-ai-services https://redhat-ai-services.github.io/helm-charts/
helm repo update redhat-ai-services
helm upgrade -i [release-name] redhat-ai-services/ml-gitops-tenant
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
  - name: "ml-gitops-tenant"
    version: "0.3.5"
    repository: "https://redhat-ai-services.github.io/helm-charts/"
```

## Requirements

Kubernetes: `>= 1.19.0`

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalRoles | list | `[{"name":"sealed-secrets-deployer","rules":[{"apiGroups":["bitnami.com"],"resources":["sealedsecrets"],"verbs":["get","list","watch","create","update","patch","delete"]}],"subject":{"name":"argocd-argocd-application-controller"}}]` | Additional roles to apply to the application controller service account in all namespaces managed by ArgoCD |
| adminGroup.create | bool | `true` | Enable the creation of the admin group.  If creation is disabled, an existing group can still be specified with the nameOverride. |
| adminGroup.members | list | `[]` | List of users to be added to the adminGroup |
| adminGroup.nameOverride | string | `""` | String to override the name of the admin group |
| fullnameOverride | string | `""` | String to fully override fullname template |
| nameOverride | string | `""` | String to partially override fullname template (will maintain the release name) |
| namespaces[0].adminGroupRole | string | `"admin"` |  |
| namespaces[0].annotations | object | `{}` |  |
| namespaces[0].labels | object | `{}` |  |
| namespaces[0].nameOverride | string | `""` |  |
| namespaces[0].nameSuffix | string | `"gitops"` |  |
| namespaces[0].role | string | `"gitops"` |  |
| namespaces[1].adminGroupRole | string | `"admin"` |  |
| namespaces[1].annotations."operator.tekton.dev/prune.keep-since" | string | `"7200"` |  |
| namespaces[1].annotations."operator.tekton.dev/prune.resources" | string | `"taskrun, pipelinerun"` |  |
| namespaces[1].labels | object | `{}` |  |
| namespaces[1].nameOverride | string | `""` |  |
| namespaces[1].nameSuffix | string | `"pipelines"` |  |
| namespaces[1].role | string | `"pipelines"` |  |
| namespaces[2].adminGroupRole | string | `"admin"` |  |
| namespaces[2].annotations | object | `{}` |  |
| namespaces[2].labels | object | `{}` |  |
| namespaces[2].nameOverride | string | `""` |  |
| namespaces[2].nameSuffix | string | `"datascience"` |  |
| namespaces[2].role | string | `"dev"` |  |
| namespaces[3].adminGroupRole | string | `"admin"` |  |
| namespaces[3].annotations | object | `{}` |  |
| namespaces[3].labels | object | `{}` |  |
| namespaces[3].nameOverride | string | `""` |  |
| namespaces[3].nameSuffix | string | `"dev"` |  |
| namespaces[3].role | string | `"dev"` |  |
| namespaces[4].adminGroupRole | string | `"view"` |  |
| namespaces[4].annotations | object | `{}` |  |
| namespaces[4].labels | object | `{}` |  |
| namespaces[4].nameOverride | string | `""` |  |
| namespaces[4].nameSuffix | string | `"test"` |  |
| namespaces[4].role | string | `"test"` |  |
| namespaces[5].adminGroupRole | string | `"view"` |  |
| namespaces[5].annotations | object | `{}` |  |
| namespaces[5].labels | object | `{}` |  |
| namespaces[5].nameOverride | string | `""` |  |
| namespaces[5].nameSuffix | string | `"prod"` |  |
| namespaces[5].role | string | `"prod"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
