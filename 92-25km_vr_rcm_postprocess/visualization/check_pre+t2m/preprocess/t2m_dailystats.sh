#   2021.03.23
#       进行t2m的后处理的部分，将hourly的数据转换到daily的统计量上去，便于和
#       daily的CN05.1资料进行对比，使用cdo进行
#       注意修改目标路径的文件夹以及操作的类型 max mean min
#   2021.05.10
#       用以扩展变量的范围 98-17年，最后进行了cdo merge
model_type=VR
opertype=max
DATAINPUT=/raid52/yycheng/MPAS/${model_type}_postprocess/\
${model_type}_merge/t2m_hourly
DATAOUT=/raid52/yycheng/MPAS/${model_type}_postprocess/\
${model_type}_merge/t2m_daily/${opertype}

mkdir -p $DATAOUT

echo "------------preprocess dir:"$target_path"-----------"

for IFILE in `ls ${DATAINPUT}/*.nc`;

do
#----
# read -u3                           #代表从管道中读取一个令牌
#----
{
    echo "${IFILE} exist!"
    FILEOUT="`basename ${IFILE}`"
    # ls $FILEOUT
    # echo $FILEOUT
    # echo ${DATAOUT}/${FILE`OUT}

    # cdo -daymean -selmon,4/8 $IFILE ${DATAOUT}/${FILEOUT}
    cdo -daymax -selmon,4/8 $IFILE ${DATAOUT}/${FILEOUT}
    # cdo -daymin -selmon,4/8 $IFILE ${DATAOUT}/${FILEOUT}

}&
    # break
done
wait
cdo mergetime ${DATAOUT}/* ${DATAOUT}/${opertype}_t2m_98-17_${model_type}.nc