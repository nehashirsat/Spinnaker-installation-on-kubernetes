# Spinnaker-installation-on-kubernetes


# prerequisite
- One Kubernetes cluster Spinnaker would be set-up in this cluster using Google Kubernetes Engine for the demonstration.
- One Virtual Machine (1 vCPU, 3.75 GB, Ubuntu 18.04) for installation of Halyard.
- One storage bucket for persistent storage of Spinnaker.


### Installation guide

#### Step 1: Create A Kubernetes Cluster

#### Step 2: Create One Machine To Install Halyard.

#### Step 3: Log in To The Machine

#### Step 4: Create Spinnaker User

```bash
adduser spinnaker
echo "spinnaker ALL=(ALL:ALL) NOPASSWD:ALL" > spinnaker && chmod 440 spinnaker && mv spinnaker /etc/sudoers.d/
su - spinnaker
```
### Step 5: Create An IAM Service Account And It’s Key
```bash
gcloud iam service-accounts create spinnaker \
--display-name "spinnaker" \
--project your-project


gcloud iam service-accounts keys create ~/.gcp/key.json \
--iam-account spinnaker@your-project.iam.gserviceaccount.com \
--project "your-project"
```


### Reference

https://www.magalix.com/blog/a-guide-on-the-installation-of-spinnaker-in-your-production-kubernetes-cluster

### Step 6: Run the bash script for installation of halyard and kubectl 
```bash
chmod +x halyard_kubectl_installation.sh
./halyard_kubectl_installation.sh
```

### Step 7: Create A Storage Bucket
```bash
BUCKET_NAME=spin-hal-bucket-demo
gsutil mb -l us-central1 -p cybage-devops gs://$BUCKET_NAME/
gsutil iam ch serviceAccount:spinnaker@your-project.iam.gserviceaccount.com:legacyBucketWriter gs://$BUCKET_NAME
```

### Step 7: Connect To Your Kubernetes Cluster On Your Halyard Machine
```bash
gcloud container clusters get-credentials <CLUSTER-NAME> --zone <ZONE> --project <PROJECT-NAME>
```

### Step 9: Create Kubernetes Service Account
```bash
CONTEXT=$(kubectl config current-context)
kubectl apply --context $CONTEXT -f https://spinnaker.io/downloads/kubernetes/service-account.yml
TOKEN=$(kubectl get secret --context $CONTEXT $(kubectl get serviceaccount spinnaker-service-account --context $CONTEXT -n spinnaker -o jsonpath='{.secrets[0].name}') -n spinnaker -o jsonpath='{.data.token}' | base64 --decode)
kubectl config set-credentials ${CONTEXT}-token-user --token $TOKEN
kubectl config set-context $CONTEXT --user ${CONTEXT}-token-user
```

### Step 10: Add The Kubernetes Cluster Into Halyard Config
```bash
hal config provider kubernetes enable
hal config provider kubernetes account add kubernetes-cluster-01 --provider-version v2 --context $(kubectl config current-context)
hal config features edit --artifacts true
```

### Step 11: Choose The Kubernetes Cluster in Which You Want To Install Spinnaker.
```bash
ACCOUNT=kubernetes-cluster-01
hal config deploy edit --type distributed --account-name $ACCOUNT
```

### Step 12: Add Storage Bucket in Halyard Config.
```bash
hal config storage gcs edit --bucket $BUCKET_NAME --project your-project --json-path ~/.gcp/key.json
hal config storage edit --type gcs
```
### Step 13: Check Available Spinnaker Versions And Deploy
```bash
hal version list
```
- Set VERSION with one of the listed versions:
```bash
VERSION=1.24.6
hal config version edit --version $VERSION
```

### Step 14: Deploy Spinnaker
```bash
hal deploy apply
```

## Post Installation Steps

- check all Spinnaker microservices running in spinnaker namespace:
```bash
kubectl get all -n spinnaker
```

- To Expose Spinnaker UI Outside Kubernetes Cluster, Change the service type to either Load Balancer or NodePort
```bash
kubectl -n spinnaker edit svc spin-deck
kubectl -n spinnaker edit svc spin-gate
```
- Update config and redeploy
```bash
hal config security ui edit --override-base-url "http://<LoadBalancerIP>:9000"
hal config security api edit --override-base-url "http://<LoadBalancerIP>:8084"
hal deploy apply
```
- If you used NodePort
```bash
hal config security ui edit --override-base-url "http://<worker-node-ip>:<nodePort>"
hal config security api edit --override-base-url "http://worker-node-ip>:<nodePort>"
hal deploy apply
```
