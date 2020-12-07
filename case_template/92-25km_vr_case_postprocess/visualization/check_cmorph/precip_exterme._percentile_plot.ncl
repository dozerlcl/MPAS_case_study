;;; 11.?? 进行简单后处理的检查，相关性非常差
;;; 11.29 单独将NCL脚本并列出
;;; 12.06 考虑用NCL一步到位绘制某个分位数的极端值的情况，直接调用quantile会出错，考虑qsort （remains
;;;   绘制某一年份，修改select_year
;;; 12.07 绘制 95 % 极端降水 占总体降水的百分数
;;;   用ipynb计算出了extreme（95%），在ncl中筛选，求平均，绘图；NCL效率足够

load "./quantile.ncl"
begin

ind_year = 0
select_year = 2003
plot = new(2,graphic) ;定义子图数组
wks = gsn_open_wks("png","./output_pic/precip_check_space/extreme/"+ select_year + "_precip_check_extreme")
do year = select_year,select_year,1

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
    
;;;>>>find exterme and count total percentile
    pre_obs_average = dim_avg_n_Wrap(pre_obs, 0)
    pre_mod_average = dim_avg_n_Wrap(pre_mod, 0)
    ; printVarSummary(pre_mod)
    ; printVarSummary(mod_exterme)
    obs_exterme_conf = conform(pre_obs, obs_exterme, (/1,2/))
    mod_exterme_conf = conform(pre_mod, mod_exterme, (/1,2/))

    copy_VarMeta(pre_mod, mod_exterme_conf)
    copy_VarMeta(pre_obs, obs_exterme_conf)

    pre_obs = where(pre_obs.ge.obs_exterme_conf, pre_obs, 0.0)
    pre_mod = where(pre_mod.ge.mod_exterme_conf, pre_mod, 0.0)
    ; printVarSummary(pre_obs)
    pre_obs_average_exterme = dim_avg_n_Wrap(pre_obs, 0)
    pre_mod_average_exterme = dim_avg_n_Wrap(pre_mod, 0)

    pre_obs_average = where(pre_obs_average.gt.0.0001, pre_obs_average, pre_obs_average@_FillValue)
    pre_mod_average = where(pre_mod_average.gt.0.0001, pre_mod_average, pre_mod_average@_FillValue)

    pre_obs_precentile = pre_obs_average_exterme / pre_obs_average
    pre_mod_precentile = pre_mod_average_exterme / pre_mod_average
    ;;; plot variable
    ; printMinMax(pre_mod_precentile, 1)
    ; printMinMax(pre_obs_precentile, 1)

    copy_VarMeta(pre_obs(0,:,:), pre_obs_precentile)
    copy_VarMeta(pre_mod(0,:,:), pre_mod_precentile)
    ; conform_dims(dims, r, ndim)
; do i = 0,dimsizes(pre_obs&time)
    ; pre_obs(i,:,:) = where(pre_obs(i,:,:).ge.obs_exterme, pre_obs(i,:,:), 0.0)
    ; pre_mod(i,:,:) = where(pre_mod(i,:,:).ge.mod_exterme, pre_mod(i,:,:), 0.0)
; end do
res = True  
  res@gsnFrame    = False
  res@gsnDraw     = False     ; don't draw plot yet， 避免plot = 之后再draw，画两张图；有叠加的时候使用
  res@cnInfoLabelOn       = False            ; turn off cn info label
  res@cnFillOn             = True
  res@cnLineLabelsOn       = False
  res@cnLinesOn            = False ;填色线条 
  ; res@pmTickMarkDisplayMode = "Always"
  res@lbLabelBarOn        = False            ; turn off individual cb's
;-------------------------------------------------------地图区域设置——中国区域res@mp
    res@mpMinLatF=15
    ; res@mpMinLatF=20
    res@mpMaxLatF=55
    ; res@mpMaxLatF=
    res@mpMinLonF=60
    ; res@mpMinLonF=120
    res@mpMaxLonF=140
    ; res@mpMaxLonF=125
    res@mpDataBaseVersion = "Ncarg4_1"   ;地图采用中等分辨率
    ; res@mpDataSetName="Earth..4"
    ; /m2data2/yycheng/playground/NCL-noob-s-practices/till2020.06/NCL-Chinamap-master
    res@mpDataSetName = "/m2data2/yycheng/playground/NCL-noob-s-practices/till2020.06/NCL-Chinamap-master/database/Earth..4" ; 使用大气所的dataset数据
    res@mpOutlineOn=True
    res@mpOutlineSpecifiers=(/"China","Taiwan"/)
    res@mpCountyLineThicknessF = 10
    ; res@mpOutlineSpecifiers=
    res@mpFillOn=False
    res@gsnAddCyclic=False

    res@mpGridAndLimbOn=True             ;设置经纬线
    res@mpGridLineThicknessF=0.5
    res@mpGridLineDashPattern=0.5
    res@mpGridLineDashPattern=2
    res@mpGridSpacingF=10

;-------------------------------------------------------地图标题设置
  ;;;
                
  ; res@gsnCenterString = "MPAS simulation TPEMIP 4-8"
  ; res@tiMainString    = "MEAN TEMPERATURE AT 2M HEIGHT"
  res@gsnCenterStringFontHeightF = 0.02  
  res@pmTickMarkDisplayMode = "Always" ;坐标标签上添加 度 符号(未起作用)
  res@gsnLeftString = "" ;不绘制左标题
  res@gsnRightString= "" ;不绘制右标题

;-------------------------------------------------------变量/x/y/刻度设置  
  ; res@cnLineThicknessF     = 0.5
  
  ;;;>>>坐标轴的处理
;   res@cnFillPalette         = "MPL_Oranges"; 用GMT_gray 进行填色。即调用了第2种色板(调色板设置)
;   res@cnFillPalette         = "precip2_17lev"; 用GMT_gray 进行填色。即调用了第2种色板(调色板设置)
  ; res@tmXBMode = "automatic" ;指定X轴坐标标签
  ; res@tmYLMode = "Manual" ; 默认"automatic"
  res@tmYLTickStartF = 0  ; 起始最小刻度值
  res@tmYLTickEndF   = 60 ;最大刻度值
  res@tmYLTickSpacingF = 10 ;刻度间隔
  res@tmXBTickSpacingF = 15 
;    resc = res
;    res_ave = res
  ; res@lbOrientation = "Vertical" ; 把色板垂直地移动 
  ; res@gsnContourZeroLineThicknessF = 0. ;略去0线
 
;   res@cnLevelSelectionMode = "ManualLevels" ;等间隔地指定等值线范围
;   res@cnMinLevelValF = 0.
;   res@cnMaxLevelValF = 12.
;   res@cnLevelSpacingF = 1. ;等值线间隔
;   res@cnFilllPalette         = "GMT_polar"; 用GMT_gray 进行填色。即调用了第2种色板(调色板设置)
;   res@cnLevelSelectionMode = "ExplicitLevels"                                                                                             
  ; res@cnFillDrawOrder="postDraw"                                                                                                     
;   res@cnLevels    = (/0.2,0.5,0.8,1.2,1.4,2,4,6,8,12,16,20,40/)
;   res@cnLevels    = (/-1,-0.8,-0.6,-0.4,-0.2,-0.1,0.1,0.2,0.4,0.6,0.8,1./)
;   res@lbBoxEndCapStyle = "TriangleBothEnds"
;   res@pmLabelBarWidthF = 0.10            

;;;;----------------------------------------------------resc 设置

;   resc@gsnCenterString = "RMSE between WRF & CN05.1 dataset"
;   res@cnFillPalette         = "precip_diff_12lev";
  res@cnFillPalette         = "precip2_17lev"; 
;   res@cnLevelSelectionMode  = "ExplicitLevels"
  ; resc@cnMaxLevelCount      = 10
  ; resc@cnLevelSelectionMode = "EqualSpacedLevels" ; equally spaced contour levels
;   delete(resc@cnlevels)
  ; resc@cnLevels              = (/0,1,2,3,4,5,6,7,8,9,10,20,30,40/)
;   resc@cnlevels = (/-1/)
;   delete(resc@cnlevels)  
;   res@cnLevels              = (/-10,-5,-4,-3,-2,-1,0,1,2,3,4,5,10/)  
  ; resc@cnFillColors          = (/1,2,3,4,7,8,9,10,11,12,13,14,15,16,17,18/); -1 为透明
  res@cnLevelSelectionMode = "ManualLevels" ;等间隔地指定等值线范围
  res@cnMinLevelValF = 0.
  res@cnMaxLevelValF = 1.
  res@cnLevelSpacingF = 0.1 ;等值线间隔
  ; resc@cnInfoLabelOn         = True       ; 关闭图右下 方的等值线信息标签
  ; resc@lbLabelBarOn          = True       ; 关闭labelbar
;;;;---------------------------------------------res_ave 设置
;;;;----------------------------------------------------resc 设置

;   resc@gsnCenterString = "RMSE between WRF & CN05.1 dataset"
;   res_ave@cnFillPalette         = "precip_11lev"; 用GMT_gray 进行填色。即调用了第2种色板(调色板设置)
;   res_ave@cnLevelSelectionMode  = "ExplicitLevels"
  ; resc@cnMaxLevelCount      = 10
; precip
  ; resc@cnLevelSelectionMode = "EqualSpacedLevels" ; equally spaced contour levels
;   delete(resc@cnlevels)
;   res_ave@cnLevels              = (/0,1,2,3,4,5,10,15,20,30/)  
  ; resc@cnFillColors          = (/1,2,3,4,7,8,9,10,11,12,13,14,15,16,17,18/); -1 为透明
;   resc@cnLevelSelectionMode = "ManualLevels" ;等间隔地指定等值线范围
;   resc@cnMinLevelValF = 0.
;   resc@cnMaxLevelValF = 8.
;   resc@cnLevelSpacingF = 0.5 ;等值线间隔
  ; resc@cnInfoLabelOn         = True       ; 关闭图右下 方的等值线信息标签
  ; resc@lbLabelBarOn          = True       ; 关闭labelbar
;;;;---------------------------------------------WRF绘制
    ; res@gsnCenterString = "MPAS simulation TPEMIP 4-8"
;   res_ave@gsnCenterString    = "COMRPH"
;   plot(0) = gsn_csm_contour_map(wks, ave_obs, res_ave)
;   res_ave@gsnCenterString    = "MPAS"
;   plot(1) = gsn_csm_contour_map(wks, ave_mod, res_ave)
;   res_ave@gsnCenterString    = "convection"
;   plot(2) = gsn_csm_contour_map(wks, ave_mod_conv, res_ave)
;   res_ave@gsnCenterString    = "grid scale"
;   plot(3) = gsn_csm_contour_map(wks, ave_mod_grid, res_ave)
  res@gsnCenterString    = year
  plot(ind_year) = gsn_csm_contour_map(wks, pre_obs_precentile, res)
  plot(ind_year+1) = gsn_csm_contour_map(wks, pre_mod_precentile, res)
;   delete(total_error)
;   res_ave@gsnCenterString    = "ABS(COMRPH - MPAS)"
;   plot(5) = gsn_csm_contour_map(wks, abs_error, res_ave)
;   res@gsnCenterString    = "total precip correlation"
  ; plot(6) = gsn_csm_contour_map(wks, cor, res)
  ; res@gsnCenterString    = "grid scale correlation"
  ; plot(7) = gsn_csm_contour_map(wks, cor_grid, res)
  ; res@gsnCenterString    = "convection correlation"
  ; plot(8) = gsn_csm_contour_map(wks, cor_conv, res)
;   plot(3) = gsn_csm_contour_map(wks, rmse_wrf, resc)
ind_year = ind_year + 2
end do

pres = True
  pres@txString              = "95 precentile"
  pres@gsnPanelLabelBar      = True ; 公用一个色标
  pres@gsnPanelFigureStrings = (/"obs","mod"/)
  pres@amJust                = "TopLeft" ;调整标签顺序
  pres@gsnPanelRowSpec       = True
  gsn_panel(wks,plot,(/2/),pres)

end