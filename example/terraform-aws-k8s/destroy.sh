source .env

terraform destroy \
-auto-approve \
-var="num_workers=$NUM_WORKERS" \
-var="cluster_name=$CLUSTER_NAME" \
-var="ami=$AMI" \
-var="pub_key_path=./tmp/$CLUSTER_NAME.pub" \
-var="private_key_path=./tmp/$CLUSTER_NAME" 
