#!/bin/bash

#Log存储路径
locationLog="/Users/smzdm/Documents/01_Android/automation_android/monkey/monkeylog"
#安装包路径，把安装包名称改为smzdm.apk
locationAPK="/Users/smzdm/Documents/01_Android/automation_android/monkey/smzdm.apk"
#获取设备ID
deviceID=`adb devices |awk '{print $1}' |awk 'NR >= 2'|awk 'NR <= 1'`
if [${deviceID} == '']; then
    sleep 60
else
    echo "设备连接成功"
fi

#获取设备型号（获取到的型号可能为数组，不能直接拿来作为名字创建文件，需要转换为字符串）
deviceModel=`adb shell getprop ro.product.model |awk '{printf $0}' |awk 'NR >= 1'|awk 'NR <= 1'`
deviceModel=${deviceModel:0:(${#deviceModel}-1)}

#卸载、安装版本
echo "Device Model:" ${deviceModel}
echo "deviceID" ${deviceID}
sleep 1
echo "Uninstalling..." 
sleep 1
adb -s ${deviceID} uninstall com.smzdm.client.android
echo "Intstalling..." 
adb -s ${deviceID} install ${locationAPK}
sleep 1

######deviceModel=${deviceModel//'b'/'a'}  #将deviceModel里面的b替换为a

# ############################################################################################################################################
while true
do
    deviceID=`adb devices |awk '{print $1}' |awk 'NR >= 2'|awk 'NR <= 1'`
    if [${deviceID} == '']; then
       echo "设备未连接"
       say 设备连接失败
    else
       echo "设备连接成功"
    fi
    if [ $deviceID != '' ];then
       currentTime=`date "+%m-%d~%H-%M-%S"`
       currentDate=`date "+%m-%d"`
       filename=${deviceModel}_${currentTime}
       echo "Start monkey..."
       echo $deviceID
       mkdir "$locationLog"/"$currentDate"
       adb -s ${deviceID} shell monkey -s 2 -p com.smzdm.client.android --throttle 300 -v 400000 >"$locationLog"/"$currentDate"/"$filename.txt"
       adb -s ${deviceID} shell screencap -p /sdcard/"$filename.png"
       echo "screen captured"
       echo "pull screenshots..."
       adb pull "/sdcard/$filename.png" "$locationLog"/"$currentDate"/"$filename.png"
    fi
    sleep 10
    echo "reboot phone..."
    adb -s ${deviceID} reboot
    sleep 90
done