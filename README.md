# travis-sandbox
[![Build Status](https://travis-ci.org/okapies/travis-sandbox.svg?branch=master)](https://travis-ci.org/okapies/travis-sandbox)

## Directory
```bash
$ cd ${TRAVIS_BUILD_DIR}
$ mkdir -p build
$ cd build
$ cmake ..
```

- `/home/travis` (= `${HOME}`)
    - `/build`
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
                - `/downloads` (cache)
                - `/protobuf-<ver>` (cache)
                - `/mkl-dnn-<ver>` (cache)

```yaml
cache:
  directories:
    - ${TRAVIS_BUILD_DIR}/build/downloads
    - ${TRAVIS_BUILD_DIR}/build/protobuf-${PROTOBUF_VERSION}
    - ${TRAVIS_BUILD_DIR}/build/mkl-dnn-${MKLDNN_VERSION}
```
