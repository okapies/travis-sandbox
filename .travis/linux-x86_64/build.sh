#!/bin/bash -ex

BASE_DIR=$(cd $(dirname $0) && pwd)

# initialize this script
source ${BASE_DIR}/../init-build-linux.sh

# check the environment
docker_exec "ls -l ${WORK_DIR}"
docker_exec "ls -l ${WORK_DIR}/build"
docker_exec "ls -l ${WORK_DIR}/build/${TRAVIS_REPO_SLUG}"

docker_exec "(printenv | grep PATH) && make --version && cmake --version && g++ --version && ldd --version"

# build and install dependencies
docker_exec_cmd \
    ${PROJ_DIR}/.travis/install-protobuf.sh \
	    --version ${PROTOBUF_VERSION} \
	    --download-dir ${WORK_DIR}/downloads \
	    --build-dir ${WORK_DIR}/build \
	    --install-dir ${PROTOBUF_INSTALL_DIR} \
	    --parallel ${MAKE_JOBS}
docker_exec_cmd \
    ${PROJ_DIR}/.travis/install-mkldnn.sh \
	    --version ${MKLDNN_VERSION} \
	    --download-dir ${WORK_DIR}/downloads \
	    --build-dir ${WORK_DIR}/build \
	    --install-dir ${MKLDNN_INSTALL_DIR} \
	    --parallel ${MAKE_JOBS}

# build and test menoh
prepare_menoh_data
build_menoh

# check the outputs
ldd ${PROJ_DIR}/menoh/build/menoh/libmenoh.so
