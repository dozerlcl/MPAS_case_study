#!/bin/bash
#   2021.04.17
#       将原本TEMP_DATA的数据进行拆分，到四个分析区域的叫不能
#       Northeast NE 42-54N 117-135E
#       North China NC 34-42N 110-123E
#       YZ basin YZ 25-34N 110-123E
#       South west SW 22-30N 98-110E

#part1 创建 NE NC YZ SW四个文件夹
in_dir=/raid52/yycheng/MPAS/REFERENCE/TEMP_DATA_large/t2m
out_dir=/raid52/yycheng/MPAS/REFERENCE/TEMP_DATA_large/partial_t2m
mkdir ${out_dir}
mkdir ${out_dir}/NE
mkdir ${out_dir}/NC
mkdir ${out_dir}/YZ
mkdir ${out_dir}/SW
mkdir ${out_dir}/SC
mkdir ${out_dir}/NWC
# 创建和此前结构相同的子目录
for dir in `ls ${out_dir}` ;
do
# echo `basename $dir`
# echo $dir
rsync -a --include='*/' --exclude='*'  ${in_dir}/ ${out_dir}/$dir #/raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/partial_pre/NE/
done