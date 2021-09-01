#	合并hourly文件part1
#	考虑进行拆分，先拆分逐月份的文件到 merge_temp 文件夹下，使用文件名的来检索时间

years=($( seq 2002 1 2002 ) )
months=($(seq 04 1 09))


targetfile='diag_1hr'
CDOFILE=
modtype='RCM'
for year in ${years[@]}

do
start_dir=${PWD}
cd ./${modtype}_model/92-25km_${modtype}_${year}/out_convert_latlon/ 


mkdir ../merge_temp_1hr
echo 'cdo deal:'${PWD}/${targetfile}

for month in ${months[@]}
do

CDOFILE="${PWD}/${targetfile}/*-0${month}-*"
cdo  -mergetime "${CDOFILE}" ../merge_temp_1hr/${year}_0${month}_${modtype}_${targetfile}.nc &

done

cd $start_dir


done
