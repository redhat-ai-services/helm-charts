# vllm-kserve

A Helm deploying vLLM with KServe on OpenShift AI

![Version: 0.4.1](https://img.shields.io/badge/Version-0.4.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.9.0.1](https://img.shields.io/badge/AppVersion-v0.9.0.1-informational?style=flat-square)

## Installing the Chart

To access charts from this from the cli repository add it:

```sh
helm repo add redhat-ai-services https://redhat-ai-services.github.io/helm-charts/
helm repo update redhat-ai-services
helm upgrade -i [release-name] redhat-ai-services/vllm-kserve
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
  - name: "vllm-kserve"
    version: "0.4.1"
    repository: "https://redhat-ai-services.github.io/helm-charts/"
```

## Usage

### Deploying a Model with ModelCar (OCI)

The chart provides the ability to deploy models via URI or S3.  To deploy a model from an OCI container (aka ModelCar) you must set the storage mode to `uri` and then provide the OCI URI.

```sh
helm upgrade -i [release-name] redhat-ai-services/vllm-kserve \
  --set model.mode=uri \
  --set model.uri="oci://quay.io/redhat-ai-services/modelcar-catalog:granite-3.3-2b-instruct"
```

### Deploy with a PVC

KServe provides the ability to deploy a model from a PVC.

The PVC must be `ReadWriteMany` and the user will need to load the model onto the PVC prior to deploying the model server.

To deploy a model serving using a PVC you can provide the following options:

```sh
helm upgrade -i [release-name] redhat-ai-services/vllm-kserve \
  --set model.mode=uri \
  --set model.uri="pvc://{pvc-name}/{model-folder}"
```

### Deploy a Model with S3

To deploy a model from an S3 bucket, a secret containing the connection details in the OpenShift AI S3 Data Connection format must exist.

```yaml
kind: Secret
apiVersion: v1
metadata:
  name: my-s3-connection
  labels:
    opendatahub.io/dashboard: 'true'
    opendatahub.io/managed: 'true'
  annotations:
    opendatahub.io/connection-type: s3
    opendatahub.io/connection-type-ref: s3
    openshift.io/description: ''
    openshift.io/display-name: my-s3-connection
type: Opaque
data:
  AWS_ACCESS_KEY_ID: YmxhaA==
  AWS_S3_BUCKET: YmxhaA==
  AWS_S3_ENDPOINT: YmxhaA==
  AWS_SECRET_ACCESS_KEY: YmxhaA==
```

To configure the S3 option, you must set the storage mode to S3 and provide the name of the secret for the S3 Data Connection and the path the model exists in the bucket.  The model cannot be located in the root folder of the bucket.

```sh
helm upgrade -i [release-name] redhat-ai-services/vllm-kserve \
  --set model.mode=s3 \
  --set model.s3.key="my-s3-connection" \
  --set model.s3.path="my-model-folder"
```

### Setting Additional Arguments

Many models may require additional arguments to be configured in order to successfully start.  Additional arguments can be set with the following option:

```sh
helm upgrade -i [release-name] redhat-ai-services/vllm-kserve \
  --set model.args={"--gpu-memory-utilization=0.95", "--max-model-len=10000"}
```

For more information on available arguments, see the [vLLM Engine Arguments](https://docs.vllm.ai/en/latest/serving/engine_args.html
) documentation.

>[!TIP]
> Model specific arguments are required to use tooling with vLLM. More info found [here](https://docs.vllm.ai/en/latest/features/tool_calling.html#quickstart)

### Securing the Endpoint

By default the vLLM instance is not secured with authentication, but this feature can be enabled by setting the following options:

```sh
helm upgrade -i [release-name] redhat-ai-services/vllm-kserve \
  --set endpoint.auth.enabled=true
```

To access the endpoint, a user token must be provided uses a `Bearer token`.  The user must have view access to the `InferenceService` instance.

For normal OpenShift users, you can utilize the same sha token used when logging in via `oc` if your user has access as the `Bearer token`, but this is not advised for long term solutions as the `oc` token expires after 24 hours by default.

Instead, you can create a Service account with the correct permissions using the following:

```sh
helm upgrade -i [release-name] redhat-ai-services/vllm-kserve \
  --set endpoint.auth.enabled=true \
  --set 'endpoint.auth.serviceAccounts[0].name=my-service-account'
```

This option will create the serviceAccount `my-service-account` and a secret with the matching name that includes an automatically generated token value.  This token is generated using a legacy k8s token tool by default.

>[!WARNING]
> Service Accounts created through this helm chart or service accounts that are granted permission to the vLLM instance are not visible through the OpenShift AI UI.

The `serviceAccounts` configuration supports several useful options:

```
endpoint:
  auth:
    serviceAccounts:
      - name: my-service-account
      - name: existing-service-account
        create: false
      - name: existing-in-another-namespace
        namespace: my-other-namespace
        create: false
      - name: no-token
        createLegacyToken: false
```

The `create` option defaults to true if not set.  Disabling `create` can be useful if you wish to grant permissions to a serviceAccount that already exists.

The `namespace` option allows you to specify which namespace the service account exists or should be created.  Generally it is recommended to only use this feature with `create: false` to grant permissions to an existing service account and not create a new one in that namespace.  If namespace is not specified it will utilize the Release Namespace by default.

The `createLegacyToken` defaults to true if not set.  This option allows you to disable the creation of a legacy k8s token when creating a new serviceAccount and instead to rely on automounted tokens in k8s.  See the official k8s [Service Account documentation](https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/#auto-generated-legacy-serviceaccount-token-clean-up) for more information.

### RawDeployment

KServe supports the option to create a "RawDeployment" that is not dependent on Istio or KNative Serverless and instead creates the models using a k8s Deployment object.

```
helm upgrade -i [release-name] redhat-ai-services/vllm-kserve \
  --set deploymentMode=RawDeployment
```

Additionally, with a RawDeployment, KServe can be configured to use a Recreate strategy which will delete the current pod, before attempting to deploy a new version, which can reduce the need for scaling additional GPUs.

```
helm upgrade -i [release-name] redhat-ai-services/vllm-kserve \
  --set deploymentMode=RawDeployment \
  --set scaling.rawDeployment.deploymentStrategy.type=Recreate
```

### Scaling

KServe supports the ability to automatically scale model servers and allows users to configure a max and min number of replicas:

```
helm upgrade -i [release-name] redhat-ai-services/vllm-kserve \
  --set scaling.minReplicas=1 \
  --set scaling.maxReplicas=5 \
```

KServe uses KNative Servereless autoscaling capabilities for Serverless deployments to scale instances based on concurrent requests by default. Serverless deployments also alternative scaling metrics including "concurrency", "rps", "cpu", and "memory".

```
helm upgrade -i [release-name] redhat-ai-services/vllm-kserve \
  --set scaling.serverless.scaleMetric=rps \
  --set scaling.serverless.scaleTarget=10
```

For more information on the supported scaleMetric options, see the [KNative Autoscaling Metrics](https://knative.dev/docs/serving/autoscaling/autoscaling-metrics/#setting-metrics-per-revision) documentation.

For RawDeployments, KServe uses HorizontalPodAutoscalers (HPA) based on CPU and memory utilization.

With the Serverless deployments, KServe provides the capability to scale to 0 pods when no active queries are being processed.  This can be achieved by setting the minReplicas to 0.

```
helm upgrade -i [release-name] redhat-ai-services/vllm-kserve \
  --set scaling.minReplicas=0
```

>[!NOTE]
> Scale to zero is only supported with Serverless deployments and is not available for RawDeployments.

KServe can also be configured to change how quickly a model is scaled to zero by setting the retentionPeriod.

```
helm upgrade -i [release-name] redhat-ai-services/vllm-kserve \
  --set scaling.minReplicas=0 \
  --set scaling.serverless.retentionPeriod=10m
```

Longer retention periods can help reduce the model server from starting and stopping as frequently and help to avoid long startup times.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| deploymentMode | string | `"Serverless"` | deploymentMode determines if the model will be deployed using KNative Serverless or a standard k8s Deployment.  Must be one of Serverless or RawDeployment |
| endpoint.auth.enabled | bool | `false` | Secures the model endpoint and creates a role to grant permissions to service accounts |
| endpoint.auth.serviceAccounts | list | `[]` | Creates service accounts with permissions to access the secured endpoint |
| endpoint.externalRoute.enabled | bool | `true` | Creates an externally accessible route for the model endpoint |
| fullnameOverride | string | `""` | String to fully override fullname template |
| image.image | string | `"quay.io/modh/vllm"` | The vLLM model server image |
| image.tag | string | `"rhoai-2.21-cuda"` | The tag or sha for the model server image |
| imagePullSecrets | list | `[]` | This is for the secretes for pulling an image from a private repository more information can be found here: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/ |
| inferenceService.name | string | `""` | Overwrite the default name for the InferenceService. |
| model.args | list | `["--gpu-memory-utilization=0.90"]` | Additional vLLM arguments to be used to start the model.  For more documentation on available arguments see https://docs.vllm.ai/en/latest/serving/engine_args.html |
| model.env | list | `[{"name":"VLLM_LOGGING_LEVEL","value":"INFO"}]` | Additional vLLM arguments to be used to start the model.  For more documentation on available environments variables see https://docs.vllm.ai/en/stable/serving/env_vars.html |
| model.mode | string | `"uri"` | Option to set how the storage will be configured.  Options: "uri" and "s3" |
| model.modelNameOverride | string | `""` | By default the model name will utilize the inferenceService name for the model. This parameter will override the default name to allow you to explicitly set the model name. |
| model.s3.key | string | `""` | The secret containing s3 credentials.  Mode must be set to "s3" to use this option. |
| model.s3.path | string | `""` | The containing the model in the s3 bucket.  Mode must be set to "s3" to use this option. |
| model.uri | string | `"oci://quay.io/redhat-ai-services/modelcar-catalog:granite-3.3-2b-instruct"` | The Uri to use for storage.  Mode must be set to "uri" to use this option.  Options: "oci://" and "pvc://" |
| nameOverride | string | `""` | String to partially override fullname template (will maintain the release name) |
| nodeSelector | object | `{}` | Node selector for the vLLM pod |
| resources | object | `{"limits":{"cpu":"2","memory":"8Gi","nvidia.com/gpu":"1"},"requests":{"cpu":"1","memory":"4Gi","nvidia.com/gpu":"1"}}` | Resource configuration for the vLLM container |
| scaling.maxReplicas | int | `1` | The maximum number of replicas to be deployed |
| scaling.minReplicas | int | `1` | The minimum number of replicas to be deployed.  Set to 0 to enable scale to zero capabilities with Serverless deployments. |
| scaling.rawDeployment.deploymentStrategy | object | `{"type":"RollingUpdate"}` | The deployment strategy to use to replace existing pods with new ones. |
| scaling.scaleMetric | string | `""` | The scaling metric used by KServe to trigger scaling a new pod.  Serverless deployments can be "concurrency", "rps", "cpu", or "memory", while RawDeployments can only utilize "cpu" and "memory".  "concurrency" is used by default for Serverless and "cpu" is used by default for RawDeployments. |
| scaling.scaleTarget | string | `""` | The scaling target used by KNative to trigger scaling a new pod.  Default is 100 when not set. |
| scaling.serverless.retentionPeriod | string | `""` | The retentionPeriod determines the minimum amount of time that the last pod will remain active after the Autoscaler decides to scale pods to zero. |
| scaling.serverless.timeout | string | `"30m"` | The timeout value determines how long before KNative marks the deployments as failed |
| servingRuntime.annotations | object | `{"opendatahub.io/apiProtocol":"REST","opendatahub.io/recommended-accelerators":"[\"nvidia.com/gpu\"]","opendatahub.io/template-display-name":"vLLM NVIDIA GPU ServingRuntime for KServe"}` | Additional annotations to configure on the servingRuntime |
| servingRuntime.args | list | `["--port=8080","--model=/mnt/models"]` | The arguments used to start vLLM |
| servingRuntime.name | string | `""` | Overwrite the default name for the ServingRuntime. |
| servingRuntime.shmSize | string | `"2Gi"` | The size of the emptyDir used for shared memory.  You most likely don't need to adjust this. |
| servingRuntime.useExisting | string | `""` | Use an existing servingRuntime instead of creating one.  If useExisting value is set, no servingRuntime will be created and the InferenceService will be configured to use the value set here as the runtime name. |
| tolerations | list | `[{"effect":"NoSchedule","key":"nvidia.com/gpu","operator":"Exists"}]` | The tolerations to be applied to the model server pod. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
