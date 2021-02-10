#!/bin/sh
OS=`uname -s`
if [ "$OS" == "Darwin" ]; then
	MinikubeIP=$(minikube ip)
else
    MinikubeIP="$(kubectl get node -o=custom-columns='DATA:status.addresses[0].address' | sed -n 2p)"
fi

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