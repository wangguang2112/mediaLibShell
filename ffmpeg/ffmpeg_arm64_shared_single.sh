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
PREFIX=`dirname $0`/android/$PLATFORM-single
  
CFLAG="-D__ANDROID_API__=$API -U_FILE_OFFSET_BITS -DBIONIC_IOCTL_NO_SIGNEDNESS_OVERLOAD -Os -fPIC -DANDROID -D__thumb__ -mthumb -Wfatal-errors -Wno-deprecated -mfloat-abi=softfp -marm"
  
mkdir -p $TMPDIR
 build_one()
{
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
--disable-shared \
--enable-static \
--enable-runtime-cpudetect \
--disable-doc \
--enable-ffmpeg \
--disable-ffplay \
--disable-ffprobe \
--disable-doc \
--disable-symver \
--enable-small \
--enable-gpl --enable-nonfree --enable-version3 --disable-iconv \
--enable-jni \
--enable-mediacodec \
--disable-decoders --enable-decoder=vp9 --enable-decoder=h264 --enable-decoder=mpeg4 --enable-decoder=aac \
--disable-encoders --enable-encoder=vp9_vaapi --enable-encoder=h264_nvenc --enable-encoder=h264_v4l2m2m --enable-encoder=hevc_nvenc \
--disable-demuxers --enable-demuxer=rtsp --enable-demuxer=rtp --enable-demuxer=flv --enable-demuxer=h264 \
--disable-muxers --enable-muxer=rtsp --enable-muxer=rtp --enable-muxer=flv --enable-muxer=h264 \
--disable-parsers --enable-parser=mpeg4video --enable-parser=aac --enable-parser=h264 --enable-parser=vp9 \
--disable-protocols --enable-protocol=rtmp --enable-protocol=rtp --enable-protocol=tcp --enable-protocol=udp \
--disable-bsfs \
--disable-indevs --enable-indev=v4l2 \
--disable-outdevs \
--disable-filters \
--disable-postproc \
--extra-cflags="$CFLAG" \
--extra-ldflags="-marm" 
}
  
build_one
  
make clean
  
make -j4
  
make install

$TOOLCHAIN/arm-linux-androideabi-ld \
    -rpath-link=$SYSROOT/usr/lib/aarch64-linux-android \
    -L$SYSROOT/usr/lib/aarch64-linux-android/$API \
    -L$SYSROOT/usr/lib/aarch64-linux-android \
    -L$PREFIX/lib \
    -L$TOOLCHAIN/../lib/gcc/aarch64-linux-android/4.9.x \
    -soname libffmpeg.so -shared -nostdlib -Bsymbolic --whole-archive --no-undefined -o \
    $PREFIX/lib/libffmpeg.so \
        libavfilter/libavfilter.a \
        libswresample/libswresample.a \
        libavformat/libavformat.a \
        libavutil/libavutil.a \
        libswscale/libswscale.a \
        libavcodec/libavcodec.a \
        libavdevice/libavdevice.a \
        -lc -lm -lz -ldl -llog --dynamic-linker=/system/bin/linker \
        $TOOLCHAIN/../lib/gcc/$ARCH-linux-android/4.9.x/libgcc.a 