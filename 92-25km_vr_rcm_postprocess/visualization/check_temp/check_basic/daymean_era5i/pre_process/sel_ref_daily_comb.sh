# 将ERA5I的合并出来的每日数据进行合并，计算ydaymean
# deal hgt
dir_in=/raid52/yycheng/MPAS/REFERENCE/ERA5I_NC/ERA5I_NC_daily/hgt
dir_out=/raid52/yycheng/MPAS/REFERENCE/ERA5I_NC/ERA5I_NC_daily/hgt

cdo mergetime ${dir_in}/hgt.*.nc ${dir_out}/merge_hgt_daily.nc
cdo ydaymean ${dir_out}merge_hgt_daily.nc ${dir_out}/ydaymean_hgt_daily.nc