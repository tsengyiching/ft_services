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
docker build -t my_wordpress srcs/wordpress
docker build -t my_phpmyadmin srcs/phpmyadmin
docker build -t my_influxdb srcs/influxdb
docker build -t my_grafana srcs/grafana

# Apply the MetalLB manifest yaml files, create controller and speaker
# Namespace is a virtual cluster supported by K8s
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml
# Create the MetalLB scret memberlist
kubectl create secret generic -n metallb-system memberlist  --from-literal=secretkey="$(openssl rand -base64 128)"

# Get minikube ip and apply it with metalLB 
export	MinikubeIP=$(minikube ip)
echo "      - $MinikubeIP-$MinikubeIP" >> srcs/metalLB.yaml

echo "vsftpd -opasv_min_port=21000 -opasv_max_port=21010 -opasv_address=$MinikubeIP /etc/vsftpd/vsftpd.conf" >> srcs/ftps/srcs/start_ftp.sh
docker build -t my_ftps srcs/ftps

kubectl apply -f srcs/metalLB.yaml
#kubectl apply -f srcs/secrets.yaml
kubectl apply -f srcs/nginx.yaml
kubectl apply -f srcs/mysql.yaml
kubectl apply -f srcs/wordpress.yaml
kubectl apply -f srcs/phpmyadmin.yaml
kubectl apply -f srcs/ftps.yaml
kubectl apply -f srcs/influxdb.yaml
kubectl apply -f srcs/grafana.yaml