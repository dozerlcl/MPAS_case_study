#!/bin/bash
start_time=`date +%s`              #定义脚本运行的开始时间
months=$(seq 4 1 8 )
for month_select in ${months[@]}

do
    {
        # mkdir -p ./output_pic/RCM/${year_select}
        export selmonth=${month_select}
        # ncl -Q ./ttest_months.ncl
        ncl -Q ./corr_months.ncl
    }&

done

wait
echo "finish!"
stop_time=`date +%s`  #定义脚本运行的结束时间
echo "TIME:`expr $stop_time - $start_time`"