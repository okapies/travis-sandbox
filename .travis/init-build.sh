# check if variables have values
test -n "${DOCKER_CONTAINER_ID}" || { echo "DOCKER_CONTAINER_ID does not exist"; exit 1; }
test -n "${GCC_ROOT_DIR}" || { echo "GCC_ROOT_DIR does not exist"; exit 1; }
test -n "${MKLDNN_VERSION}" || { echo "MKLDNN_VERSION does not exist"; exit 1; }
test -n "${MKLDNN_INSTALL_DIR}" || { echo "MKLDNN_INSTALL_DIR does not exist"; exit 1; }

function docker_exec() {
    docker exec -it ${DOCKER_CONTAINER_ID} /bin/bash -xec "$1"
}

function build_mkldnn() {
    docker_exec "$(cat << EOS
cd ${TRAVIS_BUILD_DIR} && \
([ -d "build" ] || mkdir -p build) && \
cd ${TRAVIS_BUILD_DIR}/build && \
([ -d "downloads" ] || mkdir -p downloads) && \
cd ${TRAVIS_BUILD_DIR}/build/downloads && \
wget https://github.com/intel/mkl-dnn/archive/v${MKLDNN_VERSION}.tar.gz && \
tar -zxf v${MKLDNN_VERSION}.tar.gz -C ${TRAVIS_BUILD_DIR}/build
EOS
)"
    docker_exec "cd ${TRAVIS_BUILD_DIR}/build/mkl-dnn-${MKLDNN_VERSION}/scripts && ./prepare_mkl.sh"
    docker_exec "$(cat << EOS
cd ${TRAVIS_BUILD_DIR}/build/mkl-dnn-${MKLDNN_VERSION} && \
([ -d "build" ] || mkdir -p build) && cd build && \
cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER=${GCC_ROOT_DIR}/bin/gcc \
  -DCMAKE_CXX_COMPILER=${GCC_ROOT_DIR}/bin/g++ \
  -DCMAKE_INSTALL_PREFIX=${MKLDNN_INSTALL_DIR} \
  -DWITH_TEST=OFF \
  -DWITH_EXAMPLE=OFF \
  -Wno-error=unused-result \
  ..
EOS
)"
    docker_exec "cd ${TRAVIS_BUILD_DIR}/build/mkl-dnn-${MKLDNN_VERSION}/build && timeout 35m make -j$(nproc) && make install/strip"
}
