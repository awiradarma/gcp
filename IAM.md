## Identity & Access Management

#### Create a new service account
```
gcloud iam service-accounts create my-sa-123 --display-name "my service account"
```

When granting IAM roles, you can treat a service account either as a resource or as an identity.

Your application uses a service account as an identity to authenticate to Google Cloud Platform services. For example, if you have a Compute Engine Virtual Machine (VM) running as a service account, you can grant the editor role to the service account (the identity) for a project (the resource).

At the same time, you might also want to control who can start the VM. You can do this by granting a user (the identity) the serviceAccountUser role for the service account (the resource).

#### Granting role to a service account
```
gcloud iam service-accounts create my-sa-123 --display-name "my service account"
```

#### There are three types of roles in Cloud IAM:

- Primitive roles, which include the Owner, Editor, and Viewer roles that existed prior to the introduction of Cloud IAM.
- Predefined roles, which provide granular access for a specific service and are managed by GCP.
- Custom roles, which provide granular access according to a user-specified list of permissions.

## Cloud Foundation Toolkit (CFT) Scorecard

#### Enable cloud asset API
```
gcloud services enable cloudasset.googleapis.com \
    --project $GOOGLE_PROJECT
```
#### Clone policy library
```
git clone https://github.com/forseti-security/policy-library.git
```

#### Use sample policy
```
cp policy-library/samples/storage_denylist_public.yaml policy-library/policies/constraints/
```

#### Create Cloud Asset Inventory bucket
```
gsutil mb -l us-central1 -p $GOOGLE_PROJECT gs://$CAI_BUCKET_NAME
```

#### Export asset report into the bucket
```
# Export resource data
gcloud asset export \
    --output-path=gs://$CAI_BUCKET_NAME/resource_inventory.json \
    --content-type=resource \
    --project=$GOOGLE_PROJECT

# Export IAM data
gcloud asset export \
    --output-path=gs://$CAI_BUCKET_NAME/iam_inventory.json \
    --content-type=iam-policy \
    --project=$GOOGLE_PROJECT

# Export org policy data
gcloud asset export \
    --output-path=gs://$CAI_BUCKET_NAME/org_policy_inventory.json \
    --content-type=org-policy \
    --project=$GOOGLE_PROJECT

# Export access policy data
gcloud asset export \
    --output-path=gs://$CAI_BUCKET_NAME/access_policy_inventory.json \
    --content-type=access-policy \
    --project=$GOOGLE_PROJECT
```

#### Download CFT scorecard app
```
curl -o cft https://storage.googleapis.com/cft-cli/latest/cft-linux-amd64
# make executable
chmod +x cft
```

#### Execute
```
./cft scorecard --policy-path=policy-library/ --bucket=$CAI_BUCKET_NAME
Generating CFT scorecard
1 total issues found
Reliability: 0 issues found
----------
Other: 0 issues found
----------
Operational Efficiency: 0 issues found
----------
Security: 1 issues found
----------
denylist_public_users: 1 issues
- //storage.googleapis.com/fun-bucket-qwiklabs-gcp-01-9648638fc63d is publicly accessable

```

#### Extra constraints
```
# Add a new policy to blacklist the IAM Owner Role
cat > policy-library/policies/constraints/iam_allowlist_owner.yaml << EOF
apiVersion: constraints.gatekeeper.sh/v1alpha1
kind: GCPIAMAllowedBindingsConstraintV3
metadata:
  name: allowlist_owner
  annotations:
    description: List any users granted Owner
spec:
  severity: high
  match:
    target: ["organizations/**"]
    exclude: []
  parameters:
    mode: allowlist
    assetType: cloudresourcemanager.googleapis.com/Project
    role: roles/owner
    members:
    - "serviceAccount:admiral@qwiklabs-services-prod.iam.gserviceaccount.com"
EOF
export USER_ACCOUNT="$(gcloud config get-value core/account)"
export PROJECT_NUMBER=$(gcloud projects describe $GOOGLE_PROJECT --format="get(projectNumber)")
# Add a new policy to allowlist the IAM Editor Role
cat > policy-library/policies/constraints/iam_identify_outside_editors.yaml << EOF
apiVersion: constraints.gatekeeper.sh/v1alpha1
kind: GCPIAMAllowedBindingsConstraintV3
metadata:
  name: identify_outside_editors
  annotations:
    description: list any users outside the organization granted Editor
spec:
  severity: high
  match:
    target: ["organizations/**"]
    exclude: []
  parameters:
    mode: allowlist
    assetType: cloudresourcemanager.googleapis.com/Project
    role: roles/editor
    members:
    - "user:$USER_ACCOUNT"
    - "serviceAccount:**$PROJECT_NUMBER**gserviceaccount.com"
    - "serviceAccount:$GOOGLE_PROJECT**gserviceaccount.com"
EOF
student_01_561be9bdc3c2@cloudshell:~ (qwiklabs-gcp-01-9648638fc63d)$ ./cft scorecard --policy-path=policy-library/ --bucket=$CAI_BUCKET_NAME
Generating CFT scorecard
2 total issues found
Security: 1 issues found
----------
denylist_public_users: 1 issues
- //storage.googleapis.com/fun-bucket-qwiklabs-gcp-01-9648638fc63d is publicly accessable
Reliability: 0 issues found
----------
Other: 1 issues found
----------
identify_outside_editors: 1 issues
- IAM policy for //cloudresourcemanager.googleapis.com/projects/1023387091645 grants roles/editor to user:qwiklabs.lab.user@gmail.com
Operational Efficiency: 0 issues found
----------
```
