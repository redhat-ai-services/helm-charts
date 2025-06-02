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
{{- $service := lookup "serving.knative.dev/v1" "Service" .Release.Namespace $predictor }}
{{- if hasKey $service "status" }}
{{- if hasKey $service.status "url"}}
{{- $service.status.url }}
{{- end }}
{{- end }}
{{- end }}

{{- define "vllm-kserve.image" -}}
{{- if .Values.servingRuntime.tag | hasPrefix "sha256:" }}
{{- printf "%s@%s" .Values.servingRuntime.image .Values.servingRuntime.tag }}
{{- else }}
{{- printf "%s:%s" .Values.servingRuntime.image .Values.servingRuntime.tag }}
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
