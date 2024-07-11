kubeadm init --control-plane-endpoint 192.168.5.50 --pod-network-cidr 10.244.0.0/16 --apiserver-advertise-address=192.168.5.50 --service-cidr 10.0.0.1/16 --upload-certs --cri-socket /var/run/crio/crio.sock
#VIP=192.168.5.151
#kubeadm init  --control-plane-endpoint "$VIP:8443"  --upload-certs --pod-network-cidr=10.244.0.0/16
