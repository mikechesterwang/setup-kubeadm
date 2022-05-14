curl -s https://raw.githubusercontent.com/mikechesterwang/setup-kubeadm/main/setup-ubuntu20.04.sh | sudo bash
sudo kubeadm init --cri-socket unix:///var/run/crio/crio.sock --pod-network-cidr 10.244.0.0/16 --control-plane-endpoint $(hostname):
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
