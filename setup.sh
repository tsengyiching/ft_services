#!/bin/sh
OS=`uname -s`
# Start Minikube and get ip address
if [ "$OS" == "Darwin" ]; then
	minikube delete
	minikube start --driver=hyperkit
	export	MinikubeIP=$(minikube ip)
else
	minikube delete
	minikube start --vm-driver=docker
	export	MinikubeIP="$(kubectl get node -o=custom-columns='DATA:status.addresses[0].address' | sed -n 2p)"
fi

# Add MinikubeIP in metalLB yaml file and ftps setup file
cat srcs/metalLB.yaml.example > srcs/metalLB.yaml 
echo "      - $MinikubeIP-$MinikubeIP" >> srcs/metalLB.yaml
cat srcs/ftps/srcs/start_ftps.sh.example > srcs/ftps/srcs/start_ftps.sh
echo "vsftpd -opasv_min_port=21000 -opasv_max_port=21010 -opasv_address=$MinikubeIP /etc/vsftpd/vsftpd.conf" >> srcs/ftps/srcs/start_ftps.sh

# Use the docker daemon from minikube
eval $(minikube docker-env)

# Build images
docker build -t my_nginx srcs/nginx
docker build -t my_mysql srcs/mysql
docker build -t my_wordpress srcs/wordpress
docker build -t my_phpmyadmin srcs/phpmyadmin
docker build -t my_ftps srcs/ftps
docker build -t my_influxdb srcs/influxdb
docker build -t my_grafana srcs/grafana

# Apply the MetalLB manifest yaml files, create controller and speaker
# Namespace is a virtual cluster supported by K8s
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml
# Create the MetalLB scret memberlist
kubectl create secret generic -n metallb-system memberlist  --from-literal=secretkey="$(openssl rand -base64 128)"

# Deploy services
kubectl apply -f srcs/metalLB.yaml
kubectl apply -f srcs/nginx.yaml
kubectl apply -f srcs/mysql.yaml
kubectl apply -f srcs/wordpress.yaml
kubectl apply -f srcs/phpmyadmin.yaml
kubectl apply -f srcs/ftps.yaml
kubectl apply -f srcs/influxdb.yaml
kubectl apply -f srcs/grafana.yaml

# function clear {
# 	# Clear modified files
# 	echo "Clear metalLB.yaml"
# 	rm srcs/metalLB.yaml
# 	echo "Clear start_ftps.sh"
# 	rm srcs/ftps/srcs/start_ftps.sh
# }

# # $arguments 
# if [ $1 == "clear" ]; then
# 	clear;
# fi