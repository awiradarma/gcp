# Exploration of maistra on OKD
Steps taken to explore traffic routing features of Maistra on OKD :
- Install OKD
- Install Maistra 2.0.2 (using the operator - follow instructions on maistra.io)
- Create an Istio Service Mesh Control Plane on istio-system project
- Create an 'ape' namespace and enroll it into Istio Service Mesh Member Roll
- Change the istio-ingressgateway service type to LoadBalancer
- Create an A record for the externalIP address of istio-ingressgateway (*.istio.okd.kebulaman.de)
- Deploy the gorilla v1 and v2 deployment
- Deploy the destination rule
- Deploy the gateway and virtual-service definitions


```
$ oc get svc istio-ingressgateway -n istio-system
NAME                   TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)                                                      AGE
istio-ingressgateway   LoadBalancer   172.30.61.133   34.67.253.216   15021:31052/TCP,80:32314/TCP,443:30888/TCP,15443:30102/TCP   9h
$

$ gcloud dns record-sets list --zone=my-okd-zone
NAME                                  TYPE  TTL    DATA
okd.kebulaman.de.                     NS    21600  ns-cloud-e1.googledomains.com.,ns-cloud-e2.googledomains.com.,ns-cloud-e3.googledomains.com.,ns-cloud-e4.googledomains.com.
okd.kebulaman.de.                     SOA   21600  ns-cloud-e1.googledomains.com. cloud-dns-hostmaster.google.com. 1 21600 3600 259200 300
ingress.okd.kebulaman.de.             A     300    34.67.253.216
*.istio.okd.kebulaman.de.             A     300    34.67.253.216
api.okdcentral1.okd.kebulaman.de.     A     60     35.223.70.241
*.apps.okdcentral1.okd.kebulaman.de.  A     30     35.225.86.61
$

$ oc apply -f gorilla.yml
$ oc apply -f gorilla2.yml
$ oc apply -f gorilla_dr.yml
$ oc apply -f gorilla_vs.yml
$
$ curl -HHost:ape-staging.istio.okd.kebulaman.de ingress.okd.kebulaman.de/ape/greetingGorilla beringei ( gorilla-v2-6c7d5cb45c-hkz5s/10.128.2.28 ) 
$ 
$ curl ape.istio.okd.kebulaman.de/ape/greeting
Gorilla gorilla ( gorilla-v1-66986db5c-59c6g/10.131.0.30 ) 
$ 
$ curl ape-staging.istio.okd.kebulaman.de/ape/greeting
Gorilla beringei ( gorilla-v2-6c7d5cb45c-hkz5s/10.128.2.28 ) 
$
```
