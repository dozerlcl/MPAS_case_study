;;; 11.?? 进行简单后处理的检查，相关性非常差
;;; 11.29 单独将NCL脚本并列出
;;; 12.06 考虑用NCL一步到位绘制某个分位数的极端值的情况，直接调用quantile会出错，考虑qsort （remains

;;; 绘制2005
load "./quantile.ncl"
begin

ind_year = 0
plot = new(2,graphic) ;定义子图数组
wks = gsn_open_wks("png","./output_pic/precip_check_space/"+"abserror03-09_precip_check_exterme")
do year = 2003,2003,1

;;;>>>data reader
    ;;; exterme
    diri1 = "/m2data2/yycheng/yycheng/MPAS/92-25km_VR_"+year+"/postprocess/temp_data/"
    fili1 = year + "_exterme_precip.nc"
    ncdf1 = addfile(diri1 + fili1, "r") 
    obs_exterme = ncdf1->$"precip_CMORPH"$      ; [time | 153] x [lat | 160] x [lon | 320]
    mod_exterme = ncdf1->$"precip_MPAS"$  ; [Time | 153] x [latitude | 160] x [longitude | 320]
    ;;; obs & mod
    diri2 = "/m2data2/yycheng/yycheng/MPAS/92-25km_VR_"+year+"/postprocess/temp_data/"
    fili2 = year + "_daily_precip_combine_CMORPH_MPAS.nc"
    ncdf2 = addfile(diri2 + fili2, "r") 
    pre_obs = ncdf2->$"precip_CMORPH"$
    pre_mod = ncdf2->$"precip_MPAS"$

    test = percent_to_value(pre_mod(:,1,1),95)
end do

end