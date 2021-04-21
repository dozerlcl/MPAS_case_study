;;      11.25 进行resolution的绘制，tickmark添加较为困难，暂时先搁置
;;        tick.ncl 是绘制tickmark的外部函数，参考NCL官网；mptick_9.ncl



load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "./tick.ncl"


begin

  ;
  ; Whether to do color-filled plot (filled=True) or
  ;   to plot contours of height field (filled=False)
  ;
 filled   = True
  ; filled   = False

  ;
  ; The (lat,lon) the plot is to be centered over
  ;
  cenLat   = 32.5
  cenLon   = 100.

  ;
  ; Projection to use for plot
  ;
;  projection = "Orthographic"
  projection = "CylindricalEquidistant"

    ; projection = "Lambert Conformal"
    ; mpProjectiontype = "Cylindrical Equidistant"
    cenlat = 32.5
    cenlon = 100.
  

    ;
    ; Set plotting window
    ;
    leftAngle   = 90.0
    rightAngle  = 90.0
    bottomAngle = 90.0
    topAngle    = 90.0

    mpminlat    = -5.
    mpmaxlat    = 65.
    mpminlon    = 55.
    mpmaxlon    = 145.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  r2d = 57.2957795             ; radians to degrees

  maxedges = 11

  wks = gsn_open_wks("png","./output_pic/mesh_resolution_rcm")
  colors = (/"white","black","lightskyblue1","lightskyblue1","bisque"/)
  gsn_define_colormap(wks,colors)

  ; fname = getenv("FNAME")
  ; fname = "/raid52/yycheng/MPAS/92-25km_VR_2003/" + "ea.grid.nc"
  fname = "/m2data2/yycheng/MPAS/TOOLS/MPAS-Limited-Area/" + "china_rcm.grid.nc"
  ; fname = "/m2data2/yycheng/MPAS/MESH/x1.40962/" + "x1.40962.grid.nc"
  f = addfile(fname,"r")

  lonCell   = f->lonCell(:) * r2d
  latCell   = f->latCell(:) * r2d
  lonVertex = f->lonVertex(:) * r2d
  latVertex = f->latVertex(:) * r2d
  lonEdge = f->lonEdge(:) * r2d
  latEdge = f->latEdge(:) * r2d
  verticesOnCell = f->verticesOnCell(:,:)
  alpha = f->angleEdge(:)

  res                      = True
  res@gsnMaximize          = True
  res@gsnSpreadColors      = True
  res@gsnDraw   = False                             ; don't draw yet
  res@gsnFrame  = False                             ; don't advance yet


  res@sfXArray             = lonCell
  res@sfYArray             = latCell

  res@cnFillMode           = "AreaFill"

  if (filled) then
     res@cnFillOn             = True
     res@cnLinesOn            = False
     res@cnLineLabelsOn       = False
     res@cnFillPalette         = "Cat12"; 用GMT_gray 进行填色。即调用了第2种色板(调色板设置)
     res@cnLevelSelectionMode = "ExplicitLevels"
    ;  res@cnLevels             = (/20,25,30,35,40,50/)
     res@cnLevels             = (/20,25,30,35/)
    ;  res@cnFillColors         = (/1,3,5,7,9,10,11,12/)
     res@cnFillColors         = (/1,3,5,7,9/)
  else
     res@cnFillOn             = False
     res@cnLinesOn            = True
     res@cnLineLabelsOn       = True
  end if

  res@cnLevelSpacingF      = 8.0
  res@cnInfoLabelOn        = True
  res@lbLabelAutoStride    = True
  res@lbBoxLinesOn         = False
  res@tiMainString = "Approximate mesh resolution (km)"

  res@mpProjection      = projection
  ; res@mpDataBaseVersion = "MediumRes"
  res@mpCenterLatF      = cenLat
  res@mpCenterLonF      = cenLon
  ; res@mpGridAndLimbOn   = True
  ; res@mpGridAndLimbDrawOrder = "PreDraw"
  ; res@mpGridLineColor   = "Background"
  res@mpOutlineOn       = True
  ; res@mpDataBaseVersion = "Ncarg4_1"
  ; res@mpDataSetName     = "Earth..3"
  res@mpOutlineBoundarySets = "Geophysical"
  res@mpFillOn          = True
  res@mpPerimOn         = True
  res@gsnFrame          = False
  res@cnLineThicknessF  = 2.0
  ; res@cnLineColor       = "NavyBlue"
  res@mpOceanFillColor  = 3
  res@mpInlandWaterFillColor  = 3
  res@mpLandFillColor  = 4
  ;-------------------------------------------------------地图区域设置——中国区域res@mp
  res@mpDataBaseVersion = "Ncarg4_1"   ;地图采用中等分辨率
  ; res@mpDataSetName="Earth..4"
  ; /m2data2/yycheng/playground/NCL-noob-s-practices/till2020.06/NCL-Chinamap-master
  res@mpDataSetName = "/m2data2/yycheng/playground/NCL-noob-s-practices/till2020.06/NCL-Chinamap-master/database/Earth..4" ; 使用大气所的dataset数据
  res@mpOutlineOn=True
  res@mpOutlineSpecifiers=(/"China","Taiwan"/)
  res@mpCountyLineThicknessF = 10
  res@mpNationalLineThicknessF = 4.
  ; res@mpOutlineSpecifiers=
  ; res@mpFillOn=False

  ;;;---------------add lon\lat grid and tick mark
  res@mpGridAndLimbOn   = True ; turn on grid

  ;;;---------------add lon\lat grid ticks----------------------
  res@mpGridAndLimbOn   = True ; turn on grid
  res@pmTickMarkDisplayMode  = "always" ; pm tickmark
  ; res@mpGridAndLimbDrawOrder = "Draw"
  ; res@tiMainString           = "Lat/lon grid"
  ; res@mpGridSpacingF         = 10.
  ; res@mpGridLineThicknessF   = 2.0
  ; res@mpGridLineColor        = "Gray30"
  ; res@mpGridAndLimbOn        = True
  ; res@pmTickMarkDisplayMode  = "Always"           ; turn on tickmarks
  res@mpGridAndLimbDrawOrder = "PostDraw"          ; Draw grid befres
  res@mpGridLatSpacingF = 10
  res@mpGridLonSpacingF = 10

  ;;;----------------change progection--------------------------

  ;   res@mpLimitMode       = "Angles"
  ; res@mpLeftAngleF      = leftAngle
  ;   res@mpRightAngleF     = rightAngle
  ;   res@mpBottomAngleF    = bottomAngle
  ;   res@mpTopAngleF       = topAngle
  res@mpLimitMode       = "LatLon"
  ; res@mpLimitMode       = "LambertEqualArea"
  res@mpMinLatF      = mpminlat
  res@mpMaxLatF      = mpmaxlat
  res@mpMinLonF      = mpminlon
  res@mpMaxLonF      = mpmaxlon

  ; res@gsnMaximize = True
  res@mpShapeMode  = "FreeAspect"
  res@vpWidthF      = 0.8
  res@vpHeightF     = 0.4
  ;;;----------------change progection--------------------------

  minSpacingKm = sqrt(min(f->areaCell(:))*2.0/sqrt(3.0))*6371.229
  print("Approx. min grid distance is "+minSpacingKm)
  maxSpacingKm = sqrt(max(f->areaCell(:))*2.0/sqrt(3.0))*6371.229
  print("Approx. max grid distance is "+maxSpacingKm)

  t = stringtointeger(getenv("T"))
  fld_min = minSpacingKm / (f->meshDensity(:)^0.25)
  fld_max = maxSpacingKm / (f->meshDensity(:)^0.25)
  res@cnLineDashPattern = 0
  map = gsn_csm_contour_map_ce(wks,fld_min,res)
  ;;;-----------add_map_tickmarks2函数的参数传入靠tres完成---------
  
 tmres          = True
;  tmres@gsnMaximize = True

;---Set the values you want for the map tickmarks.
  tmres@tmXBLabelFontHeightF = 0.012         ; Default is a bit large

;---We're putting tickmarks on all four axes.
  tmres@tmYLValues = ispan(0,50,10)
  tmres@tmYRValues = ispan(0,50,10)
  tmres@tmXBValues = ispan(70,140,10)
  tmres@tmXTValues = ispan(60,140,10)


;----- add latlonbox -----

  ; latlonbox(wks, map, 42., 54., 117., 135., "NE")
;************************************************
  ; add the box 2021.04.21
  ; 添加进行分区的部分，分为四个矩形框区，boxname
  ; remark gsn_add_polyline 的部分会因为dum的删除或者覆盖出错，
  ; Re: warning:TransformPostDraw: tfPolyDrawList element 0 is invalid
  ; 因此创建了很多dum图形
  ; 官方答疑 https://www.ncl.ucar.edu/Support/talk_archives/2012/0899.html


;************************************************
  resp                  = True                      ; polyline mods desired
  resp@gsLineColor      = "black"                     ; color of lines
  resp@gsLineThicknessF = 3.                       ; thickness of lines
  ; resp@gsLineLabelString= "test"                    ; adds a line label string
  ; resp@tfPolyDrawOrder = "PostDraw"
  ; setting box
  lonlatbox = (/ \  
          (/110, 98, 30, 22/),  \
          (/123, 110, 34, 25/), \
          (/123, 110, 42, 34/), \
          (/135, 117, 54, 42/),  \
          (/140, 70, 55, 15/)  \
        /)
  boxname = (/"SW", "YZ", "NC", "NE", "PLOT"/)

  dum = new(20,graphic)
  do ind_box =0,4 ; loop box
    lonmax = lonlatbox(ind_box, 0)
    lonmin = lonlatbox(ind_box, 1)
    latmax = lonlatbox(ind_box, 2)
    latmin = lonlatbox(ind_box, 3)
    str = boxname(ind_box)
    xpts = (/ lonmin,  lonmin,  lonmax, lonmax, lonmin/)
    ypts = (/latmin, latmax, latmax, latmin, latmin/)

    ; draw each line separately. Each line must contain two points.
    do i = 0, 3
      dum(i+ind_box*4)=gsn_add_polyline(wks, map, xpts(i:i+1), ypts(i:i+1), resp)      
    end do
    tres       =  True
    tres@txFontHeightF = 0.015
    dumtext = gsn_add_text(wks, map, str, (lonmax+lonmin)/2., (latmax+latmin)/2., tres) 

  end do

  draw(map)
  frame(wks)

end
