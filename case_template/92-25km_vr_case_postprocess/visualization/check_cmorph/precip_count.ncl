;;;     11.16 MPAS后处理部分 将MPAS和观测的CMORPH进行对比
;;;         pre count 部分， 将文件整合，整合后的文件放到 ncdf 下
;;;     11.29 修改相应路径，将后处理部分单独并列出来
;;;         处理 %4y
begin

    year = 2003
;;;>>> data reader
    ;;;>>>  prepare model data
    ; /m2data2/yycheng/yycheng/MPAS/92-25km_VR_2003/postprocess/out_convert_latlon/history
    diri      = "/raid52/yycheng/MPAS/92-25km_VR_"+year+"/postprocess/out_convert_latlon/convert_output/history/"
    fili      = systemfunc("cd "+diri+"; ls *.nc")
    f_mod = addfiles(diri+fili,"r")
    ;;; read time labels    
    ListSetType(f_mod,"join"); 打开多个文件并且返回文件句柄（批量读入后实质上是一个list
    ; or_t2m=f_mod[:]->$"t2m"$
    time_fromxtime=f_mod[:]->$"Time"$
    ; time_fromxtime!0 = "Time"
    ; printVarSummary(time_fromxtime)
    ;;; read data for plotting
    or_rainc=f_mod[:]->$"rainc"$
    or_rainnc=f_mod[:]->$"rainnc"$
    precip = or_rainnc + or_rainc
    copy_VarMeta(or_rainnc, precip)
    precip!0 = "Time"
    precip&Time = time_fromxtime
    ntime = dimsizes(time_fromxtime)
    pre_mod = rm_single_dims(precip) ; remove unname single demension in precip MPAS data
    or_rainc_rm = rm_single_dims(or_rainc)
    or_rainnc_rm = rm_single_dims(or_rainnc)
    ; printVarSummary(or_rainc)
    ;;;>>> prepare observation data : CMORPH
    ; /m2data2/yycheng/yycheng/MPAS/92-25km_VR_2003/postprocess/2003/cdo_merge/
    diri_cmorph = "/m2data2/yycheng/yycheng/MPAS/92-25km_VR_"+year+"/postprocess/"+year+"/cdo_merge/"
    fili_cmorph = "CMORPH_"+year+"04-08_sellon.nc"
    ; fili_cmorph = "CMORPH_200504-200508_sellon.nc"
    f_cmorph    = addfile(diri_cmorph + fili_cmorph,"r")
    pre_comrph     = f_cmorph->$"cmorph"$
    pre_obs = rm_single_dims(pre_comrph) ; remove single demension "level" in precip CMORPH data
    ; printVarSummary(pre_obs)
;;;>>> refine input data : change accumulation total precip to daily total precip
    ; print(cd_calendar(pre_obs&time, 3)) ; pre_obs 20030401 - 20030831
    ; print(cd_calendar(pre_mod&time, 3)) ; pre_obs 20030401 - 20030901
    precip_grid   = or_rainnc_rm(1:ntime-1,:,:)  - or_rainnc_rm(0:ntime-2,:,:) 
    precip_conv   = or_rainc_rm(1:ntime-1,:,:)  - or_rainc_rm(0:ntime-2,:,:) 
    pre_mod_daily = pre_mod(1:ntime-1,:,:) - pre_mod(0:ntime-2,:,:)
    copy_VarMeta(pre_mod(0:ntime-2,:,:),pre_mod_daily)
    copy_VarMeta(pre_mod(0:ntime-2,:,:),precip_grid)
    copy_VarMeta(pre_mod(0:ntime-2,:,:),precip_conv)
    pre_mod_daily@long_name = "daily total precipitation from MPAS"
    precip_grid@long_name = "daily total grid precipitation from MPAS"
    precip_conv@long_name = "daily total convection precipitation from MPAS"
    ; printVarSummary(pre_mod_daily)
;;;>>> output preprocess refine
    ; f_out = addfile(diri + fili(ind_fili), "c")
    ; /m2data2/yycheng/yycheng/MPAS/92-25km_VR_2003/postprocess/temp_data
    diro = "/m2data2/yycheng/yycheng/MPAS/92-25km_VR_"+year+"/postprocess/temp_data/"
    filo = year+"_daily_precip_combine_CMORPH_MPAS.nc"
    system("rm -f "+ diro + filo) ;删除目录下的同名文件
    ncdf = addfile(diro + filo, "c") ; c表示创建netcdf文件
    ncdf->$"precip_CMORPH"$ = pre_obs
    ncdf->$"precip_MPAS"$   = pre_mod_daily
    ncdf->$"precip_grid"$   = precip_grid
    ncdf->$"precip_conv"$   = precip_conv
    delete(ncdf)

    ; ave_precip = precip(ntime - 1,0,:,:)/ntime
    ; ave_con    = or_rainc(ntime-1,0,:,:) / ntime
    ; ave_ncon   = or_rainnc(ntime-1,0,:,:) / ntime
    ; copy_VarCoords(or_rainc(0,0,:,:), ave_precip)
    ; copy_VarCoords(or_rainc(0,0,:,:), ave_con)
    ; copy_VarCoords(or_rainc(0,0,:,:), ave_ncon)
    ; printVarSummary(ave_precip)
    ; ave_t2m = dim_avg_n_Wrap(or_t2m, (/0,1/))
    ; printVarSummary(ave_t2m)
    ; ave_t2m = ave_t2m - 273.15

end