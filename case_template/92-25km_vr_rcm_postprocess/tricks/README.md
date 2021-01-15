
CMORPH

    convert_merge_CMORPH.sh
    将CMORPH资料解压、合并、选取经纬度box输出

TRANS

    transfer.sh
    转移数据用，写了些服务器的关键地址

ERA5I_NC

    使用CDO，并发的将 48.172 上的ERA5I（netcdf4）的数据插值到需要的网格并输出
    grid_info
    进行插值的格点信息
    cdo_select_data.sh
    进行并发计算的脚本