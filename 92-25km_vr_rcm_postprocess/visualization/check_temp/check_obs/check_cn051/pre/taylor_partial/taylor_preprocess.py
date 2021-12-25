

def taylor_count(path_in, file_ref, varname_ref, file_vr, varname_vr, file_rcm, varname_rcm):
    "计算泰勒图诸要素,进行了归一化处理 \
    ,path_in 数据主要路径，file_ref参考数据路径，file_vr,vr数据，varname_ref数据中变量名 \
    "
    import xarray as xr
    import numpy  as np
    import seaborn as sns
    import pandas as pd
    import matplotlib.pyplot as plt
    import skill_metrics as sm

    ds_obs = xr.open_dataset(path_in + "/" + file_ref)
    model_set = {} # 存放不同模式结果
    model_set["vr"] = xr.open_dataset(path_in + "/" + file_vr)
    model_set["rcm"] = xr.open_dataset(path_in + "/" + file_rcm)

    months = ["4","5","6","7","8"]
    model_types = ["vr", "rcm"]
    model_stats = {} # 存放 VR RCM 的位置

    for model_type in model_types:
        month_stats = {} # 存放逐月的统计量
        # add every month
        for month_ind in months:
            # count month mean
            months_obs_mean = ds_obs[varname_ref].loc[ds_obs.time.dt.month==int(month_ind)].mean(dim=["time"])
            months_vr_mean = model_set[model_type][varname_vr].loc[model_set[model_type].Time.dt.month==int(month_ind)].mean(dim=["Time"])
            # ND to 1D
            temp_obs = months_obs_mean.values.ravel()
            temp_vr = months_vr_mean.values.ravel()
            # remove NaN
            temp_obs = temp_obs[~np.isnan(temp_obs)]
            temp_vr = temp_vr[~np.isnan(temp_vr)]
            # count taylor stats
            # pred1 , refer
            # month_stats[month_ind] = sm.taylor_statistics(np.array(months_mod_mean).ravel(),np.array(months_obs_mean).ravel())
            # add
            month_stats[month_ind] = sm.taylor_statistics(temp_vr, temp_obs)
        # add all year
        # count year(4-8 months) mean
        months_obs_mean = ds_obs[varname_ref].mean(dim=["time"])
        months_vr_mean = model_set[model_type][varname_vr].mean(dim=["Time"])
        # ND to 1D
        temp_obs = months_obs_mean.values.ravel()
        temp_vr = months_vr_mean.values.ravel()
        # remove NaN
        temp_obs = temp_obs[~np.isnan(temp_obs)]
        temp_vr = temp_vr[~np.isnan(temp_vr)]
        # add
        month_stats['all'] = sm.taylor_statistics(temp_vr, temp_obs)
        # add module set
        model_stats[model_type] = month_stats
    year_select = ["2004","2005","2006","2007","2008"]
    months = ["4","5","6","7","8","all"]
    model_types = ["vr", "rcm"]
    model_plot = {} # 存放不同模式的taylor plot的结果

    # 将泰勒图诸要素整理到 model_plot 中，并接着绘图
    for model_type in model_types:

        sdev  = []
        crmsd = []
        ccoef = []
        sdev_obs = []
        # append obs
        #----- normilized -----
        sdev.append(model_stats[model_type][month_ind]['sdev'][0]/model_stats[model_type][month_ind]['sdev'][0])
        crmsd.append(model_stats[model_type][month_ind]['crmsd'][0]/model_stats[model_type][month_ind]['sdev'][0])
        ccoef.append(model_stats[model_type][month_ind]['ccoef'][0])

        for month_ind in months:

            # statistics can be normalized
            # obs sdev=1 crmsd=0 ccoef=1
            # append 4-8 months
            #----- normilized -----
            sdev.append(model_stats[model_type][month_ind]['sdev'][1]/model_stats[model_type][month_ind]['sdev'][0])
            crmsd.append(model_stats[model_type][month_ind]['crmsd'][1]/model_stats[model_type][month_ind]['sdev'][0])
            ccoef.append(model_stats[model_type][month_ind]['ccoef'][1])

        # append all round year
        sdev  = np.array(sdev)
        crmsd = np.array(crmsd)
        ccoef = np.array(ccoef)

        # add to model plot
        model_plot[model_type] = {"sdev":sdev, "crmsd":crmsd, "ccoef":ccoef}

    return model_plot
