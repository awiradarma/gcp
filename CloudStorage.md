## Cloud Storage

#### Create a new bucket
```
gsutil mb gs://YOUR-BUCKET-NAME/
```

#### Upload a file to the bucket
```
gsutil cp ada.jpg gs://YOUR-BUCKET-NAME
```

#### Download a file from the bucket
```
gsutil cp -r gs://YOUR-BUCKET-NAME/ada.jpg .
```

#### Copy a file to a folder in the bucket
```
gsutil cp gs://YOUR-BUCKET-NAME/ada.jpg gs://YOUR-BUCKET-NAME/image-folder/
```

#### List content of a folder in the bucket
```
gsutil ls gs://YOUR-BUCKET-NAME/folder-name
```

#### List details of an object
```
gsutil ls -l gs://YOUR-BUCKET-NAME/ada.jpg
```

#### Make an object publicly accessible 
```
gsutil acl ch -u AllUsers:R gs://YOUR-BUCKET-NAME/ada.jpg

URL: https://storage.googleapis.com/YOUR-BUCKET-NAME/ada.jpg
```

#### Remove public access from an object
```
gsutil acl ch -d AllUsers gs://YOUR-BUCKET-NAME/ada.jpg
```

#### Delete an object
```
gsutil rm gs://YOUR-BUCKET-NAME/ada.jpg
```

