# 2021.04.07
#   计算年际的相关的cdo预处理部分,拆分出4-5月以及6-8月的数据,配合 corr_interannual 执行
#   IN:
input=/raid52/yycheng/MPAS/REFERENCE/TEMP_DATA_large/t2m/ordata
#   OUT:
# output=/raid52/yycheng/MPAS/REFERENCE/TEMP_DATA_large/pre/interannual
output=/raid52/yycheng/MPAS/REFERENCE/TEMP_DATA_large/t2m/ydaymean
mkdir -p $output

echo "------------preprocess dir:"$output"-----------"

for infile in `ls ${input}/*.nc`;

do
#----
# read -u3                           #代表从管道中读取一个令牌
#----
{
    echo "${infile} exist!"
    outfile="`basename ${infile}`"
    # cdo -yearmean -selmonth,4/5 $infile ${output}/am_${outfile}
    # cdo -yearmean -selmonth,6/8 $infile ${output}/jja_${outfile}
    # cdo -ydaymean $infile ${output}/${outfile}


}&

done