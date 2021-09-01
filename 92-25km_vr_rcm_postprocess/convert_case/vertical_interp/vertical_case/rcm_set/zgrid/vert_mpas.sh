#	2021.06.12
#		插值MPAS垂直层到多个高度上，从history之中进行处理，配合同目录下的python脚本，vertical_interp.py 进行
#		python脚本中有对于垂直层的具体描述，以及合适的zgrid变量的处理方法
# year=1998
years=$(seq 1998 1 2017 )
for year in ${years[@]}
do

modetype="RCM"

path_in=/raid62/yycheng/MPAS/TPEMIP_92-25km/${modetype}/92-25km_${modetype}_${year}/out/history
path_out=/raid62/yycheng/MPAS/TPEMIP_92-25km/${modetype}_postprocess/${modetype}_model/\
92-25km_${modetype}_${year}/vertical_interp/hgt_daily_vi
mkdir -p $path_out

#-----
start_time=`date +%s`              #定义脚本运行的开始时间
[ -e /tmp/fd1 ] || mkfifo /tmp/fd1 #创建有名管道
exec 3<>/tmp/fd1                   #创建文件描述符，以可读（<）可写（>）的方式关联管道文件，这时候文件描述符3就有了有名管道文件的所有特性
rm -rf /tmp/fd1                    #关联后的文件描述符拥有管道文件的所有特性,所以这时候管道文件可以删除，我们留下文件描述符来用就可以了

for ((i=1;i<=15;i++))
do
        echo >&3                   #&3代表引用文件描述符3，这条命令代表往管道里面放入了一个"令牌"
done


for IFILE in `ls ${path_in}/*.nc`;do

#----
read -u3                           #代表从管道中读取一个令牌
#----
{
python ./vertical_interp.py $IFILE $path_out/hgt_`basename ${IFILE}`
echo >& 3  # 归还令牌，上面cdo结束才会
}&
# break
done
done # end year loop

stop_time=`date +%s`  #定义脚本运行的结束时间

echo "-------TIME:`expr $stop_time - $start_time`-----"
exec 3<&-                       #关闭文件描述符的读
exec 3>&-