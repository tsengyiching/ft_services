#!/bin/sh
OS=`uname -s`
if [ "$OS" == "Darwin" ]; then
		RED='\033[1;31m'
		GREEN='\033[1;32m'
		YELLOW='\033[1;33m'
		BLUE='\033[1;34m'
		NC='\033[0m'
else
		RED='\e[0;31m'
		GREEN='\e[0;32m'
		YELLOW='\e[0;33m'
		BLUE='\e[0;34m'
fi
# Start Minikube and get ip address
echo "${GREEN}minikube start${NC}"
if [ "$OS" == "Darwin" ]; then
	minikube delete
	minikube start --driver=hyperkit
	minikube addons enable dashboard > /dev/null 2>&1
	minikube addons enable metrics-server > /dev/null 2>&1
	export	MinikubeIP=$(minikube ip)
	echo "${BLUE}Minikube IP${NC}= $MinikubeIP"
else
	minikube delete
	minikube start --vm-driver=docker
	minikube addons enable dashboard > /dev/null 2>&1
	minikube addons enable metrics-server > /dev/null 2>&1
	export	MinikubeIP="$(kubectl get node -o=custom-columns='DATA:status.addresses[0].address' | sed -n 2p)"
	echo "${BLUE}Minikube IP${NC}= $MinikubeIP"
fi

# Add MinikubeIP in metalLB yaml file, ftps setup file and nginx config file
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
echo "wp core install --url=https://$MinikubeIP:5050 --title=plop --admin_user=stud42 --admin_password=stud42 --admin_email=stud42@plop.fr --path='/usr/share/webapps/wordpress/' --skip-email" >> srcs/wordpress/srcs/setup.sh
echo "while [ \$? -ne 0 ] ; do" >> srcs/wordpress/srcs/setup.sh
echo "    wp core install --url=https://$MinikubeIP:5050 --title=plop --admin_user=stud42 --admin_password=stud42 --admin_email=stud42@plop.fr --path='/usr/share/webapps/wordpress/' --skip-email" >> srcs/wordpress/srcs/setup.sh
echo "done" >> srcs/wordpress/srcs/setup.sh
echo "wp core install --url=https://$MinikubeIP:5050 --title=plop --admin_user=stud42 --admin_password=stud42 --admin_email=stud42@plop.fr --path='/usr/share/webapps/wordpress/' --skip-email" >> srcs/wordpress/srcs/setup.sh
echo "wp user create test test@test.fr --first_name=test --last_name=test --user_pass=test --role=follower --path='/usr/share/webapps/wordpress/'" >> srcs/wordpress/srcs/setup.sh
echo "wp user create test lami@lami.fr --first_name=lami --last_name=lami --user_pass=lami --role=lami --path='/usr/share/webapps/wordpress/'" >> srcs/wordpress/srcs/setup.sh
echo "wp user create test skrrt@skrrt.fr --first_name=skrrt --last_name=skrrt --user_pass=skrrt --role=skrrt --path='/usr/share/webapps/wordpress/'" >> srcs/wordpress/srcs/setup.sh
echo "(telegraf conf &) & php-fpm7 && nginx -g \"daemon off;\"" >> srcs/wordpress/srcs/setup.sh

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
