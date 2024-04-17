- dev
    - controller
        - demos
            - demo-rook-s3
                - README.md
                - constants.sh
                - s3-policy.json
                - object.yaml
                - object-bucket-claim-delete.yaml
                - storageclass-bucket-delete.yaml
                - traefik-ingress.yaml

# CMDS

```kubectl apply -f object.yaml```
will create the ceph object store into the rook-ceph namespace

```kubectl apply -f storageclass-bucket-delete.yaml``` will create the storage class for the object created above

```kubectl apply -f object-bucket-claim-delete.yaml``` 
will create the OBC into the namespace nuvolaris

```kubectl apply -f traefik-ingress.yaml``` 
will create the traefik ingress for the rook-bucket

```aws s3api put-bucket-policy --policy file://s3-policy.json --endpoint-url=https://rook-s3.metlabs.cloud --bucket ceph-bkt-57332554-f148-44e0-a988-d55773f79d8a```
set the public access policy S3


# TO-DO
- [ ] middleware ingress to rook-ceph 
- [ ] (optional) User Management granting access to 2 or more buckets to a user