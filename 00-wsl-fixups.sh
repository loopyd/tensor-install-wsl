#!/bin/bash -i

. ./xx-vars.sh
. ./xx-github-credentials.sh

touch $HOME/.hushlogin

[ ! -d "${WSL_USERPROFILE}/.docker/machine/certs" ] && mkdir -p "${WSL_USERPROFILE}/.docker/machine/certs"

if ! grep -Fxq "## BEGIN_DOCKER_FIXUP ##" ~/.bashrc \
   && ! grep -Fxq "## END_DOCKER_FIXUP ##" ~/.bashrc ; then
        cat <<EOF >> ~/.bashrc
## BEGIN_DOCKER_FIXUP ##
export DOCKER_CERT_PATH="${WSL_USERPROFILE}/.docker/machine/certs"
export DOCKER_DAEMON_CONFIG_PATH="${WSL_USERPROFILE}/.docker/daemon.json"
export DOCKER_TLS_VERIFY=1
export DOCKER_HOST='tcp://0.0.0.0:2375'
## END_DOCKER_FIXUP ##
EOF
fi
. $HOME/.bashrc

echo "This portion of the script needs root.  If you recieve a password prompt, you must answer it for user: $USER"
[ ! $(getent group docker) ] && sudo groupadd docker
if ! id --name --groups --zero ${USER} | grep --quiet --line-regexp --fixed-strings "docker"; then
	sudo usermod -aG docker ${USER}
	exec su -l $USER
fi
[ ! -d $HOME/.docker ] && mkdir $HOME/.docker
sudo chown ${USER}:docker $HOME/.docker -R
sudo chmod g+rwx $HOME/.docker -R
echo "Root portion completed."

python - "${DOCKER_DAEMON_CONFIG_PATH}" <<'__SCRIPT__'
import os, sys, json
j = ""
with open(sys.argv[1], 'r') as file:
	data = file.read().replace('\n', '')
	jsondata = json.loads(data)

print(jsondata)
__SCRIPT__

