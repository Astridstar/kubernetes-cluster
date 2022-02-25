#!/bin/sh

kubectl delete deployment postgres 
kubectl delete configmap,svc,pv,pvc -l app=postgres
