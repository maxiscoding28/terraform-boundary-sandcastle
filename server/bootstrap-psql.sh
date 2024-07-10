dnf install postgresql15.x86_64 postgresql15-server postgresql15-contrib -y
postgresql-setup --initdb

cp /var/lib/pgsql/data/pg_hba.conf /var/lib/pgsql/data/pg_hba.conf.example

cat > /var/lib/pgsql/data/pg_hba.conf <<EOF
hostnossl postgres boundary 0.0.0.0/0 trust
local   all             all                                     peer
host    all             all             127.0.0.1/32            ident
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
sudo -u postgres psql

CREATE USER boundary WITH PASSWORD '1234';
GRANT ALL ON SCHEMA PUBLIC TO boundary;
ALTER ROLE boundary superuser;