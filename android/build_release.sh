#!/bin/bash
# build apk
# author: @sudong
# 使用方法：./build_release.sh  文件服务 http://in.test.tsmgsoce.com/sudong1/
./gradlew clean
rm -rf ./app/release/
if [ $? -eq 0 ]; then
    echo "gradle clean success"
    ./gradlew assembleRelease
    if [ $? -eq 0 ]; then
        echo "gradle build success"
        filename=`ls -t ./app/release|head -n1|awk '{print $0}'`
        echo "filename is $filename"
        cd ./app/apk/release/2.0.5/
        pwd
        scp -P 22889 $filename root@35.220.142.29:/data/test-apk/sudong1
    fi
fi

