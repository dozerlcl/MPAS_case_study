# 11.08 使用官方提供的convert_mpas 将数据转换到经纬度网格上；
#   同目录下的文件夹 target_domain 提供转换的格点信息
#   include_fields exclude_fields 提供包含、不包含的变量
#   转换多个文件前，需要先用 init 文件 给出SCVT网格的信息

years=$(seq 1998 1 2017 )
for year in ${years[@]}
do

target_file="hum_theta_daily_vi"
modetype="VR"

path_in=/raid62/yycheng/MPAS/TPEMIP_92-25km/${modetype}_postprocess/${modetype}_model\
/92-25km_${modetype}_${year}/vertical_interp/${target_file}
path_out=/raid62/yycheng/MPAS/TPEMIP_92-25km/${modetype}_postprocess/${modetype}_model\
/92-25km_${modetype}_${year}/out_convert_latlon/${target_file}

mkdir -p ${path_out}

for IFILE in `ls ${path_in}/*.nc`;do

echo "------------"${IFILE}" ready------------"
/raid62/yycheng/convert_case/convert_mpas/convert_mpas \
/raid62/yycheng/MPAS/TPEMIP_92-25km/${modetype}/92-25km_${modetype}_${year}/ea.static.nc \
${IFILE}

echo "------------finish ${IFILE} add time coordinate-----------"
export OR_NCFILE_PATH=$IFILE # 将参数传递给NCL脚本，修改时间坐标
ncl -Q ./change_time_one_file.ncl

mv latlon.nc ${path_out}/`basename ${IFILE}`
# break

done

done
