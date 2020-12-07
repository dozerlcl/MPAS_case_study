# 进行MPAS后处理的部分 <br>

数据典型的存放位置：

    year = 2003
    diri = "/m2data2/yycheng/yycheng/MPAS/92-25km_VR_"+year+"/postprocess/temp_data/"
    fili = year + "_daily_precip_combine_CMORPH_MPAS.nc"

precip.count.ncl 

    将 convert_mpas 的经纬度网格结果， 和CDO转换后的CMORPH结果进行合并（逐日对应），输出到临时文件 <br>

precip_space_statistic.ncl

    基本平均图的绘制，也直接计算空间上做差，空间上的误差分布 _space_

precip_space_stat_error.ncl
    
    将多个误差图合并为panels

precip_space_taylor.ipynb

    进行空间taylor图绘制，使用py实现

precip_time_statistic.ipynb

    进行时间序列图绘制，也直接在时间上做差，计算时间上的误差分布 _time_

precip_time_taylor.ipynb

    不同时间taylor图绘制，5-8逐月，各年