;;; 11.?? 进行简单后处理的检查，相关性非常差
;;; 11.29 单独将NCL脚本并列出


;;; 绘制2005

begin

ind_year = 0
plot = new(7,graphic) ;定义子图数组
wks = gsn_open_wks("png","./output_pic/precip_check_space/"+"abserror03-09_precip_check")
do year = 2003,2009,1

;;;>>>data reader
    diri = "/m2data2/yycheng/yycheng/MPAS/92-25km_VR_"+year+"/postprocess/temp_data/"
    fili = year + "_daily_precip_combine_CMORPH_MPAS.nc"
    ncdf = addfile(diri + fili, "r") 
    pre_obs = ncdf->$"precip_CMORPH"$
    pre_mod_daily = ncdf->$"precip_MPAS"$
    precip_grid   = ncdf->$"precip_grid"$
    precip_conv   = ncdf->$"precip_conv"$
    ; delete(ncdf)
    ;;; check lat
    print("----------check lat-------------"+year+"---------------")
    if(all(abs(pre_obs&lat - pre_mod_daily&latitude).lt.0.01)) then
      print("latitude all right!")
    end if 
    printMinMax(pre_obs&lat, 1)
    printMinMax(pre_mod_daily&latitude, 1)
;;;>>>correction
    ; cor      = escorc_n(pre_obs, pre_mod_daily, 0, 0)
    ; cor_grid = escorc_n(pre_obs, precip_grid, 0, 0)
    ; cor_conv = escorc_n(pre_obs, precip_conv, 0, 0)
    ; copy_VarCoords(pre_obs(0,:,:), cor)
    ; copy_VarCoords(pre_obs(0,:,:), cor_grid)
    ; copy_VarCoords(pre_obs(0,:,:), cor_conv)
    ; printVarSummary(cor)
    total_error = dim_avg_n_Wrap(pre_mod_daily-pre_obs, 0)
    ; abs_error = dim_avg_n_Wrap(abs(pre_obs - pre_mod_daily), 0)
    copy_VarCoords(pre_obs(0,:,:), total_error)
    ; copy_VarCoords(pre_obs(0,:,:), abs_error)
    ; printVarSummary(abs_error)
    ; ave_obs = dim_avg_n_Wrap(pre_obs, 0)
    ; ave_mod = dim_avg_n_Wrap(pre_mod_daily, 0)
    ; ave_mod_grid = dim_avg_n_Wrap(precip_grid, 0)
    ; ave_mod_conv = dim_avg_n_Wrap(precip_conv, 0) 
    ; printVarSummary(ave_obs)
    ; printVarSummary(ave_mod)
    ; rel_error = abs_error / ave_obs

;;;>>>>>plot
; PLOT = True
; if (PLOT) then
    ;>>>绘图：画空间相关系数/离差
  ; gsn_define_colormap(wks,"MPL_Oranges+GMT_polar") ;在后续定义，不用
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
  res@cnFillPalette         = "precip_diff_12lev"; 用GMT_gray 进行填色。即调用了第2种色板(调色板设置)
  res@cnLevelSelectionMode  = "ExplicitLevels"
  ; resc@cnMaxLevelCount      = 10
  ; resc@cnLevelSelectionMode = "EqualSpacedLevels" ; equally spaced contour levels
;   delete(resc@cnlevels)
  ; resc@cnLevels              = (/0,1,2,3,4,5,6,7,8,9,10,20,30,40/)
;   resc@cnlevels = (/-1/)
;   delete(resc@cnlevels)  
  res@cnLevels              = (/-10,-5,-4,-3,-2,-1,0,1,2,3,4,5,10/)  
  ; resc@cnFillColors          = (/1,2,3,4,7,8,9,10,11,12,13,14,15,16,17,18/); -1 为透明
;   resc@cnLevelSelectionMode = "ManualLevels" ;等间隔地指定等值线范围
;   resc@cnMinLevelValF = 0.
;   resc@cnMaxLevelValF = 8.
;   resc@cnLevelSpacingF = 0.5 ;等值线间隔
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
  plot(ind_year) = gsn_csm_contour_map(wks, total_error, res)
  delete(total_error)
;   res_ave@gsnCenterString    = "ABS(COMRPH - MPAS)"
;   plot(5) = gsn_csm_contour_map(wks, abs_error, res_ave)
;   res@gsnCenterString    = "total precip correlation"
  ; plot(6) = gsn_csm_contour_map(wks, cor, res)
  ; res@gsnCenterString    = "grid scale correlation"
  ; plot(7) = gsn_csm_contour_map(wks, cor_grid, res)
  ; res@gsnCenterString    = "convection correlation"
  ; plot(8) = gsn_csm_contour_map(wks, cor_conv, res)
;   plot(3) = gsn_csm_contour_map(wks, rmse_wrf, resc)
ind_year = ind_year + 1
end do
;;;;----------------------------------------------panel seeting
  pres = True
  pres@txString              = "(MPAS - CMORPH) MEAN DAILY PRECIPITATION"
  pres@gsnPanelLabelBar      = True ; 公用一个色标
  pres@gsnPanelFigureStrings = (/"03","04","05","06","07","08","09","H","I"/)
  pres@amJust                = "TopLeft" ;调整标签顺序
  pres@gsnPanelRowSpec       = True
  gsn_panel(wks,plot,(/3,2,2/),pres)

; draw(plot)
; frame(wks)

; end if

end