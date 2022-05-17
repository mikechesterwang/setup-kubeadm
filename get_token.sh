if ! [ -x "$(command -v jq)" ]; then
    echo "jq not found, please install jq at first: https://stedolan.github.io/jq/download/" 
    exit 1
fi

# parse input
eval "$(jq -r '@sh "user=\(.user) ip=\(.ip) private_key_path=\(.private_key_path)"')"

jq -n --arg token "$(ssh -o "StrictHostKeyChecking no" $user@$ip -i $private_key_path "sudo kubeadm token create")" --arg cert "$(ssh $user@$ip -i $private_key_path "openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'")" '{"token": $token, "cert": $cert}' 
