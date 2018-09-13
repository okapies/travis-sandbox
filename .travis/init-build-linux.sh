# check if variables have values
test -n "${DOCKER_CONTAINER_ID}" || { echo "DOCKER_CONTAINER_ID does not exist"; exit 1; }
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
([ -e "v${MKLDNN_VERSION}.tar.gz" ] || wget https://github.com/intel/mkl-dnn/archive/v${MKLDNN_VERSION}.tar.gz) && \
tar -zxf v${MKLDNN_VERSION}.tar.gz -C ${TRAVIS_BUILD_DIR}/build
EOS
)"
    docker_exec "cd ${TRAVIS_BUILD_DIR}/build/mkl-dnn-${MKLDNN_VERSION}/scripts && ./prepare_mkl.sh"
    docker_exec "$(cat << EOS
yum -y install cmake && \
cd ${TRAVIS_BUILD_DIR}/build/mkl-dnn-${MKLDNN_VERSION} && \
([ -d "build" ] || mkdir -p build) && cd build && \
cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=${MKLDNN_INSTALL_DIR} \
  -DWITH_TEST=OFF \
  -DWITH_EXAMPLE=OFF \
  -DARCH_OPT_FLAGS='' \
  -Wno-error=unused-result \
  ..
EOS
)"
    docker_exec "cd ${TRAVIS_BUILD_DIR}/build/mkl-dnn-${MKLDNN_VERSION}/build && make ${MAKE_JOBS} && make install/strip"
}

function build_menoh() {
    docker_exec "$(cat << EOS
cd ${TRAVIS_BUILD_DIR} && \
git clone https://github.com/pfnet-research/menoh.git && \
cd menoh && \
mkdir -p build && \
cd build && \
cmake -DLINK_STATIC_LIBPROTOBUF=ON -DLINK_STATIC_LIBSTDCXX=ON -DLINK_STATIC_LIBGCC=ON -DENABLE_TEST=ON .. && \
make && \
./test/menoh_test
EOS
)"
}
