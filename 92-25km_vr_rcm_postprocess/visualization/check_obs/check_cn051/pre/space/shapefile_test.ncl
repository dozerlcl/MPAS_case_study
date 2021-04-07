; 2021.04.07  进行shapefile测试的脚本
;   参考ncl的shapefile绘图说明

; https://www.ncl.ucar.edu/Applications/Scripts/shapefile_utils.ncl
load "./shapefile_utils.ncl"
load "./pvs.ncl"
begin

  wks  = gsn_open_wks("png","shapefiles")  ; send graphics to PNG file

  res                     = True

; For faster code, don't set res@gsnDraw = False, and see below.
  res@gsnDraw             = False          ; don't draw plot yet

  res@gsnFrame            = False          ; don't advance frame yet
  res@gsnMaximize         = True           ; maximize plot in frame
  res@mpDataBaseVersion   = "MediumRes"    ; slightly better resolution

; Zoom in on South America.
  res@mpMinLatF           = 20
  res@mpMaxLatF           = 60
  res@mpMinLonF           = 90
  res@mpMaxLonF           = 140

  res@tiMainString        = "panel + shapefile test"
  res@tiMainFontHeightF   = 0.015   ; Make font slightly smaller.


;---Section to add polylines to map.
  plres             = True           ; resource list for polylines
  plres@gsLineColor = "blue"
;   plres@
  shapefile_path = "/raid52/yycheng/MPAS/REFERENCE/MODEL_CONSTANT/R1/" + "hyd1_4l.shp"
;   id = gsn_add_shapefile_polylines(wks, plot, shapefile_path ,plres)

;   draw(plot)   ; This will draw attached polylines and map
;   frame(wks)   ; Advanced frame.

plot = new(8, graphic)
plot_new_for_shape = new(8, graphic)
; do i = 0,7,1
  plres             = True           ; resource list for polylines
  plres@gsLineColor = "blue"
  do i=0,7,1
    plot(i) = gsn_csm_map(wks,res)   ; Draw map, but don't advance frame.
    plot_new_for_shape(i) = gsn_add_shapefile_polylines(wks, plot(i), shapefile_path ,plres)
  end do
; ; ;;;;----------------------------------------------panel seeting
  pres = True
  pres@txString              = "2003-2015" + " mean" 
; ;   pres@gsnPanelLabelBar      = False ; 公用一个色标
; ; ;   pres@gsnPanelMainFontHeightF = 0.0002
  ; pres@gsnPanelFigureStrings = (/"","4","4","4","5","5","5","6","6","6","7","7","7","8","8","8","M","M","M"/)
;   pres@amJust                = "TopLeft" ;调整标签顺序
;   ; pres@gsnPanelRowSpec       = True

  ; gsn_panel(wks,plot_new_for_shape,(/4, 2/),pres)
  gsn_panel(wks,plot,(/4, 2/),pres)
end