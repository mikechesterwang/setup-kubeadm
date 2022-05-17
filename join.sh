while getopts 'ce:h:t:' OPTION; do
  case "$OPTION" in
    c)
      control_plane=1
      ;;
    e)
      endpoint="$OPTARG"
      ;;
    h)
      cert="$OPTARG"
      ;;
    t)
      token="$OPTARG"
      ;;
    ?)
      echo "c                      : create a control plnae instance in this node"
      echo "h [certificate hash]   : the hash value of the certificate"
      echo "e [endpoint ip address]: the endpoint of the control plane"
      echo "t [token]              : token"
      ;;
  esac
done

if [ "${endpoint}" == "" ]; then
  echo "ERROR: endpoint is empty. use -e to specify the endpoint."
  exit 1
fi

if [ "${token}" == "" ]; then
  echo "ERROR: token is empty. use -t to specify the token."
  exit 1
fi

if [ "${cert}" == "" ]; then
  echo "ERROR: hash is empty. use -h to specify the hash of certificate."
  exit 1
fi

if [ "${control_plane}" == 1 ]; then
  sudo kubeadm join $endpoint:6443 --cri-socket unix:///var/run/crio/crio.sock --token $token --discovery-token-ca-cert-hash sha256:$cert --control-plane
else
  sudo kubeadm join $endpoint:6443 --cri-socket unix:///var/run/crio/crio.sock --token $token --discovery-token-ca-cert-hash sha256:$cert
fi
