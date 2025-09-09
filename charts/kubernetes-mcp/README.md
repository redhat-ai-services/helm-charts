# kubernetes-mcp

A Helm chart for deploying a Kubernetes MCP server

![Version: 0.1.2](https://img.shields.io/badge/Version-0.1.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.0.49](https://img.shields.io/badge/AppVersion-v0.0.49-informational?style=flat-square)

## Installing the Chart

To access charts from this from the cli repository add it:

```sh
helm repo add redhat-ai-services https://redhat-ai-services.github.io/helm-charts/
helm repo update redhat-ai-services
helm upgrade -i [release-name] redhat-ai-services/kubernetes-mcp
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
  - name: "kubernetes-mcp"
    version: "0.1.2"
    repository: "https://redhat-ai-services.github.io/helm-charts/"
```

## Usage

### Kubernetes Access

Your Kubernetes MCP server will create a ServiceAccount which can be granted access to various Kubernetes resources.  By default, the ServiceAccount will have the `edit` role for the `ReleaseNamespace` where the Kubernetes MCP server is running but additional permissions can be granted.

#### Cluster Admin Access

By default, the Kubernetes MCP server will not have cluster level access to any resources on the cluster.  The Kubernetes MCP server can be granted `cluster-admin` access by enabling the `cluster` roleBindings capabilities:

```sh
helm upgrade -i [release-name] redhat-ai-services/kubernetes-mcp \
  --set roleBindings.cluster.enabled="true"
```

Alternatively, you can define a different cluster level of access such as providing the `view` role:

```sh
helm upgrade -i [release-name] redhat-ai-services/kubernetes-mcp \
  --set roleBindings.cluster.enabled="true" \
  --set roleBindings.cluster.roleRef.name="view"
```

#### Additional Namespace Access

The Kubernetes MCP server can also be granted access to resources in specific namespaces outside of the ReleaseNamespace.

```sh
helm upgrade -i [release-name] redhat-ai-services/kubernetes-mcp \
  --set roleBindings.additionalNamespaces[0].namespace=my-namespace \
  --set roleBindings.additionalNamespaces[0].roleRef.apiGroup=rbac.authorization.k8s.io \
  --set roleBindings.additionalNamespaces[0].roleRef.kind=ClusterRole \
  --set roleBindings.additionalNamespaces[0].roleRef.name=edit
```

Alternatively, you can create a `values.yaml` file and provide that as part of the helm install.

values.yaml:
```yaml
roleBindings:
  additionalNamespaces:
    - namespace: my-namespace
      roleRef:
        apiGroup: rbac.authorization.k8s.io
        kind: ClusterRole
        name: edit
```

```sh
helm upgrade -i [release-name] redhat-ai-services/kubernetes-mcp \
  --values values.yaml
```

## Configuration

For a complete list of all configuration options, see the [Values](#values) section below.

## Source Code

* <https://github.com/containers/kubernetes-mcp-server>
* <https://github.com/redhat-ai-services/helm-charts/tree/main/charts/kubernetes-mcp>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Map of affinity to add to the pods |
| fullnameOverride | string | `""` | String to fully override fullname template |
| image.pullPolicy | string | `"IfNotPresent"` | The pull policy for images. |
| image.repository | string | `"quay.io/manusa/kubernetes_mcp_server"` | The vLLM model server image repository |
| image.tag | string | `""` | The tag or sha for the model server image.  By default, the chart appVersion is used. |
| imagePullSecrets | list | `[]` | The image pull secret for the image repository |
| livenessProbe.httpGet.path | string | `"/healthz"` |  |
| livenessProbe.httpGet.port | string | `"http"` |  |
| nameOverride | string | `""` | String to partially override fullname template (will maintain the release name) |
| nodeSelector | object | `{}` | Map of node selectors to add to the pods |
| podAnnotations | object | `{}` | Map of annotations to add to the pods For more information checkout: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/ |
| podLabels | object | `{}` | Map of labels to add to the pods For more information checkout: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/ |
| podSecurityContext | object | `{}` | Map of security context to add to the pods |
| readinessProbe.httpGet.path | string | `"/healthz"` |  |
| readinessProbe.httpGet.port | string | `"http"` |  |
| replicaCount | int | `1` | The number of replicas to create |
| resources | object | `{}` | Resource configuration for the container |
| roleBindings.additionalNamespaces | list | `[]` | List of additional namespaces to create role bindings Use this option to add access to namespaces beside the release namespace |
| roleBindings.cluster.enabled | bool | `false` | Specifies whether to create a role binding for the cluster |
| roleBindings.cluster.roleRef | object | `{"apiGroup":"rbac.authorization.k8s.io","kind":"ClusterRole","name":"cluster-admin"}` | The role reference for the cluster |
| roleBindings.releaseNamespace.enabled | bool | `true` | Specifies whether to create a role binding for the release namespace |
| roleBindings.releaseNamespace.roleRef | object | `{"apiGroup":"rbac.authorization.k8s.io","kind":"ClusterRole","name":"edit"}` | The role reference for the release namespace |
| securityContext | object | `{}` | Map of security context to add to the containers |
| service.port | int | `8080` | The port to expose the service on More information can be found here: https://kubernetes.io/docs/concepts/services-networking/service/#field-spec-ports |
| service.type | string | `"ClusterIP"` | Kubernetes Service type More information can be found here: https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.automount | bool | `true` | Automatically mount a ServiceAccount's API credentials? |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| tolerations | list | `[]` | List of tolerations to add to the pods |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
