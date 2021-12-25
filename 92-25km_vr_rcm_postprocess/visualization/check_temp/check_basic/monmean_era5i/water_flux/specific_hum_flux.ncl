;   04.14   计算模式输出的 比湿，计算比湿的输送
;           结合降水偏差，和比湿输送一并绘制

begin
;------------------------------------------------------------
sellevels = (/850/)
fignum = 5
;------------------------------------------------------------

sellevel  = sellevels(0) ; test for loop on one level
wks = gsn_open_wks("png","./output_pic/mean/" + "qflux_vector_1998-2017_" + sellevel)
plot = new(fignum,graphic) ;定义子图数组 


;>>> read data
    ; model topo data
    f    = addfile("/raid52/yycheng/MPAS/REFERENCE/MODEL_CONSTANT/model_topo.nc", "r")
    topo = f->$"zgrid"$(:,:,0) 
    ; uwind
    ; 为数据读入选取对应的 ERA5I VR RCM的文件名、变量名

    ;ERA5    
        dir_in_ref  = "/raid52/yycheng/MPAS/REFERENCE/ERA5I_NC/ERA5I_NC_monthy"
        ;uwind
        file_in_ref = "sel_uwnd.mon.mean.nc"
        ref_varname = "uwnd"
        f = addfile(dir_in_ref + "/" + file_in_ref ,"r")
        ref_u=f->$ref_varname$(:,{sellevel},:,:) ; every level
        ;vwind
        file_in_ref = "sel_vwnd.mon.mean.nc"
        ref_varname = "vwnd"
        f = addfile(dir_in_ref + "/" + file_in_ref ,"r")
        ref_v=f->$ref_varname$(:,{sellevel},:,:)
        ;q
        file_in_ref = "sel_shum.mon.mean.nc"
        ref_varname = "shum"
        f = addfile(dir_in_ref + "/" + file_in_ref ,"r")
        ref_q=f->$ref_varname$(:,{sellevel},:,:)
    ;VR
        modtype = "VR"
        dir_in_vr   = "/raid52/yycheng/MPAS/"+modtype+"_postprocess/"+modtype+"_merge/diag_monthly/"
        file_in_vr  = "monmean_98-17"+"_"+modtype+"_diag.nc"
        f = addfile(dir_in_vr + "/" + file_in_vr, "r")
        vr_u=f->$"uzonal_850hPa"$
        vr_v=f->$"umeridional_850hPa"$
        vr_dewpoint=f->$"dewpoint_850hPa"$

    ;RCM
        modtype = "RCM"
        dir_in_rcm   = "/raid52/yycheng/MPAS/"+modtype+"_postprocess/"+modtype+"_merge/diag_monthly/"
        file_in_rcm  = "monmean_98-17"+"_"+modtype+"_diag.nc"
        f = addfile(dir_in_rcm + "/" + file_in_rcm, "r")
        rcm_u=f->$"uzonal_850hPa"$
        rcm_v=f->$"umeridional_850hPa"$
        rcm_dewpoint=f->$"dewpoint_850hPa"$

    


; ----------------------------- count mean ----------------------------
; 使用变量: vr_u vr_v vr_dewpoint rcm..... 计算比湿
;           ref_u ref_v ref_q 作为标准计算 比湿输送 来进行对比
    ; count q
    p_array = new(dimsizes(vr_dewpoint), float) ; new a pressure var
    p_array = 850 * 100 ; Pa
    vr_q    = mixhum_ptd(p_array, vr_dewpoint, -2)
    rcm_q   = mixhum_ptd(p_array, rcm_dewpoint, -2)
    ; count q flux
    era_u_qflux = ref_q * 1000 * ref_u ; ref_q kg/kg needs *1000
    era_v_qflux = ref_q * 1000 * ref_v
    vr_u_qflux  = vr_q  * vr_u
    vr_v_qflux  = vr_q  * vr_v
    rcm_u_qflux = rcm_q * rcm_u
    rcm_v_qflux = rcm_q * rcm_v
    printVarSummary(era_u_qflux)
    printVarSummary(vr_u_qflux)

    ; mean 
    era_u_qflux_mean = dim_avg_n(era_u_qflux, 0)
    era_v_qflux_mean = dim_avg_n(era_v_qflux, 0)
    vr_u_qflux_mean  = dim_avg_n(vr_u_qflux, 0)
    vr_v_qflux_mean  = dim_avg_n(vr_v_qflux, 0)
    rcm_u_qflux_mean = dim_avg_n(rcm_u_qflux, 0)
    rcm_v_qflux_mean = dim_avg_n(rcm_v_qflux, 0)
    era_q_mean       = dim_avg_n(ref_q, 0)*1000
    vr_q_mean        = dim_avg_n(vr_q, 0)
    rcm_q_mean       = dim_avg_n(rcm_q, 0)

    ; bias
    vr_u_bias  = vr_u_qflux_mean - era_u_qflux_mean
    vr_v_bias  = vr_v_qflux_mean - era_v_qflux_mean
    rcm_u_bias = rcm_u_qflux_mean - era_u_qflux_mean
    rcm_v_bias = rcm_v_qflux_mean - era_v_qflux_mean
    vr_q_bias  = vr_q_mean - era_q_mean
    rcm_q_bias = rcm_q_mean - era_q_mean
    ;divergence quit 实在是不太好看
    lat = ref_u&lat
    lon = ref_v&lon

    ; era_div  = uv2dv_cfd(era_u_qflux_mean, era_v_qflux_mean, lat, lon, 2)
    ; vr_div   = uv2dv_cfd(vr_u_qflux_mean, vr_v_qflux_mean, lat, lon, 2)
    ; rcm_div  = uv2dv_cfd(rcm_u_qflux_mean, rcm_v_qflux_mean, lat, lon, 2)

    ; add coords

    copy_VarCoords(ref_u(0,:,:), era_u_qflux_mean)
    copy_VarCoords(ref_u(0,:,:), era_v_qflux_mean)
    copy_VarCoords(ref_u(0,:,:), vr_u_qflux_mean)
    copy_VarCoords(ref_u(0,:,:), vr_v_qflux_mean)
    copy_VarCoords(ref_u(0,:,:), rcm_u_qflux_mean)
    copy_VarCoords(ref_u(0,:,:), rcm_v_qflux_mean)

    ; copy_VarCoords(ref_u(0,:,:), era_div)
    ; copy_VarCoords(ref_u(0,:,:), vr_div)
    ; copy_VarCoords(ref_u(0,:,:), rcm_div)

    copy_VarCoords(ref_u(0,:,:), vr_u_bias)
    copy_VarCoords(ref_u(0,:,:), vr_v_bias)
    copy_VarCoords(ref_u(0,:,:),rcm_u_bias)
    copy_VarCoords(ref_u(0,:,:),rcm_v_bias)

    copy_VarCoords(ref_u(0,:,:), era_q_mean)
    copy_VarCoords(ref_u(0,:,:), vr_q_mean)
    copy_VarCoords(ref_u(0,:,:), rcm_q_mean)
    copy_VarCoords(ref_u(0,:,:), vr_q_bias)
    copy_VarCoords(ref_u(0,:,:), rcm_q_bias)


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

;--------------------等值线设置 resc res_diff----------------------
;---------------- 等值线标注 --------------------
  
  resc@cnLineLabelsOn       = False
  ; res@cnLineLabelInterval = 2
  resc@cnLineLabelPlacementMode = "Computed"
  resc@cnLineLabelDensityF = 1.5
  resc@cnLinesOn            = False ;填色线条 
  ; res@cnLineLabelPlacementMode = "Constant"
;   resc = res ; for difference
;   res@lbOrientation = "Vertical" ; 把色板垂直地移动 
;--------------------等值线跨度 ----------------------
  resc@cnLevelSelectionMode = "ManualLevels" ;等间隔地指定等值线范围
  resc@lbOrientation = "Vertical" ; 把色板垂直地移动 
  res_diff = resc

;   resc@cnFillPalette         = "wind_17lev"; 
  resc@cnFillPalette         = "BlueDarkOrange18"  

  resc@cnMaxLevelValF = 15
  resc@cnMinLevelValF = 0
  resc@cnLevelSpacingF = 1 ;等值线间隔


  res_diff@cnFillPalette = "GMT_polar"
;   res_diff@cnFillPalette = "grads_rainbow"

  res_diff@cnMaxLevelValF  = 4.
  res_diff@cnMinLevelValF  = -4.
  res_diff@cnLevelSpacingF = 0.4

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
  res_vect@vcRefMagnitudeF           = 100 
  res_vect@vcRefAnnoString1          = "100 g*kg-1*m*s-1"
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

; ------------- res vect bias setting ------------

  res_vect_bias = res_vect
  res_vect_bias@vcRefMagnitudeF           = 50
  res_vect_bias@vcRefAnnoString1          = "50 g*kg-1*m*s-1"
  
; -------------- exec PLOT func ------------------

  do i=0,fignum-1,1
    plot(i) = gsn_csm_map(wks, mpres)
  end do
  res_vect@tiMainString = "ERA5I"
  vector_plot  = gsn_csm_vector(wks, era_u_qflux_mean, era_v_qflux_mean, res_vect)
  contour_plot = gsn_csm_contour(wks, era_q_mean, resc)
  overlay(plot(0), vector_plot)
  overlay(plot(0), contour_plot)
  
  res_vect@tiMainString = "VR"
  vector_plot  = gsn_csm_vector(wks, vr_u_qflux_mean, vr_v_qflux_mean, res_vect)
  contour_plot = gsn_csm_contour(wks, vr_q_mean, resc)
  overlay(plot(1), vector_plot)
  overlay(plot(1), contour_plot)

  res_vect@tiMainString = "RCM"
  vector_plot  = gsn_csm_vector(wks, rcm_u_qflux_mean, rcm_v_qflux_mean, res_vect)
  contour_plot = gsn_csm_contour(wks, rcm_q_mean, resc)
  overlay(plot(2), vector_plot)
  overlay(plot(2), contour_plot)

  res_vect_bias@tiMainString = "VR bias"
  vector_plot  = gsn_csm_vector(wks, vr_u_bias, vr_v_bias, res_vect_bias)
  contour_plot = gsn_csm_contour(wks, vr_q_bias, res_diff)
  overlay(plot(3), vector_plot)
  overlay(plot(3), contour_plot)

  res_vect_bias@tiMainString = "RCM bias"
  vector_plot  = gsn_csm_vector(wks, rcm_u_bias, rcm_v_bias, res_vect_bias)
  contour_plot = gsn_csm_contour(wks, rcm_q_bias, res_diff)
  overlay(plot(4), vector_plot)
  overlay(plot(4), contour_plot)

;;;;--------------------------panel seeting---------------------------------
  pres = True
  pres@txString              = "1998-2017" + " 850hPa mean" 
  ; pres@gsnPanelLabelBar      = False ; 公用一个色标
  ; pres@gsnPanelMainFontHeightF = 0.0002
  ; pres@gsnPanelFigureStrings = (/"","4","4","4","5","5","5","6","6","6","7","7","7","8","8","8","M","M","M"/)
  ; pres@amJust                = "TopLeft" ;调整标签顺序
  pres@gsnPanelRowSpec       = True
  gsn_panel(wks,plot,(/1, 2, 2/),pres)




end