;;; 21.03.05
;;;     修改为进行CN05.1 CMORPH 的降水后处理的读取文件
;;;     在 TEMP_DATA下先进行的了 mask 处理
;;;     处理的 ncl脚本（其中顺带使用了 cdo 命令） 在 ../precip_preprocess/ncl_mask.ncl 文件之中

begin

;;;>>>plot set
    plot = new(8,graphic) ;定义子图数组
    wks = gsn_open_wks("png","./output_pic/"+"precip_03-15_timemean")
;;;>>>data reader
    ;   mask 之后集中存放降水数据的位置：   /raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/mask_pre/mask_res
    dir_cn051 = "/raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/mask_pre/mask_res/"
    filename_cn051 = "mask_sel_CN05.1_Pre_1961_2018_daily_025x025.nc"
    
    dir_cmorph = "/raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/mask_pre/mask_res/"
    filename_cmorph = "mask_sel_CMORPH_03-15.nc"
    
    dir_vr = "/raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/mask_pre/mask_res/"
    filename_vr = "mask_vr_pre_03-15.nc"
    
    dir_rcm = "/raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/mask_pre/mask_res/"
    filename_rcm = "mask_rcm_pre_03-15.nc"

    f = addfile(dir_cn051 + filename_cn051, "r") 
    pre_cn051 = f->$"pre"$

    f = addfile(dir_cmorph + filename_cmorph, "r") 
    pre_cmorph = f->$"cmorph"$


    f = addfile(dir_vr + filename_vr, "r") 
    pre_vr  = f->$"precip_MPAS"$
    ; pre_vr_grid   = f->$"precip_grid"$
    ; pre_vr_conv   = f->$"precip_conv"$

    f = addfile(dir_rcm + filename_rcm, "r") 
    pre_rcm  = f->$"precip_MPAS"$
    ; pre_rcm_grid   = f->$"precip_grid"$
    ; pre_rcm_conv   = f->$"precip_conv"$

    ; printVarSummary(pre_cn051)
    ; printVarSummary(pre_cmorph)
    ; printVarSummary(pre_vr)
    ; printVarSummary(pre_rcm)

;;;-----count time mean-----
    pre_cn051_mean  = dim_avg_n_Wrap(pre_cn051, (/0/) )
    pre_cmorph_mean = dim_avg_n_Wrap(pre_cmorph, (/0,1/) )
    pre_vr_mean     = dim_avg_n_Wrap(pre_vr, (/0/) )
    pre_rcm_mean    = dim_avg_n_Wrap(pre_rcm, (/0/) )

    vr_error_cn051  = pre_vr_mean - pre_cn051_mean
    rcm_error_cn051 = pre_rcm_mean - pre_cn051_mean
    copy_VarMeta(pre_vr_mean, vr_error_cn051)
    copy_VarMeta(pre_rcm_mean, rcm_error_cn051)

    vr_error_cmorph = pre_vr_mean - pre_cmorph_mean
    rcm_error_cmorph = pre_rcm_mean - pre_cmorph_mean
    copy_VarMeta(pre_vr_mean, vr_error_cmorph)
    copy_VarMeta(pre_rcm_mean, rcm_error_cmorph)
    ; printVarSummary(pre_vr_mean)
    ; printVarSummary(pre_rcm_mean)
    ; printVarSummary(pre_cmorph_mean)
    ; printVarSummary(pre_cn051_mean)
    printMinMax(pre_vr_mean - pre_rcm_mean, 1)
;;;PLOT
; ;;>>>>>plot
  res = True  
  ; 页面控制
  res@gsnMaximize = True

  res@gsnFrame             = False
  res@gsnDraw              = False     ; don't draw plot yet， 避免plot = 之后再draw，画两张图；有叠加的时候使用
  res@cnInfoLabelOn        = False            ; turn on/off cn info label
  res@lbLabelBarOn         = True            ; turn on/off individual cb's
  res@cnFillOn             = True

  ;;;;------------------------------ 等值线标注
  res@cnLineLabelsOn       = False
  ; res@cnLineLabelInterval = 4
  res@cnLineLabelPlacementMode = "Computed"
  res@cnLineLabelDensityF = 1.5
  res@cnLinesOn            = False ;填色线条 
  ; res@cnLineLabelPlacementMode = "Constant"

;-------------------------------------------------------地图区域设置——中国区域res@mp
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
;-------------------------------------------------------地图标题设置
  ;;;
                
  ; res@gsnCenterString = "MPAS simulation TPEMIP 4-8"
  ; res@tiMainString    = "MEAN TEMPERATURE AT 2M HEIGHT"
;   res@gsnCenterStringFontHeightF = 0.02  
;   res@pmTickMarkDisplayMode = "Always" ;坐标标签上添加 度 符号(未起作用)
  res@gsnLeftString = "" ;不绘制左标题
  res@gsnRightString= "" ;不绘制右标题

;-------------------------------------------------------变量/x/y/刻度设置  
;   res@pmTickMarkDisplayMode = "Always"
    res@mpMinLatF=15
    ; res@mpMinLatF=20
    res@mpMaxLatF=55
    ; res@mpMaxLatF=
    res@mpMinLonF=70
    ; res@mpMinLonF=120
    res@mpMaxLonF=140
    ; res@mpMaxLonF=125

    res@gsnMajorLatSpacing = 10              ; change maj lat tm spacing
    res@gsnMajorLonSpacing = 10              ; change maj lon tm spacing
    res@gsnMinorLatSpacing = 2
    res@gsnMinorLonSpacing = 2

    res@mpGridAndLimbOn=True             ;设置经纬线
    res@mpGridLineThicknessF=0.5
    res@mpGridLineDashPattern=0.5
    res@mpGridLineDashPattern=2
    res@mpGridSpacingF=10
    
    
  res@lbOrientation = "Vertical" ; 把色板垂直地移动 
  

;--------------------等值线设置----------------------
  resc = res
  res@cnLevelSelectionMode = "ManualLevels" ;等间隔地指定等值线范围

  res@cnFillPalette         = "precip2_17lev"; 
;   res@cnFillPalette         = "temp_19lev"; 
  ; res@cnFillPalette         = "wind_17lev"; 
  ; res@cnFillPalette         = "hotcolr_19lev";
  ; res@cnFillPalette         = "srip_reanalysis";
  res@cnMinLevelValF = 0.
  res@cnMaxLevelValF = 15.
  res@cnLevelSpacingF = 1 ;等值线间隔

  resc@cnLevelSelectionMode = "ManualLevels" ;等间隔地指定等值线范围

  resc@cnFillPalette         = "precip4_diff_19lev"
  resc@cnMinLevelValF = -5
  resc@cnMaxLevelValF = 5.
  resc@cnLevelSpacingF = 0.5 ;等值线间隔 

;------------------------------plot------------------------------
    res@gsnCenterString    = "COMRPH"
  plot(0) = gsn_csm_contour_map(wks, pre_cmorph_mean, res)
  res@gsnCenterString    = "CN05.1"
  plot(1) = gsn_csm_contour_map(wks, pre_cn051_mean, res)
  res@gsnCenterString    = "VR"
  plot(2) = gsn_csm_contour_map(wks, pre_vr_mean, res)
  res@gsnCenterString    = "RCM"
  plot(3) = gsn_csm_contour_map(wks, pre_rcm_mean, res)

  resc@gsnCenterString    = "VR - CMORPH"
  plot(4) = gsn_csm_contour_map(wks, vr_error_cmorph, resc)
  resc@gsnCenterString    = "RCM - CMORPH"
  plot(5) = gsn_csm_contour_map(wks, rcm_error_cmorph, resc)

  resc@gsnCenterString    = "VR - CN05.1"
  plot(6) = gsn_csm_contour_map(wks, vr_error_cn051, resc)
  resc@gsnCenterString    = "RCM - CN05.1"
  plot(7) = gsn_csm_contour_map(wks, rcm_error_cn051, resc)

; ; ;;;;----------------------------------------------panel seeting
  pres = True
  pres@txString              = "2003-2015" + " mean " 
; ;   pres@gsnPanelLabelBar      = False ; 公用一个色标
; ; ;   pres@gsnPanelMainFontHeightF = 0.0002
  ; pres@gsnPanelFigureStrings = (/"","4","4","4","5","5","5","6","6","6","7","7","7","8","8","8","M","M","M"/)
;   pres@amJust                = "TopLeft" ;调整标签顺序
;   ; pres@gsnPanelRowSpec       = True
  gsn_panel(wks,plot,(/4, 2/),pres)


end