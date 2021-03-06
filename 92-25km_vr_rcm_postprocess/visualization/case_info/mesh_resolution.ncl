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
    mpminlon    = 60.
    mpmaxlon    = 140.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  r2d = 57.2957795             ; radians to degrees

  maxedges = 11

  wks = gsn_open_wks("png","./output_pic/mesh_resolution_rcm")
  colors = (/"white","black","lightskyblue1","lightskyblue1","bisque"/)
  gsn_define_colormap(wks,colors)

  ; fname = getenv("FNAME")
  ; 修改到VR的网格，画出RCM的截断
  fname_vr = "/raid52/yycheng/MPAS/MESH/tpemip_grid/vr_area/" + "ea.grid.nc"
  ; fname_rcm = "/m2data2/yycheng/MPAS/TOOLS/MPAS-Limited-Area/" + "china_rcm.grid.nc"
  fname_rcm = "/raid52/yycheng/MPAS/MESH/tpemip_grid/rcm_area/" + "china_rcm.grid.nc"
  ; fname = "/m2data2/yycheng/MPAS/MESH/x1.40962/" + "x1.40962.grid.nc"
  f = addfile(fname_rcm,"r")

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
     res@cnFillPalette         = "Cat12"
     res@cnLevelSelectionMode = "ExplicitLevels"
    ;  res@cnLevels             = (/20,25,30,35,40,50/)
    ;  res@cnLevels             = (/20,25,30,35/)
    res@cnLevels             = (/20,22,24,28,35,40,45/)
    ;  res@cnFillColors         = (/1,3,5,7,9,10,11,12/)
    ;  res@cnFillColors         = (/1,3,5,7,9/)
    ; res@cnFillColors         = (/1,2,4,5,7,8,9,10/)
    res@cnFillColors         = (/2,3,4,5,1,1,1,11/)
    res@cnLineDashSegLenF          = 0.18          ; assist in controlling concentration
    res@cnLineLabelInterval        = 1             ; default = 2
    res@cnLineLabelPlacementMode   = "constant"    ; choose constant label method
    res@cnLineLabelFontHeightF     = 0.008         ; linelabel sizs
    res@cnLinesOn            = True
    res@cnLineLabelsOn       = True
  else
    res@cnFillOn             = False
    res@cnLinesOn            = True
    res@cnLineLabelsOn       = True
    res@cnLevelSelectionMode = "ExplicitLevels"
    res@cnLevels             = (/18,20,22,24,28,35,40,45/)
    res@cnLineDashSegLenF          = 0.18          ; assist in controlling concentration
    res@cnLineLabelInterval        = 1             ; default = 2
    res@cnLineLabelPlacementMode   = "constant"    ; choose constant label method
    res@cnLineLabelFontHeightF     = 0.008         ; linelabel sizs

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
  ; res@mpGridAndLimbOn   = True ; turn on grid

  ; ;;;---------------add lon\lat grid ticks----------------------
  ; res@mpGridAndLimbOn   = True ; turn on grid
  ; ; res@pmTickMarkDisplayMode  = "always" ; pm tickmark
  ; ; res@mpGridAndLimbDrawOrder = "Draw"
  ; ; res@tiMainString           = "Lat/lon grid"
  ; res@mpGridSpacingF         = 10.
  ; res@mpGridLineThicknessF   = 2.0
  ; ; res@mpGridLineColor        = "Gray30"
  ; ; res@mpGridAndLimbOn        = True
  ; ; res@pmTickMarkDisplayMode  = "Always"           ; turn on tickmarks
  ; res@mpGridAndLimbDrawOrder = "PostDraw"          ; Draw grid befres
  ; res@mpGridLatSpacingF = 15
  ; res@mpGridLonSpacingF = 15
;-------------------------------------------------------变量/x/y/刻度设置  
  ; res@pmTickMarkDisplayMode = "Always"
  ; res@pmTickMarkDisplayMode = "Conditional"
  ; res@pmTickMarkZone

  ; res@gsnMajorLatSpacing = 15              ; change maj lat tm spacing
  ; res@gsnMajorLonSpacing = 15              ; change maj lon tm spacing
  ; res@gsnMinorLatSpacing = 2
  ; res@gsnMinorLonSpacing = 2

  ; res@mpGridAndLimbOn=True             ;设置经纬线
  ; res@mpGridLineThicknessF=0.5
  ; res@mpGridLineDashPattern=2
  ; res@mpGridSpacingF=10

;  Put labels with the degree symbol on the X and Y axes.
  ; res@tmXUseBottom = False
  ; res@tmXTOn = True
  ; res@tmXMinorGrid = 20
  ; res@tmYMinorGrid = 20

  res@tmYLOn = True
  res@tmXBOn = True

  ; res@tmYMinorGrid = False
  ; res@tmXMinorGrid = False
  res@gsnMinorLonSpacing = 5.
  res@gsnMinorLatSpacing = 5.
  
  res@tmYLLabelStride      =  1              ;-- write only every 3rd label
  res@tmYLLabelFontHeightF =  0.014          ;-- change major lat tickmark spacing
  res@tmYLMajorLengthF     =  0.02           ;-- change the tickmark length
  res@tmYLMinorLengthF     =  0.01           ;-- change the tickmark length
  ; res@tmYLMajorLineColor   = "blue"          ;-- change major tickmarks color
  ; res@tmXMajorGrid = 20.
  ; res@tmYMajorGrid = 15.
  ; res@tmXMinorGrid = 2.
  ; res@tmYMinorGrid = 3.
  ; res@gsnMajorLatSpacing = 15.
  ; res@gsnMajorLonSpacing = 15.
  ; res@gsnMinorLatSpacing = 3.
  ; res@gsnMinorLonSpacing = 2.
  ; res@tmXBMinorOn = True
  ; res@tmXBMinorPerMajor = 5.
  res@tmXMajorGridLineDashPattern = 8
  res@tmYMajorGridLineDashPattern = 8
  ; res@tmXBMajorLineColor   = "grey20"        ;-- change major tickmarks color
  res@tmXMajorGridLineColor =   "grey40"
  res@tmYMajorGridLineColor =   "grey40"
  ; res@tmXMajorGridLineColor =   "grey20"


  res@tmXBMode   = "Explicit"
  res@tmXBValues = ispan(60,150,15)
  res@tmXBLabels = (/"60~S~o~N~E", "75~S~o~N~E","90~S~o~N~E", \
                     "105~S~o~N~E","120~S~o~N~E","135~S~o~N~E","150~S~o~N~E"/) ;;; ~S~o~N~ reference to degree

  res@tmYLMode   = "Explicit"
  res@tmYLValues = ispan(0,60,15)
  res@tmYLLabels = (/"0~S~o~N~N","15~S~o~N~N",\
                     "30~S~o~N~N","45~S~o~N~N","60~S~o~N~N"/)

  ;;;----------------change progection--------------------------

  ;   res@mpLimitMode       = "Angles"
  ;   res@mpLeftAngleF      = leftAngle
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
  map = gsn_csm_contour_map(wks,fld_min,res)

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
      if (ind_box.eq.4) then
        resp@gsLineThicknessF = 5.
        resp@gsLineDashPattern = 3.
      end if
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
