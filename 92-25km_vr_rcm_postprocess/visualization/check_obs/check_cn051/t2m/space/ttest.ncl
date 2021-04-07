;;; 21.03.05
;;;     修改为进行CN05.1 CMORPH 的降水后处理的读取文件
;;;     在 TEMP_DATA下先进行的了 mask 处理
;;;     处理的 ncl脚本（其中顺带使用了 cdo 命令） 在 ../precip_preprocess/ncl_mask.ncl 文件之中
;;; 21.03.18
;;;   修改绘图方式，将 gsn_csm_contour overlay到 map上，需要单独绘制每个map，为之后的统计检验做准备
;;;   进行均值差异的 t 检验
;;; 21.04.05
;;;   添加一级河流shape,弃用rmsd分布

load "./shapefile_utils.ncl"
begin

;;;>>>plot set
  fignum = 5   ; 04.05 only mean bias & ttest & shapefile


  plot = new(fignum,graphic) ;定义子图数组
  wks = gsn_open_wks("png","./output_pic/"+"t2m_mean_03-15_timemean_ttest")
;;;>>>data reader
  ;   mask 之后集中存放降水数据的位置：   /raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/mask_pre/mask_res
  dir_cn051 = "/raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/mask_t2m/ordata/"
  filename_cn051 = "sel_CN05.1_Tm_1961_2018_daily_025x025.nc"
  
  dir_vr = "/raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/mask_t2m/mask_res/"
  filename_vr = "mask_mean_vr_03-15.nc"
  
  dir_rcm = "/raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/mask_t2m/mask_res/"
  filename_rcm = "mask_mean_rcm_03-15.nc"

  f = addfile(dir_cn051 + filename_cn051, "r") 
  pre_cn051 = f->$"tm"$

  f = addfile(dir_vr + filename_vr, "r") 
  pre_vr  = f->$"t2m"$
  pre_vr  = pre_vr - 273.15

  f = addfile(dir_rcm + filename_rcm, "r") 
  pre_rcm  = f->$"t2m"$
  pre_rcm  = pre_rcm - 273.15

;;;-----count time mean-----
  pre_cn051_mean  = dim_avg_n_Wrap(pre_cn051, (/0/) )
  pre_vr_mean     = dim_avg_n_Wrap(pre_vr, (/0/) )
  pre_rcm_mean    = dim_avg_n_Wrap(pre_rcm, (/0/) )
;;;-----count abs error-----
  vr_error_cn051  = pre_vr_mean - pre_cn051_mean
  rcm_error_cn051 = pre_rcm_mean - pre_cn051_mean
  copy_VarMeta(pre_vr_mean, vr_error_cn051)
  copy_VarMeta(pre_rcm_mean, rcm_error_cn051)
;;;-----add rmsd-----04.05 turn off ------------
  ; dim_rmsd_n_Wrap
  vr_rmsd_cn051  = dim_rmsd_n_Wrap(pre_vr, pre_cn051, 0)
  rcm_rmsd_cn051   = dim_rmsd_n_Wrap(pre_rcm, pre_cn051, 0)
  copy_VarCoords(pre_vr_mean, vr_rmsd_cn051)
  copy_VarCoords(pre_rcm_mean, rcm_rmsd_cn051)

;;;-----count variance-----
  cn051_variance= dim_variance_n(pre_cn051, 0)
  vr_variance   = dim_variance_n(pre_vr, 0)
  rcm_variance  = dim_variance_n(pre_rcm, 0)
  dims_vr       = dimsizes(pre_vr)
  series_num    = dims_vr(0)
  vr_prob       = ttest(pre_cn051_mean, cn051_variance, series_num, pre_vr_mean, vr_variance, series_num, True, False)
  rcm_prob      = ttest(pre_cn051_mean, cn051_variance, series_num, pre_rcm_mean, rcm_variance, series_num, True, False)
  ; copy_VarMeta(pre_cn051_mean, prob)
  copy_VarCoords(pre_cn051_mean, vr_prob)
  copy_VarCoords(pre_cn051_mean, rcm_prob)
  ; printVarSummary(prob)
  ; printMinMax(prob, 1)

;;;PLOT
  res = True  
  ;----------------页面控制--------------------
  res@gsnMaximize = True
  res@gsnFrame             = False
  res@gsnDraw              = False     ; don't draw plot yet， 避免plot = 之后再draw，画两张图；有叠加的时候使用
  mpres = res ; add map_plot

  res@cnInfoLabelOn        = False            ; turn on/off cn info label
  res@lbLabelBarOn         = True            ; turn on/off individual cb's
  res@cnFillOn             = True
  res@gsnAddCyclic=False

  ;;;;------------------------------ 等值线标注
  res@cnLineLabelsOn       = False
  ; res@cnLineLabelInterval = 2
  res@cnLineLabelPlacementMode = "Computed"
  res@cnLineLabelDensityF = 1.5
  res@cnLinesOn            = False ;填色线条 
  ; res@cnLineLabelPlacementMode = "Constant"

;-------------------------------------------------------地图区域设置——中国区域res@mp
  mpres@mpDataBaseVersion = "Ncarg4_1"   ;地图采用中等分辨率
  ; mpres@mpDataSetName="Earth..4"
  ; /m2data2/yycheng/playground/NCL-noob-s-practices/till2020.06/NCL-Chinamap-master
  mpres@mpDataSetName = "/m2data2/yycheng/playground/NCL-noob-s-practices/till2020.06/NCL-Chinamap-master/database/Earth..4" ; 使用大气所的dataset数据
  mpres@mpOutlineOn=True
  mpres@mpOutlineSpecifiers=(/"China","Taiwan"/)
  mpres@mpCountyLineThicknessF = 10
  ; mpres@mpOutlineSpecifiers=
  mpres@mpFillOn=False
;-------------------------------------------------------变量/x/y/刻度设置  
;   res@pmTickMarkDisplayMode = "Always"
  mpres@mpMinLatF=15
  mpres@mpMaxLatF=55

  mpres@mpMinLonF=70
  mpres@mpMaxLonF=140

  mpres@gsnMajorLatSpacing = 10              ; change maj lat tm spacing
  mpres@gsnMajorLonSpacing = 10              ; change maj lon tm spacing
  mpres@gsnMinorLatSpacing = 2
  mpres@gsnMinorLonSpacing = 2

  mpres@mpGridAndLimbOn=True             ;设置经纬线
  mpres@mpGridLineThicknessF=0.5
  mpres@mpGridLineDashPattern=2
  mpres@mpGridSpacingF=10
    
  ;-------------------------------------------------------地图标题设置
                
  ; res@gsnCenterString = "MPAS simulation TPEMIP 4-8"
  ; res@tiMainString    = "MEAN TEMPERATURE AT 2M HEIGHT"
  ; res@gsnCenterStringFontHeightF = 0.02  
  ; res@pmTickMarkDisplayMode = "Always" ;坐标标签上添加 度 符号(未起作用)
  res@gsnLeftString = "" ;不绘制左标题
  res@gsnRightString= "" ;不绘制右标题

;--------------------等值线设置----------------------

  res@lbOrientation = "Vertical" ; 把色板垂直地移动 
  res@cnLevelSelectionMode = "ManualLevels" ;等间隔地指定等值线范围
  ; ---- add for other vars
  resc = res ; for difference
  res_error = res
  ; res@cnFillPalette         = "precip2_17lev"; 

  res@cnFillPalette         = "temp_19lev"; 
  res@cnMinLevelValF = -10.
  res@cnMaxLevelValF = 26.
  res@cnLevelSpacingF = 2 ;等值线间隔

  resc@lbOrientation = "Vertical" ; 把色板垂直地移动 
  resc@cnFillPalette         = "temp_diff_18lev"
  resc@cnMinLevelValF = 0.
  resc@cnMaxLevelValF = 8.
  resc@cnLevelSpacingF = 0.5 ;等值线间隔
  

  res_error@lbOrientation = "Vertical" ; 把色板垂直地移动 
  res_error@cnFillPalette         = "temp_diff_18lev"
  res_error@cnMinLevelValF = -5.
  res_error@cnMaxLevelValF = 5.
  res_error@cnLevelSpacingF = 0.5 ;等值线间隔
  


;----------------------------prob 显著性检验 res设置---------------------------------
;--------------For p<0.05, fill using MonoPattern and Monocolor----------------------
  res_prob = True                                  ; res3 for probability plot
  res_prob@gsnDraw             = False       ; Do not draw plot
  res_prob@gsnFrame            = False       ; Do not advance frome
  res_prob@cnInfoLabelOn       = False       ; turn off info label
  res_prob@cnLinesOn           = False       ; do not draw contour lines
  res_prob@cnLineLabelsOn      = False       ; do not draw contour labels
  res_prob@lbLabelBarOn        = False       ; do not need lable bar for prob 
  res_prob@cnLevelSelectionMode = "ExplicitLevels" 
  res_prob@cnLevels = (/0.05/) 
  res_prob@cnFillOn = True 
  res_prob@cnMonoFillPattern = False  ; only one pattern
  res_prob@cnFillDrawOrder="postDraw"      
  ; res_prob@cnFillPattern = 6         ; stipple dot fill pattern
  ; res_prob@cnMonoFillColor = False
  ; res_prob@cnFillColor   = "black"
  res_prob@cnFillScaleF  = 0.5     ; default is 1, larger is corse, lower is dense
  ; res_prob@cnFillPatterns       = (/-1,17/)     ; the patterns 
  res_prob@cnFillPatterns       = (/17, -1/)     ; the patterns 

  res_prob@cnMonoFillScale      = False            ; want different densities                                                            
  res_prob@cnFillScales         = (/1,1/)    ; change densities                                                                        
  res_prob@cnMonoFillColor      =True                                                                                                     
  res_prob@cnFillDotSizeF       = 0.003


;------------------------------plot------------------------------
  do i=0,fignum-1,1
  plot(i) = gsn_csm_map(wks, mpres)
  end do
  
  res@gsnCenterString    = "CN05.1"
  overlay(plot(0),gsn_csm_contour(wks, pre_cn051_mean, res))
  res@gsnCenterString    = "VR"
  overlay(plot(1),gsn_csm_contour(wks, pre_vr_mean, res))
  res@gsnCenterString    = "RCM"
  overlay(plot(2),gsn_csm_contour(wks, pre_rcm_mean, res))

  ; resc@gsnCenterString    = "VR RMSD"
  ; overlay(plot(3),gsn_csm_contour(wks, vr_rmsd_cn051, resc))
  ; overlay(plot(3),gsn_csm_contour(wks, vr_prob, res_prob))
  ; resc@gsnCenterString    = "RCM RMSD"
  ; overlay(plot(4),gsn_csm_contour(wks, rcm_rmsd_cn051, resc))
  ; overlay(plot(4),gsn_csm_contour(wks, rcm_prob, res_prob))

  ; res@cnLevelSelectionMode = "ManualLevels" ;等间隔地指定等值线范围
  ; res_error@cnMaxLevelValF =  5.0
  ; res_error@cnMinLevelValF = -5.0
  ; res_error@cnLevelSpacingF = 0.5
  res_error@gsnCenterString    = "VR - CN05.1"
  overlay(plot(3),gsn_csm_contour(wks, vr_error_cn051, res_error))
  overlay(plot(3), gsn_csm_contour(wks, vr_prob, res_prob))
  res@gsnCenterString    = "RCM - cn05.1"
  overlay(plot(4),gsn_csm_contour(wks, rcm_error_cn051, res_error))
  overlay(plot(4), gsn_csm_contour(wks, rcm_prob, res_prob))

;;;-----------------------add shape file ----------------------------------
plot_new_for_shape = new(fignum, graphic)
do i = 0,fignum-1,1
  ; print(i)
  plres             = True           ; resource list for polylines
  plres@gsLineColor = "blue"
  shapefile_path = "/raid52/yycheng/MPAS/REFERENCE/MODEL_CONSTANT/R1/" + "hyd1_4l.shp"
  plot_new_for_shape(i) = gsn_add_shapefile_polylines(wks, plot(i), shapefile_path ,plres)
end do
;;;;--------------------------panel seeting---------------------------------
  pres = True
  pres@txString              = "2003-2015" + " mean " 
  ; pres@gsnPanelLabelBar      = False ; 公用一个色标
  ; pres@gsnPanelMainFontHeightF = 0.0002
  ; pres@gsnPanelFigureStrings = (/"","4","4","4","5","5","5","6","6","6","7","7","7","8","8","8","M","M","M"/)
  ; pres@amJust                = "TopLeft" ;调整标签顺序
  pres@gsnPanelRowSpec       = True
  gsn_panel(wks,plot,(/1, 2, 2/),pres)


end