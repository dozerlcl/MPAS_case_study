此处存放一些有用的SHELL脚本，不一定是在 49.19 服务器上使用


- CMORPH

    convert_merge_CMORPH.sh
    将CMORPH资料解压、合并、选取经纬度box输出

    后续添加插值的部分


- ERA5I_NC

    使用CDO，并发的将 48.172 上的ERA5I（netcdf4）的数据进行年份的筛选，区域的筛选，并插值到需要的网格并输出
    grid_info
    进行插值的格点信息
    cdo_select_data.sh
    进行并发计算的脚本（一次性处理多个文件，未设置上限排队）