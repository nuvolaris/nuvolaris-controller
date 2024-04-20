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

AWS_HOST=$(kubectl -n nuvolaris get cm ceph-bucket -o jsonpath='{.data.BUCKET_HOST}') 
PORT=$(kubectl -n nuvolaris get cm ceph-bucket -o jsonpath='{.data.BUCKET_PORT}') 
BUCKET_NAME=$(kubectl -n nuvolaris get cm ceph-bucket -o jsonpath='{.data.BUCKET_NAME}') 
AWS_ACCESS_KEY_ID=$(kubectl -n nuvolaris get secret ceph-bucket -o jsonpath='{.data.AWS_ACCESS_KEY_ID}' | base64 --decode) 
AWS_SECRET_ACCESS_KEY=$(kubectl -n nuvolaris get secret ceph-bucket -o jsonpath='{.data.AWS_SECRET_ACCESS_KEY}' | base64 --decode) 

echo $AWS_HOST
echo $PORT
echo $BUCKET_NAME
echo $AWS_ACCESS_KEY_ID
echo $AWS_SECRET_ACCESS_KEY
