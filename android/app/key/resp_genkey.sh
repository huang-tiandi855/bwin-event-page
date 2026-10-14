#!/usr/bin/expect
#功能：自动填充生成androidkey功能
#注意：expect 是用c语言写的 所以用argc和argv接收参数
#注意：expect 只接受shell而不是bash 请./运行

# expect 常用命令 
# spawn               交互程序开始后面跟命令或者指定程序
# expect              获取匹配信息匹配成功则执行expect后面的程序动作
# send exp_send       用于发送指定的字符串信息
# exp_continue        在expect中多次匹配就需要用到
# send_user           用来打印输出 相当于shell中的echo
# exit                退出expect脚本
# eof                 expect执行结束 退出
# set                 定义变量
# puts                输出变量
# set timeout         设置超时时间

if {$argc < 1} {
    puts "Please input alias.\n\n"
    exit 1
}

set password [lindex $argv 0]
# send_user $password
puts stderr $password
# spawn [exec bash  ./genkey.sh  $password]
spawn bash  ./genkey.sh $password

# expect "输入密钥库口令:"
# send "$password\r"
# expect "再次输入新口令:"
# send "$password\r"
# expect "是什么?"
# send "$password\r"
# expect "是什么?"
# send "$password\r"
# expect "是什么?"
# send "$password\r"
# expect "是什么?"
# send "$password\r"
# expect "是什么?"
# send "$password\r"
# expect "是什么?"
# send "$password\r"
# expect "是否正确?"
# send "y\r"
# expect "按回车):"
# send "\r"
# expect "输入源密钥库口令:"
# send "$password\r"
# # expect "输入目标密钥库口令:"
# # send "$password\r"
# # expect "再次输入新口令:"
# # send "$password\r"

 expect {
     "输入密钥库口令:"
     { send "$password\r"; exp_continue }
     "再次输入新口令:"
     {send "$password\r"; exp_continue}
     "是什么?"
     {send "$password\r"; exp_continue}
     "是否正确?"
     {send "y\r"; exp_continue}
     "按回车):"
     {send "\r"; exp_continue}
     "输入源密钥库口令:"
     {send "$password\r";exp_continue}
     "输入目标密钥库口令:"
     {send "$password\r";exp_continue}
     "再次输入新口令:"
     {send "$password\r";exp_continue}
 }
#  interact