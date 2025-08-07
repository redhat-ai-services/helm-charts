# vllm-kserve

A Helm deploying vLLM with KServe on OpenShift AI

![Version: 0.5.5](https://img.shields.io/badge/Version-0.5.5-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.9.0.1](https://img.shields.io/badge/AppVersion-v0.9.0.1-informational?style=flat-square)

## Table of Contents

- [Installing the Chart](#installing-the-chart)
- [Usage](#usage)
  - [Quick Start](#quick-start)
- [Deploying Models](#deploying-models)
  - [ModelCar (OCI Container)](#modelcar-oci-container)
  - [PVC Storage](#pvc-storage)
  - [S3 Storage](#s3-storage)
  - [Setting Additional Arguments](#setting-additional-arguments)
  - [GPU and Accelerator Support](#gpu-and-accelerator-support)
    - [NVIDIA GPUs (Default)](#nvidia-gpus-default)
    - [AMD GPUs](#amd-gpus)
    - [Intel Gaudi Accelerators](#intel-gaudi-accelerators)
    - [CPU-only Deployment](#cpu-only-deployment)
- [Security](#security)
  - [Securing the Endpoint](#securing-the-endpoint)
- [Deployment Modes](#deployment-modes)
  - [RawDeployment](#rawdeployment)
  - [Multi-node Deployment](#multi-node-deployment)
  - [Scaling](#scaling)
- [Troubleshooting](#troubleshooting)
  - [Common Issues](#common-issues)
  - [Getting Support](#getting-support)
- [Configuration](#configuration)
- [Values](#values)

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
    version: "0.5.5"
    repository: "https://redhat-ai-services.github.io/helm-charts/"
```

## Usage

### Quick Start

For a basic vLLM deployment with default settings:

```sh
helm upgrade -i my-vllm redhat-ai-services/vllm-kserve
```

This will deploy a single-node vLLM instance in Serverless mode with the default model.

## Deploying Models

The chart supports multiple model storage options:

### ModelCar (OCI Container)

Deploy models packaged as OCI containers (ModelCar format):

```sh
helm upgrade -i [release-name] redhat-ai-services/vllm-kserve \
  --set model.mode=uri \
  --set model.uri="oci://quay.io/redhat-ai-services/modelcar-catalog:granite-3.3-2b-instruct"
```

### PVC Storage

Deploy models from a Persistent Volume Claim:

The PVC must be `ReadWriteMany` and the user will need to load the model onto the PVC prior to deploying the model server.

To deploy a model serving using a PVC you can provide the following options:

```sh
helm upgrade -i [release-name] redhat-ai-services/vllm-kserve \
  --set model.mode=uri \
  --set model.uri="pvc://{pvc-name}/{model-folder}"
```

### S3 Storage

Deploy models from S3-compatible storage by providing S3 credentials:

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

>[!NOTE]
>In the example secret, the values have already been base64 encoded.

Alternatively, you can create the secret declaratively using the following commands:

```
oc create secret generic my-s3-connection \
  --from-literal=AWS_ACCESS_KEY_ID="your-access-key" \
  --from-literal=AWS_SECRET_ACCESS_KEY="your-secret-key" \
  --from-literal=AWS_S3_ENDPOINT="https://s3.amazonaws.com" \
  --from-literal=AWS_S3_BUCKET="your-bucket-name"

# Add the required labels and annotations for OpenShift AI
oc label secret my-s3-connection \
  opendatahub.io/dashboard=true \
  opendatahub.io/managed=true

oc annotate secret my-s3-connection \
  opendatahub.io/connection-type=s3 \
  opendatahub.io/connection-type-ref=s3 \
  openshift.io/description="S3 connection for vLLM model storage" \
  openshift.io/display-name="my-s3-connection"
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

### GPU and Accelerator Support

This chart supports multiple GPU types and accelerators:

#### NVIDIA GPUs (Default)
```sh
helm upgrade -i [release-name] redhat-ai-services/vllm-kserve \
  --set 'resources.requests.nvidia\.com/gpu=1' \
  --set 'resources.limits.nvidia\.com/gpu=1'
```

#### AMD GPUs
```sh
helm upgrade -i [release-name] redhat-ai-services/vllm-kserve \
  --set image.tag=rhoai-2.22-rocm \
  --set resources.requests.'nvidia\.com/gpu'=null \
  --set resources.limits.'nvidia\.com/gpu'=null \
  --set 'resources.requests.amd\.com/gpu=1' \
  --set 'resources.limits.amd\.com/gpu=1'
```

Additional toleration may be required.

#### Intel Gaudi Accelerators
```sh
helm upgrade -i [release-name] redhat-ai-services/vllm-kserve \
  --set image.tag=rhoai-2.22-gaudi \
  --set image.runtimeVersionOverride="0.7.2" \
  --set resources.requests.'nvidia\.com/gpu'=null \
  --set resources.limits.'nvidia\.com/gpu'=null \
  --set 'resources.requests.habana\.ai/gaudi=1' \
  --set 'resources.limits.habana\.ai/gaudi=1'
```

Additional toleration may be required.

#### CPU-only Deployment

>[!IMPORTANT]
>The CPU only version of vLLM is only supported on ppc64le and s390x CPUs and is not supported on x86 hardware.

```sh
helm upgrade -i [release-name] redhat-ai-services/vllm-kserve \
  --set image.tag=rhoai-2.22-cpu \
  --set resources.requests.'nvidia\.com/gpu'=null \
  --set resources.limits.'nvidia\.com/gpu'=null \
  --set tolerations=null
```

## Security

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

## Deployment Modes

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

### Multi-node Deployment

vLLM supports distributed multi-node inference for large models that don't fit on a single GPU or when you need to scale beyond single-node capabilities.

>[!IMPORTANT]
> Multi-node deployments are only supported with `RawDeployment` mode and cannot be used with Serverless deployments.  Additionally, multiNode only supports deploying models from an OCI container or a ReadWriteMany PVC.  It does not support serving models from S3.

To deploy a multi-node vLLM instance:

```sh
helm upgrade -i [release-name] redhat-ai-services/vllm-kserve \
  --set servingTopology=multiNode \
  --set deploymentMode=RawDeployment \
  --set multiNode.pipelineParallelSize=2 \
  --set multiNode.tensorParallelSize=2
```

`pipelineParallelSize` should be be equal to the number of pods/nodes you are deploying to, and `tensorParallelSize` should be equal to the number of GPUs available in each node.  By default, the multiNode deployment will use `pipelineParallelSize=2` and `tensorParallelSize=1`.

>[!TIP]
> - `pipeline-parallel-size` should equal the number of pods/nodes you are deploying
> - `tensor-parallel-size` should equal the number of GPUs per node

>[!NOTE]
> Autoscaling is not supported with multiNode deployments.

### Scaling

KServe supports the ability to automatically scale model servers and allows users to configure a max and min number of replicas:

```
helm upgrade -i [release-name] redhat-ai-services/vllm-kserve \
  --set scaling.minReplicas=1 \
  --set scaling.maxReplicas=5 \
```

KServe uses KNative Serverless autoscaling capabilities for Serverless deployments to scale instances based on concurrent requests by default. Serverless deployments also alternative scaling metrics including "concurrency", "rps", "cpu", and "memory".

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

## Troubleshooting

### Common Issues

#### Model Loading Errors
If the model fails to load, check:
- Model URI is accessible and correctly formatted
- Sufficient GPU memory for the model size and KV Cache configuration
- Model format is supported by vLLM

```sh
# Check pod logs
oc logs -l serving.kserve.io/inferenceservice=[release-name] -f

# Check InferenceService status
oc get inferenceservice [release-name] -o yaml
```

### Getting Support

- **Documentation**: [vLLM Documentation](https://docs.vllm.ai/)
- **KServe Documentation**: [KServe Documentation](https://kserve.github.io/website/)
- **Issues**: Report issues in the [helm-charts repository](https://github.com/redhat-ai-services/helm-charts/issues)

## Configuration

For a complete list of all configuration options, see the [Values](#values) section below.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| deploymentMode | string | `"Serverless"` | deploymentMode determines if the model will be deployed using KNative Serverless or a standard k8s Deployment.  Must be one of Serverless or RawDeployment |
| endpoint.auth.enabled | bool | `false` | Secures the model endpoint and creates a role to grant permissions to service accounts |
| endpoint.auth.serviceAccounts | list | `[]` | Creates service accounts with permissions to access the secured endpoint |
| endpoint.externalRoute.enabled | bool | `true` | Creates an externally accessible route for the model endpoint |
| fullnameOverride | string | `""` | String to fully override fullname template |
| image.image | string | `"quay.io/modh/vllm"` | The vLLM model server image |
| image.runtimeVersionOverride | string | `""` | The vLLM version that will be displayed in the RHOAI Dashboard.  If not set, the appVersion of the chart will be used. |
| image.tag | string | `"rhoai-2.22-cuda"` | The tag or sha for the model server image |
| imagePullSecrets | list | `[]` | This is for the secretes for pulling an image from a private repository more information can be found here: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/ |
| inferenceService.name | string | `""` | Overwrite the default name for the InferenceService. |
| model.args | list | `["--gpu-memory-utilization=0.90"]` | Additional vLLM arguments to be used to start the model.  For more documentation on available arguments see https://docs.vllm.ai/en/latest/serving/engine_args.html |
| model.env | list | `[]` | Additional vLLM arguments to be used to start the model.  For more documentation on available environments variables see https://docs.vllm.ai/en/stable/serving/env_vars.html. NOTE: As of RHOAI 2.22, adding environment variables to a multi-node deployment will prevent the ray-tls-generator init container from completing successfully. |
| model.mode | string | `"uri"` | Option to set how the storage will be configured.  Options: "uri" and "s3" |
| model.modelNameOverride | string | `""` | By default the model name will utilize the inferenceService name for the model. This parameter will override the default name to allow you to explicitly set the model name. |
| model.s3.key | string | `""` | The secret containing s3 credentials.  Mode must be set to "s3" to use this option. |
| model.s3.path | string | `""` | The containing the model in the s3 bucket.  Mode must be set to "s3" to use this option. |
| model.uri | string | `"oci://quay.io/redhat-ai-services/modelcar-catalog:granite-3.3-2b-instruct"` | The Uri to use for storage.  Mode must be set to "uri" to use this option.  Options: "oci://" and "pvc://" |
| multiNode.pipelineParallelSize | int | `2` | The number of pods to create for the multi-node topology.  Must be greater than 1. |
| multiNode.tensorParallelSize | int | `1` | The number of GPUs per node to use for the multi-node topology. |
| multiNode.visibleInDashboard | bool | `false` | Whether to show the multi-node deployment in the RHOAI Dashboard.  Default is false. |
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
| servingRuntime.args | list | `["--port=8080","--model=/mnt/models"]` | The arguments used to start vLLM |
| servingRuntime.name | string | `""` | Overwrite the default name for the ServingRuntime. |
| servingRuntime.shmSize | string | `"2Gi"` | The size of the emptyDir used for shared memory.  You most likely don't need to adjust this. |
| servingRuntime.useExisting | string | `""` | Use an existing servingRuntime instead of creating one.  If useExisting value is set, no servingRuntime will be created and the InferenceService will be configured to use the value set here as the runtime name. |
| servingTopology | string | `"singleNode"` | servingTopology determines if the model will be deployed using a single node or a multi-node topology.  Must be one of singleNode or multiNode |
| tolerations | list | `[{"effect":"NoSchedule","key":"nvidia.com/gpu","operator":"Exists"}]` | The tolerations to be applied to the model server pod. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
