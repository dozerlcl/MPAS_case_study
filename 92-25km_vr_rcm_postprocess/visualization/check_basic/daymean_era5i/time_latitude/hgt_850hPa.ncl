;;; 2021.03.14
;;;   绘制降水的时间、latitude剖面
;;;   load 下面的外部函数来进行时间坐标的绘制，具体可以参考：
;;;   https://www.ncl.ucar.edu/Document/Functions/User_contributed/time_axis_labels.shtml
;;;   序言先使用 cdo ydaymean mask_sel_CN05.1_Pre_1961_2018_daily_025x025.nc ydaymean_.... 将长时间序列转换为
;;;   day of years
;;; 2021.04.14
;;;   修改为两米温度的廓线
;;; 2021.04.16
;;;   修改为850hPa廓线，调整输出的分辨率，以及将特定等值线进行绘制，以便比较

load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"
begin

;;;>>>plot set
  plot = new(3, graphic) ;定义子图数组
  wk_type = "png"
  wk_type@cnRasterCellSizeF = 1. / 3000
  wk_type@wkWidth  = 3000
  wk_type@wkHeight = 3000
  wks = gsn_open_wks(wk_type,"./output_pic/"+"hgt_850_03-15_lat-time")

;;;>>>data reader
    ; ;   mask 之后集中存放降水数据的位置：   /raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/mask_pre/mask_res
    dir_cn051 = "/raid52/yycheng/MPAS/REFERENCE/ERA5I_NC/ERA5I_NC_daily/hgt/"
    filename_cn051 = "ydaymean_hgt_daily.nc"
    
    ; dir_cmorph = "/raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/mask_pre/mask_res/"
    ; filename_cmorph = "mask_sel_CMORPH_03-15.nc"
    
    dir_vr = "/raid52/yycheng/MPAS/VR_postprocess/VR_merge/diag_daily/hgt/"
    filename_vr = "ydaymean_hgt_VR_03-15.nc"
    
    dir_rcm = "/raid52/yycheng/MPAS/RCM_postprocess/RCM_merge/diag_daily/hgt/"
    filename_rcm = "ydaymean_hgt_RCM_03-15.nc"

    f = addfile(dir_cn051 + filename_cn051, "r") 
    pre_cn051 = f->$"hgt"$(:, {850}, :, :)

    ; f = addfile(dir_cmorph + filename_cmorph, "r") 
    ; pre_cmorph = f->$"cmorph"$


    f = addfile(dir_vr + filename_vr, "r") 
    pre_vr  = f->$"height_850hPa"$


    f = addfile(dir_rcm + filename_rcm, "r") 
    pre_rcm  = f->$"height_850hPa"$


;;;-----count time mean-----
    pre_cn051_mean  = dim_avg_n_Wrap(pre_cn051(:,{:70},{110:}), (/2/) )
    ; pre_cmorph_mean = dim_avg_n_Wrap(pre_cmorph, (/110/) )
    pre_vr_mean     = dim_avg_n_Wrap(pre_vr(:,{:70},{110:}), (/2/) )
    pre_rcm_mean    = dim_avg_n_Wrap(pre_rcm(:,{:70},{110:}), (/2/) )
    
    ; printVarSummary(pre_cn051_mean)
    printVarSummary(pre_vr_mean)

;;;----- PLOT -----

res                  = True                ; plot mods desired
  res@gsnMaximize = True

  res@gsnFrame             = False
  res@gsnDraw              = False     ; don't draw plot yet， 避免plot = 之后再draw，画两张图；有叠加的时候使用
  res@cnInfoLabelOn        = True            ; turn on/off cn info label
  res@lbLabelBarOn         = True            ; turn on/off individual cb's
  res@cnFillOn             = True
  res@cnLineColor          = "black"
  res@cnLinesOn            = False
  res@cnLineLabelsOn       = False

  res_singlec = res
  res@cnFillOn         = True                ; color on
  res@lbLabelStride    = 4                   ; every other label
  res@lbOrientation    = "Vertical"          ; vertical label bar
  res@pmLabelBarOrthogonalPosF = -0.04       ; move label bar closer to axis
  res@cnFillPalette    = "temp_19lev"   ; set color map

;------ single counter -----

  res_singlec@cnFillOn = False
  res_singlec@cnLinesOn = True
  res_singlec@cnInfoLabelOn = False
  res_singlec@gsnLeftString = ""    ; clean strings
  res_singlec@gsnRightString = ""

  res_singlec@cnLevelSelectionMode = "ExplicitLevels" 
  res_singlec@cnLevels = (/1480,1500,1520,1540,1560,1580,1600/)
  res_singlec@cnFillDrawOrder="postDraw"
  res_singlec@cnLineThicknessF = 3.

  res_singlec@cnLineLabelsOn = True
  res_singlec@cnLineLabelBackgroundColor = -1

  res_singlec@cnLineDashSegLenF          = 0.18          ; assist in controlling concentration
  res_singlec@cnLineLabelInterval        = 1             ; default = 2
  res_singlec@cnLineLabelPlacementMode   = "constant"    ; choose constant label method
  res_singlec@cnLineLabelFontHeightF     = 0.008         ; linelabel sizs


;------ page size -------

  res@vpXF             = 0.12                ; default is 0.2 (aspect ratio)
  res@vpYF             = 0.8                 ; default is 0.8
  res@vpHeightF        = 0.4                 ; default is 0.6
  res@vpWidthF         = 0.75                ; default is 0.6


;;;-----res contour -----

  res@cnLevelSelectionMode = "ManualLevels" ; manual levels
  res@cnMinLevelValF       = 1300.
  res@cnMaxLevelValF       =  1560.
  res@cnLevelSpacingF      =  20.


;;;-----add time axix -----
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
  res@tiMainString = "CN05.1"
  time_axis_labels(pre_cn051_mean&time, res, restick)
  time_axis_labels(pre_cn051_mean&time, res_singlec, restick)
  ; res@gsnLeftString = 
  res@gsnRightString = ""
  plot(0) = gsn_csm_contour(wks, pre_cn051_mean(lat|:, time|:), res )
  overlay(plot(0), gsn_csm_contour(wks, pre_cn051_mean(lat|:, time|:), res_singlec )) 

  res@tiMainString = "VR"
  time_axis_labels(pre_vr_mean&Time, res, restick)
  res@gsnRightString = ""
  plot(1) = gsn_csm_contour(wks, pre_vr_mean(latitude|:, Time|:), res ) 
  overlay(plot(1), gsn_csm_contour(wks, pre_vr_mean(latitude|:, Time|:), res_singlec )) 

  res@tiMainString = "RCM"
  time_axis_labels(pre_rcm_mean&Time, res, restick)
  res@gsnRightString = ""
  plot(2) = gsn_csm_contour(wks, pre_rcm_mean(latitude|:, Time|:), res ) 
  overlay(plot(2), gsn_csm_contour(wks, pre_rcm_mean(latitude|:, Time|:), res_singlec )) 

;;;----- panel seeting -----
  pres = True
;   pres@txString              = "2003-2015" + " mean " 
; ; ;   pres@gsnPanelLabelBar      = False ; 公用一个色标
; ; ; ;   pres@gsnPanelMainFontHeightF = 0.0002
;   ; pres@gsnPanelFigureStrings = (/"","4","4","4","5","5","5","6","6","6","7","7","7","8","8","8","M","M","M"/)
; ;   pres@amJust                = "TopLeft" ;调整标签顺序
  pres@gsnPanelRowSpec       = True
  gsn_panel(wks,plot,(/1, 2/),pres)


end