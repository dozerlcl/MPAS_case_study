years=($( seq 2016 1 2017 ) )

targetfile=diag
CDOFILE=
modtype='RCM'
for year in ${years[@]}

do
# start_dir=${PWD}
#/raid62/yycheng/MPAS/VR/92-25km_VR_2007/postprocess/out_convert_latlon
## mkdir ./92-25km_${modtype}_${year}/out_convert_latlon/ -p
# echo 'change dir'
#rm -rf *
cd ./RCM_model/92-25km_${modtype}_${year}/out_convert_latlon/ 
#mkdir ${targetfile}
echo 'cdo deal:'${PWD}/${targetfile}
CDOFILE="${PWD}/${targetfile}/*"
# echo "finish ${IFILE}"
# echo $CDOFILE
cdo mergetime "${CDOFILE}" ${start_dir}/merge_temp/${year}_${modtype}_${targetfile}.nc &
# collect files
#mv ${year}_${modtype}_${targetfile}.nc $start_dir/merge
cd $start_dir
#break
done
