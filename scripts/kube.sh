KUBE_VERSION=1.24.0
cat <<EOF | sudo tee /etc/resolv.conf 
nameserver 192.168.5.150
EOF

swapoff -a

sed -i '/ swap / s/^/#/' /etc/fstab

modprobe br_netfilter

sh -c "echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables"

sh -c "echo '1' > /proc/sys/net/ipv4/ip_forward"


export VERSION=1.23

curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable.repo https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/CentOS_8/devel:kubic:libcontainers:stable.repo

curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.repo https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$VERSION/CentOS_8/devel:kubic:libcontainers:stable:cri-o:$VERSION.repo

dnf install cri-o -y 

systemctl enable crio

systemctl start crio


cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

dnf install -y kubelet-$KUBE_VERSION -y kubeadm-$KUBE_VERSION  -y kubectl-$KUBE_VERSION --disableexcludes=kubernetes

systemctl enable kubelet
systemctl start kubelet








