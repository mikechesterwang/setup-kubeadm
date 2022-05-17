if [ "${ENDPOINT_IP}" == "" ]; then
    control_plane_ip=$(hostname)
else
    control_plane_ip=${ENDPOINT_IP}
fi

sudo kubeadm init --cri-socket unix:///var/run/crio/crio.sock --pod-network-cidr 10.244.0.0/16 --control-plane-endpoint $control_plane_ip:6443

# setup kubectl
unset KUBECONFIG
mkdir -p $HOME/.kube
sudo rm -f $HOME/.kube/config
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# apply pod network nodel
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
echo 'control plane all set'
