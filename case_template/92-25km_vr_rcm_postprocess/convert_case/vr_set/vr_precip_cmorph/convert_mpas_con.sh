# 2021.01.16 将 convert_mpas.sh 修改为并发的程序，下面是参考脚本

#!/bin/bash
start_time=`date +%s`              #定义脚本运行的开始时间
[ -e /tmp/fd1 ] || mkfifo /tmp/fd1 #创建有名管道
exec 3<>/tmp/fd1                   #创建文件描述符，以可读（<）可写（>）的方式关联管道文件，这时候文件描述符3就有了有名管道文件的所有特性
rm -rf /tmp/fd1                    #关联后的文件描述符拥有管道文件的所有特性,所以这时候管道文件可以删除，我们留下文件描述符来用就可以了
for ((i=1;i<=10;i++))
do
        echo >&3                   #&3代表引用文件描述符3，这条命令代表往管道里面放入了一个"令牌"
done

for ((i=1;i<=1000;i++))
do
read -u3                           #代表从管道中读取一个令牌
{
        sleep 1  #sleep 1用来模仿执行一条命令需要花费的时间（可以用真实命令来代替）
        echo 'success'$i       
        echo >&3                   #代表我这一次命令执行到最后，把令牌放回管道
}&
done
wait

stop_time=`date +%s`  #定义脚本运行的结束时间

echo "TIME:`expr $stop_time - $start_time`"
exec 3<&-                       #关闭文件描述符的读
exec 3>&-                       #关闭文件描述符的写