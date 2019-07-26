#!/bin/bash
###################自行修改区####################
API=21
# arm aarch64 i686 x86_64  进行修改
ARCH=aarch64 
# armv7a aarch64 i686 x86_64  进行修改
PLATFORM=aarch64
# armv8-a armv7a x86 x86_64
CPU=armv8-a
NDK=/usr/lib/ndk/android-ndk-r20 #NDK目录，自行修改
################################################
export TMPDIR=`dirname $0`/tmp
export SRC_DIR=`pwd`
TARGET=$PLATFORM-linux-android  #请查看目录下对应文件名，这里是64位文件名
TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/linux-x86_64/bin # 这里找到对应得文件
# SYSROOT=$NDK/platforms/android-21/arch-arm64
SYSROOT=$NDK/toolchains/llvm/prebuilt/linux-x86_64/sysroot
PREFIX=`dirname $0`/android/$PLATFORM
  
CFLAG="-D__ANDROID_API__=$API -U_FILE_OFFSET_BITS -DBIONIC_IOCTL_NO_SIGNEDNESS_OVERLOAD -Os -fPIC -DANDROID -D__thumb__ -mthumb -Wfatal-errors -Wno-deprecated -mfloat-abi=softfp -marm"
  
mkdir -p $TMPDIR
./configure --enable-cross-compile \
--cross-prefix=$TOOLCHAIN/$ARCH-linux-android- \
--ln_s="cp -rf" \
--prefix=$PREFIX \
--cc=$TOOLCHAIN/$TARGET$API-clang \
--cxx=$TOOLCHAIN/$TARGET$API-clang++ \
--ld=$TOOLCHAIN/$TARGET$API-clang \
--ar=$TOOLCHAIN/$TARGET-ar \
--nm=$TOOLCHAIN/$TARGET-nm \
--strip=$TOOLCHAIN/$TARGET-strip \
--target-os=android \
--arch=$ARCH \
--extra-cflags="$CFLAG -march=$CPU -Ifdk_aac/include -Ix264/include" \
--extra-ldflags="-marm -march=$CPU -Lfdk_aac/lib -Lx264/include"  \
--enable-static \
--disable-stripping \
--disable-ffmpeg \
--disable-ffplay \
--disable-ffserver \
--dsiable-ffprobe \
--disable-avddevice \
--disable-devices \
--disable-indevs \
--disable-outdevs \
--disable-debug \
--disable-asm \
--dsiable-yasm \
--disable-doc \
--enable-small \
--enable-dct \
--enable-dwt \
--enable-lsp \
--enable-mdct \
--enable-rdft \
--enable-fft \
--enable-version3 \
--enable-nonfree \
--disable-filters \
--disable-postproc \
--disable-bsfs \
--enable-bsf=aac_adtstoasc \
--enable-bsf=h264_mp4toannexb \
--disable-encoders \
--enable-encoder=pcm_s16le \
--enable-encoder=aac \
--enable-encoder=libvo_aacenc \
--disable-decoders \
--enable-decoder=aac \
--enable-decoder=mp3 \
--enable-decoder=pcm_s16le \
--disable-parsers \
--enable-parser=aac \
--disable-muxers \
--enable-muxer=flv \
--enable-muxer=wav \
--enable-muxer=adts \
--disable-demuxers \
--enable-demuxer=flv \
--enable-demuxer=wav \
--enable-demuxer=aac \
--disable-protocols \
--enable-protocol=rtmp \
--enable-protocol=file \
--enable-libfdk_aac \
  
make clean

make -j4
  
make install