#!/bin/bash

# 2021.1.15
# 计算 49.11 下的模式经纬度（已经完成转换后）的月平均，目的是和ERA5I的月平均数据相互对应，从而进行比较
# 处理的数据目录是 /raid52/yycheng/MPAS/RCM_postprocess 计算 RCM_merge 中的数据
# 计算月平均，使用cdo
# 先输入文件到 dump 中， 然后删除9月，就是4-8月正常的平均结果
# 需要注释掉之后重新运行
## delete month=9 Spetember 部分
MODELTYPE=VR
DATAPATHIN=/raid52/yycheng/MPAS/${MODELTYPE}_postprocess/${MODELTYPE}_merge/diag
DATAPATHOUT=/raid52/yycheng/MPAS/${MODELTYPE}_postprocess/${MODELTYPE}_merge/diag_mean_mon


mkdir -P $DATAPATHOUT/dump

FILEOUT=
for IFILE in `ls ${DATAPATHIN}/*.nc`;do
echo "${IFILE} exist!"
FILEOUT="monmean_`basename ${IFILE}`"
# echo $FILEOUT
##-----
## select data
## cdo -L -remapbil,grid_info -selmon,4/8 -selyear,2003/2015 $IFILE sel_`basename ${IFILE}` &
## get monmean
cdo monmean $IFILE ${DATAPATHOUT}/${FILEOUT} &
##----
## delete month=9 Spetember
# cdo delete,month=9 ${DATAPATHOUT}/dump/${FILEOUT} ${DATAPATHOUT}/${FILEOUT} &
echo "-----finish convert-----"
##break
done





