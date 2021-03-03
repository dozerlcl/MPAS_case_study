;;; 12.08 绘制某一年份情况，以及直接做差，包含格点、对流尺度降水

begin

;;;>>>data reader
    dir_obs = "/raid52/yycheng/MPAS/REFERENCE/CN05.1/sel_03-15/"
    filename_obs = "sel_CN05.1_Pre_1961_2018_daily_025x025.nc"
    
    dir_vr = "/raid52/yycheng/MPAS/VR_postprocess/VR_merge/pre/"
    filename_vr = "daily_pre_03-15.nc"
    
    dir_rcm = "/raid52/yycheng/MPAS/RCM_postprocess/RCM_merge/pre/"
    filename_rcm = "daily_pre_03-15.nc"

    f = addfile(dir_obs + filename_obs, "r") 
    pre_obs_daily = f->$"pre"$

    f = addfile(dir_vr + filename_vr, "r") 
    pre_vr_daily  = f->$"precip_MPAS"$
    pre_vr_grid   = f->$"precip_grid"$
    pre_vr_conv   = f->$"precip_conv"$

    f = addfile(dir_rcm + filename_vr, "r") 
    pre_rcm_daily  = f->$"precip_MPAS"$
    pre_rcm_grid   = f->$"precip_grid"$
    pre_rcm_conv   = f->$"precip_conv"$

    printVarSummary(pre_obs_daily)
    printVarSummary(pre_vr_daily)
    printVarSummary(pre_rcm_daily)
end