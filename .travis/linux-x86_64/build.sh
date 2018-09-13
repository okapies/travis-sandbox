#!/bin/bash -ex

BASE_DIR=$(cd $(dirname $0) && pwd)

PROTOBUF_INSTALL_DIR=/usr/local
MKLDNN_INSTALL_DIR=/usr/local

source ${BASE_DIR}/../init-build-linux.sh

docker_exec "ls -l ${HOME}"
docker_exec "ls -l ${HOME}/build"
docker_exec "ls -l ${HOME}/build/${TRAVIS_REPO_SLUG}"

docker_exec "(printenv | grep PATH) && make --version && cmake --version && g++ --version && ldd --version"

# build and install dependencies
prepare_downloads_dir
build_and_install_protobuf
build_and_install_mkldnn

# build and test menoh
prepare_menoh_data
build_menoh

ldd ${TRAVIS_BUILD_DIR}/menoh/build/menoh/libmenoh.so
