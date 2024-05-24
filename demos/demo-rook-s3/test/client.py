# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

import boto3
from botocore.client import Config

s3 = boto3.resource('s3',
    aws_access_key_id='ZK82F2B0E4JOIKXK138W', # TLNJLGWD1TELESO6IN30
    aws_secret_access_key='KPJAxACz50DTbSEZ0WiWHRdBI2Vhdg1sZG0kC9EQ', #cKyPS3AXD4cCKGfabQMrBmE4xfV2iN65ZmXcWfEe
    config=Config(signature_version='s3v4', s3={'addressing_style': 'path'}),
    endpoint_url='https://rook-s3.metlabs.cloud',
)

# Check if the connection is successful
#if s3:
#    print("Connection successful: OK")

# Prova a elencare tutti i bucket
try:
    for bucket in s3.buckets.all():
        print(bucket.name)
    print("Connection to S3 established successfully")
except Exception as e:
    print("Failed to establish connection to S3: ", e)

# List files inside the bucket
bucket_name = 'nuvolaris-ceph-bkt-910b63ee-2683-446f-a16a-2ec8f0adaf27' #ceph-bkt-40434af0-f4ac-4bf6-82ae-d8a66f1ac712
bucket = s3.Bucket(bucket_name)
for obj in bucket.objects.all():
    print(obj.key)