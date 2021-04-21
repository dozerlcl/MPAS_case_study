load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Converts a value to a color table index (0-based) according
; to the specified set of levels.
;
; If (val < cnLevels(0)) returns 0
; If (val >= cnLevels(nLevels-1)) returns nColors-1
; If (val == NaN) returns 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function val_to_index(cnLevels, nColors, val)
begin
   nLevels = dimsizes(cnLevels)
   nIntervals = nLevels - 1
   intervalSpan = int2flt(nColors) / int2flt(nIntervals+1) ; +1 for end intervals

   if (val .lt. cnLevels(0)) then
      return (0)
   end if
   if (val .ge. cnLevels(nLevels-1)) then
      return (nColors-1)
   end if

   j = 0
   do i=0,nIntervals-1
       if (val .ge. cnLevels(i) .and. val .lt. cnLevels(i+1)) then
           d = cnLevels(i+1) - cnLevels(i)
           w1 = (cnLevels(i+1) - val) / d
           w2 = (val - cnLevels(i)) / d
           jfloat = w2 * int2flt(i+1) + w1 * int2flt(i)
           j = floattoint(floor(intervalSpan * int2flt(i+1)))   ; +1 for left end iterval
           break
       end if
   end do

   return (j)
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Main script
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
begin

  ;
  ; Center latitude and longitude
  ;
  cenlat = 32.5
  cenlon = 100.
 

  ;
  ; Set plotting window
  ;
  leftAngle   = 90.0
  rightAngle  = 90.0
  bottomAngle = 90.0
  topAngle    = 90.0

  ;
  ; Get the name of the file containing the static information from the GNAME environment variable
  ;
;   gname = getenv("GNAME")
  gname = "/m2data2/yycheng/MPAS/TOOLS/MPAS-Limited-Area/china_rcm.static.nc"
  g = addfile(gname,"r")

  ;
  ; The field to be plotted
  ;
  h = g->ter(:)            ; Terrain height
  ivgtyp = g->ivgtyp(:)    ; Vegetation type

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  r2d = 57.2957795             ; radians to degrees

  maxedges = 7

  wks_type = "png"
  wks_type@wkWidth = 2500
  wks_type@wkHeight = 2500 
  wks_type@wkBackgroundOpacityF = 1.0
  wks = gsn_open_wks(wks_type,"./output_pic/regional_terrain")
;   system("export NCARG_COLORMAPS=/m2data2/yycheng/MPAS/TOOLS/visualization/from_tutorial/ncl_colormaps:$NCARG_ROOT/lib/ncarg/colormaps")
  gsn_define_colormap(wks,"mpas_terrain")
;   gsn_define_colormap(wks,"BlueRed")
  nColors = 98
  cnLevels = fspan(0.0, 4000.0, 99)
  nLevels = dimsizes(cnLevels)
  nIntervals = nLevels - 1

  nEdgesOnCell = g->nEdgesOnCell(:)
  verticesOnCell = g->verticesOnCell(:,:)
  verticesOnEdge = g->verticesOnEdge(:,:)
  x   = g->lonCell(:) * r2d
  y   = g->latCell(:) * r2d
  lonCell = g->lonCell(:) * r2d
  latCell = g->latCell(:) * r2d
  lonVertex = g->lonVertex(:) * r2d
  latVertex = g->latVertex(:) * r2d

  res                      = True
  res@gsnPaperOrientation  = "portrait"

  res@sfXArray             = x
  res@sfYArray             = y

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
    ;;;----------------change progection--------------------------

;   res@mpLimitMode       = "Angles"
;   res@mpLeftAngleF      = leftAngle
;   res@mpRightAngleF     = rightAngle
;   res@mpBottomAngleF    = bottomAngle
;   res@mpTopAngleF       = topAngle
  res@mpLimitMode       = "LatLon"
  res@mpMinLatF      = -5.
  res@mpMaxLatF      = 65.
  res@mpMinLonF      = 55.
  res@mpMaxLonF      = 145.
  ;;;----------------change progection--------------------------
  res@mpOceanFillColor  = 2
  res@mpInlandWaterFillColor  = 2
  res@mpLandFillColor  = 3

  ;
  ; Set field name and units
  ;
;   res@gsnLeftString   = h@long_name
;   res@gsnLeftString   = h@long_name
  res@gsnRightString  = "["+h@units+"]"
;   res@tiMainString    = gname
  res@tiMainString    = "regional terrain"


  sizes = dimsizes(h)
  nCells = sizes(0)
  xpoly = new((/maxedges/), "double")
  ypoly = new((/maxedges/), "double")

  ;
  ; The purpose of this next line is simply to set up a graphic ('map')
  ;    that uses the projection specified above, and over which we
  ;    can draw polygons
  ;
  map = gsn_csm_map(wks,res)


  cres = True
  cres@txFontColor = 0        ; background color
  cres@txFontHeightF = 0.025


  ;
  ; Draw polygons for cells
  ;
  pres = True
  do iCell=0,nCells-1
     do i=0,nEdgesOnCell(iCell)-1
        xpoly(i) = lonVertex(verticesOnCell(iCell,i)-1)
        ypoly(i) = latVertex(verticesOnCell(iCell,i)-1)
        if (i .gt. 0) then
           if (abs(xpoly(i) - xpoly(0)) .gt. 180.0) then
              if (xpoly(i) .gt. xpoly(0)) then
                 xpoly(i) = xpoly(i) - 360.0
              else
                 xpoly(i) = xpoly(i) + 360.0
              end if
           end if
        end if
     end do
     if (ivgtyp(iCell) .eq. 17) then
        pres@gsFillColor = 4
     else
        pres@gsFillColor = val_to_index(cnLevels, nColors, h(iCell)) + 5
     end if
     gsn_polygon(wks,map,xpoly(0:nEdgesOnCell(iCell)-1),ypoly(0:nEdgesOnCell(iCell)-1),pres);

  end do

  ;
  ; Draw map outline
  ;
  mres = True
  mres@mpProjection      = "Orthographic"
  mres@mpCenterLatF      = cenlat
  mres@mpCenterLonF      = cenlon
;   mres@mpGridAndLimbOn   = False
  mres@mpGridAndLimbOn   = True ; turn on grid
  mres@pmTickMarkDisplayMode  = "always" ; pm tickmark
  mres@mpGridAndLimbDrawOrder = "Draw"
;   mres@tiMainString           = "Lat/lon grid"
  mres@mpGridSpacingF         = 10.
  mres@mpGridLineThicknessF   = 2.0
  mres@mpGridLineColor        = "Gray30"
  mres@mpGridAndLimbOn        = True
  mres@pmTickMarkDisplayMode  = "Always"           ; turn on tickmarks
  mres@mpGridAndLimbDrawOrder = "PostDraw"          ; Draw grid before

  mres@mpGridLatSpacingF = 10
  mres@mpGridLonSpacingF = 10

  mres@mpOutlineOn       = True
  mres@mpFillOn          = False
  mres@mpPerimOn         = False
  mres@gsnFrame          = False
  ;;;----------------change progection--------------------------
;   mres@mpLimitMode       = "Angles"
;   mres@mpLeftAngleF      = leftAngle
;   mres@mpRightAngleF     = rightAngle
;   mres@mpBottomAngleF    = bottomAngle
;   mres@mpTopAngleF       = topAngle
  mres@mpLimitMode       = "LatLon"
  mres@mpMinLatF      = -5.
  mres@mpMaxLatF      = 65.
  mres@mpMinLonF      = 55.
  mres@mpMaxLonF      = 145.
  ;;;----------------change progection--------------------------

  mres@mpDataBaseVersion = "MediumRes"
  mres@mpOutlineBoundarySets = "GeophysicalAndUSStates"
  mapo = gsn_csm_map(wks,mres)



  frame(wks)

end

