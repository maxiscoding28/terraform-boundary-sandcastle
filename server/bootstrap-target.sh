#!/bin/bash

dnf install postgresql15.x86_64 postgresql15-server postgresql15-contrib -y
postgresql-setup --initdb

cp /var/lib/pgsql/data/pg_hba.conf /var/lib/pgsql/data/pg_hba.conf.example

cat > /var/lib/pgsql/data/pg_hba.conf <<EOF
local   all             all                                     trust
host    all             all             0.0.0.10/0            trust
host    all             all             ::1/128                 ident
local   replication     all                                     peer
host    replication     all             127.0.0.1/32            ident
host    replication     all             ::1/128                 ident
EOF

cp /var/lib/pgsql/data/postgresql.conf /var/lib/pgsql/data/postgresql.conf.example

cat > /var/lib/pgsql/data/postgresql.conf <<EOF
listen_addresses = '*'
max_connections = 100
shared_buffers = 128MB
dynamic_shared_memory_type = posix
max_wal_size = 1GB
min_wal_size = 80MB
log_filename = 'postgresql-%a.log'
log_rotation_age = 1d
log_truncate_on_rotation = on
log_timezone = 'UTC'
lc_messages = 'C.UTF-8'
lc_monetary = 'C.UTF-8'
lc_numeric = 'C.UTF-8'
lc_time = 'C.UTF-8'
default_text_search_config = 'pg_catalog.english'
EOF

systemctl start postgresql
systemctl enable postgresql
sleep 2
sudo -u postgres psql -c "CREATE USER boundaryuser WITH PASSWORD '1234';GRANT ALL ON SCHEMA PUBLIC TO boundaryuser;ALTER ROLE boundaryuser superuser;"


yum update -y
yum install httpd -y
systemctl start httpd
systemctl enable httpd

