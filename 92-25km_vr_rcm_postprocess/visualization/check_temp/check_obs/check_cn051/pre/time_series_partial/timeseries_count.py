def mean_count(path_in, file_ref, varname_ref, file_vr, varname_vr, file_rcm, varname_rcm):
    "\
    2021.04.19 \
    计算day of years 时间序列空间平均的误差 \
    ,path_in 数据主要路径，file_ref参考数据路径，file_vr,vr数据，varname_ref数据中变量名 \
    "
    import xarray as xr
    import numpy  as np
    import seaborn as sns
    import pandas as pd
    import matplotlib.pyplot as plt
    # import skill_metrics as sm


    ds_obs = xr.open_dataset(path_in + "/" + file_ref)
    ds_vr = xr.open_dataset(path_in + "/" + file_vr)
    ds_rcm = xr.open_dataset(path_in + "/" + file_rcm)

    cn051_mean  = ds_obs['pre'].mean(dim=['lon','lat']).rolling(time=5, center=True).mean()
    vr_mean     = ds_vr['precip_MPAS'].mean(dim=["longitude","latitude"]).rolling(Time=5, center=True).mean()
    rcm_mean    = ds_rcm['precip_MPAS'].mean(dim=["longitude","latitude"]).rolling(Time=5, center=True).mean()
    # cmorph_mean = ds_cmorph['cmorph'].mean(dim=["lon","lat","lev"]) # remove single dimension

    return [cn051_mean, vr_mean, rcm_mean]

def std_count(path_in, file_ref, varname_ref, file_vr, varname_vr, file_rcm, varname_rcm):
    "计算day of years 时间序列空间平均的误差 \
    ,path_in 数据主要路径，file_ref参考数据路径，file_vr,vr数据，varname_ref数据中变量名 \
    "
    import xarray as xr
    import numpy  as np
    import seaborn as sns
    import pandas as pd
    import matplotlib.pyplot as plt
    # import skill_metrics as sm


    ds_obs = xr.open_dataset(path_in + "/" + file_ref)
    ds_vr = xr.open_dataset(path_in + "/" + file_vr)
    ds_rcm = xr.open_dataset(path_in + "/" + file_rcm)

    vr_mean     = ds_vr['precip_MPAS'].std(dim=["longitude","latitude"]).rolling(Time=5, center=True).mean()
    rcm_mean    = ds_rcm['precip_MPAS'].std(dim=["longitude","latitude"]).rolling(Time=5, center=True).mean()
    # cmorph_mean = ds_cmorph['cmorph'].mean(dim=["lon","lat","lev"]) # remove single dimension
    cn051_mean  = ds_obs['pre'].std(dim=['lon','lat']).rolling(time=5, center=True).mean()

    return [cn051_mean, vr_mean, rcm_mean]
