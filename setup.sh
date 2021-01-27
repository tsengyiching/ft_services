# Start minikube
# --v=7 --alsologtostderr is for debugging mode
# need to remove it later
minikube start --driver=hyperkit

# Use the docker daemon from minikube
eval $(minikube docker-env)

# Apply the MetalLB manifest yaml files, create controller and speaker
# Namespace is a virtual cluster supported by K8s
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml
export	MinikubeIP=$(minikube ip)
echo "      - $MinikubeIP-$MinikubeIP" >> srcs/metallb.yaml
kubectl apply -f srcs/metalLB.yaml

# Create the MetalLB scret memberlist
kubectl create secret generic -n metallb-system memberlist  --from-literal=secretkey="$(openssl rand -base64 128)"

docker build -t my_nginx srcs/nginx
kubectl apply -f srcs/nginx.yaml