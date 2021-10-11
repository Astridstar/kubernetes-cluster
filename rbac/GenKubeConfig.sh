#!/bin/bash

CONTEXT_USR=pocAdmin
CURRENT_CONTEXT=pocContext
SERVICE_ACCOUNT=default

echo "---------------- Generating kubeconfig for user ${CONTEXT_USR} ---------------- "
USER_TOKEN_NAME=$(kubectl -n kube-system get serviceaccount ${SERVICE_ACCOUNT} -o=jsonpath='{.secrets[0].name}')
USER_TOKEN_VALUE=$(kubectl -n kube-system get secret/${USER_TOKEN_NAME} -o=go-template='{{.data.token}}' | base64 --decode)
CURRENT_CLUSTER=$(kubectl config view --raw -o=go-template='{{range .contexts}}{{if eq .name "'''${CURRENT_CONTEXT}'''"}}{{ index .context "cluster" }}{{end}}{{end}}')
CLUSTER_CA=$(kubectl config view --raw -o=go-template='{{range .clusters}}{{if eq .name "'''${CURRENT_CLUSTER}'''"}}"{{with index .cluster "certificate-authority-data" }}{{.}}{{end}}"{{ end }}{{ end }}')
CLUSTER_SERVER=$(kubectl config view --raw -o=go-template='{{range .clusters}}{{if eq .name "'''${CURRENT_CLUSTER}'''"}}{{ .cluster.server }}{{end}}{{ end }}')

echo "SERVICE_ACCOUNT=" ${SERVICE_ACCOUNT}
echo " USER_TOKEN_NAME=" ${USER_TOKEN_NAME}
echo " USER_TOKEN_VALUE=" ${USER_TOKEN_VALUE}
echo "   CURRENT_CLUSTER=" ${CURRENT_CLUSTER}
echo "   CLUSTER_CA=" ${CLUSTER_CA}
echo "   CLUSTER_SERVER=" ${CLUSTER_SERVER}

cat << EOF > poc-cluster-pocAdmin-config
apiVersion: v1
kind: Config
current-context: ${CURRENT_CONTEXT}
contexts:
- name: ${CURRENT_CONTEXT}
  context:
    cluster: ${CURRENT_CLUSTER}
    user: ${CONTEXT_USR}
    namespace: kube-system
clusters:
- name: ${CURRENT_CLUSTER}
  cluster:
    certificate-authority-data: ${CLUSTER_CA}
    server: ${CLUSTER_SERVER}
users:
- name: ${CONTEXT_USR}
  user:
    token: ${USER_TOKEN_VALUE}
EOF
