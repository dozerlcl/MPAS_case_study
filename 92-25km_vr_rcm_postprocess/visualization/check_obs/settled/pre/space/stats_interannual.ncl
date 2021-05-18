;;; 21.03.05
;;;     修改为进行CN05.1 CMORPH 的降水后处理的读取文件
;;;     在 TEMP_DATA下先进行的了 mask 处理
;;;     处理的 ncl脚本（其中顺带使用了 cdo 命令） 在 ../precip_preprocess/ncl_mask.ncl 文件之中
;;; 21.03.18
;;;   修改绘图方式，将 gsn_csm_contour overlay到 map上，需要单独绘制每个map，为之后的统计检验做准备
;;;   进行均值差异的 t 检验
;;; 21.03.08
;;;   进行空间相关系数的绘制，以及 r test
;;; 21.04.05
;;;   将时间拆分为两部分,4-5月以及6-8月,分别计算年际变化,需要事先通过.sh文件使用cdo命令计算年平均的逐个量
;;;   添加 interannual 的 rmsd
begin

;;;>>>env var set
  ; sel_month = getenv("selmonth")

;;;>>>plot set
  fignum = 4
  plot = new(fignum,graphic) ;定义子图数组
  wks = gsn_open_wks("png","./output_pic/"+"pre_98-17_stats_interannual")
;;;>>>data reader
;;;   分开读入 4-5月(am) 以及 6-8月(jja)
  dir_in = "/raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/mask_pre/mask_res_interannual/"
  filename_cn051 = "mask_sel_CN05.1_Pre_1961_2018_daily_025x025.nc"
  
  dir_vr = "/raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/mask_pre/mask_res_interannual/"
  filename_vr = "mask_vr_pre_98-17.nc"
  
  dir_rcm = "/raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/mask_pre/mask_res_interannual/"
  filename_rcm = "mask_rcm_pre_98-17.nc"

  f = addfile(dir_in + "am_" + filename_cn051, "r") 
  cn051_am = f->$"pre"$

  f = addfile(dir_in + "jja_" + filename_cn051, "r") 
  cn051_jja = f->$"pre"$

  f = addfile(dir_in + "am_" + filename_vr, "r") 
  vr_am  = f->$"precip_MPAS"$

  f = addfile(dir_in + "jja_" + filename_vr, "r") 
  vr_jja  = f->$"precip_MPAS"$

  f = addfile(dir_in + "am_" + filename_rcm, "r") 
  rcm_am  = f->$"precip_MPAS"$

  f = addfile(dir_in + "jja_" + filename_rcm, "r") 
  rcm_jja  = f->$"precip_MPAS"$

;;;-----count rmsd-----
;   rmsd_vr_am  = dim_rmsd_n_Wrap(vr_am, cn051_am, 0)
;   rmsd_rcm_am = dim_rmsd_n_Wrap(rcm_am, cn051_am, 0)

;   rmsd_vr_jja = dim_rmsd_n_Wrap(vr_jja, cn051_jja, 0)
;   rmsd_rcm_jja = dim_rmsd_n_Wrap(rcm_jja, cn051_jja, 0)

;;;-----count corr-----

  cor_vr_am  = escorc_n(vr_am,  cn051_am, 0, 0)
  cor_rcm_am = escorc_n(rcm_am, cn051_am, 0, 0)
  copy_VarCoords(cn051_am(0,:,:), cor_vr_am)
  copy_VarCoords(cn051_am(0,:,:), cor_rcm_am)

  cor_vr_jja  = escorc_n(vr_jja,  cn051_jja, 0, 0)
  cor_rcm_jja = escorc_n(rcm_jja, cn051_jja, 0, 0)
  copy_VarCoords(cn051_jja(0,:,:), cor_vr_jja)
  copy_VarCoords(cn051_jja(0,:,:), cor_rcm_jja)

  ; add mask
  cor_vr_am  = where(ismissing(cn051_am(0,:,:)), cor_vr_am@_FillValue, cor_vr_am)
  cor_rcm_am = where(ismissing(cn051_am(0,:,:)), cor_rcm_am@_FillValue, cor_rcm_am)

  cor_vr_jja  = where(ismissing(cn051_jja(0,:,:)), cor_vr_jja@_FillValue, cor_vr_jja)
  cor_rcm_jja = where(ismissing(cn051_jja(0,:,:)), cor_rcm_jja@_FillValue, cor_rcm_jja)

  ; rtest
  dims_vr_am  = dimsizes(vr_am)
  cor_vr_prob_am =  rtest(cor_vr_am, dims_vr_am(0), 0)
  cor_rcm_prob_am = rtest(cor_rcm_am, dims_vr_am(0), 0)
  copy_VarCoords(cn051_am(0,:,:), cor_vr_prob_am)
  copy_VarCoords(cn051_am(0,:,:), cor_rcm_prob_am)
  cor_vr_prob_am  = where(ismissing(cn051_am(0,:,:)), 999, cor_vr_prob_am)
  cor_rcm_prob_am = where(ismissing(cn051_am(0,:,:)), 999, cor_rcm_prob_am)

  dims_vr_jja = dimsizes(vr_jja)
  cor_vr_prob_jja =  rtest(cor_vr_jja, dims_vr_jja(0), 0)
  cor_rcm_prob_jja = rtest(cor_rcm_jja, dims_vr_jja(0), 0)
  copy_VarCoords(cn051_jja(0,:,:), cor_vr_prob_jja)
  copy_VarCoords(cn051_jja(0,:,:), cor_rcm_prob_jja)
  cor_vr_prob_jja  = where(ismissing(cn051_jja(0,:,:)), 999, cor_vr_prob_jja)
  cor_rcm_prob_jja = where(ismissing(cn051_jja(0,:,:)), 999, cor_rcm_prob_jja)

  ; printVarSummary($"cn051_jja"$)
;;;PLOT
  res = True  
  ;----------------页面控制--------------------
  res@gsnMaximize = True
  res@gsnFrame             = False
  res@gsnDraw              = False     ; don't draw plot yet， 避免plot = 之后再draw，画两张图；有叠加的时候使用
  mpres = res ; add map_plot

  res@cnInfoLabelOn        = False            ; turn on/off cn info label
  res@lbLabelBarOn         = False            ; turn on/off individual cb's
  res@cnFillOn             = True
  res@gsnAddCyclic=False

  ;;;;------------------------------ 等值线标注
  res@cnLineLabelsOn       = False
  res@cnLineLabelInterval = 1
  ; res@cnLineLabelPlacementMode = "Computed"
  ; res@cnLineLabelDensityF = 1.5
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
    
  ;--------------地图标题设置---------------     
  ; res@tiMainString = "MPAS simulation TPEMIP 4-8"
  ; res@tiMainString    = "MEAN TEMPERATURE AT 2M HEIGHT"
  ;   res@gsnCenterStringFontHeightF = 0.02  
  ;   res@pmTickMarkDisplayMode = "Always" ;坐标标签上添加 度 符号(未起作用)
  res@gsnLeftString = "" ;不绘制左标题
  res@gsnRightString= "" ;不绘制右标题
;   res@gsnLeftStringOrthogonalPosF   = 0.025
;   res@gsnRightStringOrthogonalPosF  = 0.025
  res@gsnCenterStringOrthogonalPosF = 0.025
  res@gsnCenterStringFontHeightF    = 0.03
;   res@gsnLeftStringFontHeightF      = 0.020
;   res@gsnRightStringFontHeightF     = 0.020
  ;;;;----- 等值线标注 + 等值线色标标签 -----
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
  res@lbTitleString = "degC"
  res@lbBoxMinorExtentF = 0.15
  res@lbLabelStride = 2
  res@lbLabelAutoStride = False
  res@lbLabelFontHeightF = 0.015
;--------------------等值线设置----------------------
  resc = res ; for difference
;   res@lbOrientation = "Vertical" ; 把色板垂直地移动 
;   res@cnLevelSelectionMode = "ManualLevels" ;等间隔地指定等值线范围
;   res@cnFillPalette         = "precip2_17lev"; 
  ; res@cnFillPalette         = "temp_19lev"; 
  ; res@cnFillPalette         = "wind_17lev"; 
  ; res@cnFillPalette         = "hotcolr_19lev";
  ; res@cnFillPalette         = "srip_reanalysis";

;   res@cnMinLevelValF = 0.
;   res@cnMaxLevelValF = 10.
;   res@cnLevelSpacingF = 1 ;等值线间隔
  ; resc seting
;   resc@lbOrientation = "Vertical" ; 把色板垂直地移动 
  resc@cnLevelSelectionMode  = "ManualLevels" ;等间隔地指定等值线范围
;   resc@cnFillPalette         = "BlAqGrWh2YeOrReVi22"; 
  resc@cnFillPalette         = "GHRSST_anomaly"; 
;   resc@cnFillPalette         = "temp_19lev"; 
  ; resc@cnFillPalette         = "precip4_diff_19lev"

  resc@cnMaxLevelValF = 1.
  resc@cnMinLevelValF = -1.
  resc@cnLevelSpacingF = 0.1 ;等值线间隔 

;----------------------------prob 显著性检验 res设置-------------
  ;=========================For p<0.05, fill using MonoPattern and Monocolor==============================
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
  res_prob@cnFillScaleF  = .2     ; default is 1, larger is corse, lower is dense
  res_prob@cnFillPatterns       = (/6, -1/)     ; the patterns 
  ; res_prob@cnFillPatterns       = (/-1, 17/)     ; the patterns 

  res_prob@cnMonoFillScale      = False            ; want different densities                                                            
  res_prob@cnFillScales         = (/0.5,1/)    ; change densities                                                                        
  res_prob@cnMonoFillColor      =True                                                                                                     
  res_prob@cnFillDotSizeF       = 0.002


;------------------------------plot------------------------------
  do i=0,fignum-1,1
  plot(i) = gsn_csm_map(wks, mpres)
  end do
  
  resc@gsnCenterString    = "VR AM COEF"
  overlay(plot(0),gsn_csm_contour(wks, cor_vr_am, resc))
  overlay(plot(0),gsn_csm_contour(wks, cor_vr_prob_am, res_prob))
  resc@gsnCenterString    = "RCM AM COEF"
  overlay(plot(1),gsn_csm_contour(wks, cor_rcm_am, resc))
  overlay(plot(1),gsn_csm_contour(wks, cor_rcm_prob_am, res_prob))
  
  resc@gsnCenterString    = "VR JJA COEF"
  overlay(plot(2),gsn_csm_contour(wks, cor_vr_jja, resc))
  overlay(plot(2),gsn_csm_contour(wks, cor_vr_prob_jja, res_prob))
  resc@gsnCenterString    = "RCM JJA COEF"
  overlay(plot(3),gsn_csm_contour(wks, cor_rcm_jja, resc))
  overlay(plot(3),gsn_csm_contour(wks, cor_rcm_prob_jja, res_prob))

;   res@gsnCenterString    = "VR AM RMSD"
;   overlay(plot(4),gsn_csm_contour(wks, rmsd_vr_am, res) )
;   res@gsnCenterString    = "RCM AM RMSD"
;   overlay(plot(5),gsn_csm_contour(wks, rmsd_rcm_am, res) )
;   res@gsnCenterString    = "VR JJA RMSD"
;   overlay(plot(6),gsn_csm_contour(wks, rmsd_vr_jja, res) )
;   res@gsnCenterString    = "RCM JJA RMSD"
;   overlay(plot(7),gsn_csm_contour(wks, rmsd_rcm_jja, res) )
;;;;--------------------------panel seeting---------------------------------
  pres = True
  pres@txString              = "1998-2017" + " precipitation interannual correlation" 
  pres@gsnPanelLabelBar      = True ; 公用一个色标
  ; pres@gsnPanelMainFontHeightF = 0.0002
  pres@gsnPanelFigureStrings = (/"a","b","c","d"/)
  ; pres@amJust                = "TopLeft" ;调整标签顺序
  pres@gsnPanelRowSpec       = True
    ;;;;----- 等值线标注 + 等值线色标标签 -----
  pres@cnLineLabelsOn       = False
  ; pres@cnLineLabelInterval = 2
  pres@cnLineLabelPlacementMode = "Computed"
  pres@cnLineLabelDensityF = 1.5
  pres@cnLinesOn            = False ;填色线条 
  ; pres@cnLineLabelPlacementMode = "Constant"
  pres@pmLabelBarWidthF = 1.0
  ; pres@pmLabelBarHeightF = 0.7
  pres@lbBoxEndCapStyle = "TriangleBothEnds"
  pres@lbTitleOn = True
  pres@lbTitleFontHeightF = 0.02
  pres@lbTitleString = ""
  pres@lbBoxMinorExtentF = 0.15
  pres@lbLabelStride = 1
  pres@lbLabelAutoStride = False
  pres@lbLabelFontHeightF = 0.015
  gsn_panel(wks,plot,(/2, 2/),pres)


end