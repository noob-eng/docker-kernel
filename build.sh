#!/bin/bash

# Clone Repo
echo
echo "Cloning Android Kernel Tools repo"
echo
#git clone --depth=1 https://github.com/kdrag0n/proton-clang.git clang
git clone --depth=1 https://github.com/TheStrechh/silont-clang clang

echo
echo "AnyKernel3 Repo"
echo
git clone --depth=1 https://github.com/osm0sis/AnyKernel3.git

echo
echo "Cloning Kernel Repo"
echo
#git clone --depth=1 --branch lineage-20 https://github.com/LineageOS/android_kernel_xiaomi_surya.git kernel
git clone --depth=1 --branch silont https://github.com/TheStrechh/android_kernel_xiaomi_surya kernel

echo
echo "Setting up env"
echo

sudo apt-get install device-tree-compiler bc cpio ccache zip

mkdir -p out
export ZIPNAME=Surya-Kernel.zip
export ARCH=arm64
export SUBARCH=arm64
export CLANG_PATH=/home/runner/work/docker-kernel/docker-kernel/clang/bin
PATH=/usr/lib/ccache:${PATH}
export PATH=${CLANG_PATH}:${PATH}
export CLANG_TRIPLE=aarch64-linux-gnu-
export CROSS_COMPILE=$CLANG_PATH/aarch64-linux-gnu-
export CROSS_COMPILE_ARM32=$CLANG_PATH/arm-linux-gnueabi-

echo
echo "Moving to kernel dir"
echo

#cp surya-docker_defconfig kernel/arch/arm64/configs/
cp silont_defconfig kernel/arch/arm64/configs/
cd kernel
echo $PWD

echo
echo "Clean Build Directory"
echo 

make clean && make mrproper

echo
echo "Issue Build Commands"
echo

mkdir -p out

echo
echo "Set DEFCONFIG"
echo 
#make CC=clang O=out surya-docker_defconfig
make CC=clang O=out silont_defconfig

echo
echo "Build The Good Stuff"
echo 

#make -j8 O=out CC="ccache clang" AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip Image.gz-dtb
make -j$(nproc --all) CC=clang CROSS_COMPILE=aarch64-linux-gnu- O=out ARCH=arm64 LLVM=1 Image.gz-dtb


cd ..

ls kernel/out/arch/arm64/boot/

zip -r surya.zip kernel/out/arch/arm64/boot/*
curl --upload-file ./surya.zip https://transfer.sh/surya.zip

cp kernel/out/arch/arm64/boot/Image.gz-dtb ./AnyKernel3

cp anykernel.patch ./AnyKernel3

cd AnyKernel3

git apply anykernel.patch
rm anykernel.patch

zip "../$ZIPNAME" * -x '*.git*' README.md *placeholder
