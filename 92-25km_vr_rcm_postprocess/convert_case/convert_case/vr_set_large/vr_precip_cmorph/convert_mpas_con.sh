# 11.08 使用官方提供的convert_mpas 将数据转换到经纬度网格上；
#   同目录下的文件夹 target_domain 提供转换的格点信息
#   include_fields exclude_fields 提供包含、不包含的变量
#   转换多个文件前，需要先用 init 文件 给出SCVT网格的信息

# 能直接使用 mpirun 但似乎没有起到作用
# 使用 ifort 编译的convert_mpas
###### convert to one file ######
# targetname=history
# convert_mpas ../../input/x1.40962.init.nc ../${targetname}/${targetname}.*.nc
# mpirun -np 96 \
# /m2data2/yycheng/MPAS/TOOLS/convert_mpas_mpi/convert_mpas \
# ../../input/x1.40962.init.nc \
# ../${targetname}/${targetname}.*.nc
# mv latlon.nc ${targetname}.nc
###### convert to independent files (like input) ######

start_time=`date +%s`              #定义脚本运行的开始时间
[ -e /tmp/fd1 ] || mkfifo /tmp/fd1 #创建有名管道
exec 3<>/tmp/fd1                   #创建文件描述符，以可读（<）可写（>）的方式关联管道文件，这时候文件描述符3就有了有名管道文件的所有特性
rm -rf /tmp/fd1                    #关联后的文件描述符拥有管道文件的所有特性,所以这时候管道文件可以删除，我们留下文件描述符来用就可以了
for ((i=1;i<=10;i++))
do
        echo >&3                   #&3代表引用文件描述符3，这条命令代表往管道里面放入了一个"令牌"
done


years=$(seq 2003 1 2015 )
for year_select in ${years[@]}

do 

#year='2006'
# path2input=/raid52/yycheng/MPAS/92-25km_VR_${year}/out/history
year=$year_select
echo $year
path2input=/raid62/yycheng/MPAS/VR/92-25km_VR_${year}/out/history
path2output=/raid62/yycheng/MPAS/VR_postprocess/VR_model/92-25km_VR_${year}/out_convert_latlon/history_test/

	for IFILE in `ls ${path2input}/*.nc`;
	do
	read -u3 # 从管道中读入一个令牌
		{
		# IFILE=path2input+'/history.2003-04-01_00.00.00.nc'
       		echo ${IFILE}" ok"
       	 	# ${NCKS} -h -A ${FNMOD} ${IFILE}
		/home/yycheng/MPAS/convert_case/convert_mpas/convert_mpas \
		/raid62/yycheng/MPAS/VR/92-25km_VR_${year}/ea.init.nc \
		${IFILE} 
		# echo "finish ${IFILE}"

		echo "------------finish ${IFILE} add time coordinate-----------"

		mv latlon.nc ${path2output}`basename ${IFILE}`
		export OR_NCFILE_PATH=$IFILE
		export CONV_NCFILE_PATH=${path2output}`basename ${IFILE}`
		ncl -Q ./change_time_one_file.ncl

		echo >&3
		}&	# 并发部分
	done

break

done


exec 3<&-                       #关闭文件描述符的读
exec 3>&-                       #关闭文件描述符的写
