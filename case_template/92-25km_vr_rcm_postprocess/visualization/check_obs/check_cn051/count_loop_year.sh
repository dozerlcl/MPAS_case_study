#!/bin/bash
start_time=`date +%s`              #定义脚本运行的开始时间
years=$(seq 2003 1 2015 )
for year_select in ${years[@]}

do
    {
        export selyear=${year_select}
        ncl -Q ./precip_count.ncl
    }&

done

wait
echo "finish!"
stop_time=`date +%s`  #定义脚本运行的结束时间
echo "TIME:`expr $stop_time - $start_time`"