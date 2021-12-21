# 2020.11.30 处理cmorph，合并为NC文件，并且进行裁剪

#!/bin/bash
start_time=`date +%s`              #定义脚本运行的开始时间
years=$(seq 2003 1 2015 )
for year in ${years[@]}
do
{
cdo fldmean ./${year}/cdo_merge/CMORPH_${year}_04-08_sellonlat.nc ./${year}/cdo_merge/spatialmean_${year}.nc
}&
done
wait
echo "finish!"
stop_time=`date +%s`  #定义脚本运行的结束时间
echo "TIME:`expr $stop_time - $start_time`"