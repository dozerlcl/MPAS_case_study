 ;  2021.01.18 
 ;  单独将数据读入的部分放一个模板 
 ;  读入 REF VR RCM 三组月平均书
  
begin

sellevels = (/925, 850, 700, 500, 250, 200/)
sellevel  = sellevels(0)
; plot = new(6*3,graphic) ;定义子图数组
; wks = gsn_open_wks("png","./output_pic/mean/" + "hgt_timemean")

;>>> read data
    dir_in_ref  = "/raid52/yycheng/MPAS/REFERENCE/ERA5I_NC/ERA5I_NC_monthy"
    file_in_ref = "sel_hgt.mon.mean.nc"
    
    modtype = "VR"
    dir_in_vr   = "/raid52/yycheng/MPAS/"+modtype+"_postprocess/"+modtype+"_merge/diag_mean_mon/"
    file_in_vr  = "monmean_2003-2015"+"_"+modtype+"_diag.nc"

    f = addfile(dir_in_ref + "/" + file_in_ref ,"r")
    ref_var_alllevel=f->$"hgt"$ ; every level
    ref_var = ref_var_alllevel(:,{sellevel},:,:) ; specific level
    f = addfile(dir_in_vr + "/" + file_in_vr, "r")
    ; time | 5 对应 4=8 共五个月
    vr_varname = "height_"+sellevel+"hPa"
    vr_var=f->$vr_varname$
    
    modtype = "RCM"
    dir_in_rcm   = "/raid52/yycheng/MPAS/"+modtype+"_postprocess/"+modtype+"_merge/diag_mean_mon/"
    file_in_rcm  = "monmean_2003-2015"+"_"+modtype+"_diag.nc"

    f = addfile(dir_in_rcm + "/" + file_in_rcm, "r")

    rcm_varname = "height_"+sellevel+"hPa"
    rcm_var=f->$rcm_varname$



end