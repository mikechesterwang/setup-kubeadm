# setup docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# download go
curl -O https://dl.google.com/go/go1.18.2.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.18.2.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
go version

# setup cri-dockerd 
git clone https://github.com/Mirantis/cri-dockerd.git
cd cri-dockerd && mkdir bin && cd src && go get && go build -o ../bin/cri-dockerd
cd ..
# run the following in ./cri-dockerd
sudo mkdir -p /usr/local/bin
sudo install -o root -g root -m 0755 bin/cri-dockerd /usr/local/bin/cri-dockerd
sudo cp -a packaging/systemd/* /etc/systemd/system
sudo sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
sudo systemctl daemon-reload
sudo systemctl enable cri-docker.service
sudo systemctl enable --now cri-docker.socket

# kubeadm
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# kubeadm (control-plane)
sudo kubeadm init --cri-socket unix://var/run/cri-dockerd/sock --control-plane-endpoint 172.31.30.11:6443 ----pod-network-cidr 172.31.0.0/16

# kubeadm (worker node) join
sudo kubeadm join 172.31.30.11:6443 --token zfb0j4.f6g5jdu5rd6ft3mm --discovery-token-ca-cert-hash sha256:848edcb354a4391ea62cebeeb05730e87640c8297106a4b75bb23a502a2a140f --cri-socket unix://var/run/cri-dockerd.sock

# setup kubectl 
unset KUBECONFIG
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# apply flannel (control-plane)
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml




