{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "catalogue.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "catalogue.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "catalogue.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "catalogue.labels" -}}
app.kubernetes.io/name: {{ include "catalogue.name" . }}
helm.sh/chart: {{ include "catalogue.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}



{{/* OADB Connection environment */}}
{{- define "catalogue.oadb.connection" -}}
{{- $globalOsb := index (.Values.global | default .) "osb" -}}
{{- $keyName := (and .Values.osb.atp .Chart.Name) | (default (and $globalOsb.atp ($globalOsb.instanceName | default "mushop"))) | default .Chart.Name -}}
- name: OADB_USER
  {{- if $globalOsb.atp }}
  value: {{ printf "mu_%s_user" .Chart.Name }}
  {{- else }}
  valueFrom:
    secretKeyRef:
      name: {{ $keyName }}-oadb-connection
      key: oadb_user
  {{- end }}
- name: OADB_PW
  valueFrom:
    secretKeyRef:
      name: {{ $keyName }}-oadb-connection
      key: oadb_pw
- name: OADB_SERVICE
  valueFrom:
    secretKeyRef:
      name: {{ $keyName }}-oadb-connection
      key: oadb_service
{{- end -}}

{{/* OADB ADMIN environment */}}
{{- define "catalogue.oadb.admin" -}}
{{- $globalOsb := index (.Values.global | default .) "osb" -}}
{{- $keyName := (and .Values.osb.atp .Chart.Name) | (default (and $globalOsb.atp ($globalOsb.instanceName | default "mushop"))) | default .Chart.Name -}}
- name: OADB_ADMIN_PW
  valueFrom:
    secretKeyRef:
      name: {{ $keyName }}-oadb-admin
      key: oadb_admin_pw
{{- end -}}

{{/* OADB Wallet mount */}}
{{- define "catalogue.mount.wallet" -}}
- name: wallet
  mountPath: /usr/lib/oracle/19.3/client64/lib/network/admin/
  readOnly: true
{{- end -}}

{{/* OADB Wallet BINDING initContainer */}}
{{- define "catalogue.init.wallet" -}}
{{- $usesOsb := (index (.Values.global | default .Values) "osb").atp | default .Values.osb.atp -}}
{{- if $usesOsb }}
# OSB Wallet Binding decoder
- name: decode-binding
  image: oraclelinux:7-slim
  command: ["/bin/sh","-c"]
  args: 
  - for i in `ls -1 /tmp/wallet | grep -v user_name`; do cat /tmp/wallet/$i | base64 --decode > /wallet/$i; done; ls -l /wallet/*;
  volumeMounts:
    - name: wallet-binding
      mountPath: /tmp/wallet
      readOnly: true
    - name: wallet
      mountPath: /wallet
      readOnly: false
{{- end -}}
{{- end -}}

{{/* OADB dbtools mount template */}}
{{- define "catalogue.mount.initdb" -}}
- name: initdb
  mountPath: /work/
{{- end -}}

{{/* USER CONTAINER VOLUME TEMPLATE */}}
{{- define "catalogue.volumes" -}}
{{/* graceful loading of .Values.global.osb */}}
{{- $globalOsb := index (.Values.global | default .Values) "osb" -}}
{{- if .Values.osb.atp }}
# Service-specific wallet binding
- name: wallet-binding
  secret:
    secretName: {{ .Chart.Name }}-oadb-wallet-binding
- name: wallet
  emptyDir: {}
{{- else if $globalOsb.atp }}
# global atp wallet binding
- name: wallet-binding
  secret:
    secretName: {{ $globalOsb.instanceName | default "mushop" }}-oadb-wallet-binding
- name: wallet
  emptyDir: {}
{{- else }}
# local wallet
- name: wallet
  secret:
    secretName: {{ .Chart.Name }}-oadb-wallet
    defaultMode: 256
{{- end }}
# service init configMap
- name: initdb
  configMap:
    name: {{ include (printf "%s.fullname" .Chart.Name) . }}-init
    items:
    - key: atp.init.sql
      path: service.sql
{{- end -}}
