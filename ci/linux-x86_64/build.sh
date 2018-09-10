#!/bin/bash -ex

DOCKER_CONTAINER_ID=$1

docker logs ${DOCKER_CONTAINER_ID}

docker exec -it ${DOCKER_CONTAINER_ID} /bin/bash -c "echo hello"
docker exec -it ${DOCKER_CONTAINER_ID} /bin/bash -c "ls -l ${HOME}"
docker exec -it ${DOCKER_CONTAINER_ID} /bin/bash -c "ls -l ${HOME}/build"
docker exec -it ${DOCKER_CONTAINER_ID} /bin/bash -c "echo hello > ${HOME}/foo.txt"
