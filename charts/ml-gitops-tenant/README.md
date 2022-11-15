# ml-gitops-tenant

A Helm chart to manage a multi-tiered gitops structure for a data science project.

![Version: 0.2.0](https://img.shields.io/badge/Version-0.2.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

## Resources Created

This helm chart deploys the following namespaces:

| Namespace | Description | Default Permissions |
| ----------- | ----------- | ----------- |
| my-tenant-gitops | This namespace will contain an ArgoCD instance that manages deploying resources to all of the other namespaces. | Admin |
| my-tenant-pipelines   | This namespace will host Tekton / OpenShift Pipeline resources. | Admin |
| my-tenant-datascience   | This namespace will host data science related resources used for model training. | Admin |
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
helm repo add rh-iap https://rh-intelligent-application-practice.github.io/helm-charts/
helm repo update rh-iap
helm install [release-name] rh-iap/ml-gitops-tenant
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
    version: "0.2.0"
    repository: "https://rh-intelligent-application-practice.github.io/helm-charts/"
```

## Requirements

Kubernetes: `>= 1.19.0`

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| adminGroup.create | bool | `true` | Enable the creation of the admin group.  If creation is disabled, an existing group can still be specified with the nameOverride. |
| adminGroup.members | list | `[]` | List of users to be added to the adminGroup |
| adminGroup.nameOverride | string | `""` | String to override the name of the admin group |
| datascienceNamespace.adminGroupRole | string | `"admin"` | Cluster role granting permissions admins group in the datascience namespace |
| datascienceNamespace.annotations | object | `{}` | Additional annotations to be added to the datascience namespace |
| datascienceNamespace.create | bool | `true` | Enable the creation of the data science namespace |
| datascienceNamespace.labels | object | `{}` | Additional labels to be added to the datascience namespace |
| datascienceNamespace.nameOverride | string | `""` | String to override the name of the datascience namespace |
| devNamespace.adminGroupRole | string | `"admin"` | Cluster role granting permissions admins group in the dev namespace |
| devNamespace.annotations | object | `{}` | Additional annotations to be added to the dev namespace |
| devNamespace.create | bool | `true` | Enable the creation of the dev namespace |
| devNamespace.labels | object | `{}` | Additional labels to be added to the dev namespace |
| devNamespace.nameOverride | string | `""` | String to override the name of the dev namespace |
| fullnameOverride | string | `""` | String to fully override fullname template |
| gitopsNamespace.adminGroupRole | string | `"admin"` | Cluster role granting permissions admins group in the gitops namespace |
| gitopsNamespace.annotations | object | `{}` | Additional annotations to be added to the gitops namespace |
| gitopsNamespace.create | bool | `true` | Enable the creation of the gitops namespace |
| gitopsNamespace.labels | object | `{}` | Additional labels to be added to the gitops namespace |
| gitopsNamespace.nameOverride | string | `""` | String to override the name of the gitops namespace |
| nameOverride | string | `""` | String to partially override fullname template (will maintain the release name) |
| pipelinesNamespace.adminGroupRole | string | `"admin"` | Cluster role granting permissions admins group in the pipelines namespace |
| pipelinesNamespace.annotations | object | `{}` | Additional annotations to be added to the pipelines namespace |
| pipelinesNamespace.create | bool | `true` | Enable the creation of the pipelines namespace |
| pipelinesNamespace.labels | object | `{}` | Additional labels to be added to the pipelines namespace |
| pipelinesNamespace.nameOverride | string | `""` | String to override the name of the pipelines namespace |
| prodNamespace.adminGroupRole | string | `"view"` | Cluster role granting permissions admins group in the prod namespace |
| prodNamespace.annotations | object | `{}` | Additional annotations to be added to the prod namespace |
| prodNamespace.create | bool | `true` | Enable the creation of the prod namespace |
| prodNamespace.labels | object | `{}` | Additional labels to be added to the prod namespace |
| prodNamespace.nameOverride | string | `""` | String to override the name of the prod namespace |
| testNamespace.adminGroupRole | string | `"view"` | Cluster role granting permissions admins group in the test namespace |
| testNamespace.annotations | object | `{}` | Additional annotations to be added to the test namespace |
| testNamespace.create | bool | `true` | Enable the creation of the test namespace |
| testNamespace.labels | object | `{}` | Additional labels to be added to the test namespace |
| testNamespace.nameOverride | string | `""` | String to override the name of the test namespace |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
