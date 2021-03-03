 ;  2021.01.18 
 ;  单独将数据读入的部分放一个模板 
 ;  读入 REF VR RCM 三组 timemean
 ;  2021.03.03
 ;    绘制相对湿度的空间分布，用模式的地形高度数据进行了地形高度的mask（500hPa以下 mask了3000m以下的高度的RH值）
  
begin
;------------------------------------------------------------
sellevels = (/925, 850, 700, 500, 250, 200/)
plot = new(6*3,graphic) ;定义子图数组 
wks = gsn_open_wks("png","./output_pic/mean/" + "rhum_timemean")
;------------------------------------------------------------
do sellevel_ind = 0,5,1
sellevel  = sellevels(sellevel_ind) ; test for loop on one level

; 为数据读入选取对应的 ERA5I VR RCM的文件名、变量名
    file_in_ref = "sel_rhum.mon.mean.nc"
    ref_varname = "rhum"
    vr_varname = "relhum_"+sellevel+"hPa"
    rcm_varname = "relhum_"+sellevel+"hPa"

;>>> read data
    dir_in_ref  = "/raid52/yycheng/MPAS/REFERENCE/ERA5I_NC/ERA5I_NC_monthy"
    f = addfile(dir_in_ref + "/" + file_in_ref ,"r")
    ref_var_alllevel=f->$ref_varname$ ; every level
    ref_var = ref_var_alllevel(:,{sellevel},:,:) ; specific level
    
    modtype = "VR"
    dir_in_vr   = "/raid52/yycheng/MPAS/"+modtype+"_postprocess/"+modtype+"_merge/diag_mean_mon/"
    file_in_vr  = "monmean_2003-2015"+"_"+modtype+"_diag.nc"

    f = addfile(dir_in_vr + "/" + file_in_vr, "r")
    ; time | 5 对应 4=8 共五个月
    vr_var=f->$vr_varname$
    
    modtype = "RCM"
    dir_in_rcm   = "/raid52/yycheng/MPAS/"+modtype+"_postprocess/"+modtype+"_merge/diag_mean_mon/"
    file_in_rcm  = "monmean_2003-2015"+"_"+modtype+"_diag.nc"

    f = addfile(dir_in_rcm + "/" + file_in_rcm, "r")

    rcm_var=f->$rcm_varname$

    ;;; add model topo part
    dir_in_topo  = "/raid52/yycheng/MPAS/REFERENCE/MODEL_CONSTANT/"
    file_in_topo = "model_topo.nc"

    f = addfile(dir_in_topo + file_in_topo, "r")

    topo_var = f->$"zgrid"$(:,:,0) 

; PLOT variable : Time | 65 (5 x 13)
    ; printVarSummary(ref_var)
    ; printVarSummary(vr_var)
    ; printVarSummary(rcm_var)
    ref_var_timemean = dim_avg_n_Wrap(ref_var, 0)
    vr_var_timemean = dim_avg_n_Wrap(vr_var, 0)
    rcm_var_timemean = dim_avg_n_Wrap(rcm_var, 0)
    ; minus ref, get error
    vr_var_timemean_error = vr_var_timemean - ref_var_timemean
    rcm_var_timemean_error = rcm_var_timemean - ref_var_timemean
    ; copy metadata
    copy_VarMeta(vr_var_timemean, vr_var_timemean_error)
    copy_VarMeta(rcm_var_timemean, rcm_var_timemean_error)

    printMinMax(ref_var_timemean, 1)
    printMinMax(vr_var_timemean_error, 1)
    printMinMax(rcm_var_timemean_error, 1)

    ;;; add land mask for plevel lower than 500hPa
    if (sellevel.gt.500) then
    ; printVarSummary(topo_var)
    ; printVarSummary(vr_var_timemean_error)
    vr_var_timemean_error = where(topo_var.lt.3000, vr_var_timemean_error, vr_var_timemean_error@_FillValue)
    rcm_var_timemean_error = where(topo_var.lt.3000, rcm_var_timemean_error, rcm_var_timemean_error@_FillValue)
    end if
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
  ; res@cnLineLabelInterval = 4
  res@cnLineLabelPlacementMode = "Computed"
  res@cnLineLabelDensityF = 1.5
  res@cnLineLabelsOn       = True
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
  


  resc = res

  res@cnFillPalette         = "rh_19lev"; 
  ; res@cnFillPalette         = "percent_11lev"; 
  ; res@cnFillPalette         = "wind_17lev"; 
  ; res@cnFillPalette         = "hotcolr_19lev";
  ; res@cnFillPalette         = "srip_reanalysis";

  res@cnLevelSelectionMode = "ManualLevels" ;等间隔地指定等值线范围
  if (sellevel.eq.200) then
  ;------200-----
  res@cnMaxLevelValF = 100.
  res@cnMinLevelValF = 0. 
  res@cnLevelSpacingF = 5. ;等值线间隔

  resc@cnMaxLevelValF = 16.
  resc@cnMinLevelValF = -16.
  resc@cnLevelSpacingF = 2. ;等值线间隔
  end if
  if (sellevel.eq.250) then
  ;------250-----
  res@cnMaxLevelValF = 100.
  res@cnMinLevelValF = 0. 
  res@cnLevelSpacingF = 5. ;等值线间隔

  resc@cnMaxLevelValF = 16.
  resc@cnMinLevelValF = -16.
  resc@cnLevelSpacingF = 2. ;等值线间隔

  end if
  if (sellevel.eq.500) then
  ;------500-----
  res@cnMaxLevelValF = 100.
  res@cnMinLevelValF = 0. 
  res@cnLevelSpacingF = 5. ;等值线间隔
  
  resc@cnMaxLevelValF = 16.
  resc@cnMinLevelValF = -16.
  resc@cnLevelSpacingF = 2. ;等值线间隔

  end if 
  if (sellevel.eq.700) then
  ;------700-----
  res@cnMaxLevelValF = 100.
  res@cnMinLevelValF = 0. 
  res@cnLevelSpacingF = 5. ;等值线间隔

  resc@cnMaxLevelValF = 16.
  resc@cnMinLevelValF = -16. ;等值线间隔  resc@cnMinLevelValF = -240.
  resc@cnLevelSpacingF = 2. ;等值线间隔

  end if 
  if (sellevel.eq.850) then
  ;------850-----
  res@cnMaxLevelValF = 100.
  res@cnMinLevelValF = 0. 
  res@cnLevelSpacingF = 5. ;等值线间隔

  resc@cnMaxLevelValF = 16.
  resc@cnMinLevelValF = -16.
  resc@cnLevelSpacingF = 2. ;等值线间隔

  end if 
  if (sellevel.eq.925) then
  ;------925-----
  res@cnMaxLevelValF = 100.
  res@cnMinLevelValF = 0. 
  res@cnLevelSpacingF = 5. ;等值线间隔

  resc@cnMaxLevelValF = 16.
  resc@cnMinLevelValF = -16.
  resc@cnLevelSpacingF = 2. ;等值线间隔

  end if

;;;;-----------------------------------------------------resc 设置
  resc@cnFillPalette         ="GMT_polar"
  resc@cnLevelSelectionMode = "ManualLevels" ;等间隔地指定等值线范围

    ;   print(selmon_ind)
  ; selmon = selmon_ind * 3
  res@gsnCenterString    = "ERA5I "  + sellevel
  plot(sellevel_ind*3) = gsn_csm_contour_map(wks, ref_var_timemean, res)
  resc@gsnCenterString    = "VR "  + sellevel
  plot(sellevel_ind*3 + 1) = gsn_csm_contour_map(wks, vr_var_timemean_error, resc)
  resc@gsnCenterString    = "RCM " + sellevel 
  plot(sellevel_ind*3 + 2) = gsn_csm_contour_map(wks, rcm_var_timemean_error, resc)


end do
; end level loop

; ; ;;;;----------------------------------------------panel seeting
  pres = True
  pres@txString              = "2003-2015" + " mean " + ref_varname 
; ;   pres@gsnPanelLabelBar      = False ; 公用一个色标
; ; ;   pres@gsnPanelMainFontHeightF = 0.0002
  ; pres@gsnPanelFigureStrings = (/"","4","4","4","5","5","5","6","6","6","7","7","7","8","8","8","M","M","M"/)
;   pres@amJust                = "TopLeft" ;调整标签顺序
;   ; pres@gsnPanelRowSpec       = True
  gsn_panel(wks,plot,(/6,3/),pres)



end