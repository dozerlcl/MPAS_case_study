;   2021.01.16
;   进行MPAS后处理，和ERA5I的hgt数据进行对比；
;   完成读取数据的部分
;   2021.01.17
;   修改为将每年RCM和VR的误差合并绘制，不同层次的图
begin
; selyear  = 2003
; do selyear=2003,2015,1
; replace year loop with getenv, get it by shell script
; selmonth = stringtoint( getenv("selmonth") )
selmonth = getenv("selmonth") 
; print(selyear)
sellevel = 200
wks = gsn_open_wks("png","./output_pic/months/" +selmonth + "/" + sellevel + "_hgt")
plot = new(20,graphic) ;定义子图数组

do selyear_ind=0,9,1

;>>> read data
    selyear = selyear_ind + 2003 ; specified year
    dir_in_ref  = "/raid52/yycheng/MPAS/REFERENCE/ERA5I_NC/ERA5I_NC_monthy"
    file_in_ref = "sel_hgt.mon.mean.nc"
    
    modtype = "VR"
    dir_in_vr   = "/raid52/yycheng/MPAS/"+modtype+"_postprocess/"+modtype+"_merge/diag_mean_mon/"
    file_in_vr  = "monmean_"+selyear+"_"+modtype+"_diag.nc"

    f = addfile(dir_in_ref + "/" + file_in_ref ,"r")
    ref=f->$"hgt"$
    f = addfile(dir_in_vr + "/" + file_in_vr, "r")
    ; time | 5 对应 4=8 共五个月
    vr_hgt_200=f->$"height_200hPa"$
    vr_hgt_250=f->$"height_250hPa"$
    vr_hgt_500=f->$"height_500hPa"$
    vr_hgt_700=f->$"height_700hPa"$
    vr_hgt_850=f->$"height_850hPa"$
    vr_hgt_925=f->$"height_925hPa"$
    
    modtype = "RCM"
    dir_in_vr   = "/raid52/yycheng/MPAS/"+modtype+"_postprocess/"+modtype+"_merge/diag_mean_mon/"
    file_in_vr  = "monmean_"+selyear+"_"+modtype+"_diag.nc"

    f = addfile(dir_in_ref + "/" + file_in_ref ,"r")
    ref=f->$"hgt"$
    f = addfile(dir_in_vr + "/" + file_in_vr, "r")
    ; time | 5 对应 4=8 共五个月
    rcm_hgt_200=f->$"height_200hPa"$
    rcm_hgt_250=f->$"height_250hPa"$
    rcm_hgt_500=f->$"height_500hPa"$
    rcm_hgt_700=f->$"height_700hPa"$
    rcm_hgt_850=f->$"height_850hPa"$
    rcm_hgt_925=f->$"height_925hPa"$
    ; printVarSummary(hgt_ref(,:,:,:))
    ref_time = cd_calendar(ref&time, 1)
    ; print(ref_time)
    ref_start_ind  = ind(ref_time.eq.(selyear*100+4)) ; 开始时间 例如 200304
    ref_end_ind    = ind(ref_time.eq.(selyear*100+8)) ; 结束时间      200308

    ; printVarSummary(vr_hgt_200)
    ref_hgt_200=ref(ref_start_ind:ref_end_ind, {200}, :, :)
    ref_hgt_250=ref(ref_start_ind:ref_end_ind, {250}, :, :)
    ref_hgt_500=ref(ref_start_ind:ref_end_ind, {500}, :, :)
    ref_hgt_700=ref(ref_start_ind:ref_end_ind, {700}, :, :)
    ref_hgt_850=ref(ref_start_ind:ref_end_ind, {850}, :, :)
    ref_hgt_925=ref(ref_start_ind:ref_end_ind, {925}, :, :)



;;;>>>>>plot
; PLOT = True
; if (PLOT) then
    ;>>>绘图：画空间相关系数/离差
  ; gsn_define_colormap(wks,"MPL_Oranges+GMT_polar") ;在后续定义，不用
  res = True  
  res@gsnFrame    = False
  res@gsnDraw     = False     ; don't draw plot yet， 避免plot = 之后再draw，画两张图；有叠加的时候使用
  res@cnInfoLabelOn       = False            ; turn on/off cn info label
  res@lbLabelBarOn        = True            ; turn off individual cb's
  res@cnFillOn             = True
  res@cnLineLabelsOn       = True
  res@cnLinesOn            = True ;填色线条 

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
  

;;;;----------------------------------------------------res 设置 --- add resc
  res@cnLineLabelInterval = 1
  res@cnLineLabelPlacementMode = "Computed"
  res@cnLineLabelDensityF = 1
  resc = res

  res@cnFillPalette         = "StepSeq25"; 用GMT_gray 进行填色。即调用了第2种色板(调色板设置)

  res@cnLevelSelectionMode = "ManualLevels" ;等间隔地指定等值线范围
  print("selyear_ind :"+selyear_ind)
  if (sellevel.eq.200) then
  ;------200-----
  ; res@cnMinLevelValF = 11000. 
  ; res@cnMaxLevelValF = 13000.
  ; res@cnLevelSpacingF = 50 ;等值线间隔
  resc@cnMinLevelValF = -240.
  resc@cnMaxLevelValF = 240.
  resc@cnLevelSpacingF = 20 ;等值线间隔
  ; ----
  vr_hgt_plot    = vr_hgt_200(selyear_ind,:,:)
  rcm_hgt_plot   = rcm_hgt_200(selyear_ind,:,:)
  ref_hgt_plot   = ref_hgt_200(selyear_ind,:,:)
  end if
  if (sellevel.eq.250) then
  ;------250-----
  res@cnMinLevelValF = 10000. 
  res@cnMaxLevelValF = 12000.
  res@cnLevelSpacingF = 50 ;等值线间隔
  resc@cnMinLevelValF = -140.
  resc@cnMaxLevelValF = 140.
  resc@cnLevelSpacingF = 20 ;等值线间隔
  ; ----
  vr_hgt_plot    = vr_hgt_250(selyear_ind,:,:)
  rcm_hgt_plot   = rcm_hgt_250(selyear_ind,:,:)
  ref_hgt_plot   = ref_hgt_250(selyear_ind,:,:)
  end if
  if (sellevel.eq.500) then
  ;------500-----
  res@cnMinLevelValF = 5500. 
  res@cnMaxLevelValF = 6000.
  res@cnLevelSpacingF = 20 ;等值线间隔
  resc@cnMinLevelValF = -100.
  resc@cnMaxLevelValF = 100.
  resc@cnLevelSpacingF = 10 ;等值线间隔
  ; ----
  vr_hgt_plot    = vr_hgt_500(selyear_ind,:,:)
  rcm_hgt_plot   = rcm_hgt_500(selyear_ind,:,:)
  ref_hgt_plot   = ref_hgt_500(selyear_ind,:,:)
  end if 
  if (sellevel.eq.700) then
  ;------700-----
  res@cnMinLevelValF = 2800. 
  res@cnMaxLevelValF = 3300.
  res@cnLevelSpacingF = 20 ;等值线间隔

  resc@cnMaxLevelValF = 80
  resc@cnMinLevelValF = -80 ;等值线间隔  resc@cnMinLevelValF = -240.
  resc@cnLevelSpacingF = 5 ;等值线间隔
  ; ----
  vr_hgt_plot    = vr_hgt_700(selyear_ind,:,:)
  rcm_hgt_plot   = rcm_hgt_700(selyear_ind,:,:)
  ref_hgt_plot   = ref_hgt_700(selyear_ind,:,:)
  end if 
  if (sellevel.eq.850) then
  ;------850-----
  res@cnMinLevelValF = 1300. 
  res@cnMaxLevelValF = 1600.
  res@cnLevelSpacingF = 10 ;等值线间隔
  resc@cnMinLevelValF = -80
  resc@cnMaxLevelValF = 80
  resc@cnLevelSpacingF = 5 ;等值线间隔
  ; ----
  vr_hgt_plot    = vr_hgt_850(selyear_ind,:,:)
  rcm_hgt_plot   = rcm_hgt_850(selyear_ind,:,:)
  ref_hgt_plot   = ref_hgt_850(selyear_ind,:,:)
  end if 
  if (sellevel.eq.925) then
  ;------925-----
  res@cnMinLevelValF = 600. 
  res@cnMaxLevelValF = 800.
  res@cnLevelSpacingF = 10 ;等值线间隔
  resc@cnMinLevelValF = -80.
  resc@cnMaxLevelValF = 80.
  resc@cnLevelSpacingF = 5 ;等值线间隔
  
  ; ----
  vr_hgt_plot    = vr_hgt_925(selyear_ind,:,:)
  rcm_hgt_plot   = rcm_hgt_925(selyear_ind,:,:)
  ref_hgt_plot   = ref_hgt_925(selyear_ind,:,:)
  end if
  ;--------------
  ; resc@cnInfoLabelOn         = True       ; 关闭图右下 方的等值线信息标签
  ; resc@lbLabelBarOn          = True       ; 关闭labelbar
;;;;-----------------------------------------------------resc 设置
  resc@cnFillPalette         ="GMT_polar"
  resc@cnLevelSelectionMode = "ManualLevels" ;等间隔地指定等值线范围

;-------------------------------------------------
  hgt_vr_error_plot = vr_hgt_plot - ref_hgt_plot
  hgt_rcm_error_plot = rcm_hgt_plot - ref_hgt_plot
  copy_VarMeta(vr_hgt_plot, hgt_vr_error_plot)
  copy_VarMeta(rcm_hgt_plot, hgt_rcm_error_plot)

;   print(selmon_ind)
  plot_ind = selyear_ind * 2
  res@gsnCenterString    = "ERA5I" 
  plot(plot_ind) = gsn_csm_contour_map(wks, ref_hgt_plot(:,:), res)
  res@gsnCenterString    = "VR" 
  plot(plot_ind+1) = gsn_csm_contour_map(wks, hgt_vr_error_plot(:,:), resc)
  res@gsnCenterString    = "RCM" 
  plot(plot_ind+2) = gsn_csm_contour_map(wks, hgt_rcm_error_plot(:,:), resc)

end do ; end month loop
;;;;----------------------------------------------panel seeting
  pres = True
  pres@txString              = selyear + " HGT " + sellevel + " hPa"
;   pres@gsnPanelLabelBar      = False ; 公用一个色标
;   pres@gsnPanelMainFontHeightF = 0.0002
  pres@gsnPanelFigureStrings = (/"4","4","4","5","5","5","6","6","6","7","7","7","8","8","8"/)
  pres@amJust                = "TopLeft" ;调整标签顺序
  pres@gsnPanelRowSpec       = True
  gsn_panel(wks,plot,(/3,3,3,3,3/),pres)


; end do ; end year loop
end