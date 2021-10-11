#!/bin/bash

echo "---------------- Create kubernetes cluster ---------------- "
sudo kubeadm init --cri-socket /run/containerd/containerd.sock --pod-network-cidr 192.168.0.0/16

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

sleep 3

echo "---------------- Apply calico ---------------- "
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml 
