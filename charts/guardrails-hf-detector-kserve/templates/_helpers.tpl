{{/*
Expand the name of the chart.
*/}}
{{- define "guardrails-hf-detector-kserve.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "guardrails-hf-detector-kserve.fullname" -}}
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
{{- define "guardrails-hf-detector-kserve.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "guardrails-hf-detector-kserve.labels" -}}
helm.sh/chart: {{ include "guardrails-hf-detector-kserve.chart" . }}
{{ include "guardrails-hf-detector-kserve.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
RHOAI Annotation
*/}}
{{- define "guardrails-hf-detector-kserve.rhoaiAnnotations" -}}
opendatahub.io/apiProtocol: REST
{{ include "guardrails-hf-detector-kserve.acceleratorAnnotations" . }}
{{ include "guardrails-hf-detector-kserve.runtimeAnnotation" . }}
{{- end }}

{{/*
RHOAI Accelerator Annotations
*/}}
{{- define "guardrails-hf-detector-kserve.acceleratorAnnotations" -}}
{{ toYaml .Values.servingRuntime.annotations }}
{{- end }}

{{/*
Guardrails HuggingFace Detector Runtime Version Annotation
*/}}
{{- define "guardrails-hf-detector-kserve.runtimeAnnotation" -}}
{{- if .Values.image.runtimeVersionOverride }}
opendatahub.io/runtime-version: {{ .Values.image.runtimeVersionOverride }}
{{- else }}
opendatahub.io/runtime-version: {{ .Chart.AppVersion }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "guardrails-hf-detector-kserve.selectorLabels" -}}
app.kubernetes.io/name: {{ include "guardrails-hf-detector-kserve.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the ServingRuntime to use
*/}}
{{- define "guardrails-hf-detector-kserve.servingRuntimeName" -}}
{{- if eq .Values.servingTopology "singleNode" -}}
{{- default (include "guardrails-hf-detector-kserve.fullname" .) .Values.servingRuntime.name -}}
{{- else -}}
{{/*
Legacy compatibility for older OpenShift AI versions
*/}}
{{- printf "guardrails-hf-detector-runtime" -}}
{{- end -}}
{{- end }}

{{/*
Create the name of the InfernceService to use
*/}}
{{- define "guardrails-hf-detector-kserve.inferenceServiceName" -}}
{{- default (include "guardrails-hf-detector-kserve.fullname" .) .Values.inferenceService.name }}
{{- end }}

{{/*
Create the name of the predictor to use
*/}}
{{- define "guardrails-hf-detector-kserve.predictorName" -}}
{{- printf "%s-%s" (include "guardrails-hf-detector-kserve.inferenceServiceName" .) "predictor" }}
{{- end }}

{{/*
Lookup the Endpoint URL
*/}}
{{- define "guardrails-hf-detector-kserve.endpointUrl" -}}
{{- $predictor := include "guardrails-hf-detector-kserve.predictorName" . }}
{{- if eq .Values.deploymentMode "Serverless" }}
{{- $service := lookup "serving.knative.dev/v1" "Service" .Release.Namespace $predictor }}
{{- if hasKey $service "status" }}
{{- if hasKey $service.status "url"}}
{{- $service.status.url }}
{{- end }}
{{- end }}
{{- else if eq .Values.deploymentMode "RawDeployment" }}
{{- $routeName := include "guardrails-hf-detector-kserve.inferenceServiceName" . }}
{{- $route := lookup "route.openshift.io/v1" "Route" .Release.Namespace $routeName }}
{{- if hasKey $route "spec" }}
{{- if hasKey $route.spec "host" }}
{{- printf "https://%s" $route.spec.host }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- define "guardrails-hf-detector-kserve.image" -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion }}
{{- if $tag | hasPrefix "sha256:" }}
{{- printf "%s@%s" .Values.image.image $tag }}
{{- else }}
{{- printf "%s:%s" .Values.image.image $tag }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "guardrails-hf-detector-kserve.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "guardrails-hf-detector-kserve.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
