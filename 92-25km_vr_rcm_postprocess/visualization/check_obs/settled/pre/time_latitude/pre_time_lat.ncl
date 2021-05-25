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
  wks = gsn_open_wks("png","./output_pic/"+"precip_98-17_lat-time")
;;;>>>data reader
  ; mask 之后集中存放降水数据的位置：   /raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/mask_pre/mask_res
  dir_cn051 = "/raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/mask_pre/mask_res_dayofyear/"
  filename_cn051 = "ydaymean_mask_sel_CN05.1_Pre_1961_2018_daily_025x025.nc"

  ; dir_cmorph = "/raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/mask_pre/mask_res/"
  ; filename_cmorph = "mask_sel_CMORPH_03-15.nc"

  dir_vr = "/raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/mask_pre/mask_res_dayofyear/"
  filename_vr = "ydaymean_mask_vr_pre_98-17.nc"

  dir_rcm = "/raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/mask_pre/mask_res_dayofyear/"
  filename_rcm = "ydaymean_mask_rcm_pre_98-17.nc"

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

;;;-----count zonal mean-----
  pre_cn051_mean  = dim_avg_n_Wrap(pre_cn051(:,{19.25:},{107:}), (/2/) )
  ; pre_cmorph_mean = dim_avg_n_Wrap(pre_cmorph, (/3/) )
  pre_vr_mean     = dim_avg_n_Wrap(pre_vr(:,{19.25:},{107:}), (/2/) )
  pre_rcm_mean    = dim_avg_n_Wrap(pre_rcm(:,{19.25:},{107:}), (/2/) )

;;;-----PLOT-----

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
  ; res@tiMainString     = "Anomalies at 90W"  ; title

  res@vpXF             = 0.12                ; default is 0.2 (aspect ratio)
  res@vpYF             = 0.8                 ; default is 0.8
  res@vpHeightF        = 0.4                 ; default is 0.6
  res@vpWidthF         = 0.75                ; default is 0.6
  ;;;----- 坐标轴范围设置 -----
  ; res@gsnMajorLatSpacing = 10              ; change maj lat tm spacing
  ; res@gsnMajorLonSpacing = 10              ; change maj lon tm spacing
  ; res@gsnMinorLatSpacing = 2
  ; res@gsnMinorLonSpacing = 2
  res@tmYLOn = True
  res@tmYLBorderOn = True


  ;;;----- 等值线设置 -----
  res@cnLevelSelectionMode = "ManualLevels" ; manual levels
  res@cnMinLevelValF       = 0
  res@cnMaxLevelValF       =  15
  res@cnLevelSpacingF      =  0.5 
  ;;;;----- 等值线标注 + 等值线色标标签 -----
  res@lbLabelBarOn = False
  res@cnLineLabelsOn       = False
  ; res@cnLineLabelInterval = 2
  res@cnLineLabelPlacementMode = "Computed"
  res@cnLineLabelDensityF = 1.5
  res@cnLinesOn            = False ;填色线条 
  ; res@cnLineLabelPlacementMode = "Constant"
  ; res@pmLabelBarWidthF = 0.1
  ; res@pmLabelBarHeightF = 0.7
  res@lbBoxEndCapStyle = "TriangleBothEnds"
  res@lbTitleOn = True
  res@lbTitleFontHeightF = 0.02
  res@lbTitleString = "mm/day"
  ; res@lbBoxMinorExtentF = 0.15
  res@lbBoxMinorExtentF = 0.15
  ; res@pmLabelBarWidthF = 1.
  res@pmLabelBarHeightF = 0.5
  res@lbLabelStride = 4
  res@lbLabelAutoStride = False
  res@lbLabelFontHeightF = 0.015
  ; res@lbBoxMinorExtentF = 
;------地图标题设置-----
  ; res@gsnCenterString = "MPAS simulation TPEMIP 4-8"
  ; res@gsnCenterString    = "MEAN TEMPERATURE AT 2M HEIGHT"
  ; res@gsnCenterStringFontHeightF = 0.02  
  ; res@pmTickMarkDisplayMode = "Always" ;坐标标签上添加 度 符号(未起作用)
  res@gsnLeftString = "" ;不绘制左标题
  res@gsnRightString= "" ;不绘制右标题
  res@gsnLeftStringOrthogonalPosF   = 0.025
  res@gsnRightStringOrthogonalPosF  = 0.025
  ; res@gsnCenterStringOrthogonalPosF = 0.025
  ; res@gsnCenterStringFontHeightF    = 0.03
  res@gsnLeftStringFontHeightF      = 0.020
  res@gsnRightStringFontHeightF     = 0.020
;;;-----add time axix -----
  ;  print(pre_vr_mean&Time)
  restick = True
  restick@ttmFormat = "%n/%d"
  restick@ttmAxis = "XB"
  restick@ttmMinorStride = 5
  restick@ttmNumTicks    = 10
  ; restick@ttmValues = (/(/2015,4,1,0,0,0/), \
  ;                       (/2015,5,1,0,0,0/), \
  ;                       (/2015,6,1,0,0,0/), \
  ;                       (/2015,7,1,0,0,0/), \
  ;                       (/2015,8,1,0,0,0/), \
  ;                       (/2015,9,1,0,0,0/) /)
  ;  plot(0) = gsn_csm_lat_time(wks, pre_cn051_mean(lat|:, time|:), res ) 
  time_axis_labels(pre_cn051_mean&time, res, restick)
;;;----- plot function -----
  res@gsnLeftString = "CN05.1"
  res@gsnRightString = "mm/day"
  plot(0) = gsn_csm_contour(wks, pre_cn051_mean(lat|:, time|:), res ) 
  ;  plot(1) = gsn_csm_lat_time(wks, pre_vr_mean(latitude|:, Time|:), res ) 
  time_axis_labels(pre_vr_mean&Time, res, restick)
  res@gsnLeftString = "VR"
  res@gsnRightString = "mm/day"
  plot(1) = gsn_csm_contour(wks, pre_vr_mean(latitude|:, Time|:), res ) 
  ; time_axis_labels(pre__mean&Time, res, restick)
  res@gsnLeftString = "RCM"
  res@gsnRightString = "mm/day"
  plot(2) = gsn_csm_contour(wks, pre_rcm_mean(latitude|:, Time|:), res ) 

;;;------panel seeting-----
  pres = True
  pres@lbBoxEndCapStyle = "TriangleBothEnds"
  pres@lbTitleOn = False
  pres@lbTitleFontHeightF = 0.015
  pres@lbTitleString = "mm/day"
  ; pres@lbBoxMinorExtentF = 0.15
  pres@lbBoxMinorExtentF = 0.15
  ; pres@pmLabelBarWidthF = 1.
  ; pres@pmLabelBarHeightF = 0.
  pres@lbLabelStride = 4
  pres@lbLabelAutoStride = False
  pres@lbLabelFontHeightF = 0.015
  ;   pres@txString              = "2003-2015" + " mean " 
  pres@gsnPanelLabelBar      = True ; 公用一个色标
  ; ; ; ;   pres@gsnPanelMainFontHeightF = 0.0002
  ;   ; pres@gsnPanelFigureStrings = (/"","4","4","4","5","5","5","6","6","6","7","7","7","8","8","8","M","M","M"/)
  ; ;   pres@amJust                = "TopLeft" ;调整标签顺序
  pres@gsnPanelRowSpec       = True
  gsn_panel(wks,plot,(/1, 2/),pres)

end