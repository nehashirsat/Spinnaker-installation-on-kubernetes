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

### Step 5: Run the bash script for installation of halyard and kubectl 
