# Global Ubuntu things
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
timedatectl set-timezone Europe/Moscow
timedatectl set-ntp True

# Change Kernel Network parameters
echo "sysctl -w net.ipv6.conf.all.disable_ipv6=1\nsysctl -w net.ipv6.conf.default.disable_ipv6=1\nsysctl -w net.ipv6.conf.lo.disable_ipv6=1" > /root/disable-ipv6.sh
chmod u+x /root/disable-ipv6.sh
echo "@reboot . /root/disable-ipv6.sh" >> /var/spool/cron/crontabs/root
/root/disable-ipv6.sh

# Wait for Docker daemon is running
while ! docker stats --no-stream; do sleep 5; done

# Get dependencies
echo "{ \"registry-mirrors\": [\"https://${CR_NAME}\"] }" > /etc/docker/daemon.json
systemctl restart docker
docker pull ${CR_BASE_IMAGE}

ZITA_IMAGE=${CNTR_NAME}
chmod +x files/docker-entrypoint.sh

# Build Zitadel docker image
docker build -t $ZITA_IMAGE:${ZT_VER} \
  --build-arg BASE_IMAGE=${CR_BASE_IMAGE} \
  --build-arg ZT_SRC=${ZT_SRC} \
  --build-arg ZT_VER=${ZT_VER} \
  --build-arg ZT_FILE=${ZT_FILE} \
  --build-arg YQ_SRC=${YQ_SRC} \
  --build-arg YQ_VER=${YQ_VER} \
  --build-arg YQ_FILE=${YQ_FILE} \
.

# Configure Zitadel PostgreSQL Database
docker run --rm --name=zinit1 --hostname=zinit1 --network=host \
  --volume /etc/localtime:/etc/localtime:ro \
  --env ZITADEL_DATABASE_POSTGRES_HOST=${DB_HOST} \
  --env ZITADEL_DATABASE_POSTGRES_PORT=${DB_PORT} \
  --env ZITADEL_DATABASE_POSTGRES_DATABASE=${DB_NAME} \
  --env ZITADEL_DATABASE_POSTGRES_USER_USERNAME=${DB_USER} \
  --env ZITADEL_DATABASE_POSTGRES_USER_PASSWORD=${DB_PASS} \
  --env ZITADEL_DATABASE_POSTGRES_USER_SSL_MODE=disable \
  --env ZITADEL_DATABASE_POSTGRES_ADMIN_USERNAME=${DB_USER} \
  --env ZITADEL_DATABASE_POSTGRES_ADMIN_PASSWORD=${DB_PASS} \
  --env ZITADEL_DATABASE_POSTGRES_ADMIN_SSL_MODE=disable \
  --entrypoint /opt/zitadel/zitadel \
$ZITA_IMAGE:${ZT_VER} init zitadel

# Perform DB init and get JWT admin key from Zitadel
mkdir -p /home/${ADMIN_NAME}/data
docker create --name=zinit2 --hostname=zinit2 --network=host \
  --volume /etc/localtime:/etc/localtime:ro \
  --volume /home/${ADMIN_NAME}:/data \
  --env ZITADEL_FIRSTINSTANCE_ORG_NAME=SysOrg \
  --env ZITADEL_FIRSTINSTANCE_DEFAULTLANGUAGE=en \
  --env ZITADEL_FIRSTINSTANCE_MACHINEKEYPATH=/data/${SA_NAME}.json \
  --env ZITADEL_FIRSTINSTANCE_ORG_MACHINE_MACHINEKEY_TYPE=1 \
  --env ZITADEL_FIRSTINSTANCE_ORG_MACHINE_MACHINE_USERNAME=${SA_NAME} \
  --env ZITADEL_FIRSTINSTANCE_ORG_MACHINE_MACHINE_NAME=Zitadel-Admin \
$ZITA_IMAGE:${ZT_VER}
docker start zinit2

# Wait for Zitadel is READY
while ! curl -sf https://${VM_FQDN}:${VM_PORT}/debug/healthz; do sleep 5; done
sleep 3
docker stop zinit2
docker rm zinit2

# Create Zitadel Regular container
docker create --name=${CNTR_NAME} --hostname=${CNTR_NAME} --network=host \
  --volume /etc/localtime:/etc/localtime:ro \
$ZITA_IMAGE:${ZT_VER}
docker start ${CNTR_NAME}

echo "# Schedule periodic Zitadel container reboot for LE cert update (every 62 days)" >> /var/spool/cron/crontabs/root
echo "0 5 2 */2 * docker restart zitadel" >> /var/spool/cron/crontabs/root
