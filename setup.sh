#!/bin/sh
OS=`uname -s`
# Check Minikube installation
# minikube version
# if [ $? -ne 0 ]; then
# 	curl -Lo minikube https://github.com/kubernetes/minikube/releases/download/v1.13.1/minikube-linux-amd64
#  		chmod +x minikube
# 	echo "user42" | sudo -S mkdir -p /usr/local/bin/
# 	echo "user42" | sudo -S install minikube /usr/local/bin/
# fi

# Set Color
if [ "$OS" == "Darwin" ]; then
	RED='\033[1;31m'
	GREEN='\033[1;32m'
	YELLOW='\033[1;33m'
	BLUE='\033[1;34m'
	WHITE='\033[1;37m'
else
	RED='\e[0;31m'
	GREEN='\e[0;32m'
	YELLOW='\e[0;33m'
	BLUE='\e[0;34m'
	WHITE='\e[0;37m'
fi

# Start Minikube and get ip address
echo "${GREEN}Minikube Start${WHITE}"
if [ "$OS" == "Darwin" ]; then
	minikube delete
	minikube start --driver=hyperkit
	minikube addons enable metrics-server
	export	MinikubeIP=$(minikube ip)
	echo "${GREEN}Minikube IP = ${WHITE}$MinikubeIP"
else
	minikube delete
	minikube start --vm-driver=docker
	minikube addons enable dashboard
	minikube addons enable metrics-server
	export	MinikubeIP="$(kubectl get node -o=custom-columns='DATA:status.addresses[0].address' | sed -n 2p)"
	echo "${GREEN}Minikube IP = ${WHITE}$MinikubeIP"
fi

# Add Minikube IP in files
echo "${GREEN}Add Minikube IP on MetalLB, Ftps, Nginx, Wordpress${WHITE}"
cat srcs/metalLB.yaml.example > srcs/metalLB.yaml 
echo "      - $MinikubeIP-$MinikubeIP" >> srcs/metalLB.yaml
cat srcs/ftps/srcs/start_ftps.sh.example > srcs/ftps/srcs/start_ftps.sh
echo "vsftpd -opasv_min_port=21000 -opasv_max_port=21010 -opasv_address=$MinikubeIP /etc/vsftpd/vsftpd.conf" >> srcs/ftps/srcs/start_ftps.sh
cat srcs/nginx/srcs/nginx.conf.example > srcs/nginx/srcs/nginx.conf
echo "\t\tlocation /phpmyadmin {" >> srcs/nginx/srcs/nginx.conf
echo "\t\tproxy_pass          http://"$MinikubeIP":5000/;" >> srcs/nginx/srcs/nginx.conf
echo "\t\tproxy_set_header    Host \$host;" >> srcs/nginx/srcs/nginx.conf
echo "\t\tproxy_set_header    X-Real-IP \$remote_addr;" >> srcs/nginx/srcs/nginx.conf
echo "\t\tproxy_set_header    X-Forwarded-For \$proxy_add_x_forwarded_for;" >> srcs/nginx/srcs/nginx.conf
echo "\t\tproxy_set_header    X-Forwarded-Proto \$scheme;" >> srcs/nginx/srcs/nginx.conf
echo "\t\tproxy_redirect      /index.php  /phpmyadmin/index.php;" >> srcs/nginx/srcs/nginx.conf
echo "\t\t}" >> srcs/nginx/srcs/nginx.conf
echo "\t}" >> srcs/nginx/srcs/nginx.conf
echo "}" >> srcs/nginx/srcs/nginx.conf
echo "wp core install --url=https://$MinikubeIP:5050 --title=plop --admin_user=stud42 --admin_password=stud42 --admin_email=stud42@plop.fr --path='usr/share/webapps/wordpress/' --skip-email" > srcs/wordpress/srcs/setup.sh
echo "while [ \$? -ne 0 ] ; do" >> srcs/wordpress/srcs/setup.sh
echo "    wp core install --url=https://$MinikubeIP:5050 --title=plop --admin_user=stud42 --admin_password=stud42 --admin_email=stud42@plop.fr --path='usr/share/webapps/wordpress/' --skip-email" >> srcs/wordpress/srcs/setup.sh
echo "done" >> srcs/wordpress/srcs/setup.sh
echo "wp core install --url=https://$MinikubeIP:5050 --title=plop --admin_user=stud42 --admin_password=stud42 --admin_email=stud42@plop.fr --path='usr/share/webapps/wordpress/' --skip-email" >> srcs/wordpress/srcs/setup.sh
echo "wp user create test test@test.fr --first_name=test --last_name=test --user_pass=test --allow-root --path='usr/share/webapps/wordpress/'" >> srcs/wordpress/srcs/setup.sh
echo "wp user create lami lami@lami.fr --first_name=lami --last_name=lami --user_pass=lami --allow-root --path='usr/share/webapps/wordpress/'" >> srcs/wordpress/srcs/setup.sh
echo "wp user create skrrt skrrt@skrrt.fr --first_name=skrrt --last_name=skrrt --user_pass=skrrt --allow-root --path='usr/share/webapps/wordpress/'" >> srcs/wordpress/srcs/setup.sh
echo "(telegraf conf &) & php-fpm7 && nginx -g \"daemon off;\"" >> srcs/wordpress/srcs/setup.sh

# Use the docker daemon from minikube
echo "${GREEN}Link Minikube with Docker${WHITE}"
eval $(minikube docker-env)

# Build images
echo "${GREEN}Build Docker Images ${WHITE}"
echo "NGINX is buiding ..."
docker build -t my_nginx srcs/nginx > /dev/null 2>&1
echo "MYSQL is buiding ..."
docker build -t my_mysql srcs/mysql > /dev/null 2>&1
echo "WORDPRESS is buiding ..."
docker build -t my_wordpress srcs/wordpress > /dev/null 2>&1
echo "PHPMYADMIN is buiding ..."
docker build -t my_phpmyadmin srcs/phpmyadmin > /dev/null 2>&1
echo "FTPS is building ..."
docker build -t my_ftps srcs/ftps > /dev/null 2>&1
echo "INFLUXDB is building ..."
docker build -t my_influxdb srcs/influxdb > /dev/null 2>&1
echo "GRAFANA is building ..."
docker build -t my_grafana srcs/grafana > /dev/null 2>&1

# Apply the MetalLB manifest yaml files, create controller and speaker
# Namespace is a virtual cluster supported by K8s
echo "${GREEN}Create MetalLB namespace and memberlist${WHITE}"
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml
# Create the MetalLB scret memberlist
kubectl create secret generic -n metallb-system memberlist  --from-literal=secretkey="$(openssl rand -base64 128)"

# Deploy services
echo "${GREEN}Deploy Services${WHITE}"
kubectl apply -f srcs/metalLB.yaml
kubectl apply -f srcs/nginx.yaml
kubectl apply -f srcs/mysql.yaml
kubectl apply -f srcs/wordpress.yaml
kubectl apply -f srcs/phpmyadmin.yaml
kubectl apply -f srcs/ftps.yaml
kubectl apply -f srcs/influxdb.yaml
kubectl apply -f srcs/grafana.yaml

sleep 10

# Display services
echo "${BLUE}//////////////////////////////PODS///////////////////////////////${WHITE}"
kubectl get pod
echo "${BLUE}///////////////////////////DEPLOYMENTS//////////////////////////${WHITE}"
kubectl get deployment
echo "${BLUE}////////////////////////////SERVICES////////////////////////////${WHITE}"
kubectl get svc

##pkill commands
#kubectl exec deploy/nginx -- pkill nginx
#kubectl exec deploy/wordpress -- pkill nginx
#kubectl exec deploy/phpmyadmin -- pkill nginx
#kubectl exec deploy/grafana -- pkill grafana
#kubectl exec deploy/ftps -- pkill vsftpd 
#kubectl exec deploy/influxdb -- pkill influxd
#kubectl exec deploy/mysql -- pkill mysqld