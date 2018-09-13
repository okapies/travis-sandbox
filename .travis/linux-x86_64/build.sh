#!/bin/bash -ex

BASE_DIR=$(cd $(dirname $0) && pwd)

PROTOBUF_INSTALL_DIR=${HOME}/protobuf-${PROTOBUF_VERSION}
MKLDNN_INSTALL_DIR=/usr/local

source ${BASE_DIR}/../init-build-linux.sh

docker_exec "ls -l ${HOME}"
docker_exec "ls -l ${HOME}/build"
docker_exec "ls -l ${HOME}/build/${TRAVIS_REPO_SLUG}"

docker_exec "(printenv | grep PATH) && make --version && cmake --version && g++ --version && ldd --version"

# build dependencies if it doesn't exist
[ ! -e "${MKLDNN_INSTALL_DIR}/lib/libmkldnn.so" ] && build_mkldnn

build_menoh

ldd ${TRAVIS_BUILD_DIR}/menoh/build/menoh/libmenoh.so
