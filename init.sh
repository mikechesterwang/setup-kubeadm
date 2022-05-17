while getopts 'e:' OPTION; do
  case "$OPTION" in
    e)
      endpoint="$OPTARG"
      ;;
    ?)
      echo "e [endpoint ip address]: the endpoint of the control plane"
      ;;
  esac
done

if [ "${endpoint}" == "" ]; then
  echo "ERROR: endpoint is empty. use -e to specify the endpoint."
  exit 1
fi

sudo kubeadm init --cri-socket unix:///var/run/crio/crio.sock --pod-network-cidr 10.244.0.0/16 --control-plane-endpoint $endpoint:6443

# setup kubectl
unset KUBECONFIG
mkdir -p $HOME/.kube
sudo rm -f $HOME/.kube/config
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# apply pod network nodel
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

echo 'control plane all set'
