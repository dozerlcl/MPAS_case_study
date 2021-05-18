;;; 21.03.05
;;;     修改为进行CN05.1 CMORPH 的降水后处理的读取文件
;;;     在 TEMP_DATA下先进行的了 mask 处理
;;;     处理的 ncl脚本（其中顺带使用了 cdo 命令） 在 ../precip_preprocess/ncl_mask.ncl 文件之中
;;; 21.03.18
;;;   修改绘图方式，将 gsn_csm_contour overlay到 map上，需要单独绘制每个map，为之后的统计检验做准备
;;;   进行均值差异的 t 检验
;;; 21.04.07
;;;   指绘制平均图的差异,添加shapefile,是我国一级河流的shp文件
;;; 21.04.21
;;;   添加输出的pictype，修改输出文件名为bias_test
;;; 21.05.12
;;;   将原本的计算绘图的脚本拆分为两份，此为part2绘图部分
;;;   修改为 am 和 jja两部分的绘图
;;; 21.05.13
;;;   修改了绘图顺序 CN05.1 CMORPH VR RCM 之后为了读数据的方便都默认使用这个顺序
;;;   修改到T2M的绘图，舍弃cmorph
;;; 21.05.16
;;;   添加最高最低温度的绘制，稍微修改绘制的温度范围以及题图


load "./shapefile_utils.ncl"
begin

;;;>>>plot set
  fignum = 10
  plot = new(fignum,graphic) ;定义子图数组
  pictype = "png"
  ; wks_type = "png"
  pictype@wkWidth = 3000
  pictype@wkHeight = 3000
  wks = gsn_open_wks(pictype,"./output_pic/"+"t2m_98-17_mean_bias_ttest")
;;;>>>data reader
  diri = "/m2data2/yycheng/playground/MPAS_case_study/92-25km_vr_rcm_postprocess/visualization/check_obs/settled/t2m/space/output_nc/"
  fili = "mean_ttest_bias.nc"
  ; am
  ncdf = addfile(diri + fili, "r") ; c表示创建netcdf文件
  am_cn051_mean  = ncdf->$"am_cn051_mean"$
  am_vr_mean     = ncdf->$"am_vr_mean"$
  am_rcm_mean    = ncdf->$"am_rcm_mean"$
  am_vr_prob     = ncdf->$"am_vr_prob"$
  am_rcm_prob    = ncdf->$"am_rcm_prob"$
  am_vr_error_cn051   =  ncdf->$"am_vr_error_cn051"$
  am_rcm_error_cn051  =  ncdf->$"am_rcm_error_cn051"$
  ; 作为leftstring的统计量
  am_vr_cn051_rmsd  = ncdf->$"am_vr_cn051_rmsd"$
  am_rcm_cn051_rmsd = ncdf->$"am_rcm_cn051_rmsd"$
  am_vr_cn051_coef  = ncdf->$"am_vr_cn051_coef"$
  am_rcm_cn051_coef = ncdf->$"am_rcm_cn051_coef"$

  ; jja
  jja_cn051_mean  = ncdf->$"jja_cn051_mean"$ 
  jja_vr_mean     = ncdf->$"jja_vr_mean"$
  jja_rcm_mean    = ncdf->$"jja_rcm_mean"$
  jja_vr_prob     = ncdf->$"jja_vr_prob"$
  jja_rcm_prob    = ncdf->$"jja_rcm_prob"$
  jja_vr_error_cn051   =  ncdf->$"jja_vr_error_cn051"$
  jja_rcm_error_cn051  =  ncdf->$"jja_rcm_error_cn051"$


  ; 作为leftstring的统计量
  jja_vr_cn051_rmsd  = ncdf->$"jja_vr_cn051_rmsd"$
  jja_rcm_cn051_rmsd = ncdf->$"jja_rcm_cn051_rmsd"$
  jja_vr_cn051_coef  = ncdf->$"jja_vr_cn051_coef"$
  jja_rcm_cn051_coef = ncdf->$"jja_rcm_cn051_coef"$

;;;-----count abs error-----


;;;-----PLOT------
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
  ; res@gsnCenterString    = "MEAN TEMPERATURE AT 2M HEIGHT"
  ; res@gsnCenterStringFontHeightF = 0.02  
  ; res@pmTickMarkDisplayMode = "Always" ;坐标标签上添加 度 符号(未起作用)
  res@gsnLeftString = "" ;不绘制左标题
  res@gsnRightString= "" ;不绘制右标题
  res@gsnLeftStringOrthogonalPosF   = 0.025
  res@gsnRightStringOrthogonalPosF  = 0.025
  res@gsnCenterStringOrthogonalPosF = 0.025
  res@gsnCenterStringFontHeightF    = 0.03
  res@gsnLeftStringFontHeightF      = 0.020
  res@gsnRightStringFontHeightF     = 0.020

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
  res@lbOrientation = "Vertical" ; 把色板垂直地移动 
  res@cnLevelSelectionMode = "ManualLevels" ;等间隔地指定等值线范围
  ; res@cnLevelSelectionMode  = "ExplicitLevels"
  res@cnFillPalette   = "MPL_rainbow" 
  ; res@cnLevels              = (/-5,-4,-3,-2,-1, 0, 2, 4, 6, 8, 10, 12, 16, 18, 22/)
  ; res@cnFillColors  = ispan(0, 17, 1)   
  res_error = res
  res_error@lbLabelStride = 1
  ; res@cnLevels          = (/1,2,3,4,5,6,7,8,9,10,15,20,25/); -1 为透明
  res@cnMinLevelValF = -15. ; mean
  res@cnMaxLevelValF = 30.  ; mean
  res@cnLevelSpacingF = 2   ; mean
  ; res@cnMinLevelValF = 0. ; max
  ; res@cnMaxLevelValF = 40.  ; max
  ; res@cnLevelSpacingF = 2   ; max
  ; res_error@cnLevelSelectionMode = "ManualLevels" ;等间隔地指定等值线范围
  res_error@cnLevelSelectionMode  = "ExplicitLevels"

  res_error@cnFillPalette         = "BlueDarkOrange18"

  res_error@cnLevels          = (/-10,-5, -4, -3, -2, -1, 0, 1, 2 ,3, 4, 5,10/); -1 为透明


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
  res_prob@cnLevels = (/0.01/) 
  res_prob@cnFillOn = True 
  res_prob@cnMonoFillPattern = False  ; only one pattern
  res_prob@cnFillDrawOrder="postDraw"      
  ; res_prob@cnFillPattern = 6         ; stipple dot fill pattern
  ; res_prob@cnMonoFillColor = False
  ; res_prob@cnFillColor   = "black"
  res_prob@cnFillScaleF  = 0.2     ; default is 1, larger is corse, lower is dense
  ; res_prob@cnFillPatterns       = (/-1,17/)     ; the patterns 
  res_prob@cnFillPatterns       = (/6, -1/)     ; the patterns 

  res_prob@cnMonoFillScale      = False            ; want different densities                                                            
  res_prob@cnFillScales         = (/0.5, 1/)    ; change densities                                                                        
  res_prob@cnMonoFillColor      =True                                                                                                     
  res_prob@cnFillDotSizeF       = 0.002


;------------------------------plot------------------------------
  do i=0,fignum-1,1
    plot(i) = gsn_csm_map(wks, mpres)
  end do
  ; print(vr_space_coef)
  ; print(rcm_space_coef)
  ;-----am part mean-----
  res@gsnRightString     = "AM"
  res@gsnCenterString    = "CN05.1"
  overlay(plot(0),gsn_csm_contour(wks, am_cn051_mean, res))
  res@gsnCenterString    = "VR"
  overlay(plot(1),gsn_csm_contour(wks, am_vr_mean, res))
  res@gsnCenterString    = "RCM"
  overlay(plot(2),gsn_csm_contour(wks, am_rcm_mean, res))
  ;-----jja part mean-----
  res@gsnRightString    = "JJA"
  res@gsnCenterString    = "CN05.1"
  overlay(plot(3),gsn_csm_contour(wks, jja_cn051_mean, res))
  res@gsnCenterString    = "VR"
  overlay(plot(4),gsn_csm_contour(wks, jja_vr_mean, res))
  res@gsnCenterString    = "RCM"
  overlay(plot(5),gsn_csm_contour(wks, jja_rcm_mean, res))

  ;-----am part difference-----
  res_error@gsnRightString    = "AM"
    
  res_error@gsnCenterString    = "(VR - CN05.1)"
    res_error@gsnLeftString   = "coef=" + sprintf("%5.3f", am_vr_cn051_coef)\
 + " " + "rmsd=" + sprintf("%5.3f", am_vr_cn051_rmsd)
  overlay(plot(6),gsn_csm_contour(wks, am_vr_error_cn051, res_error))
  overlay(plot(6), gsn_csm_contour(wks, am_vr_prob, res_prob))

  res_error@gsnCenterString    = "(RCM - CN05.1)"
  res_error@gsnLeftString   = "coef=" + sprintf("%5.3f", am_rcm_cn051_coef)\
+ " " + "rmsd=" + sprintf("%5.3f", am_rcm_cn051_rmsd)
  overlay(plot(7),gsn_csm_contour(wks, am_rcm_error_cn051, res_error))
  overlay(plot(7), gsn_csm_contour(wks, am_rcm_prob, res_prob))
  ;-----jja part difference-----
    res_error@gsnRightString    = "JJA"
  res_error@gsnCenterString    = "(VR - CN05.1)"
    res_error@gsnLeftString   = "coef=" + sprintf("%5.3f", jja_vr_cn051_coef)\
 + " " + "rmsd=" + sprintf("%5.3f", jja_vr_cn051_rmsd)
  overlay(plot(8),gsn_csm_contour(wks, jja_vr_error_cn051, res_error))
  overlay(plot(8), gsn_csm_contour(wks, jja_vr_prob, res_prob))

  res_error@gsnCenterString    = "(RCM - CN05.1)"
  res_error@gsnLeftString   = "coef=" + sprintf("%5.3f", jja_rcm_cn051_coef)\
+ " " + "rmsd=" + sprintf("%5.3f", jja_rcm_cn051_rmsd)
  overlay(plot(9),gsn_csm_contour(wks, jja_rcm_error_cn051, res_error))
  overlay(plot(9), gsn_csm_contour(wks, jja_rcm_prob, res_prob))

;;;-----------------------add shape file ----------------------------------

plot_new_for_shape = new(fignum, graphic)
do i = 0,fignum - 1,1
  plres             = True           ; resource list for polylines
  plres@gsLineColor = "blue"
  shapefile_path = "/raid52/yycheng/MPAS/REFERENCE/MODEL_CONSTANT/R1/" + "hyd1_4l.shp"
  plot_new_for_shape(i) = gsn_add_shapefile_polylines(wks, plot(i), shapefile_path ,plres)
end do


;;;;--------------------------panel seeting---------------------------------
  pres = True
  pres@txString              = "1998-2017" + " mean and ttest" 
  ; pres@gsnPanelLabelBar      = False ; 公用一个色标
  ; pres@gsnPanelMainFontHeightF = 0.0002
  pres@gsnPanelFigureStringsFontHeightF = 0.01
  pres@gsnPanelFigureStrings = (/"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s"/)
  ; pres@amJust                = "TopLeft" ;调整标签顺序
  pres@gsnPanelRowSpec       = True
  gsn_panel(wks,plot,(/3, 3, 2, 2/),pres)


end