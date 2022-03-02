#!/bin/bash

echo "---------------- Resetting kubernetes cluster ---------------- "
sudo kubeadm reset --cri-socket /run/containerd/containerd.sock

sleep 3

echo "---------------- Deleting CNI configurations ---------------- "
sudo rm /etc/cni/net.d/*

echo "---------------- Deleting .kube folder ---------------- "
rm -rf  $HOME/.kube/

