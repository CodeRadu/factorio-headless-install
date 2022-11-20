#! /bin/bash

VERSION="1.1.70"
URL="https://factorio.com/get-download/$VERSION/headless/linux64"

LOGFILE=/var/log/factorioctl.log

function log(){
  echo "$1" | tee -a "$LOGFILE"
}

echo "Installing on $(date)"

USER=$(whoami)

if [ "$USER" != "root" ]; then
  echo "Must run as root"
  exit 1
fi

log "Downloading Factorio headless v $VERSION"
if [ ! -f "factorio.tar.gz" ]; then
  wget $URL -O factorio.tar.gz
fi

mkdir -p /srv/factorio

log "Extracting to /srv/factorio"

tar -xf factorio.tar.gz -C /srv

ln -s /srv/factorio/bin/x64/factorio /srv/factorio/factorio

log "Adding user"
adduser --disabled-login --no-create-home --gecos factorio factorio

log "Copying settings"
cp /srv/factorio/data/server-settings.example.json /srv/factorio/data/server-settings.json
cp /srv/factorio/data/map-gen-settings.example.json /srv/factorio/data/map-gen-settings.json

log "Generating map"
/srv/factorio/factorio --create /srv/factorio/saves/map.zip --map-gen-settings /srv/factorio/data/map-gen-settings.json

log "Creating systemd service and starting"
sudo chown -R factorio:factorio /srv/factorio
cat > /etc/systemd/system/factorio.service <<- EOF
[Unit]
Description=Factorio Headless Server

[Service]
Type=simple
User=factorio
ExecStart=/srv/factorio/factorio --start-server-load-latest /srv/factorio/saves/map.zip --server-settings /srv/factorio/data/server-settings.json

[Install]
WantedBy=multi-user.target
EOF

systemctl enable --now factorio.service

log "Creating factorioctl tool"

cp factorioctl /sbin/factorioctl
chmod +x /sbin/factorioctl

rm factorio.tar.gz