DOCKER_CONTAINER_ID=$1

function docker_exec() {
	local cmd=$1
    docker exec -it ${DOCKER_CONTAINER_ID} /bin/bash -xec "$cmd"
}
