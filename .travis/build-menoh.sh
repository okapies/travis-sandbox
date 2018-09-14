#!/bin/bash

# retrieve arguments
while [[ $# != 0 ]]; do
    case $1 in
        --)
            shift
            break
            ;;
        --source-dir)
            ARG_SOURCE_DIR="$2"
            shift 2
            ;;
        --install-dir)
            ARG_INSTALL_DIR="$2"
            shift 2
            ;;
        --link-static)
            ARG_LINK_STATIC="$2"
            shift 2
            ;;
        -*)
            err Unknown option \"$1\"
            exit
            ;;
        *)
            break
            ;;

    esac
done

# validate the arguments
test -n "${ARG_SOURCE_DIR}" || { echo "--source-dir is not specified"; exit 1; }
test -n "${ARG_LINK_STATIC}" || ARG_LINK_STATIC='false'

echo -e "\e[33;1mBuilding Menoh\e[0m"

cd ${ARG_SOURCE_DIR}/menoh
[ -d "build" ] || mkdir -p build

cd build
if [ -n "${ARG_INSTALL_DIR}" ]; then
    CMAKE_INSTALL_PREFIX="-DCMAKE_INSTALL_PREFIX=${ARG_INSTALL_DIR}"
fi
if [ "${ARG_LINK_STATIC}" != "true" ]; then
    cmake \
        -DCMAKE_BUILD_TYPE=Release \
        ${CMAKE_INSTALL_PREFIX} \
        -DENABLE_TEST=ON ..
else
    cmake \
        -DCMAKE_BUILD_TYPE=Release \
        ${CMAKE_INSTALL_PREFIX} \
        -DLINK_STATIC_LIBGCC=ON \
        -DLINK_STATIC_LIBSTDCXX=ON \
        -DLINK_STATIC_LIBPROTOBUF=ON \
        -DENABLE_TEST=ON \
        ..
fi

make
