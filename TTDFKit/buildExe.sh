#!/bin/bash
# 确保xcodebuild路径正确,如果报下边错误
# ```
# xcode-select: error: tool 'xcodebuild' requires Xcode, but active developer directory '/Library/Developer/CommandLineTools' is a command line tools instance
# ```
# 将路径切换到Xcode的目录下
# ```
# sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer/
# ```
pwd

# 程序根目录
SRCROOT=$(cd "$(dirname "$0")";pwd)
# default is Debug
if [ -n "$1" ]; then
    CONFIGURATION='Release'
else
    CONFIGURATION='Release'
fi

echo "------------------\n当前编译版本为: $CONFIGURATION"

TARGET_NAME="TTDFKit"

OUTPUT_FOLDER="${SRCROOT}/output/${CONFIGURATION}"


BUILD_DIR_Iphoneos="${SRCROOT}/buildIphones"
BUILD_DIR_IphoneSimulator="${SRCROOT}/buildIphonesimulator"
rm -rf ${OUTPUT_FOLDER}
mkdir -p ${OUTPUT_FOLDER}

echo "------------------\n:开始构建真机..."
xcodebuild -target ${TARGET_NAME} -configuration ${CONFIGURATION} ONLY_ACTIVE_ARCH=NO -sdk iphoneos VALID_ARCHS="armv7 arm64" BUILD_DIR=${BUILD_DIR_Iphoneos} clean build
echo "------------------\n:开始构建模拟器..."
xcodebuild -target ${TARGET_NAME} -configuration ${CONFIGURATION} ONLY_ACTIVE_ARCH=NO -sdk iphonesimulator VALID_ARCHS="x86_64" BUILD_DIR=${BUILD_DIR_IphoneSimulator} clean build


cp -R "$BUILD_DIR_Iphoneos/${CONFIGURATION}-iphoneos/${TARGET_NAME}.framework" "${OUTPUT_FOLDER}/"
echo "$BUILD_DIR_Iphoneos/${CONFIGURATION}-iphoneos/${TARGET_NAME}.framework"

echo "------------------\n开始合并Framework..."
lipo -create "$BUILD_DIR_IphoneSimulator/${CONFIGURATION}-iphonesimulator/${TARGET_NAME}.framework/${TARGET_NAME}" "$BUILD_DIR_Iphoneos/${CONFIGURATION}-iphoneos/${TARGET_NAME}.framework/${TARGET_NAME}" -output "$OUTPUT_FOLDER/${TARGET_NAME}.framework/${TARGET_NAME}"

echo "------------------\n移除多余文件..."
rm -r $BUILD_DIR_Iphoneos
rm -r $BUILD_DIR_IphoneSimulator

echo "------------------  \nframework 输出地址: $OUTPUT_FOLDER/${TARGET_NAME}.framework \n"

sudo tar -zcvf TTDFKitFramework.tar.gz output/Release/TTDFKit.framework
