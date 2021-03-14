#!/bin/bash
# 2021.1.16
# 修改为并发的形式

# 2021.1.15
# 计算 49.11 下的模式经纬度（已经完成转换后）的月平均，和
# 处理的数据目录是 /raid52/yycheng/MPAS/RCM_postprocess 计算 RCM_merge 中的数据
# 计算月平均，使用cdo
# 先输入文件到 dump 中， 然后删除9月，就是4-8月正常的平均结果
# 需要注释掉之后重新运行
#----
start_time=`date +%s`              #定义脚本运行的开始时间
[ -e /tmp/fd1 ] || mkfifo /tmp/fd1 #创建有名管道
exec 3<>/tmp/fd1                   #创建文件描述符，以可读（<）可写（>）的方式关联管道文件，这时候文件描述符3就有了有名管道文件的所有特性
rm -rf /tmp/fd1                    #关联后的文件描述符拥有管道文件的所有特性,所以这时候管道文件可以删除，我们留下文件描述符来用就可以了

for ((i=1;i<=2;i++))
do
        echo >&3                   #&3代表引用文件描述符3，这条命令代表往管道里面放入了一个"令牌"
done


#----

## delete month=9 Spetember 部分
MODELTYPE=VR
DATAPATHIN=/raid52/yycheng/MPAS/${MODELTYPE}_postprocess/${MODELTYPE}_merge/diag
DATAPATHOUT=/raid52/yycheng/MPAS/${MODELTYPE}_postprocess/${MODELTYPE}_merge/diag_mean_mon_test


mkdir -p $DATAPATHOUT/dump

FILEOUT=
for IFILE in `ls ${DATAPATHIN}/*.nc`;

do
#----
read -u3                           #代表从管道中读取一个令牌
#----
{
    # echo "${IFILE} exist!"
    FILEOUT="monmean_`basename ${IFILE}`"
    # echo $FILEOUT
    ##-----
    ## select data
    ## cdo -L -remapbil,grid_info -selmon,4/8 -selyear,2003/2015 $IFILE sel_`basename ${IFILE}` &
    ## get monmean
    cdo monmean $IFILE ${DATAPATHOUT}/${FILEOUT}
    ##----
    ## delete month=9 Spetember
    # cdo delete,month=9 ${DATAPATHOUT}/dump/${FILEOUT} ${DATAPATHOUT}/${FILEOUT} &
    # echo "-----finish convert-----"
    ##break
}&
done

wait

#----

stop_time=`date +%s`  #定义脚本运行的结束时间

echo "-------TIME:`expr $stop_time - $start_time`"
exec 3<&-                       #关闭文件描述符的读
exec 3>&-                       #关闭文件描述符的写
#----



