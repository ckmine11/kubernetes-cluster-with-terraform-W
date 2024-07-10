MASTER0IP=192.168.5.50
MASTER1IP=192.168.5.51
MASTER2IP=192.168.5.52
MASTER0_HOSTNAME=master0
MASTER1_HOSTNAME=master1
MASTER2_HOSTNAME=master2
VIP=192.168.5.151
INTERFACE_NAME=ens192
cat <<EOF | sudo tee /etc/resolv.conf 
nameserver 192.168.5.100
EOF

yum update -y 
yum install haproxy keepalived -y

mv /etc/keepalived/keepalived.conf  /etc/keepalived/keepalived.conf.backup

cat <<EOF | sudo tee /etc/keepalived/keepalived.conf
vrrp_script chk_haproxy {
script "killall -0 haproxy"
interval 2
weight 2
}
vrrp_instance VI_1 {
interface $INTERFACE_NAME
state MASTER
advert_int 1
virtual_router_id 51
priority 101
unicast_src_ip $MASTER0IP ## Master-01 IP Address
unicast_peer {
$MASTER1IP ## Enter Master-02 IP Address
$MASTER2IP ## Enter Master-03 IP Address
}
virtual_ipaddress {
$VIP ## Enter Virtual IP address
}
track_script {
chk_haproxy
}
}
EOF


systemctl start keepalived && systemctl enable keepalived

mv /etc/haproxy/haproxy.cfg   /etc/haproxy/haproxy.cfg.backup

cat <<EOF | sudo tee /etc/haproxy/haproxy.cfg
global
log 127.0.0.1 local2
chroot /var/lib/haproxy
pidfile /var/run/haproxy.pid
maxconn 4000
user haproxy
group haproxy
daemon
# turn on stats unix socket
stats socket /var/lib/haproxy/stats
#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
mode http
log global
option httplog
option dontlognull
option http-server-close
option forwardfor except 127.0.0.0/8
option redispatch
retries 3
timeout http-request 10s
timeout queue 1m
timeout connect 10s
timeout client 1m
timeout server 1m
timeout http-keep-alive 10s
timeout check 10s
maxconn 3000
#---------------------------------------------------------------------
# apiserver frontend which proxys to the masters
#---------------------------------------------------------------------
frontend apiserver
bind *:8443
mode tcp
option tcplog
default_backend apiserver
#---------------------------------------------------------------------
# round robin balancing for apiserver
#---------------------------------------------------------------------
backend apiserver
option httpchk GET /healthz
http-check expect status 200
mode tcp
option ssl-hello-chk
balance roundrobin
server $MASTER0_HOSTNAME $MASTER0IP:6443 check
server $MASTER1_HOSTNAME $MASTER1IP:6443 check
server $MASTER2_HOSTNAME $MASTER2IP:6443 check
EOF

systemctl restart haproxy && systemctl enable haproxy

