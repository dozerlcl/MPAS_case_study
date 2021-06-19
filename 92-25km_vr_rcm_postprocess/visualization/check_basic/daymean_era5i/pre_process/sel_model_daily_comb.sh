#!/bin/bash
# 04.15 使用管道将daily的diag文件中的hgt文件需要的变量进行拆分
# 之后拆分出的文件再进行合并,多个变量并到一个文件中
#       使用此前准备的管道排队
# 05.25 修改为在shell脚本开头写出模式、变量名、路径的形式，方便使用；从daily的diag文件中选取变量
#       合并，并计算ydaymean
#-----
var_name="relhum_*,dewpoint_*" # diag原始文件中的变量名字
folder_name="hum" # 拆分出去的文件夹的名称，文件名的前缀
model_type='RCM'    # 进行处理的模式类型
input_dir=/raid52/yycheng/MPAS/${model_type}_postprocess/${model_type}_merge/diag_daily # 输入的diag_daily的位置
output_dir=/raid52/yycheng/MPAS/${model_type}_postprocess/${model_type}_merge/diag_daily_selected/${folder_name} # 输出的diag_selected
mkdir -p $output_dir
#-----
start_time=`date +%s`              #定义脚本运行的开始时间
[ -e /tmp/fd1 ] || mkfifo /tmp/fd1 #创建有名管道
exec 3<>/tmp/fd1                   #创建文件描述符，以可读（<）可写（>）的方式关联管道文件，这时候文件描述符3就有了有名管道文件的所有特性
rm -rf /tmp/fd1                    #关联后的文件描述符拥有管道文件的所有特性,所以这时候管道文件可以删除，我们留下文件描述符来用就可以了

for ((i=1;i<=5;i++))
do
        echo >&3                   #&3代表引用文件描述符3，这条命令代表往管道里面放入了一个"令牌"
done

for IFILE in `ls ${input_dir}/*.nc`;

do
#----
read -u3                           #代表从管道中读取一个令牌
#----
{ # 并发的部分
    echo "${IFILE} exist!"
    FILEOUT=`basename ${IFILE}`
    # 添加 -L 否则会报分段错误
    cdo -L -selmon,4/8 -selname,${var_name} ${IFILE} ${output_dir}/${FILEOUT}

echo >& 3  # 归还令牌，上面cdo结束才会


}&

done

wait 
# 完成后将上面一口气合并
cdo mergetime ${output_dir}/*.nc ${output_dir}/${folder_name}_${model_type}_98-17.nc
# 将多年的计算到 annual 上,去除diag中的9-1
cdo ydaymean ${output_dir}/${folder_name}_${model_type}_98-17.nc ${output_dir}/ydaymean_${folder_name}_${model_type}_98-17.nc
#----

stop_time=`date +%s`  #定义脚本运行的结束时间

echo "-------TIME:`expr $stop_time - $start_time`"
exec 3<&-                       #关闭文件描述符的读
exec 3>&-                       #关闭文件描述符的写
#----