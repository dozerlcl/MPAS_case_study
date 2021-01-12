;;;>>> 计算时间上的相关的统计量
begin
;;;>>>data reader
    diri = "/m2data2/yycheng/yycheng/MPAS/92-25km_VR/postprocess/temporary_data/"
    fili = "daily_precip_combine_CMORPH_MPAS.nc"
    ncdf = addfile(diri + fili, "r") 
    pre_obs = ncdf->$"precip_CMORPH"$
    pre_mod_daily = ncdf->$"precip_MPAS"$
    ; delete(ncdf)
    ; printVarSummary(pre_obs)
;;;>>>correction
    cor = escorc_n(pre_obs, pre_mod_daily, (/1,2/), (/1,2/))
    copy_VarCoords(pre_obs(:,0,0), cor)
    printVarSummary(cor)
    ; print(cor)
    total_error = dim_avg_n_Wrap(pre_obs - pre_mod_daily, (/1,2/))
    ; abs_error = dim_avg_n_Wrap(abs(pre_obs - pre_mod_daily), 0)
    ; copy_VarCoords(pre_obs(:,0,0), total_error)
    ; copy_VarCoords(pre_obs(0,:,:), abs_error)
    printVarSummary(total_error)
    ; print(avg(total_error))
    ; ave_obs = dim_avg_n_Wrap(pre_obs, 0)
    ; ave_mod = dim_avg_n_Wrap(pre_mod_daily, 0)
    ; printVarSummary(ave_obs)
    ; printVarSummary(ave_mod)
    ; rel_error = abs_error / ave_obs



end