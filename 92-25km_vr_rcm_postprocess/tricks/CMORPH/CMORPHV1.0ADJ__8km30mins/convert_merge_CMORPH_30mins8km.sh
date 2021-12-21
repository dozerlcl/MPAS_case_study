#!/bin/bash
# 2020.11.30 处理cmorph，合并为NC文件，并且进行裁剪
# 2021.08.05 处理cmorph文件，放置到更大的区域上便于后一步分析更大区域
# 测试了使用的脚本
# 2021.12.20 下载CMORPH之后进行解压、转换、插值的处理；将30mins的数据处理为逐日，通过CTL控制逐日文件的合并，需要一些date命令控制时间字符串

#----- 逐小时文件的处理部分，进行日期循环 ------
start_time=`date +%s`              #定义脚本运行的开始时间
years=$(seq 2000 1 2017 )

# loop year
for year in ${years[@]}
do

# ----- unzip files
# # tar for new files
find ./$year/ -name "*.tar" -exec tar -xvf {} --directory ./${year}/ \;
# # bzip -d for new files
bzip2 -d ${year}/${year}*/*

# ----- convert grib to nc files

mkdir ${year}/ctl_files     # 放置每个日期制作的 ctl 文件
mkdir ${year}/cdo_convertnc # 放置转换之后的nc文件
mkdir ${year}/cdo_interp    # 放置插值到分析网格的文件

# loop dates
startdate="${year}-04-01"
enddate="${year}-08-31"
enddate=$( date -d "$enddate" +%Y%m%d )  # rewrite in YYYYMMDD format
i=0

while [ "$date_y4m2d2" != "$enddate" ]; do

{
# 日期控制
date_y4m2d2=$( date -d "$startdate + $i days" +%Y%m%d )     # get $i days format 按天进行累加
date_y4m2=$( date -d "$startdate + $i days" +%Y%m )         # get Y4M2 format date
ctlstartformat_date=$( date -d "$date_y4m2d2" +%Hz%d%b%Y )  # 得到控制CTL起始时间的date

printf 'dealing date is "%s"' "$date_y4m2d2 "

# 同一天的文件用一个CTL文件来表示,需要对CTL文件中的TDEF部分进行调整
cat > ${year}/ctl_files/CMORPH_V1.0_ADJ_8km-30min_${date_y4m2d2}.ctl <<endctl
DSET /raid62/yycheng/MPAS/TPEMIP_92-25km/REFERENCE/CMORPHv1.0ADJ_30mins_8km/${year}/${date_y4m2}/CMORPH_V1.0_ADJ_8km-30min_${date_y4m2d2}%h2
OPTIONS template little_endian
UNDEF  -999.0
TITLE  Precipitation estimates
XDEF 4948 LINEAR   0.036378335 0.072756669
YDEF 1649 LINEAR -59.963614    0.072771377
ZDEF   01 LEVELS 1
TDEF 48 LINEAR  $ctlstartformat_date 30mn
VARS 1
cmorph   1  99  cmorph [ mm/hr ]
ENDVARS
endctl
out_ncfile="./${year}/cdo_convertnc/CMORPHv1.0ADJ_30mins_8km_${date_y4m2d2}.nc"
# 二进制文件转nc之后的文件过大，一天会有44G
cdo -f nc4 -import_binary ./${year}/ctl_files/CMORPH_V1.0_ADJ_8km-30min_${date_y4m2d2}.ctl ${out_ncfile}
# 插值到需要的网格上，之后对转化后的临时文件进行删除
interp_ncfile="./${year}/cdo_interp/CMORPHv1.0ADJ_30mins_8km_${date_y4m2d2}.nc"
cdo -L -P 16 remapbil,./grid_info_analysis $out_ncfile $interp_ncfile # 每次都要重新计算权重，考虑先制作一个权重的nc文件
# cdo -L -P 16 remap,grid_weights.nc $out_ncfile $interp_ncfile

i=$(( i + 1 ))
# break
} 
# end loop date
done

# merge all ncfiles in one year
cdo -P 16 mergetime ./${year}/cdo_interp/CMORPHv1.0ADJ*.nc ./cdomerge_1998-2017/CMORPH_V1.0_ADJ_0.25deg-30min_${year}.nc
# end loop year
# break
done

wait
echo "finish!"
stop_time=`date +%s`  #定义脚本运行的结束时间
echo "TIME:`expr $stop_time - $start_time`"
exec 3<&-                       #关闭文件描述符的读
exec 3>&-