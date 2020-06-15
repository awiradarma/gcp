## Networks

#### Create a new network
```
gcloud compute networks create labnet --subnet-mode=custom
```

#### Create a subnet
```
gcloud compute networks subnets create labnet-sub \
   --network labnet \
   --region us-central1 \
   --range 10.0.0.0/28
```

#### List the networks
```
gcloud compute networks list
```

#### Describe a network
```
gcloud compute networks describe NETWORK_NAME
```

#### List subnets
```
gcloud compute networks subnets list
```

#### Create firewall rules
```
gcloud compute firewall-rules create labnet-allow-internal \
	--network=labnet \
	--action=ALLOW \
	--rules=icmp,tcp:22 \
	--source-ranges=0.0.0.0/0
```

#### Other examples
```
gcloud compute networks create managementnet --project=qwiklabs-gcp-03-de8e6230f009 --subnet-mode=custom --bgp-routing-mode=regional

gcloud compute networks subnets create managementsubnet-us --project=qwiklabs-gcp-03-de8e6230f009 --range=10.130.0.0/20 --network=managementnet --region=us-central1
```

```
gcloud compute firewall-rules create privatenet-allow-icmp-ssh-rdp --direction=INGRESS --priority=1000 --network=privatenet --action=ALLOW --rules=icmp,tcp:22,tcp:3389 --source-ranges=0.0.0.0/0



```