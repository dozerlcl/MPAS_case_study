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

load "./shapefile_utils.ncl"
begin

;;;>>>plot set
  fignum = 16
  plot = new(fignum,graphic) ;定义子图数组
  pictype = "png"
  ; wks_type = "png"
  pictype@wkWidth = 3000
  pictype@wkHeight = 3000
  wks = gsn_open_wks(pictype,"./output_pic/"+"precip_98-17_rainday")
;;;>>>data reader
  diri = "/m2data2/yycheng/playground/MPAS_case_study/92-25km_vr_rcm_postprocess/visualization/check_obs/settled/pre/space/output_nc/"
  fili = "rainday_mean.nc"
  ; am
  ncdf = addfile(diri + fili, "r") ; c表示创建netcdf文件
  ; am
  am_cn051_rainday            =  ncdf->$"am_cn051_rainday"$      
  am_cn051_rainday_intensity  = ncdf->$"am_cn051_intensity"$   
  am_cmorph_rainday           = ncdf->$"am_cmorph_rainday"$     
  am_cmorph_rainday_intensity = ncdf->$"am_cmorph_intensity"$   
  am_vr_rainday               = ncdf->$"am_vr_rainday"$         
  am_vr_rainday_intensity     = ncdf->$"am_vr_intensity"$       
  am_rcm_rainday              = ncdf->$"am_rcm_rainday"$        
  am_rcm_rainday_intensity    = ncdf->$"am_rcm_intensity"$     
  ; jja
  jja_cn051_rainday            =  ncdf->$"jja_cn051_rainday"$      
  jja_cn051_rainday_intensity  = ncdf->$"jja_cn051_intensity"$   
  jja_cmorph_rainday           = ncdf->$"jja_cmorph_rainday"$     
  jja_cmorph_rainday_intensity = ncdf->$"jja_cmorph_intensity"$   
  jja_vr_rainday               = ncdf->$"jja_vr_rainday"$         
  jja_vr_rainday_intensity     = ncdf->$"jja_vr_intensity"$       
  jja_rcm_rainday              = ncdf->$"jja_rcm_rainday"$        
  jja_rcm_rainday_intensity    = ncdf->$"jja_rcm_intensity"$     

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
  res@lbTitleString = "day/month"
  res@lbBoxMinorExtentF = 0.15
  res@lbLabelStride = 1
  res@lbLabelAutoStride = False
  res@lbLabelFontHeightF = 0.015
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

;--------------------等值线设置----------------------
  resc = res ; for difference
  res@lbOrientation = "Vertical" ; 把色板垂直地移动 
  ; res@cnLevelSelectionMode = "ManualLevels" ;等间隔地指定等值线范围
  res@cnLevelSelectionMode  = "ExplicitLevels"
  res@cnFillPalette         = "precip2_17lev"; 
  ; res@cnLevels              = (/-5,-4,-3,-2,-1, 0, 2, 4, 6, 8, 10, 12, 16, 18, 22/)
  ; res@cnFillColors  = ispan(0, 17, 1)   
  res_error = res
  res@cnLevels          = (/1,5,10,15,20,25,28,30/); -1 为透明
  ; res@cnLevels          = (/1,2,3,4,5,10/); -1 为透明
  ; res@cnMinLevelValF = 0.
  ; res@cnMaxLevelValF = 33.
  ; res@cnLevelSpacingF = 3. ;等值线间隔
  ; res_error@cnLevelSelectionMode = "ManualLevels" ;等间隔地指定等值线范围
  res_error@cnLevelSelectionMode  = "ExplicitLevels"
  ; res_error@cnFillPalette         = "precip4_diff_19lev"
  res_error@cnFillPalette         = "precip2_17lev"; 
  ; res_error@cnFillPalette         = "precip_diff_12lev"
  ; res_error@cnFillPalette         = "BlueDarkOrange18"
  ; res_error@cnLinesOn = True
  ; res@cnLevelSelectionMode = "ManualLevels" ;等间隔地指定等值线范围
  ; res_error@cnMaxLevelValF = 16
  ; res_error@cnMinLevelValF = 0.
  ; res_error@cnLevelSpacingF = 2.
  res_error@cnLevels          = (/0, 2, 4, 6, 8, 10, 12, 14, 20/); 
  ; res_error@cnLevels          = (/0,1,2,3,4/); 
  res_error@lbTitleString = "mm/rainday"



;------------------------------plot------------------------------
  do i=0,fignum-1,1
    plot(i) = gsn_csm_map(wks, mpres)
  end do
  ; print(vr_space_coef)
  ; print(rcm_space_coef)
  ;-----am part mean-----
  res@gsnCenterString    = "CN05.1"
  res@gsnRightString     = "AM rainday"
  overlay(plot(0),gsn_csm_contour(wks, am_cn051_rainday, res))
  res@gsnCenterString    = "COMRPH"
  overlay(plot(1),gsn_csm_contour(wks, am_cmorph_rainday, res))
  res@gsnCenterString    = "VR"
  overlay(plot(2),gsn_csm_contour(wks, am_vr_rainday, res))
  res@gsnCenterString    = "RCM"
  overlay(plot(3),gsn_csm_contour(wks, am_rcm_rainday, res))
  ;-----jja part mean-----
  res@gsnCenterString    = "CN05.1"
    res@gsnRightString    = "JJA rainday"
  overlay(plot(4),gsn_csm_contour(wks, jja_cn051_rainday, res))
  res@gsnCenterString    = "COMRPH"
  overlay(plot(5),gsn_csm_contour(wks, jja_cmorph_rainday, res))
  res@gsnCenterString    = "VR"
  overlay(plot(6),gsn_csm_contour(wks, jja_vr_rainday, res))
  res@gsnCenterString    = "RCM"
  overlay(plot(7),gsn_csm_contour(wks, jja_rcm_rainday, res))

  ;-----am part difference-----
  
  res_error@gsnCenterString    = "CN05.1"
  res_error@gsnRightString    = "AM rainday intensity"
  overlay(plot(8),gsn_csm_contour(wks, am_cn051_rainday_intensity, res_error))
  
  res_error@gsnCenterString    = "CMORPH"
  overlay(plot(9),gsn_csm_contour(wks, am_cmorph_rainday_intensity, res_error))
  
  res_error@gsnCenterString    = "VR"
  overlay(plot(10),gsn_csm_contour(wks, am_vr_rainday_intensity, res_error))

  res_error@gsnCenterString    = "RCM"
  overlay(plot(11),gsn_csm_contour(wks, am_rcm_rainday_intensity, res_error))
  ;-----jja part difference-----
  res_error@gsnRightString    = "JJA rainday intensity"
  res_error@gsnCenterString    = "CN05.1"
  overlay(plot(12),gsn_csm_contour(wks, jja_cn051_rainday_intensity, res_error))
  
  res_error@gsnCenterString    = "CMORPH"
  overlay(plot(13),gsn_csm_contour(wks, jja_cmorph_rainday_intensity, res_error))

  res_error@gsnCenterString    = "VR"
  overlay(plot(14),gsn_csm_contour(wks, jja_vr_rainday_intensity, res_error))

  res_error@gsnCenterString    = "RCM"
  overlay(plot(15),gsn_csm_contour(wks, jja_rcm_rainday_intensity, res_error))

;;;-----------------------add shape file ----------------------------------

plot_new_for_shape = new(8, graphic)
do i = 0,7,1
  plres             = True           ; resource list for polylines
  plres@gsLineColor = "blue"
  shapefile_path = "/raid52/yycheng/MPAS/REFERENCE/MODEL_CONSTANT/R1/" + "hyd1_4l.shp"
  plot_new_for_shape(i) = gsn_add_shapefile_polylines(wks, plot(i), shapefile_path ,plres)
end do


;;;;--------------------------panel seeting---------------------------------
  pres = True
  pres@txString              = "1998-2017" + "rainday and intensity" 
  ; pres@gsnPanelLabelBar      = False ; 公用一个色标
  ; pres@gsnPanelMainFontHeightF = 0.0002
  pres@gsnPanelFigureStringsFontHeightF = 0.01
  pres@gsnPanelFigureStrings = (/"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s"/)
  ; pres@amJust                = "TopLeft" ;调整标签顺序
  pres@gsnPanelRowSpec       = True
  gsn_panel(wks,plot,(/4, 4, 4, 4/),pres)


end