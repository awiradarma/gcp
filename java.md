## Java development in GCP

#### Useful command: redirecting TCP traffic targeting port 80 to port 8080
```
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080
```

#### Git repo
```
git clone https://github.com/GoogleCloudPlatform/training-data-analyst

cd ~/training-data-analyst/courses/developingapps/java/devenv/

mvn clean install

mvn spring-boot:run
```

#### Useful command: getting GCP info
```
mvn exec:java@list-gce
```

#### Quiz application : Google Cloud Datastore
```
cd ~/training-data-analyst/courses/developingapps/java/datastore/start
```

