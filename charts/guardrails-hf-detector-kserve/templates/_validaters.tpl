{{/*
Validate that a valid deployment mode is configured.
*/}}
{{- define "guardrails-hf-detector-kserve.validateDeploymentMode" -}}
{{- $deploymentModes := list "RawDeployment" "Serverless" }}
{{- if not (mustHas .Values.deploymentMode $deploymentModes) }}
    {{- fail (printf "Model deployment mode must be one of: %s" $deploymentModes) }}
{{- end }}
{{- end }}

{{/*
Validate the scale metric.
*/}}
{{- define "guardrails-hf-detector-kserve.validateScaleMetric" -}}
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

{{/*
Validate that a valid model mode is configured.
*/}}
{{- define "guardrails-hf-detector-kserve.validateModelMode" -}}
{{- $validModes := list "uri" "s3" }}
{{- if not (has (lower .Values.model.mode) $validModes) }}
    {{- fail (printf "Invalid model.mode. Must be one of: %s" $validModes) }}
{{- end }}
{{- end }}

{{/*
Validate model storage requirements based on mode.
*/}}
{{- define "guardrails-hf-detector-kserve.validateModelStorage" -}}
{{- if eq (lower .Values.model.mode) "uri" }}
{{- if not .Values.model.uri }}
    {{- fail "model.uri is required when setting mode to 'uri'" }}
{{- end }}
{{- else if eq (lower .Values.model.mode) "s3" }}
{{- if not .Values.model.s3.key }}
    {{- fail "model.s3.key is required when setting mode to 's3'" }}
{{- end }}
{{- if not .Values.model.s3.path }}
    {{- fail "model.s3.path is required when setting mode to 's3'" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Run all validation checks.
*/}}
{{- define "guardrails-hf-detector-kserve.validateAll" -}}
{{- include "guardrails-hf-detector-kserve.validateDeploymentMode" . }}
{{- include "guardrails-hf-detector-kserve.validateModelMode" . }}
{{- include "guardrails-hf-detector-kserve.validateModelStorage" . }}
{{- if .Values.scaling.scaleMetric }}
{{- include "guardrails-hf-detector-kserve.validateScaleMetric" . }}
{{- end }}
{{- end }}
