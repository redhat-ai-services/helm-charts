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
opendatahub.io/dashboard: 'true'
helm.sh/chart: {{ include "vllm-kserve.chart" . }}
{{ include "vllm-kserve.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
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
{{- default (include "vllm-kserve.fullname" .) .Values.servingRuntime.name }}
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

{{/*
Validate that a valid deployment mode is configured.
*/}}
{{- define "vllm-kserve.validateDeploymentMode" -}}
{{- $deploymentModes := list "RawDeployment" "Serverless" }}
{{- if not (mustHas .Values.deploymentMode $deploymentModes) }}
    {{- fail (printf "Model deployment mode must be one of: %s" $deploymentModes) }}
{{- end }}
{{- end }}

{{/*
Validate the scale metric.
*/}}
{{- define "vllm-kserve.validateScaleMetric" -}}
{{- $scaleMetrics := list }}
{{- if eq .Values.deploymentMode "Serverless" }}
{{- $scaleMetrics = list "concurrency" "rps" "cpu" "memory" }}
{{- else }}
{{- $scaleMetrics = list "cpu" "memory" }}
{{- end }}
{{- if not (mustHas .Values.scaling.scaleMetric $scaleMetrics) }}
    {{- fail (printf "For %s scaleMetric must must be one of: %s" .Values.deploymentMode $scaleMetrics) }}
{{- end }}
{{- end }}
