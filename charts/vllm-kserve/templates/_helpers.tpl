{{/*
Expand the name of the chart.
*/}}
{{- define "vllm-kserve.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "vllm-kserve.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "vllm-kserve.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "vllm-kserve.labels" -}}
helm.sh/chart: {{ include "vllm-kserve.chart" . }}
{{ include "vllm-kserve.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
RHOAI Annotation
*/}}
{{- define "vllm-kserve.rhoaiAnnotations" -}}
{{- include "vllm-kserve.acceleratorAnnotations" . }}
{{- include "vllm-kserve.runtimeAnnotation" . }}
{{- end }}

{{/*
RHOAI Accelerator Annotations
*/}}
{{- define "vllm-kserve.acceleratorAnnotations" -}}
{{- if eq .Values.servingTopology "singleNode" -}}
{{- if index .Values.resources.requests "nvidia.com/gpu" -}}
opendatahub.io/recommended-accelerators: '["nvidia.com/gpu"]'
opendatahub.io/template-display-name: vLLM NVIDIA GPU ServingRuntime for KServe
{{- else if index .Values.resources.requests "amd.com/gpu" -}}
opendatahub.io/recommended-accelerators: '["amd.com/gpu"]'
opendatahub.io/template-display-name: vLLM AMD GPU ServingRuntime for KServe
{{- else if index .Values.resources.requests "habana.ai/gaudi" -}}
opendatahub.io/recommended-accelerators: '["habana.ai/gaudi"]'
opendatahub.io/template-display-name: vLLM Intel Gaudi Accelerator ServingRuntime for KServe
{{- else -}}
opendatahub.io/template-display-name: vLLM CPU (ppc64le/s390x) ServingRuntime for KServe
{{- end -}}
{{- else -}}
opendatahub.io/recommended-accelerators: '["nvidia.com/gpu"]'
opendatahub.io/template-display-name: vLLM Multi-Node ServingRuntime for KServe
{{- end -}}
{{- end }}

{{/*
vLLM Runtime Version Annotation
*/}}
{{- define "vllm-kserve.runtimeAnnotation" -}}
{{- if .Values.image.runtimeVersionOverride }}
opendatahub.io/runtime-version: {{ .Values.image.runtimeVersionOverride }}
{{- else }}
opendatahub.io/runtime-version: {{ .Chart.AppVersion }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "vllm-kserve.selectorLabels" -}}
app.kubernetes.io/name: {{ include "vllm-kserve.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the ServingRuntime to use
*/}}
{{- define "vllm-kserve.servingRuntimeName" -}}
{{- if eq .Values.servingTopology "singleNode" -}}
{{- default (include "vllm-kserve.fullname" .) .Values.servingRuntime.name -}}
{{- else -}}
{{/*
OpenShift AI 2.22 and early require the servingruntime name to be vllm-multinode-runtime
in order to properly create the ray-tls secret.
Resolved in https://github.com/opendatahub-io/odh-model-controller/commit/7cf654ec55add67ee84ca9d7b40376331b9b3386
*/}}
{{- printf "vllm-multinode-runtime" -}}
{{- end -}}
{{- end }}

{{/*
Create the name of the InfernceService to use
*/}}
{{- define "vllm-kserve.inferenceServiceName" -}}
{{- default (include "vllm-kserve.fullname" .) .Values.inferenceService.name }}
{{- end }}

{{/*
Create the name of the predictor to use
*/}}
{{- define "vllm-kserve.predictorName" -}}
{{- printf "%s-%s" (include "vllm-kserve.inferenceServiceName" .) "predictor" }}
{{- end }}

{{/*
Lookup the Endpoint URL
*/}}
{{- define "vllm-kserve.endpointUrl" -}}
{{- $predictor := include "vllm-kserve.predictorName" . }}
{{- if eq .Values.deploymentMode "Serverless" }}
{{- $service := lookup "serving.knative.dev/v1" "Service" .Release.Namespace $predictor }}
{{- if hasKey $service "status" }}
{{- if hasKey $service.status "url"}}
{{- $service.status.url }}
{{- end }}
{{- end }}
{{- else if eq .Values.deploymentMode "RawDeployment" }}
{{- $routeName := include "vllm-kserve.inferenceServiceName" . }}
{{- $route := lookup "route.openshift.io/v1" "Route" .Release.Namespace $routeName }}
{{- if hasKey $route "spec" }}
{{- if hasKey $route.spec "host" }}
{{- printf "https://%s" $route.spec.host }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- define "vllm-kserve.image" -}}
{{- if .Values.image.tag | hasPrefix "sha256:" }}
{{- printf "%s@%s" .Values.image.image .Values.image.tag }}
{{- else }}
{{- printf "%s:%s" .Values.image.image .Values.image.tag }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "vllm-kserve.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "vllm-kserve.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{- define "vllm-kserve.hugginfaceGitUrl" -}}
{{- if .Values.model.pvc.downloadModel.huggingfaceModelRepo | hasPrefix "https://huggingface.co/" }}
{{- printf "%s" .Values.model.pvc.downloadModel.huggingfaceModelRepo }}
{{- else }}
{{- printf "https://huggingface.co/%s" .Values.model.pvc.downloadModel.huggingfaceModelRepo }}
{{- end }}
{{- end }}
