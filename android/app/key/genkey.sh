#!/bin/bash
if [ $# -ne 1 ]; then
    printf -- "Please input alias.\n\n"
    exit
fi
echo "输入参数密钥$1\n"
keystoreName="$1.jks"
# echo "test code 2"

printf "\n开始生成key:[$keystoreName]...\n\n"
`keytool -genkey -alias $1 -keyalg RSA -validity 10000 -keystore $keystoreName`
printf "\n[$keystoreName]正在进行pkcs12重新加密...\n\n"
`keytool -importkeystore -srckeystore $keystoreName -destkeystore $keystoreName -deststoretype pkcs12`
printf "\n删除老的key:[$keystoreName.old]...okay\n\n"
`rm -rf $keystoreName.old`

cat /dev/null  > ../../key.properties
echo "storePassword=$1" >> ../../key.properties
echo "keyPassword=$1" >> ../../key.properties
echo "keyAlias=$1" >> ../../key.properties
echo "storeFile=./key/$keystoreName" >> ../../key.properties