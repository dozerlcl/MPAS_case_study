;;;     11.16 MPAS后处理部分 将MPAS和观测的CMORPH进行对比
;;;         pre count 部分， 将文件整合，整合后的文件放到 ncdf 下
;;;     11.29 修改相应路径，将后处理部分单独并列出来
;;;         处理 %4y
;;;     21.03.03 处理单一的模式输出数据，合并后输出这一年的 4-8月份的内容 不再进行与观测数据的合并
;;;         使用 shell 从环境中获取 year参数，并发进行NCL
begin

    ; year = 2013
    year = stringtoint( getenv("selyear") )
    modeltype = "RCM"
;;;>>> data reader
    ;;;>>>  prepare model data
    ; /raid52/yycheng/MPAS/VR_postprocess/VR_model/92-25km_VR_2003/out_convert_latlon/history
    diri      = "/raid52/yycheng/MPAS/"+modeltype+"_postprocess/"+modeltype+\
    "_model/92-25km_"modeltype"_" + year + "/out_convert_latlon/history/"
    fili      = systemfunc("cd "+diri+"; ls *.nc")
    f_mod = addfiles(diri+fili,"r")
    ;;; read time labels    
    ListSetType(f_mod,"join"); 打开多个文件并且返回文件句柄（批量读入后实质上是一个list
    time_fromxtime=f_mod[:]->$"Time"$

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
    
;;;>>> refine input data : change accumulation total precip to daily total precip

    precip_grid   = or_rainnc_rm(1:ntime-1,:,:)  - or_rainnc_rm(0:ntime-2,:,:) 
    precip_conv   = or_rainc_rm(1:ntime-1,:,:)  - or_rainc_rm(0:ntime-2,:,:) 
    pre_mod_daily = pre_mod(1:ntime-1,:,:) - pre_mod(0:ntime-2,:,:)
    copy_VarMeta(pre_mod(0:ntime-2,:,:),pre_mod_daily)
    copy_VarMeta(pre_mod(0:ntime-2,:,:),precip_grid)
    copy_VarMeta(pre_mod(0:ntime-2,:,:),precip_conv)
    pre_mod_daily@long_name = "daily total precipitation from MPAS"
    precip_grid@long_name = "daily total grid precipitation from MPAS"
    precip_conv@long_name = "daily total convection precipitation from MPAS"

;;;>>> output preprocess refine

    diro = "/raid52/yycheng/MPAS/"+modeltype+"_postprocess/"+modeltype+"_merge/pre/"
    filo = "daily_pre_" + year + ".nc"
    system("rm -f "+ diro + filo) ;删除目录下的同名文件
    ncdf = addfile(diro + filo, "c") ; c表示创建netcdf文件
    ncdf->$"precip_MPAS"$   = pre_mod_daily
    ncdf->$"precip_grid"$   = precip_grid
    ncdf->$"precip_conv"$   = precip_conv
    delete(ncdf)

end