;   2021.01.16
;   进行MPAS后处理，和ERA5I的hgt数据进行对比；
;   完成读取数据的部分
;   2021.01.17
;   修改为将每年RCM和VR的误差合并绘制，不同层次的图
;   2021.01.18 
;   _timemean
;   计算不同层次的 所有时间上的平均值
;   2021.05.24
;   固定到500层次绘制，拆分时间为am和jja    
begin
  ; selyear  = 2003
  ; do selyear=2003,2015,1
  ; replace year loop with getenv, get it by shell script
  ; selyear = stringtoint( getenv("selyear") )
  ; sellevel = stringtoint( getenv("sellevel") )
  sellevels = (/925, 850, 700, 500, 250, 200/)
  plot = new(6,graphic) ;定义子图数组
  wks = gsn_open_wks("png","./output_pic/" + "hgt_annual")
  ; sellevels = 500.
  ; sellevel = sellevels(sellevel_ind)
  sellevel = 500.
;>>> read data
  dir_in_ref  = "/raid52/yycheng/MPAS/REFERENCE/ERA5I_NC/ERA5I_NC_monthy"
  file_in_ref = "sel_hgt.mon.mean.nc"

  f = addfile(dir_in_ref + "/" + file_in_ref ,"r")
  ref_hgt_alllevel=f->$"hgt"$
  ref_hgt = ref_hgt_alllevel(:,{sellevel},:,:)

  modtype = "VR"
  dir_in_vr   = "/raid52/yycheng/MPAS/"+modtype+"_postprocess/"+modtype+"_merge/diag_monthly/"
  file_in_vr  = "monmean_98-17"+"_"+modtype+"_diag.nc"

  f = addfile(dir_in_vr + "/" + file_in_vr, "r")
  ; time | 5 对应 4=8 共五个月
  vr_varname = "height_"+sellevel+"hPa"
  vr_hgt=f->$vr_varname$
  
  modtype = "RCM"
  dir_in_vr   = "/raid52/yycheng/MPAS/"+modtype+"_postprocess/"+modtype+"_merge/diag_monthly/"
  file_in_vr  = "monmean_98-17"+"_"+modtype+"_diag.nc"

  f = addfile(dir_in_vr + "/" + file_in_vr, "r")

  rcm_varname = "height_"+sellevel+"hPa"
  rcm_hgt=f->$rcm_varname$

;>>> select AM & JJA
  time = cd_calendar(vr_hgt&Time, 0)
  am_ind = ind((time(:,1).eq.4).or.(time(:,1).eq.5))
  jja_ind = ind((time(:,1).eq.6).or.(time(:,1).eq.7).or.(time(:,1).eq.8))

;>>>count time average ref_hgt vr_hgt rcm_hgt
  mean_hgt_ref_am  = dim_avg_n_Wrap(ref_hgt(am_ind,:,:), 0)
  mean_hgt_vr_am   = dim_avg_n_Wrap(vr_hgt(am_ind,:,:), 0)
  mean_hgt_rcm_am  = dim_avg_n_Wrap(rcm_hgt(am_ind,:,:), 0)
  
  error_hgt_vr_am  = mean_hgt_vr_am  - mean_hgt_ref_am
  error_hgt_rcm_am = mean_hgt_rcm_am - mean_hgt_ref_am
  copy_VarMeta(mean_hgt_vr_am , error_hgt_vr_am)
  copy_VarMeta(mean_hgt_rcm_am, error_hgt_rcm_am)

  mean_hgt_ref_jja  = dim_avg_n_Wrap(ref_hgt(jja_ind,:,:), 0)
  mean_hgt_vr_jja   = dim_avg_n_Wrap(vr_hgt(jja_ind,:,:), 0)
  mean_hgt_rcm_jja  = dim_avg_n_Wrap(rcm_hgt(jja_ind,:,:), 0)

  error_hgt_vr_jja  = mean_hgt_vr_jja  - mean_hgt_ref_jja
  error_hgt_rcm_jja = mean_hgt_rcm_jja - mean_hgt_ref_jja

  copy_VarMeta(mean_hgt_vr_jja, error_hgt_vr_jja)
  copy_VarMeta(mean_hgt_rcm_jja, error_hgt_rcm_jja)

; ;;>>>>>plot
  res = True  
  ; 页面控制
  res@gsnMaximize = True

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

  ;------500-----
  res@cnMinLevelValF = 5500. 
  res@cnMaxLevelValF = 6000.
  res@cnLevelSpacingF = 20 ;等值线间隔
  resc@cnMinLevelValF = -60.
  resc@cnMaxLevelValF = 60.
  resc@cnLevelSpacingF = 5 ;等值线间隔


;;;;-----------------------------------------------------resc 设置
  resc@cnFillPalette         ="GMT_polar"
  resc@cnLevelSelectionMode = "ManualLevels" ;等间隔地指定等值线范围

;   print(selmon_ind)
  ; selmon = selmon_ind * 3
  res@gsnCenterString    = "AMERA5I " + sellevel 
  plot(0) = gsn_csm_contour_map(wks, mean_hgt_ref_am, res)
  resc@gsnCenterString    = "AM VR " + sellevel 
  plot(1) = gsn_csm_contour_map(wks, error_hgt_vr_am, resc)
  resc@gsnCenterString    = "AM RCM " + sellevel 
  plot(2) = gsn_csm_contour_map(wks, error_hgt_rcm_am, resc)

  res@gsnCenterString    = "JJA ERA5I " + sellevel 
  plot(3) = gsn_csm_contour_map(wks, mean_hgt_ref_jja, res)
  resc@gsnCenterString    = "JJA VR " + sellevel 
  plot(4) = gsn_csm_contour_map(wks, error_hgt_vr_jja, resc)
  resc@gsnCenterString    = "JJA RCM " + sellevel 
  plot(5) = gsn_csm_contour_map(wks, error_hgt_rcm_jja, resc)

; ; ;;;;----------------------------------------------panel seeting
  pres = True
  pres@txString              = "1998-2017 " + "500hPa HGT" 
; ;   pres@gsnPanelLabelBar      = False ; 公用一个色标
; ; ;   pres@gsnPanelMainFontHeightF = 0.0002
  ; pres@gsnPanelFigureStrings = (/"","4","4","4","5","5","5","6","6","6","7","7","7","8","8","8","M","M","M"/)
;   pres@amJust                = "TopLeft" ;调整标签顺序
;   ; pres@gsnPanelRowSpec       = True
  gsn_panel(wks,plot,(/2,3/),pres)

end