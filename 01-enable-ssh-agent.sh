#!/bin/bash

. ./xx-vars.sh
. ./xx-github-credentials.sh

if ! grep -Fxq "## BEGIN_ENABLE_SSH_AGENT ##" ~/.bashrc \
  && ! grep -Fxq "## END_ENABLE_SSH_AGENT ##" ~/.bashrc; then
	cat <<'EOF' >> ~/.bashrc 

## BEGIN_ENABLE_SSH_AGENT ##
SSH_ENV=~/.ssh/agent.env
agent_load_env () { test -f "$SSH_ENV" && . "$SSH_ENV" >| /dev/null ; }

agent_start () {
    (umask 077; ssh-agent >| "$SSH_ENV")
    . "$SSH_ENV" >| /dev/null ; }

agent_load_env

agent_run_state=$(ssh-add -l >| /dev/null 2>&1; echo $?)

if [ ! "$SSH_AUTH_SOCK" ] || [ $agent_run_state = 2 ]; then
    agent_start
    ssh-add
elif [ "$SSH_AUTH_SOCK" ] && [ $agent_run_state = 1 ]; then
    ssh-add
fi

unset SSH_ENV
## END_ENABLE_SSH_AGENT ##
EOF
fi

__authorized_keys_clear() {
        sed -i -z "s/^$(echo $(cat ${GITHUB_KEYFILE}.pub) | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')\n//g" $HOME/.ssh/authorized_keys
}

__authorized_keys_write() {
	echo $(cat ${GITHUB_KEYFILE}.pub) | sudo -u $USER tee -a $HOME/.ssh/authorized_keys > /dev/null
}

if [ ! -z "${GITHUB_KEYFILE}" ] || [ ! -z "${GITHUB_KEYFILE}.pub" ]; then
	[ ! -z "${GITHUB_KEYFILE}" ] && rm -f "${GITHUB_KEYFILE}"
	if [ ! -z "${GITHUB_KEYFILE}.pub" ]; then
		__authorized_keys_clear
		rm -f "${GITHUB_KEYFILE}.pub"
	fi
	ssh-keygen -q -t ed25519 -C "${GITHUB_EMAIL}" -f "${GITHUB_KEYFILE}" -N ''
	ssh-add "${GITHUB_KEYFILE}"
	SSH_PUB_ID=$(cat "${GITHUB_KEYFILE}".pub)
	# in the unlikely, god-tier event that we somehow generate a new public key as the last (please buy a goddamn lottery ticket)
	__authorized_keys_clear
	__authorized_keys_write
fi

source ~/.bashrc
