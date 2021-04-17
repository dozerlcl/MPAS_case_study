#!/bin/bash
# 04.15 将daily的diag文件中的hgt文件进行合并并输出,多个层次合并到一个文件中
#       使用此前准备的管道排队
#----

start_time=`date +%s`              #定义脚本运行的开始时间
[ -e /tmp/fd1 ] || mkfifo /tmp/fd1 #创建有名管道
exec 3<>/tmp/fd1                   #创建文件描述符，以可读（<）可写（>）的方式关联管道文件，这时候文件描述符3就有了有名管道文件的所有特性
rm -rf /tmp/fd1                    #关联后的文件描述符拥有管道文件的所有特性,所以这时候管道文件可以删除，我们留下文件描述符来用就可以了

for ((i=1;i<=5;i++))
do
        echo >&3                   #&3代表引用文件描述符3，这条命令代表往管道里面放入了一个"令牌"
done

model_type='RCM'
input_dir=/raid52/yycheng/MPAS/${model_type}_postprocess/${model_type}_merge/diag
output_dir=/raid52/yycheng/MPAS/${model_type}_postprocess/${model_type}_merge/diag_daily/hgt/


for IFILE in `ls ${input_dir}/*.nc`;

do
#----
read -u3                           #代表从管道中读取一个令牌
#----
{ # 并发的部分
    echo "${IFILE} exist!"
    FILEOUT=`basename ${IFILE}`
    cdo -selname,height* ${IFILE} ${output_dir}/${FILEOUT}

echo >& 3  # 归还令牌，上面cdo结束才会


}&

done

wait 
# 完成后将上面一口气合并
cdo mergetime ${output_dir}/*.nc ${output_dir}/hgt_${model_type}_03-15.nc
#----

stop_time=`date +%s`  #定义脚本运行的结束时间

echo "-------TIME:`expr $stop_time - $start_time`"
exec 3<&-                       #关闭文件描述符的读
exec 3>&-                       #关闭文件描述符的写
#----