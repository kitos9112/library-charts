{{/*
Volumes included by the controller.
*/}}
{{- define "common.controller.volumes" -}}
{{- range $index, $persistence := .Values.persistence }}
{{- if $persistence.enabled }}
- name: {{ $index }}
  {{- if eq (default "pvc" $persistence.type) "pvc" }}
    {{- $pvcName := (include "common.names.fullname" $) -}}
    {{- if $persistence.existingClaim }}
      {{- /* Always prefer an existingClaim if that is set */}}
      {{- $pvcName = $persistence.existingClaim -}}
    {{- else -}}
      {{- /* Otherwise refer to the PVC name */}}
      {{- if $persistence.nameOverride -}}
        {{- if not (eq $persistence.nameOverride "-") -}}
          {{- $pvcName = (printf "%s-%s" (include "common.names.fullname" $) $persistence.nameOverride) -}}
        {{- end -}}
      {{- else -}}
        {{- $pvcName = (printf "%s-%s" (include "common.names.fullname" $) $index) -}}
      {{- end -}}
    {{- end }}
  persistentVolumeClaim:
    claimName: {{ $pvcName }}
  {{- else if eq $persistence.type "emptyDir" }}
    {{- $emptyDir := dict -}}
    {{- with $persistence.medium -}}
      {{- $_ := set $emptyDir "medium" . -}}
    {{- end -}}
    {{- with $persistence.sizeLimit -}}
      {{- $_ := set $emptyDir "sizeLimit" . -}}
    {{- end }}
  emptyDir: {{- $emptyDir | toYaml | nindent 4 }}
  {{ else }}
    {{- fail (printf "Not a valid persistence.type (%s)" .Values.persistence.type) }}
  {{- end }}
{{- end }}
{{- end }}

{{- if .Values.additionalVolumes }}
  {{- toYaml .Values.additionalVolumes | nindent 0 }}
{{- end }}

{{/*
Creates Volumes for hostPaths which can be directly mounted to a container
*/}}
{{- range $name, $hpm := .Values.hostPathMounts -}}
{{ if $hpm.enabled }}
{{ if $hpm.name }}
{{ $name = $hpm.name }}
{{ end }}
- name: hostpathmounts-{{ $name }}
  {{ if $hpm.emptyDir }}
  emptyDir: {}
  {{- else -}}
  hostPath:
    path: {{ required "hostPath not set" $hpm.hostPath }}
  {{ end }}
{{ end }}
{{- end -}}
{{- end }}
