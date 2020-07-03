## GKE

#### List all available zones
```
gcloud compute zones list
```

#### Set a default zone
```
gcloud config set compute/zone us-central1-a
```

#### Create a private GKE cluster
When you create a private cluster, you must specify a /28 CIDR range for the VMs that run the Kubernetes master components and you need to enable IP aliases.

Next you'll create a cluster named private-cluster, and specify a CIDR range of 172.16.0.16/28 for the masters. When you enable IP aliases, you let Kubernetes Engine automatically create a subnetwork for you.

You'll create the private cluster by using the --private-cluster, --master-ipv4-cidr, and --enable-ip-alias flags.
```
gcloud beta container clusters create private-cluster \
    --enable-private-nodes \
    --master-ipv4-cidr 172.16.0.16/28 \
    --enable-ip-alias \
    --create-subnetwork ""
```

#### List subnets in default network
```
gcloud compute networks subnets list --network default
```

#### Describe the us-central subnet
```
gcloud compute networks subnets describe gke-private-cluster-subnet-93bff8da --region us-central1
creationTimestamp: '2020-07-02T17:35:59.106-07:00'
description: auto-created subnetwork for cluster "private-cluster"
fingerprint: lTJtpuoWSUw=
gatewayAddress: 10.33.40.1
id: '7821834278002738048'
ipCidrRange: 10.33.40.0/22
kind: compute#subnetwork
name: gke-private-cluster-subnet-93bff8da
network: https://www.googleapis.com/compute/v1/projects/qwiklabs-gcp-01-fb128e93aa13/global/networks/default
privateIpGoogleAccess: true
privateIpv6GoogleAccess: DISABLE_GOOGLE_ACCESS
purpose: PRIVATE
region: https://www.googleapis.com/compute/v1/projects/qwiklabs-gcp-01-fb128e93aa13/regions/us-central1
secondaryIpRanges:
- ipCidrRange: 10.33.0.0/20
  rangeName: gke-private-cluster-services-93bff8da
- ipCidrRange: 10.36.0.0/14
  rangeName: gke-private-cluster-pods-93bff8da
selfLink: https://www.googleapis.com/compute/v1/projects/qwiklabs-gcp-01-fb128e93aa13/regions/us-central1/subnetworks/gke-private-cluster-subnet-93bff8da
```

#### Create a VM which you'll use to check the connectivity to Kubernetes clusters:
```
gcloud compute instances create source-instance --zone us-central1-a --scopes 'https://www.googleapis.com/auth/cloud-platform'


student_01_d35b916c5179@cloudshell:~ (qwiklabs-gcp-01-fb128e93aa13)$ gcloud compute instances describe source-instance --zone us-central1-a | grep natIP
    natIP: 104.198.223.126

student_01_d35b916c5179@cloudshell:~(qwiklabs-gcp-01-fb128e93aa13)$ gcloud container clusters update private-cluster \
>     --enable-master-authorized-networks \
>     --master-authorized-networks 104.198.223.126/32
Updating private-cluster...done.
Updated [https://container.googleapis.com/v1/projects/qwiklabs-gcp-01-fb128e93aa13/zones/us-central1-a/clusters/private-cluster].
To inspect the contents of your cluster, go to: https://console.cloud.google.com/kubernetes/workload_/gcloud/us-central1-a/private-cluster?project=qwiklabs-gcp-01-fb128e93aa13


student_01_d35b916c5179@cloudshell:~ (qwiklabs-gcp-01-fb128e93aa13)$ gcloud compute ssh source-instance --zone us-central1-a

sudo apt-get install kubectl

gcloud container clusters get-credentials private-cluster --zone us-central1-a

kubectl get nodes --output yaml | grep -A4 addresses

    addresses:
    - address: 10.33.40.4
      type: InternalIP
    - address: ""
      type: ExternalIP
--
    addresses:
    - address: 10.33.40.2
      type: InternalIP
    - address: ""
      type: ExternalIP
--
    addresses:
    - address: 10.33.40.3
      type: InternalIP
    - address: ""
      type: ExternalIP

kubectl get nodes --output wide
NAME                                             STATUS   ROLES    AGE   VERSION           INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                             KERNEL-VERSION   CONTAINER-RUNTIME
gke-private-cluster-default-pool-c15fbe6d-0m01   Ready    <none>   15m   v1.14.10-gke.36   10.33.40.4                  Container-Optimized OS from Google   4.14.138+        docker://18.9.7
gke-private-cluster-default-pool-c15fbe6d-7mrs   Ready    <none>   15m   v1.14.10-gke.36   10.33.40.2                  Container-Optimized OS from Google   4.14.138+        docker://18.9.7
gke-private-cluster-default-pool-c15fbe6d-slcv   Ready    <none>   15m   v1.14.10-gke.36   10.33.40.3                  Container-Optimized OS from Google   4.14.138+        docker://18.9.7
student-01-d35b916c5179@source-instance:~$

gcloud container clusters delete private-cluster --zone us-central1-a

```

#### Create private GKE cluster with custom network

You'll create your own custom subnetwork, and then create a private cluster. Your subnetwork has a primary address range and two secondary address ranges.


```
gcloud compute networks subnets create my-subnet \
    --network default \
    --range 10.0.4.0/22 \
    --enable-private-ip-google-access \
    --region us-central1 \
    --secondary-range my-svc-range=10.0.32.0/20,my-pod-range=10.4.0.0/14
```

#### Create private cluster using the custom subnets
```
gcloud beta container clusters create private-cluster2 \
    --enable-private-nodes \
    --enable-ip-alias \
    --master-ipv4-cidr 172.16.0.32/28 \
    --subnetwork my-subnet \
    --services-secondary-range-name my-svc-range \
    --cluster-secondary-range-name my-pod-range
```

#### Provide VM access to the new private cluster
```
gcloud container clusters update private-cluster2 \
    --enable-master-authorized-networks \
    --master-authorized-networks 104.198.223.126/32
```

#### Validate
```
student-01-d35b916c5179@source-instance:~$ kubectl get nodes --output yaml | grep -A4 addresses
    addresses:
    - address: 10.0.4.4
      type: InternalIP
    - address: ""
      type: ExternalIP
--
    addresses:
    - address: 10.0.4.2
      type: InternalIP
    - address: ""
      type: ExternalIP
--
    addresses:
    - address: 10.0.4.3
      type: InternalIP
    - address: ""
      type: ExternalIP
```