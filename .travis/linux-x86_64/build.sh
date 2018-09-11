#!/bin/bash -ex

BASE_DIR=$(cd $(dirname $0) && pwd)

GCC_ROOT_DIR=/usr/local/gcc-${GCC_VERSION}
PROTOBUF_INSTALL_DIR=${HOME}/protobuf-${PROTOBUF_VERSION}
MKLDNN_INSTALL_DIR=/usr/local

source ${BASE_DIR}/../init-build-linux.sh

docker_exec "ls -l ${HOME}"
docker_exec "ls -l ${HOME}/build"
docker_exec "ls -l ${HOME}/build/${TRAVIS_REPO_SLUG}"

docker_exec "make --version && cmake --version && ${GCC_ROOT_DIR}/bin/g++ --version && ldd --version"

# build dependencies if it doesn't exist
[ ! -e "${MKLDNN_INSTALL_DIR}/lib/libmkldnn.so" ] && build_mkldnn

docker_exec "$(cat << EOS
yum -y install opencv-devel && \
git clone https://github.com/pfnet-research/menoh.git && \
cd menoh && \
git checkout feature/protobuf-config-options && \
mkdir -p build && \
cd build && \
cmake -DARCH_OPT_FLAGS="" -DCMAKE_C_COMPILER=${GCC_ROOT_DIR}/bin/gcc -DCMAKE_CXX_COMPILER=${GCC_ROOT_DIR}/bin/g++ -DENABLE_TEST=ON -DLINK_STATIC_LIBPROTOBUF=ON -DLINK_STATIC_LIBSTDCXX=ON -DLINK_STATIC_LIBGCC=ON .. && \
make && \
./test/menoh_test
EOS
)"

ls -l ${TRAVIS_BUILD_DIR}/build/mkl-dnn-${MKLDNN_VERSION}/build
