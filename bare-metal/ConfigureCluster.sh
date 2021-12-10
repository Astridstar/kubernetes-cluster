#!/bin/bash

echo "---------------- Create kubernetes cluster ---------------- "
sudo kubeadm init --cri-socket /run/containerd/containerd.sock --pod-network-cidr 192.168.0.0/16

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

sleep 3

echo "---------------- Apply calico ---------------- "
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml 

sleep 3

echo "---------------- Generate CSR for pocAdmin ---------------- "
openssl req -new -newkey rsa:4096 -nodes -keyout pocAdmin.key -out pocAdmin.csr -subj "/CN=pocAdmin/O=devops" | cat pocAdmin.csr | base64 | tr -d '\n'
CERT_VALUE=$(cat pocAdmin.csr | base64 | tr -d '\n')
sed -i "s|<string>|$CERT_VALUE|g" ./pocAdminCsr.yaml

CONTEXT_USR=pocAdmin
CURRENT_CONTEXT=pocContext
SERVICE_ACCOUNT=poc-servic-account


echo "---------------- Creating service account ${SERVICE_ACCOUNT} ---------------- "

kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: poc-service-accounts
EOF

echo "---------------- Apply user and role for ${CONTEXT_USR} ---------------- "
kubectl apply -f roles.yaml 
kubectl apply -f users.yaml 

echo "---------------- Approve CSR for ${CONTEXT_USR} ---------------- "
kubectl certificate approve ${CONTEXT_USR}

echo "---------------- Generate certs for ${CONTEXT_USR} ---------------- "
kubectl get csr ${CONTEXT_USR} -o jsonpath='{.status.certificate}'| base64 -d > ${CONTEXT_USR}.crt

echo "---------------- set credendtials to context ---------------- "

kubectl config set-credentials ${CONTEXT_USR} --client-key=${CONTEXT_USR}.key --client-certificate=${CONTEXT_USR}.crt --embed-certs=true
kubectl config set-context ${CURRENT_CONTEXT} --cluster=kubernetes --user=${CONTEXT_USR}
kubectl config use-context ${CURRENT_CONTEXT}

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
    cluster: ${CURRENT_CONTEXT}
    user: default
    namespace: kube-system
clusters:
- name: ${CURRENT_CONTEXT}
  cluster:
    certificate-authority-data: ${CLUSTER_CA}
    server: ${CLUSTER_SERVER}
users:
- name: default
  user:
    token: ${USER_TOKEN_VALUE}
EOF
