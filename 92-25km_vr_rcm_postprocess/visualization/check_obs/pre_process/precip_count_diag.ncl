;;;     11.16 MPAS后处理部分 将MPAS和观测的CMORPH进行对比
;;;         pre count 部分， 将文件整合，整合后的文件放到 ncdf 下
;;;     11.29 修改相应路径，将后处理部分单独并列出来
;;;         处理 %4y
;;;     21.03.03 处理单一的模式输出数据，合并后输出这一年的 4-8月份的内容 不再进行与观测数据的合并
;;;         使用 shell 从环境中获取 year参数，并发进行NCL
;;;         输入数据为转到经纬度网格时候MPAS单独输出的降水以及温度之类的，不是diag 而是history部分
;;;     21.05.10 修改为处理合并后的diag中的降水变量
;;;             大小因为整理数据（去掉了此前输出变量的Time属性，以免和坐标混淆）少了2000KB
begin

    ; year = 1998
    year = stringtoint( getenv("selyear") )
    modeltype = "RCM"
;;;>>> data reader
    ;;;>>>  prepare model data
    ; /raid52/yycheng/MPAS/VR_postprocess/VR_merge/diag_daily
    diri      = "/raid52/yycheng/MPAS/"+modeltype+"_postprocess/"+modeltype+\
    "_merge/diag_daily/"
    fili      = year + "_"+modeltype+"_diag.nc"
    f_mod = addfile(diri+fili,"r")
    ;;; read time labels    
    time_all=f_mod->$"Time"$ ; 从04-01 - 09-01
    dims_time_all = dimsizes(time_all)
    time_pre=time_all(0:dims_time_all - 2)
    ; printVarSummary(time_pre)

    ;;; read data for plotting
    or_rainc=f_mod->$"rainc"$
    or_rainnc=f_mod->$"rainnc"$
    pre_mod = or_rainnc + or_rainc
    copy_VarMeta(or_rainnc, pre_mod)
    
;;;>>> refine input data : change accumulation total precip to daily total precip
    ntime = dims_time_all
    precip_grid   = or_rainnc(1:ntime-1,:,:)  - or_rainnc(0:ntime-2,:,:) 
    precip_conv   = or_rainc(1:ntime-1,:,:)  - or_rainc(0:ntime-2,:,:) 
    pre_mod_daily = pre_mod(1:ntime-1,:,:) - pre_mod(0:ntime-2,:,:)
    copy_VarMeta(pre_mod(0:ntime-2,:,:),pre_mod_daily)
    copy_VarMeta(pre_mod(0:ntime-2,:,:),precip_grid)
    copy_VarMeta(pre_mod(0:ntime-2,:,:),precip_conv)
    pre_mod_daily@long_name = "daily total precipitation from MPAS"
    precip_grid@long_name = "daily total grid precipitation from MPAS"
    precip_conv@long_name = "daily total convection precipitation from MPAS"
    printVarSummary(pre_mod_daily)
; ;;;>>> output preprocess refine

    diro = "/raid52/yycheng/MPAS/"+modeltype+"_postprocess/"+modeltype+"_merge/pre_daily/"
    filo = "daily_pre_" + year + ".nc"
    system("rm -f "+ diro + filo) ;删除目录下的同名文件
    ncdf = addfile(diro + filo, "c") ; c表示创建netcdf文件
    ncdf->$"precip_MPAS"$   = pre_mod_daily
    ncdf->$"precip_grid"$   = precip_grid
    ncdf->$"precip_conv"$   = precip_conv
    delete(ncdf)

end