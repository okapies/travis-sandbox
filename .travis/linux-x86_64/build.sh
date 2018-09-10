#!/bin/bash -ex

BASE_DIR=$(cd $(dirname $0) && pwd)

GCC_ROOT_DIR=/usr/local/gcc-${GCC_VERSION}
PROTOBUF_INSTALL_DIR=${HOME}/protobuf-${PROTOBUF_VERSION}
MKLDNN_INSTALL_DIR=${HOME}/mkl-dnn-${MKLDNN_VERSION}

source ${BASE_DIR}/../init-build.sh

docker_exec "ls -l ${HOME}"
docker_exec "ls -l ${HOME}/build"
docker_exec "ls -l ${HOME}/build/${TRAVIS_REPO_SLUG}"

docker_exec "echo hello > ${HOME}/build/result.txt"

docker_exec "make --version && cmake --version && ${GCC_ROOT_DIR}/bin/g++ --version && ldd --version"

# build dependencies if it doesn't exist
[ ! -e "${MKLDNN_INSTALL_DIR}/lib/libmkldnn.so" ] && build_mkldnn

ls -l ${HOME}/build/mkl-dnn-${MKLDNN_VERSION}/build
ls -l ${HOME}/mkl-dnn-${MKLDNN_VERSION}

docker_exec "false"
