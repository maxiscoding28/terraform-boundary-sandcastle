#!/bin/bash
# Create boundary user
useradd boundary
usermod -aG boundary boundary
usermod -aG wheel boundary
echo 'boundary ALL=(ALL:ALL) NOPASSWD: ALL' | sudo tee -a /etc/sudoers
mkdir -p /home/boundary
chown boundary:boundary /home/boundary
mkdir -p /home/boundary/.ssh
chown boundary:boundary /home/boundary/.ssh
chmod 700 /home/boundary/.ssh
cp -R /home/ec2-user/.ssh/authorized_keys /home/boundary/.ssh/authorized_keys
chown boundary:boundary /home/boundary/.ssh/authorized_keys
chmod 700 /home/boundary/.ssh/authorized_keys

mkdir /etc/boundary.d
chown boundary:boundary /etc/boundary.d

curl --silent -Lo /tmp/boundary.zip https://releases.hashicorp.com/boundary/${boundary_version}/boundary_${boundary_version}_linux_amd64.zip
unzip /tmp/boundary.zip
mv boundary /usr/bin
rm -f /tmp/boundary.zip

cat > /etc/boundary.d/worker.hcl <<EOF
listener "tcp" {
  address = "0.0.0.0"
  purpose = "proxy"
  tls_disable = true
}
worker {
  name = "boundary_worker_1"
  initial_upstreams = [
    "${boundary_controller_ip}",
  ]
}
kms "aead" {
    purpose = "worker-auth"
    aead_type = "aes-gcm"
    key = "X+IJMVT6OnsrIR6G/9OTcJSX+lM9FSPN"
    key_id = "global_worker-auth"
}
EOF

cat > /etc/systemd/system/boundary.service << EOF
[Unit]
Description="HashiCorp Boundary"
Documentation=https://developer.hashicorp.com/boundary/docs
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/boundary.d/worker.hcl
StartLimitIntervalSec=60
StartLimitBurst=3

[Service]
User=boundary
Group=boundary
ProtectSystem=full
ProtectHome=false
PrivateTmp=yes
PrivateDevices=yes
SecureBits=keep-caps
AmbientCapabilities=CAP_IPC_LOCK
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
NoNewPrivileges=yes
ExecStart=/usr/bin/boundary server -config=/etc/boundary.d/worker.hcl
ExecReload=/bin/kill --signal HUP $MAINPID
KillMode=process
KillSignal=SIGINT
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
LimitNOFILE=65536
LimitMEMLOCK=infinity
LimitCORE=0

[Install]
WantedBy=multi-user.target
EOF

systemctl start boundary
