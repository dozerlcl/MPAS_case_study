#	合并hourly文件part2
#	将前一步中逐月合并的部分提取出来变量，到 select_field 中，并合并到最外侧的 merge_temp 文件夹下面

years=($( seq 2002 1 2002 ) )


modtype='RCM'
target_field='t2m'
for year in ${years[@]}

do
start_dir=${PWD}
cd ./${modtype}_model/92-25km_${modtype}_${year} 


#mkdir ../merge_temp

 # file temopalte 2003_04_VR_diag_1hr.nc
CDOFILE="${PWD}/merge_temp_1hr/*0[4-8]*"
mkdir ./merge_temp_1hr/select_field
	for IFILE in `ls ${CDOFILE}`;do
		echo "${IFILE} ok"
		# echo `basename $IFILE`
		cdo -select,name=${target_field} ${IFILE} ./merge_temp_1hr/select_field/`basename $IFILE` 
		#ls $CDOFILE
	done
cdo  mergetime  ./merge_temp_1hr/select_field/* ${start_dir}/merge_temp/merge_${target_field}_${year}_${modtype}.nc &

cd $start_dir
# break
done
