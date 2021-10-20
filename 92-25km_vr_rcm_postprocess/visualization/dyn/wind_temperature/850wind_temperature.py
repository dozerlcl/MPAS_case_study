# 要添加一个新单元，输入 '# %%'
# 要添加一个新的标记单元，输入 '# %% [markdown]'
# %%
import numpy as np
import matplotlib.pyplot as plt
import xarray as xr
import pandas as pd
import cmaps

# 国内政区图的绘制
# Load the border data, CN-border-La.dat is download from
# https://gmt-china.org/data/CN-border-La.dat
import cartopy.crs as ccrs
import cartopy.io.shapereader as shpreader
import cartopy.crs as ccrs
import cartopy.feature as cfeature
import matplotlib.patches as mpatches

# %% [markdown]
# # 进行风和比湿拆分的绘制
# 
# 使用shumflux中进行前处理的脚本，将VR,RCM,OBS读作相同坐标的变量，之后再使用dict进行变量区域的筛选，筛选出850hPa风以及比湿之后放入REFERENCE中待下一步绘制
# %% [markdown]
# ## 数据读取、筛选部分

# %%
ds_wind = {}
ds_qv   = {}

# diag数据包含9-1，需要去掉尾部
dir_in = "/raid52/yycheng/MPAS/VR_postprocess/VR_merge_large/ke_daily_vi/"
ds_wind['vr'] = xr.open_mfdataset(dir_in + "????_VR_ke_daily_vi.nc", parallel=True, chunks={"time": 10})
ds_wind['vr'] = ds_wind['vr'].sel(Time = ds_wind['vr'].Time.dt.month.isin([4,5,6,7,8]))
dir_in = "/raid52/yycheng/MPAS/VR_postprocess/VR_merge_large/hum_theta_daily_vi/"
ds_qv['vr'] = xr.open_mfdataset(dir_in + "????_VR_hum_theta_daily_vi.nc", parallel=True)
ds_qv['vr'] = ds_qv['vr'].sel(Time = ds_qv['vr'].Time.dt.month.isin([4,5,6,7,8]))

dir_in = "/raid52/yycheng/MPAS/RCM_postprocess/RCM_merge_large/ke_daily_vi/"
ds_wind['rcm'] = xr.open_mfdataset(dir_in + "????_RCM_ke_daily_vi.nc", parallel=True, chunks={"time": 10})
ds_wind['rcm'] = ds_wind['rcm'].sel(Time = ds_wind['rcm'].Time.dt.month.isin([4,5,6,7,8]))
dir_in = "/raid52/yycheng/MPAS/RCM_postprocess/RCM_merge_large/hum_theta_daily_vi/"
ds_qv['rcm'] = xr.open_mfdataset(dir_in + "????_RCM_hum_theta_daily_vi.nc", parallel=True)
ds_qv['rcm'] = ds_qv['rcm'].sel(Time = ds_qv['rcm'].Time.dt.month.isin([4,5,6,7,8]))


# %%
# 添加ERA5I观测数据
ds_wind['obs'] = {}

# 切换 ERA5I 坐标到MPAS输出结果，方便转换

rename_dict = {"level":"plevels", "lon":"longitude", "lat":"latitude", "time":"Time"}
# ds_wind['obs']['uReconstructZonal'].assign_coords(Time = Time)
# show converting coords
for rename_i in rename_dict:
    print(rename_i + " -----converting to----- " + rename_dict[rename_i])
# 读取数据后就整理坐标，和RCM的坐标一致，之后再进行计算
dir_in = "/raid52/yycheng/MPAS/REFERENCE/ERA5I_NC/ERA5I_NC_daily_large/u_98-17_daily/"
ds_wind['obs']["uReconstructZonal"] = xr.open_dataset(dir_in + "merge_uwnd_98-17_daily.nc")    .rename(rename_dict).assign_coords(ds_qv['rcm']['qv'].coords)['uwnd']

dir_in = "/raid52/yycheng/MPAS/REFERENCE/ERA5I_NC/ERA5I_NC_daily_large/v_98-17_daily/"
ds_wind['obs']["uReconstructMeridional"] = xr.open_dataset(dir_in + "merge_vwnd_98-17_daily.nc")    .rename(rename_dict).assign_coords(ds_qv['rcm']['qv'].coords)['vwnd']

dir_in = "/raid52/yycheng/MPAS/REFERENCE/ERA5I_NC/ERA5I_NC_daily_large/shum_98-17_daily/"
ds_qv['obs'] = xr.open_dataset(dir_in + "merge_shum_98-17_daily.nc").rename(rename_dict).assign_coords(ds_qv['rcm']['qv'].coords)
ds_qv['obs'] = ds_qv['obs'].rename({"shum":"qv"})


# %%
# ----- select data range -----
lat_sel     = (ds_qv['vr'].latitude >= 5) & (ds_qv['vr'].latitude <= 60)
lon_sel     = (ds_qv['vr'].longitude >= 70) & (ds_qv['vr'].longitude <= 140)
plevels_sel = (ds_qv['vr'].plevels == 850) #(ds_qv['vr'].plevels >= 200) & (ds_qv['vr'].plevels <= 925)

# plevels_sel = (ds_qv['vr'].plevels == 100)
time_year    = (ds_qv['vr'].Time.dt.year >= 1998) # 时次相对较长，一开始使用1998年一年进行尝试
time_sel_am     = ds_qv['vr'].Time.dt.month.isin([4,5])
time_sel_jja    = ds_qv['vr'].Time.dt.month.isin([6,7,8])

sel_dict = {}
sel_dict['alltime'] = {'longitude':lon_sel, "latitude":lat_sel, "plevels":plevels_sel, "Time":(time_year)}
# sel_dict['am']    = {'longitude':lon_sel, "latitude":lat_sel, "plevels":plevels_sel, "Time":(time_sel_am & time_year)}
# sel_dict['jja']   = {'longitude':lon_sel, "latitude":lat_sel, "plevels":plevels_sel, "Time":(time_sel_jja & time_year)}
# sel_dict['jja']   = {'longitude':lon_sel, "latitude":lat_sel, "plevels":plevels_sel, "Time":(time_sel_jja & time_year)}


# %%
# ----- 选取变量 -----
mod_list    = ['obs', 'vr', 'rcm']
season_list = ['am', 'jja']

u_sel = {}
v_sel = {}
qv_sel = {}

for imod in mod_list:
    u_sel[imod]  = ds_wind[imod]['uReconstructZonal'].isel(sel_dict['alltime'])
    v_sel[imod]  = ds_wind[imod]['uReconstructMeridional'].isel(sel_dict['alltime'])
    qv_sel[imod] = ds_qv[imod]['qv'].isel(sel_dict['alltime'])

# %% [markdown]
# ## 创建临时输出

# %%
# 处理RCM 中边界的NAN的问题，合并成同样的fillvalues，之后赋值为 -1e30
# for iseason in season_list:
#     rcm_nan_index = (uflux_vi['rcm'][iseason][:,:,:] > 1e10)
#     uflux_vi['rcm'][iseason][rcm_nan_index] = -1e30
#     vflux_vi['rcm'][iseason][rcm_nan_index] = -1e30


# %%
dir_out = "/raid52/yycheng/MPAS/REFERENCE/TEMP_DATA_large/dyn/wind_shum_850hPa/"

for imod in mod_list:
    u_sel[imod].to_netcdf(dir_out + 'uwnd/'  + imod + "_uwind.nc")
    v_sel[imod].to_netcdf(dir_out + 'vwnd/'  + imod + "_vwind.nc")
    qv_sel[imod].to_netcdf(dir_out + 'shum/' + imod + "_shum.nc")


