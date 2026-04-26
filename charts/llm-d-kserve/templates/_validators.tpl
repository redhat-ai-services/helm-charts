{{/*
validateLegacyTokenInAnotherNamespace: normalized auth service accounts in a namespace
other than the release cannot use legacy tokens; createLegacyToken must be false.

Uses `range` over the items slice (no $x :=) so the context `.` is each map, and
`index` for keys — compatible with map[string]any from JSON in all Helm versions.
*/}}
{{- define "llm-d-kserve.validateLegacyTokenInAnotherNamespace" -}}
{{- $items := index (fromJson (include "llm-d-kserve.normalizedServiceAccounts" .)) "items" -}}
{{- range $items -}}
  {{- if and (ne (index . "namespace") $.Release.Namespace) (index . "createLegacyToken") -}}
  {{- $saName := index . "name" | toString -}}
  {{- fail (printf "The auth.serviceAccount %s is setting a namespace different from the default.  createLegacyToken must be set to false." $saName) -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Run all validation checks.
*/}}
{{- define "llm-d-kserve.validateAll" -}}
{{- include "llm-d-kserve.validateLegacyTokenInAnotherNamespace" . }}
{{- end }}
