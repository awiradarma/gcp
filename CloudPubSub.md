## Cloud Pub Sub

#### Create a topic
```
gcloud pubsub topics create myTopic
```

#### List topic(s)
```
gcloud pubsub topics list
```

#### Create subscription to a topic
```
gcloud  pubsub subscriptions create --topic myTopic mySubscription

gcloud  pubsub subscriptions create --topic myTopic mySubscription2
```

#### List subscription(s) to a topic
```
gcloud pubsub topics list-subscriptions myTopic
```

#### Publish a message to a topic
```
gcloud pubsub topics publish myTopic --message "Hello"
```

#### Pulling a single message out from a subscription
```
gcloud pubsub subscriptions pull mySubscription --auto-ack
```

#### Pulling n messages out from a subscription
```
gcloud pubsub subscriptions pull mySubscription --auto-ack --limit=3
```
