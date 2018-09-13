# check if variables have values
test -n "${DOCKER_CONTAINER_ID}" || { echo "DOCKER_CONTAINER_ID does not exist"; exit 1; }
test -n "${PROTOBUF_VERSION}" || { echo "PROTOBUF_VERSION does not exist"; exit 1; }
test -n "${PROTOBUF_INSTALL_DIR}" || { echo "PROTOBUF_INSTALL_DIR does not exist"; exit 1; }
test -n "${MKLDNN_VERSION}" || { echo "MKLDNN_VERSION does not exist"; exit 1; }
test -n "${MKLDNN_INSTALL_DIR}" || { echo "MKLDNN_INSTALL_DIR does not exist"; exit 1; }

export DOWNLOAD_DIR=${HOME}/downloads

# define shared functions for Linux-based platforms
function docker_exec() {
    docker exec -it ${DOCKER_CONTAINER_ID} /bin/bash -xec "$1"
}

function prepare_downloads_dir() {
    docker_exec "[ -d \"${DOWNLOAD_DIR}\" ] || mkdir -p ${DOWNLOAD_DIR}"
}

function build_and_install_protobuf() {
    local download_url="https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOBUF_VERSION}/protobuf-cpp-${PROTOBUF_VERSION}.tar.gz"
    # download (if it isn't cached)
    docker_exec "$(cat << EOS
        if [ ! -e "${HOME}/build/protobuf-${PROTOBUF_VERSION}/LICENSE" ]; then
            cd ${DOWNLOAD_DIR} && \
            ([ -e "protobuf-cpp-${PROTOBUF_VERSION}.tar.gz" ] || wget ${download_url}) && \
            tar -zxf protobuf-cpp-${PROTOBUF_VERSION}.tar.gz -C ${HOME}/build
        fi
EOS
)"
    # build (if it isn't cached)
    docker_exec "$(cat << EOS
        if [ ! -e "${HOME}/build/protobuf-${PROTOBUF_VERSION}/src/libprotobuf.so" ]; then
            cd ${HOME}/build/protobuf-${PROTOBUF_VERSION} && \
            ./configure --prefix=${PROTOBUF_INSTALL_DIR} CFLAGS=-fPIC CXXFLAGS=-fPIC && \
            make ${MAKE_JOBS}
        else
            echo 'libprotobuf is already built.'
        fi
EOS
)"
    # install (always)
    docker_exec "echo -e \"\e[33;1mInstalling libprotobuf\e[0m\" && cd ${HOME}/build/protobuf-${PROTOBUF_VERSION} && make install"
}

function build_and_install_mkldnn() {
    local download_url="https://github.com/intel/mkl-dnn/archive/v${MKLDNN_VERSION}.tar.gz"
    # download (if it isn't cached)
    docker_exec "$(cat << EOS
        if [ ! -e "${HOME}/build/mkl-dnn-${MKLDNN_VERSION}/LICENSE" ]; then
            cd ${DOWNLOAD_DIR} && \
            ([ -e "mkl-dnn-${MKLDNN_VERSION}.tar.gz" ] || wget -O mkl-dnn-${MKLDNN_VERSION}.tar.gz ${download_url}) && \
            tar -zxf mkl-dnn-${MKLDNN_VERSION}.tar.gz -C ${HOME}/build
        fi
EOS
)"
    # build (if it isn't cached)
    docker_exec "$(cat << EOS
        if [ ! -e "${HOME}/build/mkl-dnn-${MKLDNN_VERSION}/build/src/libmkldnn.so" ]; then
            cd ${HOME}/build/mkl-dnn-${MKLDNN_VERSION}/scripts && \
            ./prepare_mkl.sh && \
            cd ${HOME}/build/mkl-dnn-${MKLDNN_VERSION} && \
            ([ -d "build" ] || mkdir -p build) && cd build && \
            cmake \
                -DCMAKE_BUILD_TYPE=Release \
                -DCMAKE_INSTALL_PREFIX=${MKLDNN_INSTALL_DIR} \
                -DWITH_TEST=OFF \
                -DWITH_EXAMPLE=OFF \
                -DARCH_OPT_FLAGS='' \
                -Wno-error=unused-result \
                .. && \
            make ${MAKE_JOBS}
        else
            echo 'libmkldnn is already built.'
        fi
EOS
)"
    # install (always)
    docker_exec "echo -e \"\e[33;1mInstalling libmkldnn\e[0m\" && cd ${HOME}/build/mkl-dnn-${MKLDNN_VERSION}/build && make install/strip"
}

function prepare_menoh_data() {
    docker_exec "pip3 install --user chainer"
    docker_exec "$(cat << EOS
        cd ${TRAVIS_BUILD_DIR} && \
        git clone https://github.com/pfnet-research/menoh.git && \
        cd menoh && \
        mkdir -p data && \
        python3 retrieve_data.py && \
        python3 gen_test_data.py
EOS
)"
}

function build_menoh() {
    docker_exec "$(cat << EOS
        cd ${TRAVIS_BUILD_DIR} && \
        cd menoh && \
        mkdir -p build && \
        cd build && \
        cmake -DENABLE_TEST=ON .. && \
        make && \
        ./test/menoh_test
EOS
)"
}
function build_menoh_static() {
    docker_exec "$(cat << EOS
        cd ${TRAVIS_BUILD_DIR} && \
        cd menoh && \
        mkdir -p build && \
        cd build && \
        cmake -DLINK_STATIC_LIBPROTOBUF=ON -DLINK_STATIC_LIBSTDCXX=ON -DLINK_STATIC_LIBGCC=ON -DENABLE_TEST=ON .. && \
        make && \
        ./test/menoh_test
EOS
)"
}
