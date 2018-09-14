# check if variables have values
test -n "${DOCKER_CONTAINER_ID}" || { echo "DOCKER_CONTAINER_ID does not exist"; exit 1; }

# TODO: make them configurable for outside Travis
export WORK_DIR=${HOME}
export PROJ_DIR=${TRAVIS_BUILD_DIR} # = ${HOME}/build/${TRAVIS_REPO_SLUG}

export PROTOBUF_INSTALL_DIR=/usr/local
export MKLDNN_INSTALL_DIR=/usr/local

# define shared functions for Linux-based platforms
function docker_exec() {
    docker exec -it ${DOCKER_CONTAINER_ID} /bin/bash -xec "$1"
}

function docker_exec_cmd() {
    docker exec -it ${DOCKER_CONTAINER_ID} /bin/bash -xe $@
}

function prepare_menoh_data() {
    echo -e "\e[33;1mInstalling chainer\e[0m"
    docker_exec "pip3 install --user chainer"
    echo -e "\e[33;1mPreparing data/ for Menoh\e[0m"
    docker_exec "$(cat << EOS
        cd ${PROJ_DIR} && \
        git clone https://github.com/pfnet-research/menoh.git && \
        cd menoh && \
        mkdir -p data && \
        python3 retrieve_data.py && \
        python3 gen_test_data.py
EOS
)"
}

function build_menoh() {
    echo -e "\e[33;1mBuilding Menoh\e[0m"
    docker_exec "$(cat << EOS
        cd ${PROJ_DIR} && \
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
    echo -e "\e[33;1mBuilding Menoh\e[0m"
    docker_exec "$(cat << EOS
        cd ${PROJ_DIR} && \
        cd menoh && \
        mkdir -p build && \
        cd build && \
        cmake -DLINK_STATIC_LIBGCC=ON -DLINK_STATIC_LIBSTDCXX=ON -DLINK_STATIC_LIBPROTOBUF=ON -DENABLE_TEST=ON .. && \
        make && \
        ./test/menoh_test
EOS
)"
}
