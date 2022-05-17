source .env

mkdir tmp

if ! test -f "./tmp/$CLUSTER_NAME"; then
    ssh-keygen -f ed25519 -f ./tmp/$CLUSTER_NAME -P ""
fi

private_key_path="./tmp/$CLUSTER_NAME"
public_key_path="./tmp/$CLUSTER_NAME.pub"

terraform apply \
-auto-approve \
-var="num_workers=$NUM_WORKERS" \
-var="cluster_name=$CLUSTER_NAME" \
-var="ami=$AMI" \
-var="pub_key_path=$public_key_path" \
-var="private_key_path=$private_key_path" 