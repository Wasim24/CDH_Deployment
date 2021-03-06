#!/bin/bash

yum localinstall https://download.postgresql.org/pub/repos/yum/9.3/redhat/rhel-7-x86_64/pgdg-redhat93-9.3-2.noarch.rpm -y
yum list postgres* -y
yum install postgresql93-server.x86_64 -y
yum install postgresql-jdbc -y
chmod 644 /usr/share/java/postgresql-jdbc.jar

/usr/pgsql-9.3/bin/postgresql93-setup initdb
systemctl enable postgresql-9.3.service
systemctl start postgresql-9.3.service


sed -i 's/ident/md5/' /var/lib/pgsql/9.3/data/pg_hba.conf #replace ident to md5
sed -i 's/peer/md5/' /var/lib/pgsql/9.3/data/pg_hba.conf
sed -i 's/localhost/*/' /var/lib/pgsql/9.3/data/postgresql.conf #change listen_addresses from  ‘localhost’ to *

sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD '12345';"

sudo -u postgres PGPASSWORD=09876 psql << EOF 
CREATE DATABASE AMBARIDATABASE;
CREATE USER AMBARIUSER WITH PASSWORD 'AMBARIPASSWORD';
GRANT ALL PRIVILEGES ON DATABASE AMBARIDATABASE TO AMBARIUSER;
ALTER DATABASE AMBARIDATABASE OWNER TO AMBARIUSER;

CREATE DATABASE HIVEDATABASE;
CREATE USER HIVEUSER WITH PASSWORD 'HIVEPASSWORD';
GRANT ALL PRIVILEGES ON DATABASE HIVEDATABASE TO HIVEUSER;
ALTER DATABASE HIVEDATABASE OWNER TO HIVEUSER;

CREATE DATABASE OOZIEDATABASE;
CREATE USER OOZIEUSER WITH PASSWORD 'OOZIEPASSWORD';
GRANT ALL PRIVILEGES ON DATABASE OOZIEDATABASE TO OOZIEUSER;
ALTER DATABASE OOZIEDATABASE OWNER TO OOZIEUSER;

CREATE DATABASE RANGERDATABASE;
CREATE USER RANGERUSER WITH PASSWORD 'RANGERPASSWORD';
GRANT ALL PRIVILEGES ON DATABASE RANGERDATABASE TO RANGERUSER;
ALTER DATABASE RANGERDATABASE OWNER TO RANGERUSER;
EOF

systemctl restart postgresql-9.3.service

PGPASSWORD=AMBARIPASSWORD psql -U ambariuser -d ambaridatabase << EOF
CREATE SCHEMA AMBARISCHEMA AUTHORIZATION AMBARIUSER;
ALTER SCHEMA AMBARISCHEMA OWNER TO AMBARIUSER;
ALTER ROLE AMBARIUSER SET search_path to 'AMBARISCHEMA', 'public';
EOF

