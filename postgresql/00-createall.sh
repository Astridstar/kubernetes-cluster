#!/bin/sh

echo "Applying the config maps"
kubectl apply -f 01-ConfigMap.yaml

echo "Applying the pv and pvcs"
kubectl apply -f 02-storage.yaml

echo "Applying the deployments"
kubectl apply -f 03-deployment.yaml

echo "Applying the services"
kubectl apply -f 04-svc.yaml

#echo "Applying tcp routing in traefik"
#kubectl apply -f 05-traefik.yaml
