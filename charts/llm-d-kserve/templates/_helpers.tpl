{{/*
Expand the name of the chart.
*/}}
{{- define "llm-d-kserve.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "llm-d-kserve.fullname" -}}
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
{{- define "llm-d-kserve.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "llm-d-kserve.labels" -}}
helm.sh/chart: {{ include "llm-d-kserve.chart" . }}
{{ include "llm-d-kserve.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "llm-d-kserve.selectorLabels" -}}
app.kubernetes.io/name: {{ include "llm-d-kserve.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "llm-d-kserve.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "llm-d-kserve.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Name of the shared ServiceAccount used for auth legacy token secrets (one per release).
*/}}
{{- define "llm-d-kserve.legacyServiceAccountName" -}}
{{- printf "%s-sa" (include "llm-d-kserve.fullname" .) }}
{{- end }}

{{/*
Build a list of auth.serviceAccounts with explicit create and createLegacyToken booleans
(optional create defaults true; if createLegacyToken is unset and create is true, legacy token
is enabled; if create is false, createLegacyToken defaults false). Namespace defaults to
.Release.Namespace when not set on the item.
The result is a JSON object `{"items":[...]}` (not a top-level array) so templates can `range` over
`.items` reliably; each item is a map built with JSON round-trip.
*/}}
{{- define "llm-d-kserve.normalizedServiceAccounts" -}}
{{- $result := list -}}
{{- range .Values.auth.serviceAccounts }}
  {{- $name := .name -}}
  {{- $namespace := $.Release.Namespace -}}
  {{- if hasKey . "namespace" }}
    {{- $namespace = .namespace -}}
  {{- else }}
    {{- $namespace = $.Release.Namespace -}}
  {{- end }}
  {{- $create := true -}}
  {{- if hasKey . "create" }}
    {{- $create = .create -}}
  {{- else }}
    {{- $create = true -}}
  {{- end }}
  {{- $createLegacyToken := false -}}
  {{- if hasKey . "createLegacyToken" }}
    {{- $createLegacyToken = .createLegacyToken -}}
  {{- else }}
    {{- if $create }}
      {{- $createLegacyToken = true -}}
    {{- else }}
      {{- $createLegacyToken = false -}}
    {{- end }}
  {{- end }}
  {{- $item := fromJson (printf `{"name":%q,"namespace":%q,"create":%t,"createLegacyToken":%t}` $name $namespace $create $createLegacyToken) -}}
  {{- $result = append $result $item -}}
{{- end }}
{{- toJson (dict "items" $result) -}}
{{- end -}}

{{/*
Create the name of the data connect to use
*/}}
{{- define "llm-d-kserve.dataConnectionName" -}}
{{- default (include "llm-d-kserve.fullname" .) (index .Values "dataConnection" "name") }}
{{- end }}

{{/*
Render a map as a compact YAML list item ("- key: …" instead of "-\n  key: …").
*/}}
{{- define "llm-d-kserve.toYamlListItem" -}}
{{- $lines := splitList "\n" (toYaml .) -}}
- {{ first $lines }}
{{- range rest $lines }}
{{- if . }}
  {{ . }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "llm-d-kserve.image" -}}
{{- if hasPrefix "sha256:" (toString .Values.vllm.image.tag) }}
{{- printf "%s@%s" .Values.vllm.image.repository .Values.vllm.image.tag }}
{{- else }}
{{- printf "%s:%s" .Values.vllm.image.repository .Values.vllm.image.tag }}
{{- end }}
{{- end }}
