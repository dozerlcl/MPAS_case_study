# 2020.11.30 处理cmorph，合并为NC文件，并且进行裁剪

#!/bin/bash
start_time=`date +%s`              #定义脚本运行的开始时间
years=$(seq 2003 1 2015 )
for year in ${years[@]}
do
{
# bzip -d for new files
rm -rf {year}/20*0[1-3] {year}20*1[0-2] {year}/20*09
bzip2 -d ${year}/${year}*/*


mkdir ${year}/cdo_merge
cat > ${year}/CMORPH_V1.0_RAW_0.25deg-DLY_00Z.ctl <<endctl
DSET /raid52/yycheng/MPAS/REFERENCE/CMORPH/DAILY/${year}/%y4%m2/CMORPH_V1.0_ADJ_0.25deg-DLY_00Z_%y4%m2%d2  
TITLE  CMORPH Version 1.0BETA Version, daily precip from 00Z-24Z 
OPTIONS template little_endian
UNDEF  -999.0
XDEF 1440 LINEAR    0.125  0.25
YDEF  480 LINEAR  -59.875  0.25
ZDEF   01 LEVELS 1
TDEF 99999 LINEAR  01apr${year} 1dy 
VARS 1
cmorph   1   99 yyyyy CMORPH Version 1.o daily precipitation (mm)  
ENDVARS
endctl
cdo -f nc -import_binary ./${year}/CMORPH_V1.0_RAW_0.25deg-DLY_00Z.ctl ./${year}/cdo_merge/CMORPH_${year}_04-08.nc
cdo -sellonlatbox,70,140,15,55 ./${year}/cdo_merge/CMORPH_${year}_04-08.nc ./${year}/cdo_merge/CMORPH_${year}_04-08_sellonlat.nc
}
done
wait
echo "finish!"
stop_time=`date +%s`  #定义脚本运行的结束时间
echo "TIME:`expr $stop_time - $start_time`"