sudo kubeadm join $ENDPOINT_IP:6443 --cri-socket unix:///var/run/crio/crio.sock --token $TOKEN --discovery-token-ca-cert-hash sha256:$CERT
