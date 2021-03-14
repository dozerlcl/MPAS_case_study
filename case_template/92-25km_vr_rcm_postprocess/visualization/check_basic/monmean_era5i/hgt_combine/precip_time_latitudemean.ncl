;;; 2021.03.14
;;;   绘制降水的时间、latitude剖面
;;;   load 下面的外部函数来进行时间坐标的绘制，具体可以参考：
;;;   https://www.ncl.ucar.edu/Document/Functions/User_contributed/time_axis_labels.shtml
;;;   序言先使用 cdo ydaymean mask_sel_CN05.1_Pre_1961_2018_daily_025x025.nc ydaymean_.... 将长时间序列转换为
;;;   day of years

load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"
begin

;;;>>>plot set
    plot = new(3, graphic) ;定义子图数组
    wks = gsn_open_wks("png","./output_pic/"+"precip_03-15_lonmean")
;;;>>>data reader
    ; ;   mask 之后集中存放降水数据的位置：   /raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/mask_pre/mask_res
    dir_cn051 = "/raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/mask_pre/mask_res/"
    filename_cn051 = "ydaymean_mask_sel_CN05.1_Pre_1961_2018_daily_025x025.nc"
    
    ; dir_cmorph = "/raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/mask_pre/mask_res/"
    ; filename_cmorph = "mask_sel_CMORPH_03-15.nc"
    
    dir_vr = "/raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/mask_pre/mask_res/"
    filename_vr = "ydaymean_mask_vr_pre_03-15.nc"
    
    dir_rcm = "/raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/mask_pre/mask_res/"
    filename_rcm = "ydaymean_mask_rcm_pre_03-15.nc"

    f = addfile(dir_cn051 + filename_cn051, "r") 
    pre_cn051 = f->$"pre"$

    ; f = addfile(dir_cmorph + filename_cmorph, "r") 
    ; pre_cmorph = f->$"cmorph"$


    f = addfile(dir_vr + filename_vr, "r") 
    pre_vr  = f->$"precip_MPAS"$
    ; ; pre_vr_grid   = f->$"precip_grid"$
    ; ; pre_vr_conv   = f->$"precip_conv"$

    f = addfile(dir_rcm + filename_rcm, "r") 
    pre_rcm  = f->$"precip_MPAS"$
    ; ; pre_rcm_grid   = f->$"precip_grid"$
    ; ; pre_rcm_conv   = f->$"precip_conv"$

    ; printVarSummary(pre_cn051)
    ; printVarSummary(pre_cmorph)
    ; printVarSummary(pre_vr)
    ; printVarSummary(pre_rcm)

;;;-----count time mean-----
    pre_cn051_mean  = dim_avg_n_Wrap(pre_cn051(:,{20:50},{110:130}), (/2/) )
    ; pre_cmorph_mean = dim_avg_n_Wrap(pre_cmorph, (/3/) )
    pre_vr_mean     = dim_avg_n_Wrap(pre_vr(:,{20:50},{110:130}), (/2/) )
    pre_rcm_mean    = dim_avg_n_Wrap(pre_rcm(:,{20:50},{110:130}), (/2/) )
    
    ; vr_error_cn051  = pre_vr_mean - pre_cn051_mean
    ; rcm_error_cn051 = pre_rcm_mean - pre_cn051_mean
    ; copy_VarMeta(pre_vr_mean, vr_error_cn051)
    ; copy_VarMeta(pre_rcm_mean, rcm_error_cn051)

    ; vr_error_cmorph = pre_vr_mean - pre_cmorph_mean
    ; rcm_error_cmorph = pre_rcm_mean - pre_cmorph_mean
    ; copy_VarMeta(pre_vr_mean, vr_error_cmorph)
    ; copy_VarMeta(pre_rcm_mean, rcm_error_cmorph)
    ; printVarSummary(pre_vr_mean)
    ; printVarSummary(pre_rcm_mean)
    ; printVarSummary(pre_cmorph_mean)
    ; printVarSummary(pre_cn051_mean)
    ; printMinMax(pre_vr_mean, 1)

    ; printVarSummary(pre_cn051_mean)
    printVarSummary(pre_vr_mean)
;;;PLOT

; wks   = gsn_open_wks ("png", "time_lat" )  ; send graphics to PNG file 


res                  = True                ; plot mods desired
  res@gsnMaximize = True

  res@gsnFrame             = False
  res@gsnDraw              = False     ; don't draw plot yet， 避免plot = 之后再draw，画两张图；有叠加的时候使用
  res@cnInfoLabelOn        = False            ; turn on/off cn info label
  res@lbLabelBarOn         = True            ; turn on/off individual cb's
  res@cnFillOn             = True

 res@cnFillOn         = True                ; color on
 res@lbLabelStride    = 4                   ; every other label
 res@lbOrientation    = "Vertical"          ; vertical label bar
 res@pmLabelBarOrthogonalPosF = -0.04       ; move label bar closer to axis
 res@cnLinesOn        = False               ; turn off contour lines
 res@cnFillPalette    = "ViBlGrWhYeOrRe"    ; set color map

;  res@tiMainString     = "Anomalies at 90W"  ; title

 res@vpXF             = 0.12                ; default is 0.2 (aspect ratio)
 res@vpYF             = 0.8                 ; default is 0.8
 res@vpHeightF        = 0.4                 ; default is 0.6
 res@vpWidthF         = 0.75                ; default is 0.6

 res@cnLevelSelectionMode = "ManualLevels" ; manual levels
 res@cnMinLevelValF       = 0
 res@cnMaxLevelValF       =  15
 res@cnLevelSpacingF      =  1. 

 ;;;-----add time axix -----
 printVarSummary(pre_vr_mean&Time)
  restick = True
  restick@ttmFormat = "%c"
  restick@ttmAxis = "XB"

;  plot(0) = gsn_csm_lat_time(wks, pre_cn051_mean(lat|:, time|:), res ) 
  time_axis_labels(pre_cn051_mean&time, res, restick)
 plot(0) = gsn_csm_contour(wks, pre_cn051_mean(lat|:, time|:), res ) 
;  plot(1) = gsn_csm_lat_time(wks, pre_vr_mean(latitude|:, Time|:), res ) 
  time_axis_labels(pre_vr_mean&Time, res, restick)
 plot(1) = gsn_csm_contour(wks, pre_vr_mean(latitude|:, Time|:), res ) 
  ; time_axis_labels(pre__mean&Time, res, restick)
 plot(2) = gsn_csm_contour(wks, pre_rcm_mean(latitude|:, Time|:), res ) 

; ; ; ;;;;----------------------------------------------panel seeting
  pres = True
;   pres@txString              = "2003-2015" + " mean " 
; ; ;   pres@gsnPanelLabelBar      = False ; 公用一个色标
; ; ; ;   pres@gsnPanelMainFontHeightF = 0.0002
;   ; pres@gsnPanelFigureStrings = (/"","4","4","4","5","5","5","6","6","6","7","7","7","8","8","8","M","M","M"/)
; ;   pres@amJust                = "TopLeft" ;调整标签顺序
  pres@gsnPanelRowSpec       = True
  gsn_panel(wks,plot,(/1, 3/),pres)


end