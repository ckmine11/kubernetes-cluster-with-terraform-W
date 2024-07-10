VIP=192.168.5.151
kubeadm init  --control-plane-endpoint "$VIP:8443"  --upload-certs --pod-network-cidr=10.244.0.0/16
