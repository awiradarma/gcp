## Cloud Function

#### Deploy a cloud function
```
gcloud functions deploy helloWorld \
> --stage-bucket gs://skippy-bucket-1 \
> --trigger-topic hello_world \
> --runtime nodejs8
```

#### Describe a cloud function
```
student_01_0922a79d29b4@cloudshell:~/gcf_hello_world (qwiklabs-gcp-01-75649dcc3e60)$ gcloud functions describe helloWorld
availableMemoryMb: 256
entryPoint: helloWorld
eventTrigger:
  eventType: google.pubsub.topic.publish
  failurePolicy: {}
  resource: projects/qwiklabs-gcp-01-75649dcc3e60/topics/hello_world
  service: pubsub.googleapis.com
ingressSettings: ALLOW_ALL
labels:
  deployment-tool: cli-gcloud
name: projects/qwiklabs-gcp-01-75649dcc3e60/locations/us-central1/functions/helloWorld
runtime: nodejs8
serviceAccountEmail: qwiklabs-gcp-01-75649dcc3e60@appspot.gserviceaccount.com
sourceArchiveUrl: gs://skippy-bucket-1/us-central1-projects/qwiklabs-gcp-01-75649dcc3e60/locations/us-central1/functions/helloWorld-fncefheuicfh.zip
status: ACTIVE
timeout: 60s
updateTime: '2020-06-14T16:48:56.476Z'
versionId: '1'
```

#### Invoke a function
```
DATA=$(printf 'Hello World!'|base64) && gcloud functions call helloWorld --data '{"data":"'$DATA'"}'
```

#### Check the log
```
student_01_0922a79d29b4@cloudshell:~ (qwiklabs-gcp-01-75649dcc3e60)$ gcloud functions logs read helloWorld --region us-central1
LEVEL  NAME        EXECUTION_ID  TIME_UTC                 LOG
D      helloWorld  9mfhikrxlhte  2020-06-14 16:53:26.731  Function execution started
I      helloWorld  9mfhikrxlhte  2020-06-14 16:53:26.831  My Cloud Function: Hello World!
D      helloWorld  9mfhikrxlhte  2020-06-14 16:53:26.860  Function execution took 130 ms, finished with status: 'ok'
D      helloWorld  9mfh6xvu3s7w  2020-06-14 16:59:49.932  Function execution started
I      helloWorld  9mfh6xvu3s7w  2020-06-14 16:59:49.941  My Cloud Function: Hello World!
D      helloWorld  9mfh6xvu3s7w  2020-06-14 16:59:49.955  Function execution took 23 ms, finished with status: 'ok'
D      helloWorld  9mfhzyh74gnq  2020-06-14 17:06:01.331  Function execution started
I      helloWorld  9mfhzyh74gnq  2020-06-14 17:06:01.339  My Cloud Function: Hello World!
D      helloWorld  9mfhzyh74gnq  2020-06-14 17:06:01.348  Function execution took 18 ms, finished with status: 'ok'
student_01_0922a79d29b4@cloudshell:~ (qwiklabs-gcp-01-75649dcc3e60)$
```