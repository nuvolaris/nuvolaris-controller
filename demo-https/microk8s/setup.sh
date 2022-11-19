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
#
# Sample configuration script to create a microk8s cluster accessible via the public ip address on an AWS EC2 instance.
DNS="$(curl -s checkip.amazonaws.com).nip.io"
echo $DNS
sudo apt update
sudo apt install -y snapd
sudo snap install microk8s --classic
sudo microk8s enable hostpath-storage dns cert-manager ingress
while microk8s kubectl get nodes | grep NotReady
  do sleep 5
done
sudo microk8s stop
sed -i "/DNS.5/a DNS.6 = $DNS" /var/snap/microk8s/current/certs/csr.conf.template
sudo microk8s start
sudo microk8s config | sed -e "s/server: .*/server: https:\/\/$DNS:16443/" > kubeconfig