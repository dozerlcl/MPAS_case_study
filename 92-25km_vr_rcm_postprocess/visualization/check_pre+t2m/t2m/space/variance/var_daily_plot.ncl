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
load "./shapefile_utils.ncl"
begin

;;;>>>plot set
  fignum = 6
  plot = new(fignum,graphic) ;定义子图数组
  pictype = "png"
  ; wks_type = "png"
  pictype@wkWidth = 3000
  pictype@wkHeight = 3000
  wks = gsn_open_wks(pictype,"./output_pic/"+"daily_t2m_98-17_variance")
;;;>>>data reader
  diri = "/m2data2/yycheng/playground/MPAS_case_study/92-25km_vr_rcm_postprocess/visualization/check_obs/settled/t2m/space/output_nc/"
  ; am
  fili = "am_t2m_variance.nc"
  ncdf = addfile(diri + fili, "r") 
  am_cn051_var  = ncdf->$"cn051"$
  am_vr_var     = ncdf->$"vr"$
  am_rcm_var    = ncdf->$"rcm"$
  ; jja
  fili = "jja_t2m_variance.nc"
  ncdf = addfile(diri + fili, "r") 
  jja_cn051_var  = ncdf->$"cn051"$
  jja_vr_var     = ncdf->$"vr"$
  jja_rcm_var    = ncdf->$"rcm"$


;;;-----PLOT------
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
  ; res@cnFillMode           = "RasterFill"
  res@pmTickMarkDisplayMode       = "always"          ; nicer tick mark labels
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
  ; res@lbBoxEndCapStyle = "TriangleBothEnds"
  ; res@lbTitleOn = True
  ; res@lbTitleFontHeightF = 0.01
  ; res@lbLabelFontHeightF = 0.01
  ; res@lbTitleString = "(mm/day)^2"
  ; res@lbBoxMinorExtentF = 0.15
  ; res@lbLabelStride = 2
  ; res@lbTopMarginF  = 0.5

  ; res@lbLabelAutoStride = False
  ; res@lbLabelFontHeightF = 0.015
;--------------------等值线设置----------------------
  res@lbOrientation = "Vertical" ; 把色板垂直地移动 
  res@cnLevelSelectionMode = "ManualLevels" ;等间隔地指定等值线范围
  res@cnMinLevelValF = 0.
  res@cnMaxLevelValF = 60.
  res@cnLevelSpacingF = 2 ;等值线间隔
  ; res@cnLevelSelectionMode  = "ExplicitLevels"
  ; res@cnFillPalette         = "precip2_17lev"; 
  res@cnFillPalette         = "MPL_gist_ncar"; 
  ; res@cnFillPalette         = "WhiteBlueGreenYellowRed"; 
;   res@cnFillPalette         = "WhiteBlueGreenYellowRed"; 
  ; res@cnLevels              = (/-5,-4,-3,-2,-1, 0, 2, 4, 6, 8, 10, 12, 16, 18, 22/)
  ; res@cnFillColors  = ispan(0, 17, 1)   


;------------------------------plot------------------------------
  do i=0,fignum-1,1
    plot(i) = gsn_csm_map(wks, mpres)
  end do
  ; print(vr_space_coef)
  ; print(rcm_space_coef)
  ;-----am part var-----
  res@gsnRightString     = "AM"
  res@gsnCenterString    = "CN05.1"
  overlay(plot(0),gsn_csm_contour(wks, am_cn051_var, res))
  res@gsnCenterString    = "VR"
  overlay(plot(1),gsn_csm_contour(wks, am_vr_var, res))
  res@gsnCenterString    = "RCM"
  overlay(plot(2),gsn_csm_contour(wks, am_rcm_var, res))
  ;-----jja part var-----

  res@gsnRightString     = "JJA"
  res@gsnCenterString    = "CN05.1"
  overlay(plot(3),gsn_csm_contour(wks, jja_cn051_var, res))
  res@gsnCenterString    = "VR"
  overlay(plot(4),gsn_csm_contour(wks, jja_vr_var, res))
  res@gsnCenterString    = "RCM"
  overlay(plot(5),gsn_csm_contour(wks, jja_rcm_var, res))



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
  pres@txString              = "1998-2017" + "daily t2m variance" 
  pres@gsnPanelLabelBar      = True ; 公用一个色标
  ; pres@lbTitleFontHeightF    = 0.05
  pres@lbTitleOn             = True
  pres@lbTitleString        = "degC"
  ; pres@gsnPanelMainFontHeightF = 0.0002
  pres@lbBoxEndCapStyle = "TriangleBothEnds"
  ; res@lbTitleOn = True
  pres@lbTitleFontHeightF = 0.01
  pres@lbLabelFontHeightF = 0.01
  ; res@lbTitleString = "(mm/day)^2"
  ; res@lbBoxMinorExtentF = 0.15
  pres@lbLabelStride = 2
  pres@lbTopMarginF  = .5
  ; pres@lbBottomMarginF = 1.
  pres@gsnPanelFigureStringsFontHeightF = 0.01
  pres@gsnPanelFigureStrings = (/"a","b","c","d","e","f","g","h"/)
  ; pres@amJust                = "TopLeft" ;调整标签顺序
  pres@gsnPanelRowSpec       = True
  gsn_panel(wks,plot,(/3, 3/),pres)


end