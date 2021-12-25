;;; 21.03.05
;;;     修改为进行CN05.1 CMORPH 的降水后处理的读取文件
;;;     在 TEMP_DATA下先进行的了 mask 处理
;;;     处理的 ncl脚本（其中顺带使用了 cdo 命令） 在 ../precip_preprocess/ncl_mask.ncl 文件之中
;;; 21.03.18
;;;   修改绘图方式，将 gsn_csm_contour overlay到 map上，需要单独绘制每个map，为之后的统计检验做准备
;;;   进行均值差异的 t 检验
;;; 21.03.08
;;;   进行空间相关系数的绘制，以及 r test
begin

;;;>>>env var set
  ; sel_month = getenv("selmonth")
  pvalue = 0.01

;;;>>>plot set
  fignum = 2
  plot = new(fignum,graphic) ;定义子图数组
  wks = gsn_open_wks("png","./output_pic/"+"t2m_03-15_cor_rtest")
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

  f = addfile(dir_rcm + filename_rcm, "r") 
  pre_rcm  = f->$"t2m"$
;;;-----select months------

  ; time_dt = cd_calendar(pre_vr&Time, 0)
  ; sel_month_inds = ind(time_dt(:,1).eq.sel_month)
  pre_cn051_selmonth = pre_cn051(:, :, :)
  pre_vr_selmonth    = pre_vr(:, :, :)
  pre_rcm_selmonth   = pre_rcm(:, :, :)
  delete(pre_cn051)
  delete(pre_vr)
  delete(pre_rcm)
  pre_cn051 = pre_cn051_selmonth
  pre_vr = pre_vr_selmonth
  pre_rcm = pre_rcm_selmonth
;;;-----count corr-----

  cor_vr  = escorc_n(pre_vr,  pre_cn051, 0, 0)
  cor_rcm = escorc_n(pre_rcm, pre_cn051, 0, 0)
  copy_VarCoords(pre_cn051(0,:,:), cor_vr)
  copy_VarCoords(pre_cn051(0,:,:), cor_rcm)
  dims_vr = dimsizes(pre_vr)
  ; add mask
  cor_vr = where(ismissing(pre_cn051(0,:,:)), cor_vr@_FillValue, cor_vr)
  cor_rcm= where(ismissing(pre_cn051(0,:,:)), cor_rcm@_FillValue, cor_rcm)

  ; rtest
  cor_vr_prob = rtest(cor_vr, dims_vr(0), 0)
  cor_rcm_prob = rtest(cor_rcm, dims_vr(0), 0)
  copy_VarCoords(pre_cn051(0,:,:), cor_vr_prob)
  copy_VarCoords(pre_cn051(0,:,:), cor_rcm_prob)
  cor_vr_prob = where(ismissing(pre_cn051(0,:,:)), 999, cor_vr_prob)
  cor_rcm_prob= where(ismissing(pre_cn051(0,:,:)), 999, cor_rcm_prob)



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
  ;;;
                
  ; res@gsnCenterString = "MPAS simulation TPEMIP 4-8"
  ; res@tiMainString    = "MEAN TEMPERATURE AT 2M HEIGHT"
  ;   res@gsnCenterStringFontHeightF = 0.02  
  ;   res@pmTickMarkDisplayMode = "Always" ;坐标标签上添加 度 符号(未起作用)
  res@gsnLeftString = "" ;不绘制左标题
  res@gsnRightString= "" ;不绘制右标题

;--------------------等值线设置----------------------
  resc = res ; for difference
  res@lbOrientation = "Vertical" ; 把色板垂直地移动 
  res@cnLevelSelectionMode = "ManualLevels" ;等间隔地指定等值线范围
  res@cnFillPalette         = "precip2_17lev"; 

  ; res@cnFillPalette         = "temp_19lev"; 
  ; res@cnFillPalette         = "wind_17lev"; 
  ; res@cnFillPalette         = "hotcolr_19lev";
  ; res@cnFillPalette         = "srip_reanalysis";
  res@cnMinLevelValF = 0.
  res@cnMaxLevelValF = 15.
  res@cnLevelSpacingF = 1 ;等值线间隔

  resc@lbOrientation = "Vertical" ; 把色板垂直地移动 
  resc@cnLevelSelectionMode  = "ManualLevels" ;等间隔地指定等值线范围
  resc@cnFillPalette         = "temp_19lev"; 
  ; resc@cnFillPalette         = "precip4_diff_19lev"

  resc@cnMaxLevelValF = 1.
  resc@cnMinLevelValF = 0.3
  resc@cnLevelSpacingF = 0.05 ;等值线间隔 

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
  res_prob@cnLevels = (/pvalue/) 
  res_prob@cnFillOn = True 
  res_prob@cnMonoFillPattern = False  ; only one pattern
  res_prob@cnFillDrawOrder="postDraw"      
  ; res_prob@cnFillPattern = 6         ; stipple dot fill pattern
  ; res_prob@cnMonoFillColor = False
  ; res_prob@cnFillColor   = "black"
  res_prob@cnFillScaleF  = .5     ; default is 1, larger is corse, lower is dense
  res_prob@cnFillPatterns       = (/17, -1/)     ; the patterns 
  ; res_prob@cnFillPatterns       = (/-1, 17/)     ; the patterns 

  res_prob@cnMonoFillScale      = False            ; want different densities                                                            
  res_prob@cnFillScales         = (/0.5,1/)    ; change densities                                                                        
  res_prob@cnMonoFillColor      =True                                                                                                     
  res_prob@cnFillDotSizeF       = 0.0010


;------------------------------plot------------------------------
  do i=0,fignum-1,1
  plot(i) = gsn_csm_map(wks, mpres)
  end do
  
  res@gsnCenterString    = "VR"
  overlay(plot(0),gsn_csm_contour(wks, cor_vr, resc))
  overlay(plot(0),gsn_csm_contour(wks, cor_vr_prob, res_prob))
  res@gsnCenterString    = "RCM"
  overlay(plot(1),gsn_csm_contour(wks, cor_rcm, resc))
  overlay(plot(1),gsn_csm_contour(wks, cor_rcm_prob, res_prob))


;;;;--------------------------panel seeting---------------------------------
  pres = True
  pres@txString              = "2003-2015" + " mean (CN051)" 
  ; pres@gsnPanelLabelBar      = False ; 公用一个色标
  ; pres@gsnPanelMainFontHeightF = 0.0002
  ; pres@gsnPanelFigureStrings = (/"","4","4","4","5","5","5","6","6","6","7","7","7","8","8","8","M","M","M"/)
  ; pres@amJust                = "TopLeft" ;调整标签顺序
  pres@gsnPanelRowSpec       = True
  gsn_panel(wks,plot,(/2/),pres)


end