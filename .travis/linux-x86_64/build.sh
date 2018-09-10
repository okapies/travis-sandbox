#!/bin/bash -ex

BASE_DIR=$(cd $(dirname $0) && pwd)
source ${BASE_DIR}/../init-build.sh

docker_exec "ls -l ${HOME}"
docker_exec "ls -l ${HOME}/build"
docker_exec "ls -l ${HOME}/build/${TRAVIS_REPO_SLUG}"

docker_exec "echo hello > ${HOME}/build/result.txt"
