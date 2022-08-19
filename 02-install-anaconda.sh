#!/bin/bash

source ./xx-vars.sh

[ -z "~/${ANACONDA_FILENAME}" ] && wget "${ANACONDA_URL}"
if [[ -z "/home/saber7ooth/anaconda" ]]; then
	bash ${ANACONDA_FILENAME} -b -p ~/anaconda
	if ! grep -Fxq 'export PATH="~/anaconda/bin:$PATH"' ~/.bashrc; then
		echo 'export PATH="~/anaconda/bin:$PATH"' >> ~/.bashrc
		source ~/.bashrc
	fi
fi
[ ! -z "~/${ANACONDA_FILENAME}.sh" ] && rm -f "~/${ANACONDA_FILENAME}.sh"

conda update conda -y
