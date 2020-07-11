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

## GKE with istio add-on

```
gcloud beta container clusters create $CLUSTER_NAME \
    --zone $CLUSTER_ZONE --num-nodes 4 \
    --machine-type "n1-standard-2" --image-type "COS" \
    --cluster-version=$CLUSTER_VERSION \
    --enable-stackdriver-kubernetes \
    --scopes "gke-default","compute-rw" \
    --enable-autoscaling --min-nodes 4 --max-nodes 8 \
    --enable-basic-auth \
    --addons=Istio --istio-config=auth=MTLS_STRICT

export GCLOUD_PROJECT=$(gcloud config get-value project)

gcloud container clusters get-credentials $CLUSTER_NAME \
    --zone $CLUSTER_ZONE --project $GCLOUD_PROJECT

kubectl create clusterrolebinding cluster-admin-binding \
    --clusterrole=cluster-admin \
    --user=$(gcloud config get-value core/account)

student_04_764b0cc6ef62@cloudshell:~ (qwiklabs-gcp-04-a5da6be4bdc1)$ gcloud container clusters list
NAME     LOCATION       MASTER_VERSION  MASTER_IP       MACHINE_TYPE   NODE_VERSION   NUM_NODES  STATUS
central  us-central1-b  1.16.10-gke.8   35.232.159.127  n1-standard-2  1.16.10-gke.8  4          RUNNING
student_04_764b0cc6ef62@cloudshell:~ (qwiklabs-gcp-04-a5da6be4bdc1)$

export LAB_DIR=$HOME/bookinfo-lab
export ISTIO_VERSION=1.4.6

mkdir $LAB_DIR
cd $LAB_DIR

curl -L https://git.io/getLatestIstio | ISTIO_VERSION=$ISTIO_VERSION sh -

cd ./istio-*

export PATH=$PWD/bin:$PATH

istioctl version
```

## Other sample config
```
student_04_764b0cc6ef62@cloudshell:~/bookinfo-lab/istio-1.4.6 (qwiklabs-gcp-04-a5da6be4bdc1)$ cat world.yml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: world-v1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: world
      version: v1
  template:
    metadata:
      labels:
        app: world
        version: v1
    spec:
      dnsPolicy: ClusterFirst
      containers:
      - name: service
        image: buoyantio/helloworld:0.1.4
        env:
        - name: POD_IP
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
        command:
        - "/bin/sh"
        - "-c"
        - "helloworld -addr=:7778 -text=world "
        ports:
        - name: service
          containerPort: 7778
---
apiVersion: v1
kind: Service
metadata:
  name: world-v1
spec:
  selector:
    app: world
    version: v1
  ports:
  - name: http
    port: 80
    targetPort: 7778
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: world-v2
spec:
  replicas: 1
  selector:
    matchLabels:
      app: world
      version: v2
  template:
    metadata:
      labels:
        app: world
        version: v2
    spec:
      dnsPolicy: ClusterFirst
      containers:
      - name: service
        image: buoyantio/helloworld:0.1.4
        env:
        - name: POD_IP
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
        command:

kubectl apply -f <(istioctl kube-inject -f samples/bookinfo/platform/kube/bookinfo.yaml)
student_04_764b0cc6ef62@cloudshell:~/bookinfo-lab/istio-1.4.6 (qwiklabs-gcp-04-a5da6be4bdc1)$ cat world-gateway.yml
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: world-gateway
spec:
  selector:
    istio: ingressgateway # use istio default controller
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "*.world.34.69.149.0.nip.io"
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: world
spec:
  hosts:
  - "*.world.34.69.149.0.nip.io"
  gateways:
  - world-gateway
  http:
  - route:
    - destination:
        host: world-v1
        port:
          number: 80
        - "/bin/sh"
        - "-c"
        - "helloworld -addr=:7778 -text=earth "
        ports:
        - name: service
          containerPort: 7778
---
apiVersion: v1
kind: Service
metadata:
  name: world-v2
spec:
  selector:
    app: world
    version: v2
  ports:
  - name: http
    port: 80
    targetPort: 7778
---
apiVersion: v1
kind: Service
metadata:
  name: world
spec:
  selector:
    app: world
  ports:
  - name: http
    port: 80
    targetPort: 7778
---
```


#### Setting up default account to use by gcloud
```
gcloud auth application-default login
```

## Unprivileged service accounts
All Kubernetes Engine nodes are assigned the default Compute Engine service account. This service account is fairly high privilege and has access to many GCP services. Because of the way the Google Cloud SDK is setup, software that you write will use the credentials assigned to the compute engine instance on which it is running. Since you don't want all of your containers to have the privileges that the default Compute Engine service account has, you need to make a least-privilege service account for your Kubernetes Engine nodes and then create more specific (but still least-privilege) service accounts for your containers.

The only two ways to get service account credentials are through:

- Your host instance (which you don't want)
- A credentials file

## Cloud SQL Proxy
The Cloud SQL Proxy allows you to offload the burden of creating and maintaining a connection to your Cloud SQL instance to the Cloud SQL Proxy process. Doing this allows your application to be unaware of the connection details and simplifies your secret management. The Cloud SQL Proxy comes pre-packaged by Google as a Docker container that you can run alongside your application container in the same Kubernetes Engine pod.

https://gcr.io/cloudsql-docker/gce-proxy:1.11

The application doesn't have to know anything about how to connect to Cloud SQL, nor does it have to have any exposure to its API. The Cloud SQL Proxy process takes care of that for the application. It's important to note that the Cloud SQL Proxy container is running as a 'sidecar' container in the pod.


## Binary Authorization

Binary Authorization is a GCP managed service that works closely with GKE to enforce deploy-time security controls to ensure that only trusted container images are deployed. With Binary Authorization you can whitelist container registries, require images to be signed by trusted authorities, and centrally enforce those policies. By enforcing this policy, you can gain tighter control over your container environment by ensuring only approved and/or verified images are integrated into the build-and-release process.

The Binary Authorization and Container Analysis APIs are based upon the open-source projects Grafeas and Kritis.

Grafeas defines an API spec for managing metadata about software resources, such as container images, Virtual Machine (VM) images, JAR files, and scripts. You can use Grafeas to define and aggregate information about your project’s components.

Kritis defines an API for ensuring a deployment is prevented unless the artifact (container image) is conformant to central policy and optionally has the necessary attestations present.

## Application Privileges

When configuring security, applications should be granted the smallest set of privileges that still allows them to operate correctly. When applications have more privileges than they need, they are more dangerous when compromised. In a Kubernetes cluster, these privileges can be grouped into the following broad levels:

- Host access: describes what permissions an application has on it's host node, outside of its container. This is controlled via Pod and Container security contexts, as well as app armor profiles.
- Network access: describes what other resources or workloads an application can access via the network. This is controlled with NetworkPolicies.
- Kubernetes API access: describes which API calls an application is allowed to make against. API access is controlled using the Role Based Access Control (RBAC) model via Role and RoleBinding definitions.


## Hardening

#### Obtain GCE instance metadata

```
curl -s http://metadata.google.internal/computeMetadata/v1beta1/instance/name

curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/name

curl -s http://metadata.google.internal/computeMetadata/v1beta1/instance/attributes/

curl -s http://metadata.google.internal/computeMetadata/v1beta1/instance/attributes/kube-env
```

There exists a high likelihood for compromise and exfiltration of sensitive kubelet bootstrapping credentials via the Compute Metadata endpoint. With the kubelet credentials, it is possible to leverage them in certain circumstances to escalate privileges to that of cluster-admin and therefore have full control of the GKE Cluster including all data, applications, and access to the underlying nodes.

By default, GCP projects with the Compute API enabled have a default service account in the format of NNNNNNNNNN-compute@developer.gserviceaccount.com in the project and the Editor role attached to it. Also by default, GKE clusters created without specifying a service account will utilize the default Compute service account and attach it to all worker nodes.

```
root@gcloud:/# curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/scopes
https://www.googleapis.com/auth/devstorage.read_only
https://www.googleapis.com/auth/logging.write
https://www.googleapis.com/auth/monitoring
https://www.googleapis.com/auth/service.management.readonly
https://www.googleapis.com/auth/servicecontrol
https://www.googleapis.com/auth/trace.append
```

The combination of authentication scopes and the permissions of the service account dictates what applications on this node can access. The above list is the minimum scopes needed for most GKE clusters, but some use cases require increased scopes.

If the authentication scope were to be configured during cluster creation to include https://www.googleapis.com/auth/cloud-platform, this would allow any GCP API to be considered "in scope", and only the IAM permissions assigned to the service account would determine what can be accessed. 

If the default service account is in use and the default IAM Role of Editor was not modified, this effectively means that any pod on this node pool has Editor permissions to the GCP project where the GKE cluster is deployed. As the Editor IAM Role has a wide range of read/write permissions to interact with resources in the project such as Compute instances, GCS buckets, GCR registries, and more, this is most likely not desired.

## Deploy a pod that mounts the host filesystem

One of the simplest paths for "escaping" to the underlying host is by mounting the host's filesystem into the pod's filesystem using standard Kubernetes volumes and volumeMounts in a Pod specification.

```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: hostpath
spec:
  containers:
  - name: hostpath
    image: google/cloud-sdk:latest
    command: ["/bin/bash"]
    args: ["-c", "tail -f /dev/null"]
    volumeMounts:
    - mountPath: /rootfs
      name: rootfs
  volumes:
  - name: rootfs
    hostPath:
      path: /
EOF
pod/hostpath created
student_02_7dbd9427a5b8@cloudshell:~ (qwiklabs-gcp-02-6368d7ae6818)$ kubectl exec -it hostpath -- bash
root@hostpath:/# chroot /rootfs /bin/bash
hostpath / #
```

With those simple commands, the pod is now effectively a root shell on the node. You are now able to do the following:

run the standard docker command with full permissions

docker ps

list docker images

docker images

docker run a privileged container of your choosing

docker run --privileged <imagename>:<imageversion>

examine the Kubernetes secrets mounted

mount | grep volumes | awk '{print $3}' | xargs ls

exec into any running container (even into another pod in another namespace)

docker exec -it <docker container ID> sh

Nearly every operation that the root user can perform is available to this pod shell. This includes persistence mechanisms like adding SSH users/keys, running privileged docker containers on the host outside the view of Kubernetes, and much more.

## Available controls

- Disabling the Legacy GCE Metadata API Endpoint - By specifying a custom metadata key and value, the v1beta1 metadata endpoint will no longer be available from the instance.

- Enable Metadata Concealment - Passing an additional configuration during cluster and/or node pool creation, a lightweight proxy will be installed on each node that proxies all requests to the Metadata API and prevents access to sensitive endpoints.

- Enable and configure PodSecurityPolicy - Configuring this option on a GKE cluster will add the PodSecurityPolicy Admission Controller which can be used to restrict the use of insecure settings during Pod creation. In this demo's case, preventing containers from running as the root user and having the ability to mount the underlying host filesystem.


```
gcloud beta container node-pools create second-pool --cluster=simplecluster --zone=$MY_ZONE --num-nodes=1 --metadata=disable-legacy-endpoints=true --workload-metadata-from-node=SECURE
```

Note: In GKE versions 1.12 and newer, the --metadata=disable-legacy-endpoints=true setting will automatically be enabled. 

```
kubectl run -it --rm gcloud --image=google/cloud-sdk:latest --restart=Never --overrides='{ "apiVersion": "v1", "spec": { "securityContext": { "runAsUser": 65534, "fsGroup": 65534 }, "nodeSelector": { "cloud.google.com/gke-nodepool": "second-pool" } } }' -- bash

These will fail:
curl -s http://metadata.google.internal/computeMetadata/v1beta1/instance/name

curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/kube-env

Non-sensitive data will still be available
curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/name
```

## Pod Security Policy

```
kubectl create clusterrolebinding clusteradmin --clusterrole=cluster-admin --user="$(gcloud config list account --format 'value(core.account)')"

cat <<EOF | kubectl apply -f -
---
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  name: restrictive-psp
  annotations:
    seccomp.security.alpha.kubernetes.io/allowedProfileNames: 'docker/default'
    apparmor.security.beta.kubernetes.io/allowedProfileNames: 'runtime/default'
    seccomp.security.alpha.kubernetes.io/defaultProfileName:  'docker/default'
    apparmor.security.beta.kubernetes.io/defaultProfileName:  'runtime/default'
spec:
  privileged: false
  # Required to prevent escalations to root.
  allowPrivilegeEscalation: false
  # This is redundant with non-root + disallow privilege escalation,
  # but we can provide it for defense in depth.
  requiredDropCapabilities:
    - ALL
  # Allow core volume types.
  volumes:
    - 'configMap'
    - 'emptyDir'
    - 'projected'
    - 'secret'
    - 'downwardAPI'
    # Assume that persistentVolumes set up by the cluster admin are safe to use.
    - 'persistentVolumeClaim'
  hostNetwork: false
  hostIPC: false
  hostPID: false
  runAsUser:
    # Require the container to run without root privileges.
    rule: 'MustRunAsNonRoot'
  seLinux:
    # This policy assumes the nodes are using AppArmor rather than SELinux.
    rule: 'RunAsAny'
  supplementalGroups:
    rule: 'MustRunAs'
    ranges:
      # Forbid adding the root group.
      - min: 1
        max: 65535
  fsGroup:
    rule: 'MustRunAs'
    ranges:
      # Forbid adding the root group.
      - min: 1
        max: 65535
EOF

cat <<EOF | kubectl apply -f -
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: restrictive-psp
rules:
- apiGroups:
  - extensions
  resources:
  - podsecuritypolicies
  resourceNames:
  - restrictive-psp
  verbs:
  - use
EOF

cat <<EOF | kubectl apply -f -
---
# All service accounts in kube-system
# can 'use' the 'permissive-psp' PSP
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: restrictive-psp
  namespace: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: restrictive-psp
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:authenticated
EOF

Note: In a real environment, consider replacing the system:authenticated user in the RoleBinding with the specific user or service accounts that you want to have the ability to create pods in the default namespace.

Next, enable the PodSecurityPolicy Admission Controller:

gcloud beta container clusters update simplecluster --zone $MY_ZONE --enable-pod-security-policy

```
## Validate Pod Security Policy
```
gcloud iam service-accounts create demo-developer
MYPROJECT=$(gcloud config list --format 'value(core.project)')
gcloud iam service-accounts keys create key.json --iam-account "demo-developer@${MYPROJECT}.iam.gserviceaccount.com"
gcloud auth activate-service-account --key-file=key.json
gcloud container clusters get-credentials simplecluster --zone $MY_ZONE
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: hostpath
spec:
  containers:
  - name: hostpath
    image: google/cloud-sdk:latest
    command: ["/bin/bash"]
    args: ["-c", "tail -f /dev/null"]
    volumeMounts:
    - mountPath: /rootfs
      name: rootfs
  volumes:
  - name: rootfs
    hostPath:
      path: /
EOF
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: hostpath
spec:
  securityContext:
    runAsUser: 1000
    fsGroup: 2000
  containers:
  - name: hostpath
    image: google/cloud-sdk:latest
    command: ["/bin/bash"]
    args: ["-c", "tail -f /dev/null"]
EOF
kubectl get pod hostpath -o=jsonpath="{ .metadata.annotations.kubernetes\.io/psp }"
```