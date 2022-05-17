# Setup Kubernest cluster with Terraform

This example shows how to start a Kubernetes cluster using Terraform CLI. `run.sh` will take about 3 miniutes to start serveral ec2 instances and init a Kubernetes cluster using kubeadm and crio. `destroy.sh` will destroy the cluster.

## Setup
### 1. Prerequisites
1. An AWS account
2. [Terraform CLI](https://www.terraform.io/downloads)
3. ssh-keygen (self-signed key for aws connection)

### 2. Create an env file
Create a file named `.env` and fill out with the following template:
```
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=us-east-1

CLUSTER_NAME=
NUM_WORKERS=
AMI=ami-00f446ee544eb1520
```
(Note that this AMI contains everything you need to run `kubeadm init/join` directly. The AMI is set up by this [script](https://github.com/mikechesterwang/setup-kubeadm/blob/main/setup-ubuntu20.04.sh).)

### 3. Init Terraform
And then run
```
terraform init
```

## Operations
### 1. Start a cluster with ec2 instances
```bash
sh run.sh
```
### 2. Delete a cluster and terminate ec2 instances
```bash
sh destroy.sh
```

## Troubleshooting
 - remote-exec provisioner error: i/o timeout: A `remote-exec` script will connect to the remote server from your local machine. This would happen sometime since some IPs have troubles with the connection. Simply run `sh destroy.sh` to destroy the current resources and then run `sh run.sh` to start a cluster again. Or you can use a proxy for ssh tunnel for better connection in China:
    
    `.ssh/config`
    ```
    Host *
    ProxyCommand nc -X 5 -x <ip>:<socks5 port> %h %p
    ```
