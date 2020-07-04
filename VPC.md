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

![firewall-rule.png](firewall-rule.png)
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
## VPC Peering
Google Cloud Platform (GCP) Virtual Private Cloud (VPC) Network Peering allows private connectivity across two VPC networks regardless of whether or not they belong to the same project or the same organization.

#### Create custom network
```
gcloud compute networks create network-a --subnet-mode custom
```

#### Create subnet
```
gcloud compute networks subnets create network-a-central --network network-a \
    --range 10.0.0.0/16 --region us-central1
```
#### Create VM instance
```
gcloud compute instances create vm-a --zone us-central1-a --network network-a --subnet network-a-central
```

#### Enable SSH and ICMP
```
gcloud compute firewall-rules create network-a-fw --network network-a --allow tcp:22,icmp
```

#### Do the same thing on the other VPC
```
gcloud compute networks create network-b --subnet-mode custom

gcloud compute networks subnets create network-b-central --network network-b \
    --range 10.8.0.0/16 --region us-central1

gcloud compute instances create vm-b --zone us-central1-a --network network-b --subnet network-b-central

gcloud compute firewall-rules create network-b-fw --network network-b --allow tcp:22,icmp
```

#### Establish peering

Project-A

Go to the VPC Network Peering in the Google Cloud Platform Console by navigating to the Networking section and clicking VPC Network > VPC network peering in the left menu. Once you're there:

- Click Create connection.
- Click Continue.
- Type "peer-ab" as the Name for this side of the connection.
- Under Your VPC network, select the network you want to peer (network-a).
- Set the Peered VPC network radio buttons to In another project.
- Paste in the Project ID of the second project.
- Type in the VPC network name of the other network (network-b).
- Click Create.


At this point, the peering state remains INACTIVE because there is no matching configuration in network-b in project-B.

Set up network peering on the other project.

#### Check route table
```
student_01_469aaf8526a4@cloudshell:~ (qwiklabs-gcp-01-ad572a9b433d)$ gcloud compute routes list --project qwiklabs-gcp-01-32421a26dc9c
NAME                            NETWORK    DEST_RANGE     NEXT_HOP                  PRIORITY
default-route-0191cb759453b6c3  default    10.140.0.0/20  default                   0
default-route-0e00ebf70aad4ab3  default    10.166.0.0/20  default                   0
default-route-0efc8e71c1276778  default    10.146.0.0/20  default                   0
default-route-0fcb80cc4fb5614c  default    10.162.0.0/20  default                   0
default-route-126a5aa193766745  network-a  10.0.0.0/16    network-a                 0
default-route-23412fd3d6d293a0  default    10.170.0.0/20  default                   0
default-route-2dbae3ec2a44fc65  default    10.138.0.0/20  default                   0
default-route-39083dcf1e6e31fc  default    10.172.0.0/20  default                   0
default-route-3faa4c18412a4ddf  default    10.180.0.0/20  default                   0
default-route-63649d7c047de546  default    10.160.0.0/20  default                   0
default-route-67962c81e40561dc  default    10.168.0.0/20  default                   0
default-route-6cd928b2b2908a89  default    10.178.0.0/20  default                   0
default-route-72cc84452b82c8af  default    10.152.0.0/20  default                   0
default-route-790fefa2d0bc851a  network-a  0.0.0.0/0      default-internet-gateway  1000
default-route-826efabc01bd303d  default    10.132.0.0/20  default                   0
default-route-9049ce419e68b8e4  default    10.154.0.0/20  default                   0
default-route-97c0a29afe9c9078  default    10.150.0.0/20  default                   0
default-route-a14ddac62a33dcf1  default    10.184.0.0/20  default                   0
default-route-a2cee690ba506bda  default    10.128.0.0/20  default                   0
default-route-b49a49632b4c9dd0  default    10.174.0.0/20  default                   0
default-route-c6129e25c584c4aa  default    10.142.0.0/20  default                   0
default-route-caa38e8772288c5f  default    10.182.0.0/20  default                   0
default-route-d1dd3321d54e35fe  default    10.158.0.0/20  default                   0
default-route-d327acb32fe9dfd4  default    0.0.0.0/0      default-internet-gateway  1000
default-route-da878d1210d3d502  default    10.148.0.0/20  default                   0
default-route-df9c400facfb432e  default    10.156.0.0/20  default                   0
default-route-e774ea90f3f076ca  default    10.164.0.0/20  default                   0
peering-route-62f531ee074919a2  network-a  10.8.0.0/16    peer-ab                   0

student_01_469aaf8526a4@cloudshell:~ (qwiklabs-gcp-01-ad572a9b433d)$ gcloud compute routes list --project qwiklabs-gcp-01-ad572a9b433d
NAME                            NETWORK    DEST_RANGE     NEXT_HOP                  PRIORITY
default-route-0481ffe3d4300f87  default    10.146.0.0/20  default                   0
default-route-10b0696de6c885b5  default    10.154.0.0/20  default                   0
default-route-17152b980e9752f6  default    10.164.0.0/20  default                   0
default-route-1b5848459e28fa6c  default    10.162.0.0/20  default                   0
default-route-27108ca6a3406bf8  default    10.138.0.0/20  default                   0
default-route-2766ac37bc8eff5d  default    10.152.0.0/20  default                   0
default-route-2e56194d0df88c97  default    10.178.0.0/20  default                   0
default-route-305a748362c321c3  default    10.160.0.0/20  default                   0
default-route-44984a5c7c593753  default    10.166.0.0/20  default                   0
default-route-459c78153f36d508  default    10.156.0.0/20  default                   0
default-route-462b31ac6c96e3cd  default    10.148.0.0/20  default                   0
default-route-574e54180634bd46  default    10.182.0.0/20  default                   0
default-route-57d5b9d1608e4050  default    10.140.0.0/20  default                   0
default-route-6bb3f8ba8e2b0979  default    10.150.0.0/20  default                   0
default-route-7a1a07883d4df14c  default    10.184.0.0/20  default                   0
default-route-7b839db50dabf02d  default    10.168.0.0/20  default                   0
default-route-7f1e3b108d722925  default    0.0.0.0/0      default-internet-gateway  1000
default-route-81d191206e62f6ca  default    10.172.0.0/20  default                   0
default-route-8f5223858c76307d  default    10.170.0.0/20  default                   0
default-route-a5aa6c2781a22a98  network-b  0.0.0.0/0      default-internet-gateway  1000
default-route-a96388bf87576ab3  network-b  10.8.0.0/16    network-b                 0
default-route-acf4f8c6ad975231  default    10.128.0.0/20  default                   0
default-route-c06de053c0e2db1f  default    10.142.0.0/20  default                   0
default-route-c28bc62de77046a3  default    10.132.0.0/20  default                   0
default-route-c95ad4d7eae01a88  default    10.174.0.0/20  default                   0
default-route-c962773dd98fcedf  default    10.158.0.0/20  default                   0
default-route-db653ce9b0e70d0b  default    10.180.0.0/20  default                   0
peering-route-97148565b668d5a5  network-b  10.0.0.0/16    peer-ba                   0
```

## HTTP Load Balancer with Cloud Armor

GCP HTTP(S) load balancing is implemented at the edge of Google's network in Google's points of presence (POP) around the world. User traffic directed to an HTTP(S) load balancer enters the POP closest to the user and is then load balanced over Google's global network to the closest backend that has sufficient capacity available.

Cloud Armor IP blacklists/whitelists enable you to restrict or allow access to your HTTP(S) load balancer at the edge of the Google Cloud, as close as possible to the user and to malicious traffic. This prevents malicious users or traffic from consuming resources or entering your virtual private cloud (VPC) networks.


## Network Performance

#### Ping 
Ping uses the ICMP Echo Request and Echo Reply messages to test connectivity. Ping measures packet loss as well as latency. Packet loss is always bad because it means network traffic does not reach it's target, or there is an error on the return path. You should not experience this within this lab. Latency is defined as the Round Trip Time (RTT) network packets take to get from one host to the other and back. Lower latency improves user experience (anything over 100ms application delay, which might include several network round trips, is noticeable) and also improves transfer speeds. With higher latency, extra caching layers or WAN accelerators might have to be used.

```
ping -i0.2 w2-vm

sudo ping -i0.05 w2-vm -c 1000 #(sends a ping every 50ms, 1000 times)

sudo ping -f -i0.05 w2-vm #(flood ping, adds a dot for every sent packet, and removes one for every received packet)  - careful with flood ping without interval, it will send packets as fast as possible, which within the same zone is very fast

sudo ping -i0.05 w2-vm -c 100 -s 1400 #(send larger packets, does it get slower?)
```

#### Traceroute
Functionality: Traceroute shows all Layer 3 (routing layer) hops between the hosts. Packets are sent to the remote destination with increasing TTL (Time To Live) value (starting at 1). The TTL field is a field in the IP packet which gets decreased by one at every router. Once the TTL hits zero, the packet gets discarded and a "TTL exceeded" ICMP message is returned to the sender. This approach is used to avoid routing loops; packets cannot loop continuously because the TTL field will eventually decrement to 0. By default the OS sets the TTL value to a high value (64, 128, 255 or similar), so this should only ever be reached in abnormal situations.
So traceroute sends packets first with TTL value of 1, then TTL value of 2, etc., causing these packets to expire at the first/second/etc. router in the path. It then takes the source IP/host of the ICMP TTL exceeded message returned to show the name/IP of the intermediate hop. Once the TTL is high enough, the packet reaches the destination, and the destination responds.

The type of packet sent varies by implementation. Under Linux, UDP packets are sent to a high, unused port. So the final destination responds with an ICMP Port Unreachable. Windows and the mtr tool by default use ICMP echo requests (like ping), so the final destinations answers with an ICMP echo reply.

```
student-04-3516714ee6cb@e1-vm:~$ traceroute www.icann.org
traceroute to www.icann.org (192.0.32.7), 30 hops max, 60 byte packets
 1  209.85.255.147 (209.85.255.147)  13.626 ms 209.85.255.245 (209.85.255.245)  13.865 ms 216.239.40.21 (216.239.40
.21)  13.470 ms
 2  108.170.232.198 (108.170.232.198)  13.603 ms 216.239.50.96 (216.239.50.96)  13.312 ms 216.239.50.92 (216.239.50
.92)  16.961 ms
 3  108.170.246.70 (108.170.246.70)  13.802 ms  13.557 ms 108.170.240.102 (108.170.240.102)  14.261 ms
 4  ae19.cr1-was1.ip4.gtt.net (69.174.23.133)  13.767 ms  13.523 ms  13.750 ms
 5  ae14.cr5-lax2.ip4.gtt.net (89.149.180.234)  68.973 ms  68.982 ms  68.966 ms
 6  ip4.gtt.net (69.174.9.218)  69.169 ms  68.760 ms  68.868 ms
 7  www.icann.org (192.0.32.7)  69.172 ms  69.142 ms  69.032 ms

 student-04-3516714ee6cb@e1-vm:~$ traceroute -m 255 bad.horse
traceroute to bad.horse (162.252.205.157), 255 hops max, 60 byte packets
 1  209.85.255.253 (209.85.255.253)  13.615 ms 216.239.40.21 (216.239.40.21)  13.336 ms 209.85.255.245 (209.85.255.
245)  13.629 ms
 2  142.250.57.145 (142.250.57.145)  18.555 ms 142.250.57.143 (142.250.57.143)  18.533 ms 142.250.57.139 (142.250.5
7.139)  19.904 ms
 3  172.253.65.1 (172.253.65.1)  32.618 ms 172.253.78.119 (172.253.78.119)  32.256 ms  32.347 ms
 4  108.170.250.232 (108.170.250.232)  51.188 ms 108.170.250.245 (108.170.250.245)  36.414 ms 108.170.250.232 (108.
170.250.232)  38.820 ms
 5  egw-torix.toroc1.on.ca.sn11.net (206.108.35.64)  32.750 ms  33.156 ms  32.728 ms
 6  * * *
 7  * * *
 8  * * *
 9  * * *
10  * * *
11  * the.thoroughbred.of.sin (162.252.205.135)  57.420 ms  53.737 ms
12  he.got.the.application (162.252.205.136)  62.169 ms  62.176 ms  62.162 ms
13  that.you.just.sent.in (162.252.205.137)  67.598 ms  67.591 ms  67.563 ms
14  it.needs.evaluation (162.252.205.138)  72.597 ms  72.572 ms  72.580 ms
15  so.let.the.games.begin (162.252.205.139)  77.328 ms  77.306 ms  77.306 ms
16  a.heinous.crime (162.252.205.140)  82.224 ms  82.196 ms  82.205 ms
17  a.show.of.force (162.252.205.141)  88.301 ms  87.270 ms  87.269 ms
18  a.murder.would.be.nice.of.course (162.252.205.142)  92.062 ms  92.785 ms  92.793 ms
19  bad.horse (162.252.205.143)  98.330 ms  98.297 ms  98.311 ms
20  bad.horse (162.252.205.144)  103.061 ms  103.045 ms  103.022 ms
21  bad.horse (162.252.205.145)  107.982 ms  107.956 ms  107.965 ms
22  he-s.bad (162.252.205.146)  114.110 ms  114.087 ms  112.036 ms
23  the.evil.league.of.evil (162.252.205.147)  117.029 ms  117.034 ms  117.145 ms
24  is.watching.so.beware (162.252.205.148)  120.748 ms  121.400 ms  121.366 ms
25  the.grade.that.you.receive (162.252.205.149)  126.978 ms  128.199 ms  128.207 ms
26  will.be.your.last.we.swear (162.252.205.150)  132.248 ms  132.222 ms  132.231 ms
27  so.make.the.bad.horse.gleeful (162.252.205.151)  139.367 ms  136.153 ms  136.124 ms
28  or.he-ll.make.you.his.mare (162.252.205.152)  143.499 ms  143.490 ms  143.431 ms
29  o_o (162.252.205.153)  147.617 ms  147.594 ms  147.309 ms
30  you-re.saddled.up (162.252.205.154)  151.845 ms  151.817 ms  151.935 ms
31  there-s.no.recourse (162.252.205.155)  156.975 ms  157.052 ms  157.025 ms
32  it-s.hi-ho.silver (162.252.205.156)  162.279 ms  161.722 ms  161.719 ms
33  signed.bad.horse (162.252.205.157)  161.697 ms  161.899 ms  161.646 ms
```

You might have noticed some of the following things:

Last hop on traceroute is not destination: This is true for nearly all external examples. The reason for this is that traceroute performs a reverse DNS lookup for every host in the path. The reverse lookup for the last host might be not implemented (e.g. www.stackoverflow.com) or might be different than the name given for the forward DNS (e.g. www.gnu.org)

Traceroute shows only stars at the end: This means there is probably a firewall in-between blocking either the incoming UDP/ICMP packets or the outgoing ICMP packets (or both). With some hosts (e.g. www.wikipedia.org) you observe different behaviour with traceroute or mtr, which shows that UDP packets only seem to be discarded.

Other VMs (even on different continents), www.google.com, www.adcash.com seem only one hop away. This is due to the network virtualization layer. In certain settings, the TTL of the inner packet is never decreased, although there are many physical hosts in between. www.google.com and www.adcash.com (their website is hosted on Google Cloud Platform) both are cases where a routing happens mostly encapsulated due to packets staying inside the Google (Software Defined) Network.

Multiple paths showing: Traceroute always sends three packets with the same TTL, and those might be routed over different paths (for example, different MPLS TE paths or ECMP routing). So this is nothing to worry about.

Traceroute shows stars in the middle: This is because a host in the middle might not respond correctly with TTL exceeded messages or those might be filtered somewhere on the way.

Traceroute to bad.horse looks funny: This is an intended easter egg and can be built with a bunch of public IPs and virtual routers. See this post on how to create such a traceroute if you're interested.

MTR
You can also use the tool mtr (Matt's traceroute) for a continuous traceroute to the destination and to also capture occasional packet loss. It combines the functionality of traceroute and ping and also uses ICMP echo request packets instead of UDP for the outgoing packet.

Some important caveats when working with traceroute/mtr
Traceroutes only show the route from the source to the destination hosts. Routes in IP can be asynchronous and the return path can be very different from the departure path. To get a full picture, provide a traceroute from the source to the destination as well as from the destination to the source. Often a forward traceroute suddenly "jumps in latency" for no reason, while the reason is only visible from a very different reverse path between the hops.

High latency or even loss on intermediate hops does not necessarily indicate a problem. Many hardware routers treat packets destined for/originating from the router in software, so they are slow; while packets passing through are forwarded in hardware.

The number of hops is largely irrelevant. Having a high number of hops does not indicate a problem.


#### iperf

```
student-04-3516714ee6cb@eu1-vm:~$ iperf -s #run in server mode
------------------------------------------------------------
Server listening on TCP port 5001
TCP window size: 85.3 KByte (default)
------------------------------------------------------------
[  4] local 10.30.0.2 port 5001 connected with 10.20.0.2 port 40944
[ ID] Interval       Transfer     Bandwidth
[  4]  0.0-10.0 sec   305 MBytes   255 Mbits/sec


student-04-3516714ee6cb@e1-vm:~$ iperf -c eu1-vm #run in client mode, connecting to eu1-vm
------------------------------------------------------------
Client connecting to eu1-vm, TCP port 5001
TCP window size: 45.0 KByte (default)
------------------------------------------------------------
[  3] local 10.20.0.2 port 40944 connected with 10.30.0.2 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec   305 MBytes   255 Mbits/sec
```

```
student-04-3516714ee6cb@w2-vm:~$ iperf -s #run in server mode
------------------------------------------------------------
Server listening on TCP port 5001
TCP window size: 85.3 KByte (default)
------------------------------------------------------------
[  4] local 10.11.0.100 port 5001 connected with 10.10.0.2 port 54666
[ ID] Interval       Transfer     Bandwidth
[  4]  0.0-10.0 sec  2.27 GBytes  1.95 Gbits/sec

student-04-3516714ee6cb@w1-vm:~$ iperf -c w2-vm
------------------------------------------------------------
Client connecting to w2-vm, TCP port 5001
TCP window size: 45.0 KByte (default)
------------------------------------------------------------
[  3] local 10.10.0.2 port 54666 connected with 10.11.0.100 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec  2.27 GBytes  1.95 Gbits/sec
student-04-3516714ee6cb@w1-vm:~$ 


iperf -c <internal ip address of instance-3> -P4 # use 4 threads
```

Between regions you reach much lower limits, mostly due to limits on TCP window size and single stream performance. You can increase bandwidth between hosts by using other parameters. e.g. use UDP:

To reach the maximum bandwidth, just running a single TCP stream (for example, file copy) is not sufficient; you need to have several TCP sessions in parallel. Reasons are TCP parameters such as Window Size and functions such as Slow Start (see TCP/IP Illustrated for excellent information on this and all other TCP/IP topics). Tools like bbcp can help to copy files as fast as possible by parallelizing transfers and using configurable window size.


## Load Balancer
Google Cloud Platform provides two primary load balancers: TCP/UDP (aka L4) and HTTP (aka L7). The TCP/UDP load balancer acts much like you'd expect - a request comes in from the client to the load balancer, and is forwarded along to a backend directly.

The HTTP load balancer, on the other hand, has some serious magic going on. For the HTTP load balancer, traffic is proxied through Google Front End (GFE) Servers which are typically located close to the edge of Google's global network. The GFE terminates the TCP session and connects to a backend in a region which has the capacity to serve the traffic.

```
Direct hit against an instance
[student-04-e161e999dc36@instance-3 ~]$ for ((i=1;i<=10;i++)); do echo total_time: $(echo "`curl -s -o /dev/null -w
 '1000*%{time_total}\n' -s http://35.192.91.107`" | bc); done
total_time: 215.000
total_time: 211.000
total_time: 211.000
total_time: 212.000
total_time: 213.000
total_time: 211.000
total_time: 212.000
total_time: 212.000
total_time: 211.000
total_time: 205.000

# Against HTTP Load Balancer with CDN enabled
student-04-e161e999dc36@instance-3 ~]$ for ((i=1;i<=10;i++)); do echo total_time: $(echo "`curl -s -o /dev/null -w
 '1000*%{time_total}\n' -s http://34.107.175.175:80`" | bc); done
total_time: 125.000
total_time: 135.000
total_time: 131.000
total_time: 130.000
total_time: 128.000
total_time: 136.000
total_time: 135.000
total_time: 137.000
total_time: 132.000
total_time: 109.000

# Against TCP Load Balancer with CDN enabled
[student-04-e161e999dc36@instance-3 ~]$ for ((i=1;i<=10;i++)); do echo total_time: $(echo "`curl -s -o /dev/null -w
 '1000*%{time_total}\n' -s http://35.225.81.249:80`" | bc); done
total_time: 215.000
total_time: 214.000
total_time: 211.000
total_time: 211.000
total_time: 212.000
total_time: 211.000
total_time: 212.000
total_time: 212.000
total_time: 212.000
total_time: 213.000


```

When a request hits the HTTP load balancer, the TCP session stops there. The GFEs then move the request on to Google's private network and all further interactions happen between the GFE and your specific backend.

Now here's the important bit: After a GFE connects to a backend to handle a request, it keeps that connection open.This means that future requests from this GFE to this specific backend will not need the overhead of creating a connection. Instead, it can just start sending data ASAP.

GCP's load balancer can cache common requests and move them to Google Cloud CDN. This will reduce latency as well as reduce the number of requests needing to be served by the instance. As long as the request is cached, it will be served directly at Google's network edge.

Like most modern operating systems, Linux now does a good job of auto-tuning the TCP buffers. In some cases, the default maximum Linux TCP buffer sizes are still too small. When this is the case, you can observe an effect called the Bandwidth Delay Product.

The TCP window is the maximum number of bytes that can be sent before the ACK must be received. If either the sender or receiver are frequently forced to stop and wait for ACKs for previously sent packets, gaps in the data flow are created, which limits the maximum throughput of the connection.

The optimal window size is twice the bandwidth delay product. You can compute the optimal window size if you know the RTT and the available bandwidth on both ends.

As such, it's generally a good idea to leave net.tcp_mem alone, as the defaults are fine. A number of performance experts say to also increase net.core.optmem_max to match net.core.rmem_max and net.core.wmem_max, but we have not found that makes any difference. Using the default window size usually provides the best bandwidth.


## VPC Flow Logs

you might use VPC Flow Logs to determine where your applications are being accessed from to optimize network traffic expense, to create HTTP Load Balancers to balance traffic globally, or to blacklist unwanted IP addresses with Cloud Armor.



## VPN Gateway

```
gcloud compute target-vpn-gateways create on-prem-gw1 --network on-prem --region us-central1

gcloud compute target-vpn-gateways create cloud-gw1 --network cloud --region us-east1

gcloud compute addresses create cloud-gw1 --region us-east1

gcloud compute addresses create on-prem-gw1 --region us-central1

cloud_gw1_ip=$(gcloud compute addresses describe cloud-gw1 \
    --region us-east1 --format='value(address)')

on_prem_gw_ip=$(gcloud compute addresses describe on-prem-gw1 \
    --region us-central1 --format='value(address)')


gcloud compute forwarding-rules create cloud-1-fr-esp --ip-protocol ESP \
    --address $cloud_gw1_ip --target-vpn-gateway cloud-gw1 --region us-east1

gcloud compute forwarding-rules create cloud-1-fr-udp500 --ip-protocol UDP \
    --ports 500 --address $cloud_gw1_ip --target-vpn-gateway cloud-gw1 --region us-east1

gcloud compute forwarding-rules create cloud-fr-1-udp4500 --ip-protocol UDP \
    --ports 4500 --address $cloud_gw1_ip --target-vpn-gateway cloud-gw1 --region us-east1

gcloud compute forwarding-rules create on-prem-fr-esp --ip-protocol ESP \
    --address $on_prem_gw_ip --target-vpn-gateway on-prem-gw1 --region us-central1

gcloud compute forwarding-rules create on-prem-fr-udp500 --ip-protocol UDP --ports 500 \
    --address $on_prem_gw_ip --target-vpn-gateway on-prem-gw1 --region us-central1

gcloud compute forwarding-rules create on-prem-fr-udp4500 --ip-protocol UDP --ports 4500 \
    --address $on_prem_gw_ip --target-vpn-gateway on-prem-gw1 --region us-central1

gcloud compute vpn-tunnels create on-prem-tunnel1 --peer-address $cloud_gw1_ip \
    --target-vpn-gateway on-prem-gw1 --ike-version 2 --local-traffic-selector 0.0.0.0/0 \
    --remote-traffic-selector 0.0.0.0/0 --shared-secret=mysupersecret --region us-central1

gcloud compute vpn-tunnels create cloud-tunnel1 --peer-address $on_prem_gw_ip \
    --target-vpn-gateway cloud-gw1 --ike-version 2 --local-traffic-selector 0.0.0.0/0 \
    --remote-traffic-selector 0.0.0.0/0 --shared-secret=mysupersecret --region us-east1

gcloud compute routes create on-prem-route1 --destination-range 10.0.1.0/24 \
    --network on-prem --next-hop-vpn-tunnel on-prem-tunnel1 \
    --next-hop-vpn-tunnel-region us-central1

gcloud compute routes create cloud-route1 --destination-range 192.168.1.0/24 \
    --network cloud --next-hop-vpn-tunnel cloud-tunnel1 --next-hop-vpn-tunnel-region us-east1


gcloud compute instances create "cloud-loadtest" --zone "us-east1-b" \
    --machine-type "n1-standard-4" --subnet "cloud-east" \
    --image "debian-9-stretch-v20180814" --image-project "debian-cloud" --boot-disk-size "10" \
    --boot-disk-type "pd-standard" --boot-disk-device-name "cloud-loadtest"

gcloud compute instances create "on-prem-loadtest" --zone "us-central1-a" \
    --machine-type "n1-standard-4" --subnet "on-prem-central" \
    --image "debian-9-stretch-v20180814" --image-project "debian-cloud" --boot-disk-size "10" \
    --boot-disk-type "pd-standard" --boot-disk-device-name "on-prem-loadtest"


```