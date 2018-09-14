# travis-sandbox
[![Build Status](https://travis-ci.org/okapies/travis-sandbox.svg?branch=master)](https://travis-ci.org/okapies/travis-sandbox)

## Architecture
`.travis.yml` -> `run-build.sh` -> `build.sh` -> `install-*.sh` & `build-menoh.sh`

1. `run-build.sh` starts a Docker container for building the project
2. `build.sh` runs a build workflow in the container
    - (All commands are run by `docker_exec` and `docker_exec_cmd` functions)
    - Install the prerequisites
    - Run a build
    - Run a test
3. Release and clean up

## Directory
- `/home/travis` (= `${HOME}`)
    - `/downloads` (cache)
    - `/build`
        - `/protobuf-<ver>` (cache)
        - `/mkl-dnn-<ver>` (cache)
        - `/<user>/<repo>` (= `${TRAVIS_BUILD_DIR}`)
            - `/menoh`
            - `/test`
            - `/cmake`
            - `CMakeLists.txt`
            - ...
            - `/build`
                - `/menoh`
                - `/test`
                - ...

```yaml
cache:
  directories:
    - ${HOME}/downloads
    - ${HOME}/build/protobuf-${PROTOBUF_VERSION}
    - ${HOME}/build/mkl-dnn-${MKLDNN_VERSION}
```
