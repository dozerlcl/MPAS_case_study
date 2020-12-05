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
year='2006'
path2input=/raid52/yycheng/MPAS/92-25km_VR_${year}/out/history
path2output=/m2data2/yycheng/yycheng/MPAS/92-25km_VR_${year}/postprocess/out_convert_latlon

for IFILE in `ls ${path2input}/*.nc`;do
# IFILE=path2input+'/history.2003-04-01_00.00.00.nc'
       echo ${IFILE}" ok"
        # ${NCKS} -h -A ${FNMOD} ${IFILE}
/m2data2/yycheng/MPAS/TOOLS/convert_mpas_mpi/convert_mpas \
/raid52/yycheng/MPAS/92-25km_VR_${year}/ea.init.nc \
${IFILE} 
echo "finish ${IFILE}"
mv latlon.nc ${path2output}/convert_output/history/`basename ${IFILE}`
# break
done