# Docker-Self-Host-Project

The goal of this project is to self-host a html file and involve orchestration with Docker

# Config Kubernetes to make HTML content as a volume:

kubectl create configmap custom-website-html --from-file=index.html

kubectl apply -f deployment.yaml

kubectl apply -f service.yaml

minikube ip

# Create a Python virtual environment for Ansible Orchestration:

python3 -m venv venv and source venv/bin/activate

pip3 install ansible

pip3 install kubernetes

# Deploy the project via Ansible:

ansible-playbook deploy_website.yaml

deactivate
