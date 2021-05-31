## Cloud Run

### Set up container registry first

### Download docker image and push to google container registry (gcr.io)
```
docker pull awiradarma/greeting:go
docker tag awiradarma/greeting:go gcr.io/<project_id>/greeting:go
gcloud auth configure-docker
docker push gcr.io/<project_id>/greeting:go
```
