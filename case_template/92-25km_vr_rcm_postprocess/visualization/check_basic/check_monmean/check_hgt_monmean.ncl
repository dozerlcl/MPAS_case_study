;   2021.01.16
;   进行MPAS后处理，和ERA5I的hgt数据进行对比；
;   完成读取数据的部分
begin

selyear=2003

;>>> read data
    dir_in_ref  = "/raid52/yycheng/MPAS/REFERENCE/ERA5I_NC/ERA5I_NC_monthy"
    file_in_ref = "sel_hgt.mon.mean.nc"
    dir_in_vr   = "/raid52/yycheng/MPAS/VR_postprocess/VR_merge/diag_mean_mon/"
    file_in_vr  = "monmean_"+selyear+"_VR_diag.nc"

    f = addfile(dir_in_ref + "/" + file_in_ref ,"r")
    ref=f->$"hgt"$
    f = addfile(dir_in_vr + "/" + file_in_vr, "r")
    ; time | 5 对应 4=8 共五个月
    vr_hgt_200=f->$"height_200hPa"$
    vr_hgt_250=f->$"height_250hPa"$
    vr_hgt_500=f->$"height_500hPa"$
    vr_hgt_700=f->$"height_700hPa"$
    vr_hgt_850=f->$"height_850hPa"$
    vr_hgt_925=f->$"height_925hPa"$
    ; printVarSummary(hgt_ref(,:,:,:))
    ref_time = cd_calendar(ref&time, 1)
    ; print(ref_time)
    ref_start_ind  = ind(ref_time.eq.(selyear*100+4)) ; 开始时间 例如 200304
    ref_end_ind    = ind(ref_time.eq.(selyear*100+8)) ; 结束时间      200308

    ; printVarSummary(vr_hgt_200)
    ref_hgt_200=ref(ref_start_ind:ref_end_ind, {200}, :, :)
    ref_hgt_250=ref(ref_start_ind:ref_end_ind, {250}, :, :)
    ref_hgt_500=ref(ref_start_ind:ref_end_ind, {500}, :, :)
    ref_hgt_700=ref(ref_start_ind:ref_end_ind, {700}, :, :)
    ref_hgt_850=ref(ref_start_ind:ref_end_ind, {850}, :, :)
    ref_hgt_925=ref(ref_start_ind:ref_end_ind, {925}, :, :)




end