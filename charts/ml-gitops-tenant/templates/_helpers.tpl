{{/*
Expand the name of the chart.
*/}}
{{- define "ml-gitops-tenant.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ml-gitops-tenant.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{- define "ml-gitops-tenant.namespace" -}}
{{- if .namespace.nameOverride }}
{{- .namespace.nameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $fullname := include "ml-gitops-tenant.fullname" .context }}
{{- printf "%s-%s"  $fullname .namespace.nameSuffix  }}
{{- end }}
{{- end }}

{{- define "ml-gitops-tenant.gitops-name" -}}
{{- range $namespace := .Values.namespaces -}}
{{- if eq $namespace.role "gitops" }}
{{- if $namespace.nameOverride }}
{{- $namespace.nameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $fullname := include "ml-gitops-tenant.fullname" $ }}
{{- printf "%s-%s"  $fullname $namespace.nameSuffix  }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- define "ml-gitops-tenant.pipelines-name" -}}
{{- range $namespace := .Values.namespaces -}}
{{- if eq $namespace.role "pipelines" }}
{{- if $namespace.nameOverride }}
{{- $namespace.nameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $fullname := include "ml-gitops-tenant.fullname" $ }}
{{- printf "%s-%s"  $fullname $namespace.nameSuffix  }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- define "ml-gitops-tenant.admin-group" -}}
{{- if .Values.adminGroup.nameOverride }}
{{- .Values.adminGroup.nameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $fullname := include "ml-gitops-tenant.fullname" . }}
{{- printf "%s-%s"  $fullname "admins"  }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "ml-gitops-tenant.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ml-gitops-tenant.labels" -}}
helm.sh/chart: {{ include "ml-gitops-tenant.chart" . }}
{{ include "ml-gitops-tenant.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ml-gitops-tenant.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ml-gitops-tenant.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "ml-gitops-tenant.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "ml-gitops-tenant.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
