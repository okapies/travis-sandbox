#!/bin/bash

# check if variables have values
test -n "${PLATFORM_ID}" || { echo "PLATFORM_ID does not exist"; exit 1; }
test -n "${BUILDENV_IMAGE}" || { echo "BUILDENV_IMAGE does not exist"; exit 1; }

export PLATFORM_DIR=${TRAVIS_BUILD_DIR}/.travis/${PLATFORM_ID}

docker pull ${BUILDENV_IMAGE} || true

# Run a docker container and map Travis's $HOME to the container's $HOME
# $HOME:$HOME = /home/travis                     : /home/travis
#               /home/travis/build               : /home/travis/build
#               /home/travis/build/<user>/<repo> : /home/travis/build/<user>/<repo>
export DOCKER_CONTAINER_ID=$(docker run --privileged -d -v $HOME:$HOME -v /sys/fs/cgroup:/sys/fs/cgroup:ro ${BUILDENV_IMAGE} /sbin/init)

# Stop the container when exits
trap '[[ "$DOCKER_CONTAINER_ID" ]] && docker stop ${DOCKER_CONTAINER_ID} && docker rm -v ${DOCKER_CONTAINER_ID}' 0 1 2 3 15

echo "travis_fold:start:Run build.sh for ${PLATFORM_ID}"

if [ -e "${PLATFORM_DIR}/build.sh" ]; then
    echo -e "\e[33;1mRunning .travis/${PLATFORM_ID}/build.sh on ${TRAVIS_REPO_SLUG}\e[0m"
    /bin/bash -ex ${PLATFORM_DIR}/build.sh
else
    echo 'The specified platform not found: '${PLATFORM_ID} 1>&2
    exit 1
fi

echo "travis_fold:end:Run build.sh for ${PLATFORM_ID}"
