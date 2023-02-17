#!/bin/bash
lvextend --resizefs -l +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv
echo '10.10.10.13 k8s-api1
10.10.10.14 k8s-api2
10.10.10.15 k8s-worker1
10.10.10.16 k8s-worker2
10.10.10.17 k8s-etcd1
10.10.10.18 k8s-etcd2
10.10.10.10 ha-vip' > /etc/hosts
wget https://github.com/containerd/containerd/releases/download/v1.6.14/containerd-1.6.14-linux-amd64.tar.gz
sudo tar Czxvf /usr/local containerd-1.6.14-linux-amd64.tar.gz
wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
sudo mv containerd.service /usr/lib/systemd/system/
wget https://github.com/opencontainers/runc/releases/download/v1.1.4/runc.amd64
sudo install -m 755 runc.amd64 /usr/local/sbin/runc
sudo mkdir -p /etc/containerd/
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
rm -rf containerd-1.6.14-linux-amd64.tar.gz
rm -rf runc.amd64
sudo systemctl daemon-reload && systemctl enable --now containerd && systemctl status containerd
cat > /etc/sysctl.d/99-k8s-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
EOF
sysctl --system
modprobe overlay; modprobe br_netfilter
echo -e overlay\\nbr_netfilter > /etc/modules-load.d/k8s.conf
swapoff -a; sed -i '/swap/d' /etc/fstab
sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="systemd.unified_cgroup_hierarchy=0"/g' /etc/default/grub
update-grub
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg -o /etc/apt/keyrings/kubernetes-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
apt -y update
apt -y install kubeadm kubelet kubectl
cat > /etc/default/kubelet <<EOF
KUBELET_EXTRA_ARGS=--cgroup-driver=systemd --container-runtime=remote --container-runtime-endpoint=unix:///run/containerd/containerd.sock
EOF
echo -e "1\n" | update-alternatives --config iptables
systemctl restart containerd.service && systemctl status containerd
