## Private GKE cluster

### Create brand new project
```
gcloud projects create --name "GKE sample project"
gcloud config set project <project-id>
```

### Set the billing account and enable container API
```
gcloud beta billing accounts list
gcloud beta billing projects link <project-id> --billing-account=<billing-account>
gcloud services enable container.googleapis.com
```

### Provision the cluster
```
terraform init
terraform plan
terraform apply
```

### Use the cluster
- Get the kubeconfig to access the cluster
```
$ gcloud container clusters get-credentials my-gke-cluster-prod --region us-central1
```

- Get the list of container nodes (google compute engine instances)
```
$ kubectl get nodes -o wide
NAME                                              STATUS   ROLES    AGE   VERSION             INTERNAL-IP   EXTERNAL-IP      OS-IMAGE                             KERNEL-VERSION   CONTAINER-RUNTIME
gke-my-gke-cluster-prod-node-pool-3b58a6fa-bd0g   Ready    <none>   90s   v1.19.10-gke.1600   10.10.0.4     34.68.81.58      Container-Optimized OS from Google   5.4.89+          docker://19.3.14
gke-my-gke-cluster-prod-node-pool-761d059b-xvt3   Ready    <none>   98s   v1.19.10-gke.1600   10.10.0.2     34.121.239.130   Container-Optimized OS from Google   5.4.89+          docker://19.3.14
gke-my-gke-cluster-prod-node-pool-8dd223d0-gxrp   Ready    <none>   98s   v1.19.10-gke.1600   10.10.0.3     35.223.232.98    Container-Optimized OS from Google   5.4.89+          docker://19.3.14

$ gcloud compute instances list
NAME                                             ZONE           MACHINE_TYPE  PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP     STATUS
gke-my-gke-cluster-prod-node-pool-3b58a6fa-bd0g  us-central1-a  e2-medium                  10.10.0.4    34.68.81.58     RUNNING
gke-my-gke-cluster-prod-node-pool-8dd223d0-gxrp  us-central1-b  e2-medium                  10.10.0.3    35.223.232.98   RUNNING
gke-my-gke-cluster-prod-node-pool-761d059b-xvt3  us-central1-c  e2-medium                  10.10.0.2    34.121.239.130  RUNNING

$ gcloud compute instance-groups list
NAME                                               LOCATION       SCOPE  NETWORK           MANAGED  INSTANCES
gke-my-gke-cluster-prod-default-pool-750be23e-grp  us-central1-a  zone   gke-network-prod  Yes      0
gke-my-gke-cluster-prod-node-pool-3b58a6fa-grp     us-central1-a  zone   gke-network-prod  Yes      1
gke-my-gke-cluster-prod-node-pool-8dd223d0-grp     us-central1-b  zone   gke-network-prod  Yes      1
gke-my-gke-cluster-prod-default-pool-3f8d641c-grp  us-central1-c  zone   gke-network-prod  Yes      0
gke-my-gke-cluster-prod-node-pool-761d059b-grp     us-central1-c  zone   gke-network-prod  Yes      1
gke-my-gke-cluster-prod-default-pool-5edd2d72-grp  us-central1-f  zone   gke-network-prod  Yes      0

$ gcloud compute instance-groups describe gke-my-gke-cluster-prod-node-pool-3b58a6fa-grp
creationTimestamp: '2021-05-31T15:34:53.607-07:00'
description: "This instance group is controlled by Instance Group Manager 'gke-my-gke-cluster-prod-node-pool-3b58a6fa-grp'.\
  \ To modify instances in this group, use the Instance Group Manager API: https://cloud.google.com/compute/docs/reference/latest/instanceGroupManagers"
fingerprint: 42WmSpB8rSM=
id: '6937672839765482082'
kind: compute#instanceGroup
name: gke-my-gke-cluster-prod-node-pool-3b58a6fa-grp
network: https://www.googleapis.com/compute/v1/projects/gke-sample-project-315422/global/networks/gke-network-prod
selfLink: https://www.googleapis.com/compute/v1/projects/gke-sample-project-315422/zones/us-central1-a/instanceGroups/gke-my-gke-cluster-prod-node-pool-3b58a6fa-grp
size: 1
subnetwork: https://www.googleapis.com/compute/v1/projects/gke-sample-project-315422/regions/us-central1/subnetworks/gke-subnet-prod
zone: https://www.googleapis.com/compute/v1/projects/gke-sample-project-315422/zones/us-central1-a

$ gcloud compute instance-templates list
NAME                                           MACHINE_TYPE  PREEMPTIBLE  CREATION_TIMESTAMP
gke-my-gke-cluster-prod-default-pool-3f8d641c  e2-medium                  2021-05-31T15:32:24.702-07:00
gke-my-gke-cluster-prod-default-pool-5edd2d72  e2-medium                  2021-05-31T15:32:23.687-07:00
gke-my-gke-cluster-prod-default-pool-750be23e  e2-medium                  2021-05-31T15:32:23.961-07:00
gke-my-gke-cluster-prod-node-pool-3b58a6fa     e2-medium                  2021-05-31T15:34:33.339-07:00
gke-my-gke-cluster-prod-node-pool-761d059b     e2-medium                  2021-05-31T15:34:33.399-07:00
gke-my-gke-cluster-prod-node-pool-8dd223d0     e2-medium                  2021-05-31T15:34:33.331-07:00

$ gcloud compute firewall-rules list
NAME                                  NETWORK           DIRECTION  PRIORITY  ALLOW                         DENY  DISABLED
default-allow-icmp                    default           INGRESS    65534     icmp                                False
default-allow-internal                default           INGRESS    65534     tcp:0-65535,udp:0-65535,icmp        False
default-allow-rdp                     default           INGRESS    65534     tcp:3389                            False
default-allow-ssh                     default           INGRESS    65534     tcp:22                              False
gke-my-gke-cluster-prod-8fa330f8-all  gke-network-prod  INGRESS    1000      sctp,tcp,udp,icmp,esp,ah            False
gke-my-gke-cluster-prod-8fa330f8-ssh  gke-network-prod  INGRESS    1000      tcp:22                              False
gke-my-gke-cluster-prod-8fa330f8-vms  gke-network-prod  INGRESS    1000      icmp,tcp:1-65535,udp:1-65535        False

$ gcloud compute firewall-rules describe gke-my-gke-cluster-prod-8fa330f8-vms
allowed:
- IPProtocol: icmp
- IPProtocol: tcp
  ports:
  - 1-65535
- IPProtocol: udp
  ports:
  - 1-65535
creationTimestamp: '2021-05-31T15:32:22.909-07:00'
description: ''
direction: INGRESS
disabled: false
id: '4934448355735035161'
kind: compute#firewall
logConfig:
  enable: false
name: gke-my-gke-cluster-prod-8fa330f8-vms
network: https://www.googleapis.com/compute/v1/projects/gke-sample-project-315422/global/networks/gke-network-prod
priority: 1000
selfLink: https://www.googleapis.com/compute/v1/projects/gke-sample-project-315422/global/firewalls/gke-my-gke-cluster-prod-8fa330f8-vms
sourceRanges:
- 10.10.0.0/16
targetTags:
- gke-my-gke-cluster-prod-8fa330f8-node

$ gcloud compute forwarding-rules list
Listed 0 items.

$ kubectl get po --all-namespaces
NAMESPACE     NAME                                                         READY   STATUS    RESTARTS   AGE
kube-system   event-exporter-gke-67986489c8-nlcl5                          2/2     Running   0          11m
kube-system   fluentbit-gke-6ldvw                                          2/2     Running   0          10m
kube-system   fluentbit-gke-dr9lb                                          2/2     Running   0          10m
kube-system   fluentbit-gke-lfgkh                                          2/2     Running   0          10m
kube-system   gke-metadata-server-fzcfw                                    1/1     Running   0          10m
kube-system   gke-metadata-server-jkbmn                                    1/1     Running   0          10m
kube-system   gke-metadata-server-zrj45                                    1/1     Running   0          10m
kube-system   gke-metrics-agent-5psh2                                      1/1     Running   0          10m
kube-system   gke-metrics-agent-dplpl                                      1/1     Running   0          10m
kube-system   gke-metrics-agent-jcqkn                                      1/1     Running   0          10m
kube-system   kube-dns-6c7b8dc9f9-b8t2l                                    4/4     Running   0          10m
kube-system   kube-dns-6c7b8dc9f9-v5mh6                                    4/4     Running   0          11m
kube-system   kube-dns-autoscaler-58cbd4f75c-pjwn2                         1/1     Running   0          11m
kube-system   kube-proxy-gke-my-gke-cluster-prod-node-pool-3b58a6fa-bd0g   1/1     Running   0          10m
kube-system   kube-proxy-gke-my-gke-cluster-prod-node-pool-761d059b-xvt3   1/1     Running   0          10m
kube-system   kube-proxy-gke-my-gke-cluster-prod-node-pool-8dd223d0-gxrp   1/1     Running   0          10m
kube-system   l7-default-backend-66579f5d7-wq8mz                           1/1     Running   0          11m
kube-system   metrics-server-v0.3.6-6c47ffd7d7-9mmrj                       2/2     Running   0          9m53s
kube-system   netd-9c9x5                                                   1/1     Running   0          10m
kube-system   netd-bjcs2                                                   1/1     Running   0          10m
kube-system   netd-gvm7z                                                   1/1     Running   0          10m
kube-system   pdcsi-node-4wkmr                                             2/2     Running   0          10m
kube-system   pdcsi-node-dspmx                                             2/2     Running   0          10m
kube-system   pdcsi-node-l996f                                             2/2     Running   0          10m
kube-system   stackdriver-metadata-agent-cluster-level-557db96c7c-jr77q    2/2     Running   0          9m59s

```

### Mapping pod and services
- Apply a k8s deployment

```
$ kubectl apply -f deployment.yaml

$ kubectl get po -o wide
NAME                          READY   STATUS    RESTARTS   AGE   IP          NODE                                              NOMINATED NODE   READINESS GATES
greeting-go-8d4fc9567-2l5rk   1/1     Running   0          73s   10.20.2.4   gke-my-gke-cluster-prod-node-pool-3b58a6fa-bd0g   <none>           <none>
greeting-go-8d4fc9567-lr55l   1/1     Running   0          73s   10.20.1.5   gke-my-gke-cluster-prod-node-pool-8dd223d0-gxrp   <none>           <none>
greeting-go-8d4fc9567-n2gd5   1/1     Running   0          73s   10.20.0.6   gke-my-gke-cluster-prod-node-pool-761d059b-xvt3   <none>           <none>
```
- Deploy a service of type LoadBalancer
```
$ kubectl apply -f service.yaml

$ kubectl get svc 
NAME          TYPE           CLUSTER-IP    EXTERNAL-IP       PORT(S)          AGE
greeting-go   LoadBalancer   10.30.151.4   104.198.214.161   9080:30636/TCP   51s
kubernetes    ClusterIP      10.30.0.1     <none>            443/TCP          15m

$ curl http://104.198.214.161:9080/greetings
hello (greeting-go-8d4fc9567-2l5rk)
```
- Let's look at the mapping between k8s service and the underlying gcp resources
```
$ kubectl describe svc greeting-go 
Name:                     greeting-go
Namespace:                default
Labels:                   <none>
Annotations:              cloud.google.com/neg: {"ingress":true}
Selector:                 name=greeting-go
Type:                     LoadBalancer
IP:                       10.30.151.4
LoadBalancer Ingress:     104.198.214.161
Port:                     <unset>  9080/TCP
TargetPort:               8080/TCP
NodePort:                 <unset>  30636/TCP
Endpoints:                10.20.0.6:8080,10.20.1.5:8080,10.20.2.4:8080
Session Affinity:         None
External Traffic Policy:  Cluster
Events:
  Type    Reason                Age    From                Message
  ----    ------                ----   ----                -------
  Normal  EnsuringLoadBalancer  3m33s  service-controller  Ensuring load balancer
  Normal  EnsuredLoadBalancer   2m49s  service-controller  Ensured load balancer


$ gcloud compute forwarding-rules list
NAME                              REGION       IP_ADDRESS       IP_PROTOCOL  TARGET
a92a87ddb5b1c44b08b9f559ce09495c  us-central1  104.198.214.161  TCP          us-central1/targetPools/a92a87ddb5b1c44b08b9f559ce09495c

$ gcloud compute forwarding-rules describe a92a87ddb5b1c44b08b9f559ce09495c
IPAddress: 104.198.214.161
IPProtocol: TCP
creationTimestamp: '2021-05-31T15:49:43.735-07:00'
description: '{"kubernetes.io/service-name":"default/greeting-go"}'
fingerprint: wb2rytlG-3o=
id: '3100410261355943656'
kind: compute#forwardingRule
labelFingerprint: 42WmSpB8rSM=
loadBalancingScheme: EXTERNAL
name: a92a87ddb5b1c44b08b9f559ce09495c
networkTier: PREMIUM
portRange: 9080-9080
region: https://www.googleapis.com/compute/v1/projects/gke-sample-project-315422/regions/us-central1
selfLink: https://www.googleapis.com/compute/v1/projects/gke-sample-project-315422/regions/us-central1/forwardingRules/a92a87ddb5b1c44b08b9f559ce09495c
target: https://www.googleapis.com/compute/v1/projects/gke-sample-project-315422/regions/us-central1/targetPools/a92a87ddb5b1c44b08b9f559ce09495c


$ gcloud compute target-pools describe a92a87ddb5b1c44b08b9f559ce09495c
creationTimestamp: '2021-05-31T15:49:36.494-07:00'
description: '{"kubernetes.io/service-name":"default/greeting-go"}'
healthChecks:
- https://www.googleapis.com/compute/v1/projects/gke-sample-project-315422/global/httpHealthChecks/k8s-f6eb789c299931e0-node
id: '1780698744100542191'
instances:
- https://www.googleapis.com/compute/v1/projects/gke-sample-project-315422/zones/us-central1-b/instances/gke-my-gke-cluster-prod-node-pool-8dd223d0-gxrp
- https://www.googleapis.com/compute/v1/projects/gke-sample-project-315422/zones/us-central1-a/instances/gke-my-gke-cluster-prod-node-pool-3b58a6fa-bd0g
- https://www.googleapis.com/compute/v1/projects/gke-sample-project-315422/zones/us-central1-c/instances/gke-my-gke-cluster-prod-node-pool-761d059b-xvt3
kind: compute#targetPool
name: a92a87ddb5b1c44b08b9f559ce09495c
region: https://www.googleapis.com/compute/v1/projects/gke-sample-project-315422/regions/us-central1
selfLink: https://www.googleapis.com/compute/v1/projects/gke-sample-project-315422/regions/us-central1/targetPools/a92a87ddb5b1c44b08b9f559ce09495c
sessionAffinity: NONE



$ gcloud compute http-health-checks describe k8s-f6eb789c299931e0-node
checkIntervalSec: 8
creationTimestamp: '2021-05-31T15:49:34.591-07:00'
description: '{"kubernetes.io/service-name":"k8s-f6eb789c299931e0-node"}'
healthyThreshold: 1
host: ''
id: '403722908923910417'
kind: compute#httpHealthCheck
name: k8s-f6eb789c299931e0-node
port: 10256
requestPath: /healthz
selfLink: https://www.googleapis.com/compute/v1/projects/gke-sample-project-315422/global/httpHealthChecks/k8s-f6eb789c299931e0-node
timeoutSec: 1
unhealthyThreshold: 3

$ gcloud compute firewall-rules list
NAME                                     NETWORK           DIRECTION  PRIORITY  ALLOW                         DENY  DISABLED
default-allow-icmp                       default           INGRESS    65534     icmp                                False
default-allow-internal                   default           INGRESS    65534     tcp:0-65535,udp:0-65535,icmp        False
default-allow-rdp                        default           INGRESS    65534     tcp:3389                            False
default-allow-ssh                        default           INGRESS    65534     tcp:22                              False
gke-my-gke-cluster-prod-8fa330f8-all     gke-network-prod  INGRESS    1000      sctp,tcp,udp,icmp,esp,ah            False
gke-my-gke-cluster-prod-8fa330f8-ssh     gke-network-prod  INGRESS    1000      tcp:22                              False
gke-my-gke-cluster-prod-8fa330f8-vms     gke-network-prod  INGRESS    1000      icmp,tcp:1-65535,udp:1-65535        False
k8s-f6eb789c299931e0-node-http-hc        gke-network-prod  INGRESS    1000      tcp:10256                           False
k8s-fw-a92a87ddb5b1c44b08b9f559ce09495c  gke-network-prod  INGRESS    1000      tcp:9080                            False

$ gcloud compute firewall-rules describe k8s-f6eb789c299931e0-node-http-hc
allowed:
- IPProtocol: tcp
  ports:
  - '10256'
creationTimestamp: '2021-05-31T15:49:30.682-07:00'
description: '{"kubernetes.io/cluster-id":"f6eb789c299931e0"}'
direction: INGRESS
disabled: false
id: '5909037518222317845'
kind: compute#firewall
logConfig:
  enable: false
name: k8s-f6eb789c299931e0-node-http-hc
network: https://www.googleapis.com/compute/v1/projects/gke-sample-project-315422/global/networks/gke-network-prod
priority: 1000
selfLink: https://www.googleapis.com/compute/v1/projects/gke-sample-project-315422/global/firewalls/k8s-f6eb789c299931e0-node-http-hc
sourceRanges:
- 209.85.152.0/22
- 209.85.204.0/22
- 130.211.0.0/22
- 35.191.0.0/16
targetTags:
- gke-my-gke-cluster-prod-8fa330f8-node

$ gcloud compute firewall-rules describe k8s-fw-a92a87ddb5b1c44b08b9f559ce09495c
allowed:
- IPProtocol: tcp
  ports:
  - '9080'
creationTimestamp: '2021-05-31T15:49:24.132-07:00'
description: '{"kubernetes.io/service-name":"default/greeting-go", "kubernetes.io/service-ip":"104.198.214.161"}'
direction: INGRESS
disabled: false
id: '8309228211466197275'
kind: compute#firewall
logConfig:
  enable: false
name: k8s-fw-a92a87ddb5b1c44b08b9f559ce09495c
network: https://www.googleapis.com/compute/v1/projects/gke-sample-project-315422/global/networks/gke-network-prod
priority: 1000
selfLink: https://www.googleapis.com/compute/v1/projects/gke-sample-project-315422/global/firewalls/k8s-fw-a92a87ddb5b1c44b08b9f559ce09495c
sourceRanges:
- 0.0.0.0/0
targetTags:
- gke-my-gke-cluster-prod-8fa330f8-node


$ gcloud compute instances list --filter='tags:gke-my-gke-cluster-prod-8fa330f8-node'
NAME                                             ZONE           MACHINE_TYPE  PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP     STATUS
gke-my-gke-cluster-prod-node-pool-3b58a6fa-bd0g  us-central1-a  e2-medium                  10.10.0.4    34.68.81.58     RUNNING
gke-my-gke-cluster-prod-node-pool-8dd223d0-gxrp  us-central1-b  e2-medium                  10.10.0.3    35.223.232.98   RUNNING
gke-my-gke-cluster-prod-node-pool-761d059b-xvt3  us-central1-c  e2-medium                  10.10.0.2    34.121.239.130  RUNNING
```
### Mapping ClusterIP based k8s service and Ingress to GCP resources
- 
```
$ kubectl apply -f service1.yaml 
service/greeting-go-clusterip created

$ kubectl get svc
NAME                    TYPE           CLUSTER-IP      EXTERNAL-IP       PORT(S)          AGE
greeting-go             LoadBalancer   10.30.151.4     104.198.214.161   9080:30636/TCP   14m
greeting-go-clusterip   ClusterIP      10.30.170.158   <none>            80/TCP           17s
kubernetes              ClusterIP      10.30.0.1       <none>            443/TCP          29m

$ kubectl describe svc greeting-go-clusterip
Name:              greeting-go-clusterip
Namespace:         default
Labels:            <none>
Annotations:       cloud.google.com/neg: {"ingress":true}
                   cloud.google.com/neg-status:
                     {"network_endpoint_groups":{"80":"k8s1-f6eb789c-default-greeting-go-clusterip-80-d9016e0c"},"zones":["us-central1-a","us-central1-b","us-c...
Selector:          name=greeting-go
Type:              ClusterIP
IP:                10.30.170.158
Port:              <unset>  80/TCP
TargetPort:        8080/TCP
Endpoints:         10.20.0.6:8080,10.20.1.5:8080,10.20.2.4:8080
Session Affinity:  None
Events:
  Type    Reason  Age   From            Message
  ----    ------  ----  ----            -------
  Normal  Create  36m   neg-controller  Created NEG "k8s1-f6eb789c-default-greeting-go-clusterip-80-d9016e0c" for default/greeting-go-clusterip-k8s1-f6eb789c-default-greeting-go-clusterip-80-d9016e0c--/80-8080-GCE_VM_IP_PORT-L7 in "us-central1-a".
  Normal  Create  36m   neg-controller  Created NEG "k8s1-f6eb789c-default-greeting-go-clusterip-80-d9016e0c" for default/greeting-go-clusterip-k8s1-f6eb789c-default-greeting-go-clusterip-80-d9016e0c--/80-8080-GCE_VM_IP_PORT-L7 in "us-central1-b".
  Normal  Create  36m   neg-controller  Created NEG "k8s1-f6eb789c-default-greeting-go-clusterip-80-d9016e0c" for default/greeting-go-clusterip-k8s1-f6eb789c-default-greeting-go-clusterip-80-d9016e0c--/80-8080-GCE_VM_IP_PORT-L7 in "us-central1-c".
  Normal  Attach  36m   neg-controller  Attach 1 network endpoint(s) (NEG "k8s1-f6eb789c-default-greeting-go-clusterip-80-d9016e0c" in zone "us-central1-b")
  Normal  Attach  36m   neg-controller  Attach 1 network endpoint(s) (NEG "k8s1-f6eb789c-default-greeting-go-clusterip-80-d9016e0c" in zone "us-central1-c")
  Normal  Attach  36m   neg-controller  Attach 1 network endpoint(s) (NEG "k8s1-f6eb789c-default-greeting-go-clusterip-80-d9016e0c" in zone "us-central1-a")

$ kubectl apply -f ingress.yaml

$ kubectl get ing -o wide
NAME          CLASS    HOSTS   ADDRESS         PORTS   AGE
greeting-go   <none>   *       35.244.234.55   80      20m


$ kubectl describe ing greeting-go
Name:             greeting-go
Namespace:        default
Address:          35.244.234.55
Default backend:  default-http-backend:80   10.20.1.4:8080)
Rules:
  Host        Path  Backends
  ----        ----  --------
  *           
              /*   greeting-go-clusterip:80   10.20.0.6:8080,10.20.1.5:8080,10.20.2.4:8080)
Annotations:  cloud.google.com/load-balancer-type: External
              ingress.kubernetes.io/backends:
                {"k8s-be-30201--f6eb789c299931e0":"HEALTHY","k8s1-f6eb789c-default-greeting-go-clusterip-80-d9016e0c":"UNHEALTHY"}
              ingress.kubernetes.io/forwarding-rule: k8s2-fr-6pr7r9iw-default-greeting-go-bd8q8v23
              ingress.kubernetes.io/target-proxy: k8s2-tp-6pr7r9iw-default-greeting-go-bd8q8v23
              ingress.kubernetes.io/url-map: k8s2-um-6pr7r9iw-default-greeting-go-bd8q8v23
              kubernetes.io/ingress.class: gce
Events:
  Type    Reason     Age               From                     Message
  ----    ------     ----              ----                     -------
  Normal  Sync       19m               loadbalancer-controller  UrlMap "k8s2-um-6pr7r9iw-default-greeting-go-bd8q8v23" created
  Normal  Sync       19m               loadbalancer-controller  TargetProxy "k8s2-tp-6pr7r9iw-default-greeting-go-bd8q8v23" created
  Normal  Sync       19m               loadbalancer-controller  ForwardingRule "k8s2-fr-6pr7r9iw-default-greeting-go-bd8q8v23" created
  Normal  IPChanged  19m               loadbalancer-controller  IP is now 35.244.234.55
  Normal  Sync       8m (x6 over 21m)  loadbalancer-controller  Scheduled for sync


$ gcloud compute firewall-rules list
NAME                                     NETWORK           DIRECTION  PRIORITY  ALLOW                         DENY  DISABLED
default-allow-icmp                       default           INGRESS    65534     icmp                                False
default-allow-internal                   default           INGRESS    65534     tcp:0-65535,udp:0-65535,icmp        False
default-allow-rdp                        default           INGRESS    65534     tcp:3389                            False
default-allow-ssh                        default           INGRESS    65534     tcp:22                              False
gke-my-gke-cluster-prod-8fa330f8-all     gke-network-prod  INGRESS    1000      sctp,tcp,udp,icmp,esp,ah            False
gke-my-gke-cluster-prod-8fa330f8-ssh     gke-network-prod  INGRESS    1000      tcp:22                              False
gke-my-gke-cluster-prod-8fa330f8-vms     gke-network-prod  INGRESS    1000      icmp,tcp:1-65535,udp:1-65535        False
k8s-f6eb789c299931e0-node-http-hc        gke-network-prod  INGRESS    1000      tcp:10256                           False
k8s-fw-a92a87ddb5b1c44b08b9f559ce09495c  gke-network-prod  INGRESS    1000      tcp:9080                            False
k8s-fw-l7--f6eb789c299931e0              gke-network-prod  INGRESS    1000      tcp:30000-32767,tcp:8080            False


$ gcloud compute firewall-rules describe k8s-fw-l7--f6eb789c299931e0
allowed:
- IPProtocol: tcp
  ports:
  - 30000-32767
  - '8080'
creationTimestamp: '2021-05-31T16:12:13.203-07:00'
description: GCE L7 firewall rule
direction: INGRESS
disabled: false
id: '285256050064020386'
kind: compute#firewall
logConfig:
  enable: false
name: k8s-fw-l7--f6eb789c299931e0
network: https://www.googleapis.com/compute/v1/projects/gke-sample-project-315422/global/networks/gke-network-prod
priority: 1000
selfLink: https://www.googleapis.com/compute/v1/projects/gke-sample-project-315422/global/firewalls/k8s-fw-l7--f6eb789c299931e0
sourceRanges:
- 130.211.0.0/22
- 35.191.0.0/16
targetTags:
- gke-my-gke-cluster-prod-8fa330f8-node

$ gcloud compute forwarding-rules list
NAME                                           REGION       IP_ADDRESS       IP_PROTOCOL  TARGET
k8s2-fr-6pr7r9iw-default-greeting-go-bd8q8v23               35.244.234.55    TCP          k8s2-tp-6pr7r9iw-default-greeting-go-bd8q8v23
a92a87ddb5b1c44b08b9f559ce09495c               us-central1  104.198.214.161  TCP          us-central1/targetPools/a92a87ddb5b1c44b08b9f559ce09495c

$ gcloud compute target-http-proxies list
NAME                                           URL_MAP
k8s2-tp-6pr7r9iw-default-greeting-go-bd8q8v23  k8s2-um-6pr7r9iw-default-greeting-go-bd8q8v23

$ gcloud compute target-http-proxies describe k8s2-tp-6pr7r9iw-default-greeting-go-bd8q8v23
creationTimestamp: '2021-05-31T16:13:28.991-07:00'
description: '{"kubernetes.io/ingress-name": "default/greeting-go"}'
fingerprint: ZlOMtzsfdWA=
id: '8689332469269844855'
kind: compute#targetHttpProxy
name: k8s2-tp-6pr7r9iw-default-greeting-go-bd8q8v23
selfLink: https://www.googleapis.com/compute/v1/projects/gke-sample-project-315422/global/targetHttpProxies/k8s2-tp-6pr7r9iw-default-greeting-go-bd8q8v23
urlMap: https://www.googleapis.com/compute/v1/projects/gke-sample-project-315422/global/urlMaps/k8s2-um-6pr7r9iw-default-greeting-go-bd8q8v23


$ gcloud compute url-maps list
NAME                                           DEFAULT_SERVICE
k8s2-um-6pr7r9iw-default-greeting-go-bd8q8v23  backendServices/k8s-be-30201--f6eb789c299931e0


$ gcloud compute url-maps describe k8s2-um-6pr7r9iw-default-greeting-go-bd8q8v23
creationTimestamp: '2021-05-31T16:13:27.298-07:00'
defaultService: https://www.googleapis.com/compute/v1/projects/gke-sample-project-315422/global/backendServices/k8s-be-30201--f6eb789c299931e0
fingerprint: wMMZ2oJLjUQ=
hostRules:
- hosts:
  - '*'
  pathMatcher: host3389dae361af79b04c9c8e7057f60cc6
id: '2239757385706558328'
kind: compute#urlMap
name: k8s2-um-6pr7r9iw-default-greeting-go-bd8q8v23
pathMatchers:
- defaultService: https://www.googleapis.com/compute/v1/projects/gke-sample-project-315422/global/backendServices/k8s-be-30201--f6eb789c299931e0
  name: host3389dae361af79b04c9c8e7057f60cc6
  pathRules:
  - paths:
    - /*
    service: https://www.googleapis.com/compute/v1/projects/gke-sample-project-315422/global/backendServices/k8s1-f6eb789c-default-greeting-go-clusterip-80-d9016e0c
selfLink: https://www.googleapis.com/compute/v1/projects/gke-sample-project-315422/global/urlMaps/k8s2-um-6pr7r9iw-default-greeting-go-bd8q8v23


$ gcloud compute backend-services list
NAME                                                     BACKENDS                                                                                                                                                                                                                                                                             PROTOCOL
k8s-be-30201--f6eb789c299931e0                           us-central1-a/instanceGroups/k8s-ig--f6eb789c299931e0,us-central1-b/instanceGroups/k8s-ig--f6eb789c299931e0,us-central1-c/instanceGroups/k8s-ig--f6eb789c299931e0                                                                                                                    HTTP
k8s1-f6eb789c-default-greeting-go-clusterip-80-d9016e0c  us-central1-a/networkEndpointGroups/k8s1-f6eb789c-default-greeting-go-clusterip-80-d9016e0c,us-central1-b/networkEndpointGroups/k8s1-f6eb789c-default-greeting-go-clusterip-80-d9016e0c,us-central1-c/networkEndpointGroups/k8s1-f6eb789c-default-greeting-go-clusterip-80-d9016e0c  HTTP

$ gcloud compute network-endpoint-groups list
NAME                                                     LOCATION       ENDPOINT_TYPE   SIZE
k8s1-f6eb789c-default-greeting-go-clusterip-80-d9016e0c  us-central1-a  GCE_VM_IP_PORT  1
k8s1-f6eb789c-default-greeting-go-clusterip-80-d9016e0c  us-central1-b  GCE_VM_IP_PORT  1
k8s1-f6eb789c-default-greeting-go-clusterip-80-d9016e0c  us-central1-c  GCE_VM_IP_PORT  1

```

### Sources
- [learnk8s.io](https://learnk8s.io/terraform-gke)
- [terraform GKE module](https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/latest)
$ gcloud compute target-http-proxies list
NAME                                           URL_MAP
k8s2-tp-6pr7r9iw-default-greeting-go-bd8q8v23  k8s2-um-6pr7r9iw-default-greeting-go-bd8q8v23
