# phoenix

A Helm chart for deploying Phoenix on OpenShift

![Version: 0.1.1](https://img.shields.io/badge/Version-0.1.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: version-4.20.2](https://img.shields.io/badge/AppVersion-version--4.20.2-informational?style=flat-square)

## Installing the Chart

To access charts from this from the cli repository add it:

```sh
helm repo add redhat-ai-services https://redhat-ai-services.github.io/helm-charts/
helm repo update redhat-ai-services
helm upgrade -i [release-name] redhat-ai-services/phoenix
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
  - name: "phoenix"
    version: "0.1.1"
    repository: "https://redhat-ai-services.github.io/helm-charts/"
```

## Source Code

* <https://github.com/redhat-ai-services/helm-charts/tree/main/charts/phoenix>
* <https://github.com/Arize-ai/phoenix>

## Usage

### Setting the Phoenix URL for your application

By default when doing trace collection, Phoenix attempts to log metrics to a phoenix instance running on `localhost:6006`.  When deplying a Phoenix server you must tell your application the host URL for that server.  You can configure that by setting the `PHOENIX_HOST` environment variable if your application is running in OpenShift:

```
import os
os.environ["PHOENIX_HOST"] = "release-name.my-namespace.svc.cluster.local"
```

Or by setting `PHOENIX_COLLECTOR_ENDPOINT`:

```
import os
os.environ["PHOENIX_COLLECTOR_ENDPOINT"] = "http://release-name.my-namespace.svc.cluster.local:6006"
```

With `PHOENIX_HOST`, the Phoenix client will use the default port 6006 and construct the `PHOENIX_COLLECTOR_ENDPOINT` for you.

For more information see the official configuration documentation:

https://docs.arize.com/phoenix/setup/configuration

> [!WARNING]
>
> By default, this helm chart disables the ability to authenticate via bearer token.  To enable this feature, you can install phoenix with the following option:
>
> ```
> helm upgrade -i [release-name] redhat-ai-services/phoenix \
>     --set openshiftOauth.enableBearerTokenAccess=True
> ```
>
> This option requires cluster admin privileges.
>
> At this point in time, the phoenix instrumentation does not appear to support authenticating via bearer token.  It is recommended that you run Phoenix on the same cluster as your application to allow them to communicate using the service port.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity configuration for the application |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| fullnameOverride | string | `""` | String to fully override fullname template |
| image.pullPolicy | string | `"IfNotPresent"` | The image pull policy |
| image.repository | string | `"arizephoenix/phoenix"` | The image repository to use |
| image.tag | string | Chart appVersion | The image tag to use |
| imagePullSecrets | list | `[]` | The image pull secret for the image repository |
| ingress.annotations | object | `{}` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"chart-example.local"` |  |
| ingress.hosts[0].paths | list | `[]` |  |
| ingress.tls | list | `[]` |  |
| livenessProbe.httpGet.path | string | `"/"` |  |
| livenessProbe.httpGet.port | string | `"http"` |  |
| nameOverride | string | `""` | String to partially override fullname template (will maintain the release name) |
| nodeSelector | object | `{}` | Node selector for the application |
| openai.key | object | `{}` |  |
| openshiftOauth.enableBearerTokenAccess | bool | `false` | Enable access to the application using an OpenShift Bearer Token.  This feature enables users from outside of the cluster to read/write to the API. Warning: This feature requires cluster admin to install. |
| openshiftOauth.enabled | bool | `true` | Secures the application with OpenShift Oauth Proxy.  If disabling this option it is recommended to set `route.tls.termination: edge`. |
| openshiftOauth.image.pullPolicy | string | `"IfNotPresent"` | The docker image pull policy |
| openshiftOauth.image.repository | string | `"registry.redhat.io/openshift4/ose-oauth-proxy"` | The image repository to use |
| openshiftOauth.image.tag | string | Chart appVersion | The image tag to use |
| openshiftOauth.resources | object | `{}` |  |
| persistence.pvc.volumeSize | string | `"8Gi"` | The volume size when utilizing the pvc storage option |
| persistence.type | string | `"pvc"` | Configures the type of persistence that should be used. Supported options include `pvc`, `postgres`, and `crunchy-postgres` |
| podAnnotations | object | `{"prometheus.io/path":"/metrics","prometheus.io/port":"9090","prometheus.io/scrape":"true"}` | Map of annotations to add to the pods |
| podLabels | object | `{}` | Map of labels to add to the pods |
| podSecurityContext | object | `{}` | Map of securityContexts to add to the pod |
| readinessProbe.httpGet.path | string | `"/"` |  |
| readinessProbe.httpGet.port | string | `"http"` |  |
| replicaCount | int | `1` | Number of replicas |
| resources | object | `{}` | Resource configuration for the application server |
| route.annotations | object | `{}` | Additional custom annotations for the route |
| route.enabled | bool | `true` | Enable creation of the OpenShift Route object |
| route.host | string | Set by OpenShift | The hostname for the route |
| route.path | string | `""` | The path for the OpenShift route |
| route.tls.enabled | bool | `true` | Enable secure route settings |
| route.tls.insecureEdgeTerminationPolicy | string | `"Redirect"` | Insecure route termination policy |
| route.tls.termination | string | `"reencrypt"` | Secure route termination policy |
| securityContext | object | `{}` | Map of securityContexts to add to the container |
| service.port | int | `6006` | The http port for the application |
| service.type | string | `"ClusterIP"` | Kubernetes Service type |
| serviceAccount.annotations | object | `{}` | Additional custom annotations for the ServiceAccount |
| serviceAccount.create | bool | `true` | Enable creation of a ServiceAccount |
| serviceAccount.name | string | fullname template | The name of the ServiceAccount to use. |
| tolerations | list | `[]` | Tolerations for the application |
| volumeClaimTemplates.requests.storage | string | `"8Gi"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
