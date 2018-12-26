#!/bin/bash
kubectl apply -f ./dashboard
kubectl apply -f ./metrics-server/deploy/1.8+/
kubectl create clusterrolebinding traefik-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:traefik-ingress-controller
kubectl apply -f ./traefik
kubectl create clusterrolebinding heapster-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:heapster
#kubectl create serviceaccount --namespace kube-system tiller
#kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/influxdb.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/rbac/heapster-rbac.yaml
kubectl apply -f ./app-autoscaling

