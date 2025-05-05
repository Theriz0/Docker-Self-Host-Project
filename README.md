# Kubernetes Orchestration via Ansible

## Project Goal

This project aims to demonstrate how to self-host a simple HTML website using Docker and manage its deployment and lifecycle within a local Kubernetes cluster (Minikube) using Ansible for automation.

## Project Components

1.  **`index.html`**: The HTML file containing the content of the website you want to self-host.
2.  **`deployment.yaml`**: A Kubernetes Deployment definition that describes how your website's container (running Nginx) should be deployed and managed. It uses a ConfigMap to mount the HTML content.
3.  **`service.yaml`**: A Kubernetes Service definition that exposes your website to the network using a NodePort.
4.  **`ingress-https.yaml`**: A Kubernetes Ingress definition to expose the service externally via HTTPS.
5.  **`deploy_website.yaml`**: An Ansible Playbook that automates the following steps:
    * Creating a Kubernetes ConfigMap from the `index.html` file.
    * Applying the Kubernetes Deployment defined in `deployment.yaml`.
    * Applying the Kubernetes Service defined in `service.yaml`.

## Prerequisites

Before you begin, ensure you have the following installed on your system:

* **Docker**: For containerizing the Nginx web server.
* **Minikube**: A tool for running a single-node Kubernetes cluster locally. Follow the installation instructions on the official Minikube website: [https://minikube.sigs.k8s.io/docs/start/](https://minikube.sigs.k8s.io/docs/start/)
* **kubectl**: The Kubernetes command-line tool. Minikube usually installs this or provides instructions.
* **Python 3**: Required for Ansible.
* **pip**: The Python package installer.
* **Ansible**: For automating the deployment to Kubernetes. Install within a virtual environment (see setup).
* **Kubernetes Python Client**: Ansible uses this to interact with the Kubernetes API. Install within the virtual environment (see setup).

## Setup and Deployment

Follow these steps to deploy your self-hosted website:

**1. Prepare Your Website Content:**

* Ensure your `index.html` file is in the project directory. You can add other static assets (CSS, JavaScript, images) later, which would require updating the ConfigMap or using a different volume source.

**2. Configure Kubernetes Manifests:**

* **`deployment.yaml`**: This file defines how your Nginx container will run. It specifies:
    * A single replica of the Pod.
    * A selector to manage Pods with the label `app: my-website`.
    * A template for the Pod, including:
        * A volume named `html-volume` sourced from the `custom-website-html` ConfigMap.
        * A container named `nginx-container` using the `nginx:latest` image.
        * Port 80 exposed on the container.
        * A volume mount to map the `html-volume` to Nginx's web root (`/usr/share/nginx/html`) as read-only.
    * **Important:** Ensure `metadata.namespace: default` is present.
* **`service.yaml`**: This file defines how to expose your Nginx Pod:
    * A selector that matches Pods with the label `app: my-website`.
    * A mapping of the Service's port 80 to the Pod's target port 80.
    * A `type: NodePort` to expose the service on a specific port (31000 in this case) on all Minikube nodes.
    * **Important:** Ensure `metadata.namespace: default` is present.

**3. Set Up Ansible for Orchestration:**

* **Create a Python Virtual Environment:**
    ```bash
    python3 -m venv venv
    source venv/bin/activate
    ```
* **Install Ansible, Kubernetes Python Client and minikube addons:**
    ```bash
    pip3 install ansible
    pip3 install kubernetes
    minikube addons enable ingress
    ```

**4. Generate Self-Signed Certificates and Create Kubernetes Secret:**

   These steps are done manually before running the Ansible playbook:

   ```bash
   openssl genrsa -out tls.key 2048
   openssl req -new -key tls.key -out server.csr -subj "/CN=<domain-you-want>" # Use your desired DNS name
   openssl x509 -req -days 365 -in server.csr -signkey tls.key -out tls.crt
   kubectl create secret tls tls-secret --key tls.key --cert tls.crt
   ```

**5. Deploy using Ansible:**

* Run the Ansible Playbook `deploy_website.yaml`:
    ```bash
    ansible-playbook deploy_website.yaml
    ```
    This playbook will:
    * Create the `custom-website-html` ConfigMap from your `index.html` file in the `default` namespace.
    * Apply the Deployment defined in `deployment.yaml` to the `default` namespace.
    * Apply the Service defined in `service.yaml` to the `default` namespace.

**6. Access Your Deployed Website:**

* Get the IP address of your Minikube cluster:
    ```bash
    minikube ip
    ```
* Open your web browser and navigate to the following URL, replacing `<minikube-ip>` with the actual IP address:
    ```
    https://<minikubeIP-pointed-domain>
    ```
    You should now see your self-hosted HTML content.
  
**7. Deactivate the Virtual Environment (Optional):**
   ```bash
   kubectl get ingress my-website-ingress-https -n default
   kubectl get svc my-website-service -n default
   kubectl get pods -l app=my-website -n default
   ```
  
**8. Deactivate the Virtual Environment (Optional):**
   ```bash
   deactivate
