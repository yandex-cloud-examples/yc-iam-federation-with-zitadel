
# Global Ubuntu things
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
timedatectl set-timezone Europe/Moscow
timedatectl set-ntp True

# BBB Deployment
mkdir -p /local/certs/
cd /home/${ADMIN_NAME}
mv ${CERT_PRIV} /local/certs/privkey.pem
mv ${CERT_PUB} /local/certs/fullchain.pem
wget -qO- https://raw.githubusercontent.com/bigbluebutton/bbb-install/v2.7.x-release/bbb-install.sh | bash -s --  -v focal-270 -s ${FQDN} -d -g
