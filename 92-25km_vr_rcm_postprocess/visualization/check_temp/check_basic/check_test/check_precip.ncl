begin
    diri      = "/raid52/yycheng/MPAS/92-25km_VR/out_convert_latlon/convert_output/history/"
    fili      = systemfunc("cd "+diri+"; ls *.nc")
    f = addfiles(diri+fili,"r")
    ;;; read time labels    
    ListSetType(f,"join"); 打开多个文件并且返回文件句柄（批量读入后实质上是一个list
    or_t2m=f[:]->$"t2m"$;将臭氧8小时平均中的臭氧值赋值
    time_fromxtime=f[:]->$"Time"$;将臭氧8小时平均中的臭氧值赋值
    time_fromxtime!0 = "time"
    ; printVarSummary(time_fromxtime)
    ;;; read data for plotting
    or_rainc=f[:]->$"rainc"$;将臭氧8小时平均中的臭氧值赋值
    or_rainnc=f[:]->$"rainnc"$;将臭氧8小时平均中的臭氧值赋值
    precip = or_rainnc + or_rainc
    precip!0 = "time"
    precip&time = time_fromxtime
    ntime = dimsizes(time_fromxtime)
    ave_precip = precip(ntime - 1,0,:,:)/ntime
    ave_con    = or_rainc(ntime-1,0,:,:) / ntime
    ave_ncon   = or_rainnc(ntime-1,0,:,:) / ntime
    copy_VarCoords(or_rainc(0,0,:,:), ave_precip)
    copy_VarCoords(or_rainc(0,0,:,:), ave_con)
    copy_VarCoords(or_rainc(0,0,:,:), ave_ncon)
    printVarSummary(ave_precip)
    ; ave_t2m = dim_avg_n_Wrap(or_t2m, (/0,1/))
    ; printVarSummary(ave_t2m)
    ; ave_t2m = ave_t2m - 273.15
;;;>>>>>plot
PLOT = True
if (PLOT) then
    ;>>>绘图：画空间相关系数/离差
  plot = new(3,graphic) ;定义子图数组
  wks = gsn_open_wks("png","./output_pic/precip_ave")
  ; gsn_define_colormap(wks,"MPL_Oranges+GMT_polar") ;在后续定义，不用
  res = True  
  res@gsnFrame    = False
  res@gsnDraw     = False     ; don't draw plot yet， 避免plot = 之后再draw，画两张图；有叠加的时候使用
  res@cnInfoLabelOn       = False            ; turn off cn info label
  res@cnFillOn             = True
  res@cnLineLabelsOn       = False
  res@cnLinesOn            = False ;填色线条 
  ; res@pmTickMarkDisplayMode = "Always"
  res@lbLabelBarOn        = False            ; turn off individual cb's
;-------------------------------------------------------地图区域设置——中国区域res@mp
    res@mpMinLatF=15
    res@mpMaxLatF=55
    res@mpMinLonF=60
    res@mpMaxLonF=140
    res@mpDataBaseVersion = "Ncarg4_1"   ;地图采用中等分辨率
    ; res@mpDataSetName="Earth..4"
    ; /m2data2/yycheng/playground/NCL-noob-s-practices/till2020.06/NCL-Chinamap-master
    res@mpDataSetName = "/m2data2/yycheng/playground/NCL-noob-s-practices/till2020.06/NCL-Chinamap-master/database/Earth..4" ; 使用大气所的dataset数据
    res@mpOutlineOn=True
    res@mpOutlineSpecifiers=(/"China","Taiwan"/)
    ; res@mpOutlineSpecifiers=
    res@mpFillOn=False
    res@gsnAddCyclic=False

    res@mpGridAndLimbOn=True             ;设置经纬线
    res@mpGridLineThicknessF=0.5
    res@mpGridLineDashPattern=0.5
    res@mpGridLineDashPattern=2
    res@mpGridSpacingF=10

;-------------------------------------------------------地图标题设置
  ;;;
                
  res@gsnCenterString = "MPAS simulation TPEMIP 4-8"
  ; res@tiMainString    = "MEAN TEMPERATURE AT 2M HEIGHT"
  res@gsnCenterStringFontHeightF = 0.02  
  res@pmTickMarkDisplayMode = "Always" ;坐标标签上添加 度 符号(未起作用)
  res@gsnLeftString = "" ;不绘制左标题
  res@gsnRightString= "" ;不绘制右标题

;-------------------------------------------------------变量/x/y/刻度设置  
  ; res@cnLineThicknessF     = 0.5
  
  ;;;>>>坐标轴的处理
;   res@cnFillPalette         = "MPL_Oranges"; 用GMT_gray 进行填色。即调用了第2种色板(调色板设置)
  res@cnFillPalette         = "precip2_17lev"; 用GMT_gray 进行填色。即调用了第2种色板(调色板设置)
  ; res@tmXBMode = "automatic" ;指定X轴坐标标签
  ; res@tmYLMode = "Manual" ; 默认"automatic"
  res@tmYLTickStartF = 0  ; 起始最小刻度值
  res@tmYLTickEndF   = 60 ;最大刻度值
  res@tmYLTickSpacingF = 10 ;刻度间隔
  res@tmXBTickSpacingF = 15 

  ; res@lbOrientation = "Vertical" ; 把色板垂直地移动 
  ; res@gsnContourZeroLineThicknessF = 0. ;略去0线
 
  ; res@cnLevelSelectionMode = "ManualLevels" ;等间隔地指定等值线范围
;   res@cnMinLevelValF = 0.
;   res@cnMaxLevelValF = 12.
;   res@cnLevelSpacingF = 1. ;等值线间隔
  res@cnLevelSelectionMode = "ExplicitLevels"                                                                                             
  ; res@cnFillDrawOrder="postDraw"                                                                                                     
  res@cnLevels    = (/0.2,0.5,0.8,1.2,1.4,2,4,6,8,12,16,20,40/)
  res@lbBoxEndCapStyle = "TriangleBothEnds"
  res@pmLabelBarWidthF = 0.10            

;;;;----------------------------------------------------resc 设置
   resc = res
;   resc@gsnCenterString = "RMSE between WRF & CN05.1 dataset"
  resc@cnFillPalette         = "GMT_polar"; 用GMT_gray 进行填色。即调用了第2种色板(调色板设置)
  ; resc@cnLevelSelectionMode  = "ExplicitLevels"
  ; resc@cnMaxLevelCount      = 10
  ; resc@cnLevelSelectionMode = "EqualSpacedLevels" ; equally spaced contour levels
  ; resc@cnLevels              = (/0,1,2,3,4,5,6,7,8,9,10,11,12,13,14/)  
  ; resc@cnFillColors          = (/1,2,3,4,7,8,9,10,11,12,13,14,15,16,17,18/); -1 为透明
  resc@cnLevelSelectionMode = "ManualLevels" ;等间隔地指定等值线范围
;   resc@cnMinLevelValF = 0.
;   resc@cnMaxLevelValF = 8.
;   resc@cnLevelSpacingF = 0.5 ;等值线间隔
  ; resc@cnInfoLabelOn         = True       ; 关闭图右下 方的等值线信息标签
  ; resc@lbLabelBarOn          = True       ; 关闭labelbar
;;;;---------------------------------------------WRF绘制
  res@tiMainString    = "total precipitation"
  plot(0) = gsn_csm_contour_map(wks, ave_precip(:, :), res)
  res@tiMainString    = "convection precipitation"
  plot(1) = gsn_csm_contour_map(wks, ave_con(:, :), res)
  res@tiMainString    = "grid scale precipitation"
  plot(2) = gsn_csm_contour_map(wks, ave_ncon(:, :), res)
;   plot(3) = gsn_csm_contour_map(wks, rmse_wrf, resc)
;;;;----------------------------------------------panel seeting
  pres = True
  pres@txString              = "MEAN DAILY PRECIPITATION"
  pres@gsnPanelLabelBar      = True ; 公用一个色标
  pres@gsnPanelFigureStrings = (/"A","B","C"/)
  pres@amJust                = "TopLeft" ;调整标签顺序
  pres@gsnPanelRowSpec       = True
  gsn_panel(wks,plot,(/1,2/),pres)

draw(plot)
frame(wks)

end if

end