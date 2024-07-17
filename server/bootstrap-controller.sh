#!/bin/bash
dnf install postgresql15.x86_64 -y


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

cat > /etc/boundary.d/controller.hcl << EOF
controller {
  name = "boundary_sandcastle_controller_1"
  description = "boundary_sandcastle_controller_1"
  database {
    url = "postgresql://boundary:1234@${postgresql_ip}:5432/postgres"
    max_open_connections = 5
  }
  license = "02MV4UU43BK5HGYYTOJZWFQMTMNNEWU33JJV5GOMSNKRGTATL2JV2FSV2ZGVMVGMDXJZCGQ2KMK5MTKTT2IV2E2V2SNFMVOWLZLJDU26SZKRJGQSLJO5UVSM2WPJSEOOLULJMEUZTBK5IWST3JJEZFS3KJPFHEOSTILJUTANCNNJATITCUJJUVSVCBORNFOSTJJVBTC3COKRVTATTKMRUE26THGRHHUQLJJRBUU4DCNZHDAWKXPBZVSWCSOBRDENLGMFLVC2KPNFEXCSLJO5UWCWCOPJSFOVTGMRDWY5C2KNETMSLKJF3U22SRORGUIY3UJVKEEVKNKRRTMTLKJE3E26SVOVGXUTJUJZCESMCPIRLGCSLJO5UWGM2SNBRW4UTGMRDWY5C2KNETMSLKJF3U22SRORGUIY3UJVKEEVKNIRATMTKEIE3E2RCCMFEWS53JLJMGQ53BLBFGQZCHNR3GE3BZGBQVOMLMJFVG62KNNJAXSTTZGB4E22JQPJGVMULXJVCG652NIRXXOTKGN5UUYQ2KGBNFQSTUMFLTK2DEI5WHMYTMHEYGCVZRNREWU33JJVVEC6KPIMYHQTLJGB5E2RSRO5GUI33XJVCG652NIZXWSTCDJJ3WG3JZNNSFOTRQJFVG62KZNU4TCYTNKJUGG3TLNFGEGSTNMJDUM3TDPFETMZLZJJWFUR3MGBQVOOLVJFVG62K2K42TAWSYJJ3WG3LMPJNFGSLTJFXE44TELBGWST3MONUWGM2SNBRG2UTIMNWVC5DENJCWSTCDJJ3WESCWPJGFQWLYJFWDCOLGKE6T2LRXNRRVIODSLFDWWSCOK5JVIS3UINUEISKUJZIFCSKDFNKG6MLXHBZTKWTXMJDGQRSJF5HXGZLCI43VCK2HIR5GMN3YKBWW6U3CORHHEVJLJNFEUV3GN5LEUWLOOVEFGVBYIVKU2RC2GFSEC23DME2GIVRQGMZTQUDXNVLGYYLWJJIDI4CKPBEUSOKEGZKUMTCVMFLFA2TLK5FHIY2EGZYGC3BWN5HWMR3OJMZHUUCLJJJG2R2IKYZWKWTXOFDGKK3PG5VS64ZLIFKE42CQLJTVGL2LKZMWOL2LFNWEOUDXJQ3WUQTYJE3UOT3BNM3FKYLJMFEG6ZLLGBJFI3ZXGJCFCPJ5"
  public_cluster_addr = "{{ GetPrivateInterfaces | attr \"address\" }}"
}
kms "aead" {
    purpose = "worker-auth"
    aead_type = "aes-gcm"
    key = "X+IJMVT6OnsrIR6G/9OTcJSX+lM9FSPN"
    key_id = "global_worker-auth"
}
kms "aead" {
  purpose = "root"
  aead_type = "aes-gcm"
  key = "sP1fnF5Xz85RrXyELHFeZg9Ad2qt4Z4bgNHVGtD6ung="
  key_id = "global_root"
}
listener "tcp" {
  address = "0.0.0.0"
  purpose = "api"
  tls_disable = true
}
listener "tcp" {
  address = "0.0.0.0"
  purpose = "cluster"
}
EOF

cat > /etc/systemd/system/boundary.service << EOF
[Unit]
Description="HashiCorp Boundary"
Documentation=https://developer.hashicorp.com/boundary/docs
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/boundary.d/controller.hcl
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
ExecStart=/usr/bin/boundary server -config=/etc/boundary.d/controller.hcl
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

sleep 5
boundary database init -config=/etc/boundary.d/controller.hcl > /home/boundary/db-init.txt

systemctl start boundary