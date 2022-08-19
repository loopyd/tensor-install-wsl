#!/bin/bash

source ./xx-vars.sh

[ ! -z "$HOME/.cache" ] && chown -R ${ENV_USER_ID}:${ENV_GROUP_ID} ~/.cache
if [ ! -z "$HOME/.cache/bazelisk" ]; then
	chown -R ${ENV_USER_ID}:${ENV_GROUP_ID} ~/.cache/bazelisk
	rm -rf ~/.cache/bazelisk
fi
mkdir -p $HOME/.cache/bazelisk

[ -z "${HOME}/tensorflow" ] && mkdir -p $HOME/tensorflow
git clone "https://github.com/tensorflow/tensorflow.git" $HOME/tensorflow
pushd $HOME/tensorflow
git checkout master
# this part of the script is interactive until I figure out what files are written to
# by ./configure, my wsl instance freezes for some reason because I don't call ./configure
./configure
popd

docker pull tensorflow/tensorflow:devel-gpu
docker run --gpus all -i -w /tensorflow -v "${HOME}/tensorflow:/tensorflow" -v "${HOME}/.cache:/.cache" -v "$PWD:/mnt" -e HOST_PERMS="$(id -u):$(id -g)" -e USER="$(id -u)" -u $(id -u):$(id -g) tensorflow/tensorflow:devel-gpu /bin/bash -s <<EOF
bazel build --config=opt //tensorflow/tools/pip_package:build_pip_package
./bazel-bin/tensorflow/tools/pip_package/build_pip_package /mnt
chown $HOST_PERMS /mnt/tensorflow-*-tags.whl
pip uninstall tensorflow
pip install /mnt/tensorflow-*-tags.whl
cd /tmp
python -c "import tensorflow as tf; print(\"Num GPUs Available: \", len(tf.config.list_physical_devices('GPU')))"
EOF
