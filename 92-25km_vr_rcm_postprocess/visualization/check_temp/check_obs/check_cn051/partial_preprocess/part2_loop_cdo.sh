#!/bin/bash
#   2021.04.17
#       将原本TEMP_DATA的数据进行拆分，到四个分析区域的叫不能
#       Northeast NE 42-54N 117-135E
#       North China NC 34-42N 110-123E
#       YZ basin YZ 25-34N 110-123E
#       South west SW 22-30N 98-110E

#part2 循环使用CDO将文件夹重新放置到四个subfolder中
#       注意修改处理的数据类型
in_dir=/raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/mask_pre
out_dir=/raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/partial_pre
# 创建和此前结构相同的子目录
# get items in $in_dir
x=( $(find "${in_dir}" ! -type d -name "*.nc") );

for dir in `ls ${out_dir}` ;
do

    echo $dir
# echo "${x[@]}"
    #Then you can loop through
    for item in "${x[@]}"; 
    do
        if [ $dir == "NE" ] # northeast
        then
            slat=42.
            nlat=54.
            wlon=117.
            elon=135.
        elif [ $dir == "NC" ] # north china
        then
            slat=34.
            nlat=42.
            wlon=110.
            elon=123.
        elif [ $dir == "YZ" ] # yangzi basin
        then
            slat=25.
            nlat=34.
            wlon=110.
            elon=123.
        elif [ $dir == "SW" ] # south west
        then
            slat=22.
            nlat=30.
            wlon=98.
            elon=110.
        fi

        echo ${slat} ${nlat} ${wlon} ${elon}
        { 
            echo "$item"; 
            # target="${item/mask_pre/partial_pre/${dir}}"
            target="${item/mask_pre/partial_pre/${dir}}"
            echo $target
            cdo sellonlatbox,${wlon},${elon},${slat},${nlat} ${item} ${target}
        }
    # break
    done
# break
done

