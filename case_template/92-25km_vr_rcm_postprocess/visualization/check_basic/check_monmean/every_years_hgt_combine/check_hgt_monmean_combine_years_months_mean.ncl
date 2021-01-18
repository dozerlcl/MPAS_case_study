;   2021.01.16
;   进行MPAS后处理，和ERA5I的hgt数据进行对比；
;   完成读取数据的部分
;   2021.01.17
;   修改为将每年RCM和VR的误差合并绘制，不同层次的图
;   2021.01.18 
;   _mean 修改为计算所有年 4-8五个月的平均误差 放置图片在/output_pic/mean之中
;   因为图片过大的原因拆分两份来做，分别为03-08年 以及 09-15年
begin
; selyear  = 2003
; do selyear=2003,2015,1
; replace year loop with getenv, get it by shell script
; selyear = stringtoint( getenv("selyear") )
; sellevel = stringtoint( getenv("sellevel") )
sellevels = (/925, 850, 700, 500, 250, 200/)
plot = new(6*3,graphic) ;定义子图数组
wks = gsn_open_wks("png","./output_pic/mean/" + "hgt_timemean")
do sellevel_ind = 0, 6-1, 1
sellevel = sellevels(sellevel_ind)
; print(selyear)
; startyear = 2003
; endyear   = 2008
; startyear = 2009
; endyear   = 2015
; yearnum = endyear - startyear + 1

; do selmon_ind=0,4,1

; do year_ind = 0,yearnum-1,1 ; year #
  ; selyear = startyear + year_ind ; real year
;>>> read data
    dir_in_ref  = "/raid52/yycheng/MPAS/REFERENCE/ERA5I_NC/ERA5I_NC_monthy"
    file_in_ref = "sel_hgt.mon.mean.nc"
    
    modtype = "VR"
    dir_in_vr   = "/raid52/yycheng/MPAS/"+modtype+"_postprocess/"+modtype+"_merge/diag_mean_mon/"
    file_in_vr  = "monmean_2003-2015"+"_"+modtype+"_diag.nc"

    f = addfile(dir_in_ref + "/" + file_in_ref ,"r")
    ref_hgt_alllevel=f->$"hgt"$
    ref_hgt = ref_hgt_alllevel(:,{sellevel},:,:)
    f = addfile(dir_in_vr + "/" + file_in_vr, "r")
    ; time | 5 对应 4=8 共五个月
    vr_varname = "height_"+sellevel+"hPa"
    vr_hgt=f->$vr_varname$
    
    modtype = "RCM"
    dir_in_vr   = "/raid52/yycheng/MPAS/"+modtype+"_postprocess/"+modtype+"_merge/diag_mean_mon/"
    file_in_vr  = "monmean_2003-2015"+"_"+modtype+"_diag.nc"

    f = addfile(dir_in_vr + "/" + file_in_vr, "r")

    rcm_varname = "height_"+sellevel+"hPa"
    rcm_hgt=f->$rcm_varname$

    ; check plot variables
    ; printVarSummary(ref_hgt)
    ; printVarSummary(vr_hgt)
    ; printVarSummary(rcm_hgt)

;>>>count time average ref_hgt vr_hgt rcm_hgt
    mean_hgt_ref  = dim_avg_n_Wrap(ref_hgt, 0)
    mean_hgt_vr   = dim_avg_n_Wrap(vr_hgt, 0)
    mean_hgt_rcm  = dim_avg_n_Wrap(rcm_hgt, 0)

    error_hgt_vr  = mean_hgt_vr  - mean_hgt_ref
    error_hgt_rcm = mean_hgt_rcm - mean_hgt_ref

    copy_VarMeta(mean_hgt_vr , error_hgt_vr)
    copy_VarMeta(mean_hgt_rcm, error_hgt_rcm)

; ;;>>>>>plot
; PLOT = True
; if (PLOT) then
    ;>>>绘图：画空间相关系数/离差
  ; gsn_define_colormap(wks,"MPL_Oranges+GMT_polar") ;在后续定义，不用
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
  if (sellevel.eq.200) then
  ;------200-----
  res@cnMinLevelValF = 11000. 
  res@cnMaxLevelValF = 13000.
  res@cnLevelSpacingF = 50 ;等值线间隔
  resc@cnMinLevelValF = -60.
  resc@cnMaxLevelValF = 60.
  resc@cnLevelSpacingF = 5 ;等值线间隔
  end if
  if (sellevel.eq.250) then
  ;------250-----
  res@cnMinLevelValF = 10000. 
  res@cnMaxLevelValF = 12000.
  res@cnLevelSpacingF = 50 ;等值线间隔
  resc@cnMinLevelValF = -60.
  resc@cnMaxLevelValF = 60.
  resc@cnLevelSpacingF = 5 ;等值线间隔

  end if
  if (sellevel.eq.500) then
  ;------500-----
  res@cnMinLevelValF = 5500. 
  res@cnMaxLevelValF = 6000.
  res@cnLevelSpacingF = 20 ;等值线间隔
  resc@cnMinLevelValF = -60.
  resc@cnMaxLevelValF = 60.
  resc@cnLevelSpacingF = 5 ;等值线间隔

  end if 
  if (sellevel.eq.700) then
  ;------700-----
  res@cnMinLevelValF = 2800. 
  res@cnMaxLevelValF = 3300.
  res@cnLevelSpacingF = 20 ;等值线间隔

  resc@cnMaxLevelValF = 40
  resc@cnMinLevelValF = -40 ;等值线间隔  resc@cnMinLevelValF = -240.
  resc@cnLevelSpacingF = 5 ;等值线间隔

  end if 
  if (sellevel.eq.850) then
  ;------850-----
  res@cnMinLevelValF = 1300. 
  res@cnMaxLevelValF = 1600.
  res@cnLevelSpacingF = 10 ;等值线间隔
  resc@cnMinLevelValF = -40
  resc@cnMaxLevelValF = 40
  resc@cnLevelSpacingF = 5 ;等值线间隔

  end if 
  if (sellevel.eq.925) then
  ;------925-----
  res@cnMinLevelValF = 600. 
  res@cnMaxLevelValF = 800.
  res@cnLevelSpacingF = 10 ;等值线间隔
  resc@cnMinLevelValF = -40.
  resc@cnMaxLevelValF = 40.
  resc@cnLevelSpacingF = 5 ;等值线间隔

  end if
  ;--------------
  ; resc@cnInfoLabelOn         = True       ; 关闭图右下 方的等值线信息标签
  ; resc@lbLabelBarOn          = True       ; 关闭labelbar
;;;;-----------------------------------------------------resc 设置
  resc@cnFillPalette         ="GMT_polar"
  resc@cnLevelSelectionMode = "ManualLevels" ;等间隔地指定等值线范围

;   print(selmon_ind)
  ; selmon = selmon_ind * 3
  res@gsnCenterString    = "ERA5I" 
  plot(sellevel_ind*3) = gsn_csm_contour_map(wks, mean_hgt_ref, res)
  resc@gsnCenterString    = "VR" 
  plot(sellevel_ind*3 + 1) = gsn_csm_contour_map(wks, error_hgt_vr, resc)
  resc@gsnCenterString    = "RCM" 
  plot(sellevel_ind*3 + 2) = gsn_csm_contour_map(wks, error_hgt_rcm, resc)

end do ; end level loop

; ; ;;;;----------------------------------------------panel seeting
  pres = True
  pres@txString              = "2003-2015" + "mean HGT" 
; ;   pres@gsnPanelLabelBar      = False ; 公用一个色标
; ; ;   pres@gsnPanelMainFontHeightF = 0.0002
  ; pres@gsnPanelFigureStrings = (/"","4","4","4","5","5","5","6","6","6","7","7","7","8","8","8","M","M","M"/)
;   pres@amJust                = "TopLeft" ;调整标签顺序
;   ; pres@gsnPanelRowSpec       = True
  gsn_panel(wks,plot,(/6,3/),pres)


end