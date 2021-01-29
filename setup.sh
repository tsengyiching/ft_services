#!/bin/sh

# Start minikube
# --v=7 --alsologtostderr is for debugging mode
# --driver=virtualbox for school mac
# --driver=docker on vm
minikube delete
minikube start --driver=hyperkit

# Use the docker daemon from minikube
eval $(minikube docker-env)

# Build images
docker build -t my_nginx srcs/nginx
docker build -t my_mysql srcs/mysql

# Apply the MetalLB manifest yaml files, create controller and speaker
# Namespace is a virtual cluster supported by K8s
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml
# Create the MetalLB scret memberlist
kubectl create secret generic -n metallb-system memberlist  --from-literal=secretkey="$(openssl rand -base64 128)"

# Get minikube ip and apply it with metalLB 
export	MinikubeIP=$(minikube ip)
echo "      - $MinikubeIP-$MinikubeIP" >> srcs/metalLB.yaml

kubectl apply -f srcs/metalLB.yaml
kubectl apply -f srcs/nginx.yaml
kubectl apply -f srcs/mysql.yaml