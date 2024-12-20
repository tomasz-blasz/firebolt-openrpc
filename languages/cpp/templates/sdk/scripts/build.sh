#!/bin/bash
set -e
usage()
{
   echo "options:"
   echo "    -p sdk path"
   echo "    -s sysroot path"
   echo "    -c clear build"
   echo "    -l enable static build"
   echo "    -t enable test"
   echo "    -b enable bidirectional gateway"
   echo "    -h : help"
   echo
   echo "usage: "
   echo "    ./build.sh -p path -tc"
}

SdkPath="."
EnableTest="OFF"
SysrootPath=${SYSROOT_PATH}
ClearBuild="N"
EnableStaticLib="OFF"
EnableBidirectional="OFF"
while getopts p:s:cltbh flag
do
    case "${flag}" in
        p) SdkPath="${OPTARG}";;
        s) SysrootPath="${OPTARG}";;
        c) ClearBuild="Y";;
        l) EnableStaticLib="ON";;
        t) EnableTest="ON";;
        b) EnableBidirectional="ON";;
        h) usage && exit 1;;
    esac
done

if [ "${ClearBuild}" == "Y" ];
then
    rm -rf ${SdkPath}/build
fi

rm -rf ${SdkPath}/build/src/libFireboltSDK.so
cmake -B${SdkPath}/build -S${SdkPath} -DSYSROOT_PATH=${SysrootPath} -DENABLE_TESTS=${EnableTest} -DHIDE_NON_EXTERNAL_SYMBOLS=OFF -DFIREBOLT_ENABLE_STATIC_LIB=${EnableStaticLib} -DENABLE_BIDIRECTIONAL=${EnableBidirectional} || exit 1
cmake --build ${SdkPath}/build || exit 1
if [ -f "${SdkPath}/build/src/libFireboltSDK.so" ];
then
    cmake --install ${SdkPath}/build --prefix ${SdkPath}/build/Firebolt/usr || exit 1
fi
