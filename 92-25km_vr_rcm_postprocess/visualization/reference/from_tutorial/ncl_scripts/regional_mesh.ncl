load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Main script
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
begin

  ;
  ; Center latitude and longitude of plot
  ;
  cenlat = 32.5
  cenlon = 100.0

  ;
  ; The bounding box for the plot
  ;
  leftAngle   = 90.0
  rightAngle  = 90.0
  bottomAngle = 90.0
  topAngle    = 90.0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  r2d = 57.2957795             ; radians to degrees

  ;
;   gname = getenv("GNAME")
  gname = "/m2data2/yycheng/MPAS/TOOLS/MPAS-Limited-Area/china.static.nc"
  g = addfile(gname,"r")

  maxedges = 7

  wks_type = "png"
  wks_type@wkWidth = 2500
  wks_type@wkHeight = 2500 
  wks_type@wkBackgroundOpacityF = 1.0
  wks = gsn_open_wks(wks_type,"./output_pic/regional_mesh")
  gsn_define_colormap(wks,"mpas_mesh")

  res                      = True
  res@gsnPaperOrientation  = "portrait"

  res@cnFillOn             = True
  res@cnFillMode           = "RasterFill"
  res@cnLinesOn            = False
  res@cnLineLabelsOn       = False
  res@cnInfoLabelOn        = False

  res@lbLabelAutoStride    = True
  res@lbBoxLinesOn         = False

  res@mpProjection      = "Orthographic"
  res@mpDataBaseVersion = "MediumRes"
  res@mpCenterLatF      = cenlat
  res@mpCenterLonF      = cenlon
  res@mpGridAndLimbOn   = False
  res@mpOutlineOn       = False
  res@mpFillOn          = True
  res@mpPerimOn         = False
  res@gsnFrame          = False
;   res@mpLimitMode       = "Angles"
;   res@mpLeftAngleF      = leftAngle
;   res@mpRightAngleF     = rightAngle
;   res@mpBottomAngleF    = bottomAngle
;   res@mpTopAngleF       = topAngle
;   res@gsnFrame          = False
  res@mpLimitMode       = "LatLon"
  res@mpMinLatF      = -10.
  res@mpMaxLatF      = 70.
  res@mpMinLonF      = 50.
  res@mpMaxLonF      = 150.
  res@mpOceanFillColor  = 2
  res@mpInlandWaterFillColor  = 2
  res@mpLandFillColor  = 3


  ;
  ; Set mesh filename as title of plot
  ;
  res@tiMainString = gname


  ;
  ; The purpose of this next line is simply to set up a graphic ('map')
  ;    that uses the projection specified above, and over which we
  ;    can draw polygons
  ;
  map = gsn_csm_map(wks,res)


  ;
  ; Draw mesh outline
  ;
  glonEdge = g->lonEdge(:) * r2d
  glatEdge = g->latEdge(:) * r2d
  glonVertex = g->lonVertex(:) * r2d
  glatVertex = g->latVertex(:) * r2d
  gverticesOnEdge = g->verticesOnEdge(:,:)

  lres = True
  lres@gsLineThicknessF = 2.0

  esizes = dimsizes(glatEdge)
  ecx = new((/esizes(0),2/),double)
  ecy = new((/esizes(0),2/),double)
  do j=0,esizes(0)-1
     ecy(j,0) = glatVertex(gverticesOnEdge(j,0)-1)
     ecx(j,0) = glonVertex(gverticesOnEdge(j,0)-1)
     ecy(j,1) = glatVertex(gverticesOnEdge(j,1)-1)
     ecx(j,1) = glonVertex(gverticesOnEdge(j,1)-1)
  end do

  do j=0,esizes(0)-1
     if (abs(ecx(j,0) - ecx(j,1)) .gt. 180.0) then
        if (ecx(j,0) .gt. ecx(j,1)) then
           ecx(j,0) = ecx(j,0) - 360.0
        else
           ecx(j,1) = ecx(j,1) - 360.0
        end if
     end if
  end do

  do j=0,esizes(0)-1
     gsn_polyline(wks,map,ecx(j,:),ecy(j,:),lres)
  end do


  ;
  ; Draw map outline
  ;
  mres = True
  mres@mpProjection      = "Orthographic"
  mres@mpCenterLatF      = cenlat
  mres@mpCenterLonF      = cenlon
  mres@mpGridAndLimbOn   = False
  mres@mpOutlineOn       = True
  mres@mpFillOn          = False
  mres@mpPerimOn         = False
  mres@gsnFrame          = False
  mres@mpLimitMode       = "Angles"
  mres@mpLeftAngleF      = leftAngle
  mres@mpRightAngleF     = rightAngle
  mres@mpBottomAngleF    = bottomAngle
  mres@mpTopAngleF       = topAngle
  mres@mpDataBaseVersion = "MediumRes"
  mres@mpOutlineBoundarySets = "GeophysicalAndUSStates"
  mapo = gsn_csm_map(wks,mres)

  frame(wks)

end
