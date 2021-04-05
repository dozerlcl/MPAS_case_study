;   2021.03.27
;   进行风矢量异常的绘制，绘制vector & counter
  
begin
;------------------------------------------------------------
sellevels = (/850/)
plot = new(5,graphic) ;定义子图数组 
wks = gsn_open_wks("png","./output_pic/mean/" + "uvwnd_vector")
;------------------------------------------------------------
do sellevel_ind = 0,0,1
sellevel  = sellevels(sellevel_ind) ; test for loop on one level


;>>> read data
    ; uwind
    ; 为数据读入选取对应的 ERA5I VR RCM的文件名、变量名
    file_in_ref = "sel_uwnd.mon.mean.nc"
    ref_varname = "uwnd"
    vr_varname = "uzonal_"+sellevel+"hPa"
    rcm_varname = "uzonal_"+sellevel+"hPa"
    dir_in_ref  = "/raid52/yycheng/MPAS/REFERENCE/ERA5I_NC/ERA5I_NC_monthy"
    f = addfile(dir_in_ref + "/" + file_in_ref ,"r")
    ref_var_alllevel=f->$ref_varname$ ; every level
    ref_u = ref_var_alllevel(:,{sellevel},:,:) ; specific level
    
    modtype = "VR"
    dir_in_vr   = "/raid52/yycheng/MPAS/"+modtype+"_postprocess/"+modtype+"_merge/diag_mean_mon/"
    file_in_vr  = "monmean_2003-2015"+"_"+modtype+"_diag.nc"

    f = addfile(dir_in_vr + "/" + file_in_vr, "r")
    ; time | 5 对应 4=8 共五个月
    vr_u=f->$vr_varname$
    
    modtype = "RCM"
    dir_in_rcm   = "/raid52/yycheng/MPAS/"+modtype+"_postprocess/"+modtype+"_merge/diag_mean_mon/"
    file_in_rcm  = "monmean_2003-2015"+"_"+modtype+"_diag.nc"

    f = addfile(dir_in_rcm + "/" + file_in_rcm, "r")

    rcm_u=f->$rcm_varname$

    
    ; vwind
    file_in_ref = "sel_vwnd.mon.mean.nc"
    ref_varname = "vwnd"
    vr_varname = "umeridional_"+sellevel+"hPa"
    rcm_varname = "umeridional_"+sellevel+"hPa"

    dir_in_ref  = "/raid52/yycheng/MPAS/REFERENCE/ERA5I_NC/ERA5I_NC_monthy"
    f = addfile(dir_in_ref + "/" + file_in_ref ,"r")
    ref_var_alllevel=f->$ref_varname$ ; every level
    ref_v = ref_var_alllevel(:,{sellevel},:,:) ; specific level
    
    modtype = "VR"
    dir_in_vr   = "/raid52/yycheng/MPAS/"+modtype+"_postprocess/"+modtype+"_merge/diag_mean_mon/"
    file_in_vr  = "monmean_2003-2015"+"_"+modtype+"_diag.nc"

    f = addfile(dir_in_vr + "/" + file_in_vr, "r")
    ; time | 5 对应 4=8 共五个月
    vr_v=f->$vr_varname$
    
    modtype = "RCM"
    dir_in_rcm   = "/raid52/yycheng/MPAS/"+modtype+"_postprocess/"+modtype+"_merge/diag_mean_mon/"
    file_in_rcm  = "monmean_2003-2015"+"_"+modtype+"_diag.nc"

    f = addfile(dir_in_rcm + "/" + file_in_rcm, "r")

    rcm_v=f->$rcm_varname$
; ----------------------------- count mean ----------------------------

    ;;; ave，多年平均
    ref_u_timemean = dim_avg_n_Wrap(ref_u, 0)
    vr_u_timemean = dim_avg_n_Wrap(vr_u, 0)
    rcm_u_timemean = dim_avg_n_Wrap(rcm_u, 0)
    
    ref_v_timemean = dim_avg_n_Wrap(ref_v, 0)
    vr_v_timemean = dim_avg_n_Wrap(vr_v, 0)
    rcm_v_timemean = dim_avg_n_Wrap(rcm_v, 0)
    ;;; 计算风速等值线，是用在overlay
    ref_speed = wind_speed(ref_u_timemean, ref_v_timemean)
    vr_speed  = wind_speed(vr_u_timemean, vr_v_timemean)
    rcm_speed = wind_speed(rcm_u_timemean, rcm_v_timemean)

    ; 直接对风速做差
    vr_speed_error  =  vr_speed - ref_speed
    rcm_speed_error = rcm_speed - ref_speed
    ; printVarSummary(vr_speed)
    copy_VarCoords(vr_speed, vr_speed_error) ; 做差之后注意重新拷贝属性
    copy_VarCoords(rcm_speed, rcm_speed_error)
    ;  计算和观测结果的偏差风
    ; vr_speed_error = wind_speed(vr_u_timemean - ref_u_timemean, vr_v_timemean - ref_v_timemean)
    ; rcm_speed_error = wind_speed(rcm_u_timemean - ref_u_timemean, rcm_v_timemean - ref_v_timemean)
; ----------------------------- temp data --------------------------------

    ; temp_path = "/raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/plot_mean/uv/"
    ; system("rm -f " + temp_path) ;删除目录下的同名文件
    ; ncdf_temp = addfile(temp_path, "c") ; c表示创建netcdf文件
    ; ncdf_temp->ref_u = ref_u_timemean
    ; ncdf_temp->tm_wrf_step1   = 
    ; delete(ncdf_step1)
; ------------------------ PLOT -----------------------

  res = True  
  ;----------------页面控制--------------------
  res@gsnMaximize = True
  res@gsnFrame             = False
  res@gsnDraw              = False     ; don't draw plot yet， 避免plot = 之后再draw，画两张图；有叠加的时候使用
  mpres = res ; add map_plot
; --------------- 矢量图res ---------------------
  res_vect = res
; --------------- 等值线图的一些属性 ------------
  resc = res
  resc@cnInfoLabelOn        = False            ; turn on/off cn info label
  resc@lbLabelBarOn         = True            ; turn on/off individual cb's
  resc@cnFillOn             = True
  resc@gsnAddCyclic=False

;---------------- 等值线标注 --------------------
  
  resc@cnLineLabelsOn       = False
  ; res@cnLineLabelInterval = 2
  resc@cnLineLabelPlacementMode = "Computed"
  resc@cnLineLabelDensityF = 1.5
  resc@cnLinesOn            = False ;填色线条 
  ; res@cnLineLabelPlacementMode = "Constant"
;--------------------等值线设置----------------------
;   resc = res ; for difference
;   res@lbOrientation = "Vertical" ; 把色板垂直地移动 
  resc@cnLevelSelectionMode = "ManualLevels" ;等间隔地指定等值线范围

  resc@cnFillPalette         = "wind_17lev"; 

  resc@cnMinLevelValF = 0.
  resc@cnMaxLevelValF = 20.
  resc@cnLevelSpacingF = 1. ;等值线间隔

  resc@lbOrientation = "Vertical" ; 把色板垂直地移动 

  res_diff = resc
  res_diff@cnFillPalette = "GMT_polar"

  res_diff@cnMinLevelValF = -5.
  res_diff@cnMaxLevelValF = 5.
  res_diff@cnLevelSpacingF = .5 ;等值线间隔

;--------------------地图区域设置——中国区域res@mp ------------------------
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

; ----------------- 矢量图控制 -----------------------


  res_vect@vcLineArrowThicknessF      = 2
  res_vect@vcMinDistanceF             = 0.02
  res_vect@vcRefLengthF               = 0.05

  ;;wind barb resources don't apply
  ;;        res_vect@vcGlyphStyle               = "WindBarb"
  ;;        res_vect@vcWindBarbLineThicknessF   = 5
  ;;        res_vect@vcWindBarbColor            = "Gray40"

  res_vect@vcRefAnnoOn               = True
  res_vect@vcRefMagnitudeF           = 10 
  res_vect@vcRefAnnoString1          = "10"
;   res_vect@vcRefAnnoSide             = "Top"
  res_vect@vcRefAnnoSide             = "Left"
  res_vect@vcRefAnnoZone             = 5

  res_vect@vcRefAnnoString2On        = False
  res_vect@vcRefAnnoPerimOn          = False
  res_vect@vcRefAnnoOrthogonalPosF   = -0.12
  res_vect@vcRefAnnoParallelPosF     = 0.999
;   res_vect@vcRefAnnoBackgroundColor  = "Purple"

  
  res_vect@vcVectorDrawOrder         = "PostDraw"
;   res_vect@gsnRightString            = "Wind"

  

; -------------- exec PLOT func ------------------
  do i=0,5-1,1
  plot(i) = gsn_csm_map(wks, mpres)
  end do
;   map     = gsn_csm_map(wks,mpres)
;   contour = gsn_csm_contour(wks,t,cnres)
  vector_plot  = gsn_csm_vector(wks, ref_u_timemean, ref_v_timemean, res_vect)
  contour_plot = gsn_csm_contour(wks, ref_speed, resc)
  overlay(plot(0), vector_plot)
  overlay(plot(0), contour_plot)
  
  vector_plot  = gsn_csm_vector(wks, vr_u_timemean, vr_v_timemean, res_vect)
  contour_plot = gsn_csm_contour(wks, vr_speed, resc)
  overlay(plot(1), vector_plot)
  overlay(plot(1), contour_plot)

  vector_plot  = gsn_csm_vector(wks, rcm_u_timemean, rcm_v_timemean, res_vect)
  contour_plot = gsn_csm_contour(wks, rcm_speed, resc)
  overlay(plot(2), vector_plot)
  overlay(plot(2), contour_plot)

  vector_plot  = gsn_csm_vector(wks, vr_u_timemean - ref_u_timemean, vr_v_timemean - ref_v_timemean, res_vect)
  contour_plot = gsn_csm_contour(wks, vr_speed_error, res_diff)
  overlay(plot(3), vector_plot)
  overlay(plot(3), contour_plot)

  vector_plot  = gsn_csm_vector(wks, rcm_u_timemean - ref_u_timemean, rcm_v_timemean - ref_v_timemean, res_vect)
  contour_plot = gsn_csm_contour(wks, rcm_speed_error, res_diff)
  overlay(plot(4), vector_plot)
  overlay(plot(4), contour_plot)



end do

;;;;--------------------------panel seeting---------------------------------
  pres = True
  pres@txString              = "2003-2015" + " 850hPa mean" 
  ; pres@gsnPanelLabelBar      = False ; 公用一个色标
  ; pres@gsnPanelMainFontHeightF = 0.0002
  ; pres@gsnPanelFigureStrings = (/"","4","4","4","5","5","5","6","6","6","7","7","7","8","8","8","M","M","M"/)
  ; pres@amJust                = "TopLeft" ;调整标签顺序
  pres@gsnPanelRowSpec       = True
  gsn_panel(wks,plot,(/1, 2, 2/),pres)

end