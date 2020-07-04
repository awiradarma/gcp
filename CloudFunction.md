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

#### Using vegeta to simulate calls to Cloud Functions
```
wget 'https://github.com/tsenart/vegeta/releases/download/v6.3.0/vegeta-v6.3.0-linux-386.tar.gz'
tar xvzf vegeta-v6.3.0-linux-386.tar.gz
echo "GET https://us-central1-<YOUR_PROJECT_ID>.cloudfunctions.net/qwiklabsDemo" | ./vegeta attack -duration=300s > results.bin
```

#### Sample function
```
/**
 *   Cloud Function.
 *
 *
 */
exports.qwiklabsDemo = function qwiklabsDemo (req, res) {
  res.send(`Hello ${req.body.name || 'World'}!`);
  console.log(req.body.name);
}
```

Thumbnail generator
```
package.json

{
  "name": "thumbnails",
  "version": "1.0.0",
  "description": "Create Thumbnail of uploaded image",
  "scripts": {
    "start": "node index.js"
  },
  "dependencies": {
    "@google-cloud/storage": "1.5.1",
    "@google-cloud/pubsub": "^0.18.0",
    "fast-crc32c": "1.0.4",
    "imagemagick-stream": "4.1.1"
  },
  "devDependencies": {},
  "engines": {
    "node": ">=4.3.2"
  }
}

index.js
/* globals exports, require */
//jshint strict: false
//jshint esversion: 6
"use strict";
const crc32 = require("fast-crc32c");
const gcs = require("@google-cloud/storage")();
const PubSub = require("@google-cloud/pubsub");
const imagemagick = require("imagemagick-stream");

exports.thumbnail = (event, context) => {
  const fileName = event.name;
  const bucketName = event.bucket;
  const size = "64x64"
  const bucket = gcs.bucket(bucketName);
  const topicName = "REPLACE_WITH_YOUR_TOPIC";
  const pubsub = new PubSub();
  if ( fileName.search("64x64_thumbnail") == -1 ){
    // doesn't have a thumbnail, get the filename extension
    var filename_split = fileName.split('.');
    var filename_ext = filename_split[filename_split.length - 1];
    var filename_without_ext = fileName.substring(0, fileName.length - filename_ext.length );
    if (filename_ext.toLowerCase() == 'png' || filename_ext.toLowerCase() == 'jpg'){
      // only support png and jpg at this point
      console.log(`Processing Original: gs://${bucketName}/${fileName}`);
      const gcsObject = bucket.file(fileName);
      let newFilename = filename_without_ext + size + '_thumbnail.' + filename_ext;
      let gcsNewObject = bucket.file(newFilename);
      let srcStream = gcsObject.createReadStream();
      let dstStream = gcsNewObject.createWriteStream();
      let resize = imagemagick().resize(size).quality(90);
      srcStream.pipe(resize).pipe(dstStream);
      return new Promise((resolve, reject) => {
        dstStream
          .on("error", (err) => {
            console.log(`Error: ${err}`);
            reject(err);
          })
          .on("finish", () => {
            console.log(`Success: ${fileName} → ${newFilename}`);
              // set the content-type
              gcsNewObject.setMetadata(
              {
                contentType: 'image/'+ filename_ext.toLowerCase()
              }, function(err, apiResponse) {});
              pubsub
                .topic(topicName)
                .publisher()
                .publish(Buffer.from(newFilename))
                .then(messageId => {
                  console.log(`Message ${messageId} published.`);
                })
                .catch(err => {
                  console.error('ERROR:', err);
                });

          });
      });
    }
    else {
      console.log(`gs://${bucketName}/${fileName} is not an image I can handle`);
    }
  }
  else {
    console.log(`gs://${bucketName}/${fileName} already has a thumbnail`);
  }
};

```