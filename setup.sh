# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    setup.sh                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: alicetetu <marvin@42.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/04/23 17:35:31 by alicetetu         #+#    #+#              #
#    Updated: 2020/04/27 21:23:58 by alicetetu        ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

services="nginx mysql wordpress phpmyadmin ftps influxdb telegraf grafana"

#Filezilla
echo "user42" | sudo -S apt install -y filezilla

#Delete all minikube elements
echo "Deleting all possible Minikube elements"
minikube delete
docker rm $(docker ps -a -q)

#launch of minikube
echo "Minikube starting...\n"
minikube start --memory 3000 --vm-driver=docker --extra-config=apiserver.service-node-port-range=1-35000
minikube addons enable ingress
minikube addons enable dashboard
minikube addons enable metrics-server

#stockage of minikube ip
MINIKUBE_IP=`minikube ip`
echo "minikube ip: $MINIKUBE_IP"

#File configuration
echo "File configuration..."
cp srcs/containers/ftps/start_model.sh srcs/containers/ftps/start.sh
cp srcs/containers/mysql/wordpress_model.sql srcs/containers/mysql/wordpress.sql
cp srcs/containers/nginx/index_model.html srcs/containers/nginx/index.html
cp srcs/containers/telegraf/telegraf_model.conf srcs/containers/telegraf/telegraf.conf

sed -i 's/MINIKUBE_IP/'"$MINIKUBE_IP"'/g' srcs/containers/ftps/start.sh
sed -i 's/MINIKUBE_IP/'"$MINIKUBE_IP"'/g' srcs/containers/mysql/wordpress.sql
sed -i 's/MINIKUBE_IP/'"$MINIKUBE_IP"'/g' srcs/containers/nginx/index.html
sed -i 's/MINIKUBE_IP/'"$MINIKUBE_IP"'/g' srcs/containers/telegraf/telegraf.conf

# necessary for docker images
eval $(minikube docker-env)

# build docker images + deployment
for service in $services
do
	echo "Building of $service image\n"
	docker build -t $service-image srcs/containers/$service
	echo "Deployment of $service service\n"
	kubectl apply -f srcs/deployments/$service-deployment.yaml
done

echo "Deployment of ingress\n"
kubectl apply -f srcs/deployments/ingress-deployment.yaml

echo "\033[01;34m\nSITES\n"
echo "Nginx: http://$MINIKUBE_IP (or https)"
echo "Nginx ssh: ssh admin@$MINIKUBE_IP -p 2222"
echo "Account: admin/admin"
echo "Nginx ftps: open Filezilla"
echo "Account: $MINIKUBE_IP/admin/password/21\n"
echo "Grafana: http://$MINIKUBE_IP:3000"
echo "Account : admin/password\n"
echo "Wordpress: http://$MINIKUBE_IP:5050"
echo "Accounts: admin/admin - user1/user1 - user2/user2\n"
echo "Phpmyadmin: http://$MINIKUBE_IP:5000"
echo "Account: admin/admin\n"
echo "Dashboard: enter \"minikube dashboard\""

#TO TEST PERSISTENT DATABASES
#kubectl exec -it $(kubectl get pods | grep mysql | cut -d" " -f1) -- /bin/sh -c "ps"
#kubectl exec -it $(kubectl get pods | grep mysql | cut -d" " -f1) -- /bin/sh -c "kill 1"
