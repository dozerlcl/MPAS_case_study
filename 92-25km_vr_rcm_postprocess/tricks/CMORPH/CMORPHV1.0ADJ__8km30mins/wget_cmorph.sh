#!/bin/bash
# 2021.12.17
# 下载 CMORPH v1.0 30mins 8km数据

years=$(seq 2020 1 2021 )
start_time=`date +%s`              #定义脚本运行的开始时间
for year in ${years[@]}
do
{
    mkdir /data1/yycheng/download/CMORPHv1.0_30mins_8km/${year}
    wget  -P ./${year} ftp://ftp.cpc.ncep.noaa.gov/precip/CMORPH_V1.0/CRT/8km-30min/${year}/CMORPH_V1.0_ADJ_8km-30min_${year}*.tar
}
wait
stop_time=`date +%s`  #定义脚本运行的结束时间
echo "TIME:`expr $stop_time - $start_time`"
echo "finish " + $year
done
