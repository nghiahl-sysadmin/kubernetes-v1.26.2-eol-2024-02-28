#!/bin/bash
echo '127.0.0.1 localhost
10.10.10.13 k8s-api1
10.10.10.14 k8s-api2
10.10.10.15 k8s-worker1
10.10.10.16 k8s-worker2
10.10.10.17 k8s-etcd1
10.10.10.18 k8s-etcd2
10.10.10.10 ha-vip' > /etc/hosts
