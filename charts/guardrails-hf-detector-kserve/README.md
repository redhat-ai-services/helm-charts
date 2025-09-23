# guardrails-hf-detector-kserve

A Helm chart deploying guardrails-huggingface-detector with KServe on OpenShift AI

![Version: 0.1.2](https://img.shields.io/badge/Version-0.1.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: rhoai-2.23-82e4a518ac3d144a5312205eede5674cf6a5888e](https://img.shields.io/badge/AppVersion-rhoai--2.23--82e4a518ac3d144a5312205eede5674cf6a5888e-informational?style=flat-square)

## Installing the Chart

To access charts from this from the cli repository add it:

```sh
helm repo add redhat-ai-services https://redhat-ai-services.github.io/helm-charts/
helm repo update redhat-ai-services
helm upgrade -i [release-name] redhat-ai-services/guardrails-hf-detector-kserve
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
  - name: "guardrails-hf-detector-kserve"
    version: "0.1.2"
    repository: "https://redhat-ai-services.github.io/helm-charts/"
```

## Usage

Todo

## Configuration

For a complete list of all configuration options, see the [Values](#values) section below.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| deploymentMode | string | `"RawDeployment"` | deploymentMode determines if the model will be deployed using KNative Serverless or a standard k8s Deployment.  Must be one of Serverless or RawDeployment |
| endpoint.auth.enabled | bool | `false` | Secures the model endpoint and creates a role to grant permissions to service accounts |
| endpoint.auth.serviceAccounts | list | `[]` | Creates service accounts with permissions to access the secured endpoint |
| endpoint.externalRoute.enabled | bool | `true` | Creates an externally accessible route for the model endpoint |
| fullnameOverride | string | `""` | String to fully override fullname template |
| image.image | string | `"quay.io/modh/odh-trustyai-hf-detector-runtime-rhel9"` | The guardrails-huggingface-detector model server image |
| image.runtimeVersionOverride | string | `""` | The guardrails-huggingface-detector version that will be displayed in the RHOAI Dashboard.  If not set, the appVersion of the chart will be used. |
| image.tag | string | `""` | The tag or sha for the model server image |
| imagePullSecrets | list | `[]` | This is for the secretes for pulling an image from a private repository more information can be found here: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/ |
| inferenceService.name | string | `""` | Overwrite the default name for the InferenceService. |
| model.args | list | `[]` | Additional guardrails-huggingface-detector arguments to be used to start the model. |
| model.env | list | `[]` | Additional guardrails-huggingface-detector environment variables to be used to start the model. |
| model.mode | string | `"uri"` | Option to set how the storage will be configured.  Options: "uri" and "s3" |
| model.s3.key | string | `""` | The secret containing s3 credentials.  Mode must be set to "s3" to use this option. |
| model.s3.path | string | `""` | The containing the model in the s3 bucket.  Mode must be set to "s3" to use this option. |
| model.uri | string | `"oci://quay.io/redhat-ai-services/modelcar-catalog:granite-guardian-hap-38m"` | The Uri to use for storage.  Mode must be set to "uri" to use this option.  Options: "oci://" and "pvc://" |
| nameOverride | string | `""` | String to partially override fullname template (will maintain the release name) |
| nodeSelector | object | `{}` | Node selector for the guardrails-huggingface-detector pod |
| resources | object | `{"limits":{"cpu":"2","memory":"8Gi","nvidia.com/gpu":"1"},"requests":{"cpu":"1","memory":"4Gi","nvidia.com/gpu":"1"}}` | Resource configuration for the guardrails-huggingface-detector container |
| scaling.maxReplicas | int | `1` | The maximum number of replicas to be deployed |
| scaling.minReplicas | int | `1` | The minimum number of replicas to be deployed.  Set to 0 to enable scale to zero capabilities with Serverless deployments. |
| scaling.rawDeployment.deploymentStrategy | object | `{"type":"RollingUpdate"}` | The deployment strategy to use to replace existing pods with new ones. |
| scaling.scaleMetric | string | `""` | The scaling metric used by KServe to trigger scaling a new pod.  Serverless deployments can be "concurrency", "rps", "cpu", or "memory", while RawDeployments can only utilize "cpu" and "memory".  "concurrency" is used by default for Serverless and "cpu" is used by default for RawDeployments. |
| scaling.scaleTarget | string | `""` | The scaling target used by KNative to trigger scaling a new pod.  Default is 100 when not set. |
| scaling.serverless.retentionPeriod | string | `""` | The retentionPeriod determines the minimum amount of time that the last pod will remain active after the Autoscaler decides to scale pods to zero. |
| scaling.serverless.timeout | string | `"30m"` | The timeout value determines how long before KNative marks the deployments as failed |
| scaling.stopped | bool | `false` | Sets the model server to a stopped state and spins down all pods. |
| servingRuntime.annotations."opendatahub.io/recommended-accelerators" | string | `"[\"nvidia.com/gpu\"]"` |  |
| servingRuntime.annotations."opendatahub.io/template-display-name" | string | `"Hugging Face Detector ServingRuntime for KServe"` |  |
| servingRuntime.args | list | `["--workers=1","--host=0.0.0.0","--port=8000","--log-config=/common/log_conf.yaml"]` | The arguments used to start guardrails-huggingface-detector |
| servingRuntime.name | string | `""` | Overwrite the default name for the ServingRuntime. |
| servingRuntime.shmSize | string | `"2Gi"` | The size of the emptyDir used for shared memory.  You most likely don't need to adjust this. |
| servingRuntime.useExisting | string | `""` | Use an existing servingRuntime instead of creating one.  If useExisting value is set, no servingRuntime will be created and the InferenceService will be configured to use the value set here as the runtime name. |
| tolerations | list | `[{"effect":"NoSchedule","key":"nvidia.com/gpu","operator":"Exists"}]` | The tolerations to be applied to the model server pod. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
