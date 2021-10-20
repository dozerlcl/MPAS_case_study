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

years=$(seq 1999 1 2017 )

target_file_in="diag"
target_file_out="diag"
modetype="VR"
for year_select in ${years[@]}

do 
#year='2006'
# path_in=/raid52/yycheng/MPAS/92-25km_VR_${year}/out/history
year=$year_select
echo $year
path_in=/raid62/yycheng/MPAS/TPEMIP_92-25km/${modetype}/92-25km_${modetype}_${year}/out/${target_file_in}
path_out=/raid62/yycheng/MPAS/TPEMIP_92-25km/${modetype}_postprocess/${modetype}_model/92-25km_${modetype}_${year}/out_convert_latlon_large/${target_file_out}/
mkdir -p $path_out

for IFILE in `ls ${path_in}/*.nc`;do
# IFILE=path_in+'/history.2003-04-01_00.00.00.nc'
       echo ${IFILE}" ok"
        # ${NCKS} -h -A ${FNMOD} ${IFILE}
/home/yycheng/MPAS/convert_case/convert_mpas/convert_mpas \
/raid62/yycheng/MPAS/TPEMIP_92-25km/${modetype}/92-25km_${modetype}_${year}/ea.init.nc \
${IFILE} 

echo "------------finish ${IFILE} add time coordinate-----------"
export OR_NCFILE_PATH=$IFILE 
ncl -Q ./change_time_one_file.ncl

mv latlon.nc ${path_out}`basename ${IFILE}`
# break
done
# break
done
