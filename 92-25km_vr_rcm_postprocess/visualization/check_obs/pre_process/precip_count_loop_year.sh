#!/bin/bash
# loop precip_count.ncl脚本计算各个年份的降水
# 2021.05.10 修改为从diag中获取降水数据，运行 precip_count_diag.ncl
start_time=`date +%s`              #定义脚本运行的开始时间
years=$(seq 1998 1 2017)
for year_select in ${years[@]}

do
    {
        export selyear=${year_select}
        # ncl -Q ./precip_count.ncl
        ncl -Q ./precip_count_diag.ncl
    }&

done

wait
echo "finish!"
stop_time=`date +%s`  #定义脚本运行的结束时间
echo "TIME:`expr $stop_time - $start_time`"