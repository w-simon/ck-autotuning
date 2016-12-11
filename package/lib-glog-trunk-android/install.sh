#! /bin/bash

#
# Installation script for clBLAS.
#
# See CK LICENSE for licensing details.
# See CK COPYRIGHT for copyright details.
#
# Developer(s):
# - Grigori Fursin, 2015;
# - Anton Lokhmotov, 2016.
#

# PACKAGE_DIR
# INSTALL_DIR

cd ${INSTALL_DIR}

############################################################
echo ""
echo "Cloning package from '${PACKAGE_URL}' ..."

rm -rf src

git clone ${PACKAGE_URL} src

if [ "${?}" != "0" ] ; then
  echo "Error: cloning package failed!"
  exit 1
fi

############################################################
echo ""
echo "Patching package for Android ..."

cd src

patch -p1 < ${PACKAGE_DIR}/misc/android.patch

if [ "${?}" != "0" ] ; then
  echo "Error: patching package failed!"
  exit 1
fi

cp -rf ${PACKAGE_DIR}/misc/Findgflags.cmake cmake

############################################################
echo ""
echo "Cleaning ..."

cd ${INSTALL_DIR}

rm -rf obj

mkdir obj
cd obj

############################################################
echo ""
echo "Executing cmake ..."

CK_TOOLCHAIN=android.toolchain.cmake
if [ "${CK_ENV_LIB_CRYSTAX_LIB}" != "" ] ; then
  CK_TOOLCHAIN=toolchain.cmake
fi

cmake -DCMAKE_TOOLCHAIN_FILE="${PACKAGE_DIR}/misc/${CK_TOOLCHAIN}" \
      -DGFLAGS_LIBRARY="${CK_ENV_LIB_GFLAGS_LIB}" \
      -DGFLAGS_INCLUDE_DIR="${CK_ENV_LIB_GFLAGS_INCLUDE}" \
      -DANDROID_SO_UNDEFINED:BOOL=ON \
      -DANDROID_NDK="${CK_ANDROID_NDK_ROOT_DIR}" \
      -DCMAKE_BUILD_TYPE=Release \
      -DANDROID_ABI="${CK_ANDROID_ABI}" \
      -DANDROID_NATIVE_API_LEVEL=${CK_ANDROID_API_LEVEL} \
      -DANDROID_STL=gnustl_static \
      -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}/install" \
      ../src

if [ "${?}" != "0" ] ; then
  echo "Error: cmake failed!"
  exit 1
fi

############################################################
echo ""
echo "Building package ..."

rm -rf install

#make VERBOSE=1 -j ${CK_HOST_CPU_NUMBER_OF_PROCESSORS}
make -j ${CK_HOST_CPU_NUMBER_OF_PROCESSORS}
if [ "${?}" != "0" ] ; then
  echo "Error: build failed!"
  exit 1
fi

############################################################
echo ""
echo "Installing package ..."

make install/strip
if [ "${?}" != "0" ] ; then
  echo "Error: installation failed!"
  exit 1
fi

exit 0