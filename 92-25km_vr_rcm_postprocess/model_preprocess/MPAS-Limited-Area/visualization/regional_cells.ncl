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
  ; Get the name of the file containing the field from the FNAME environment variable
  ;
  fname = getenv("FNAME")
  f = addfile(fname,"r")

  ;
  ; Get the name of the file containing the mesh information from the GNAME environment variable
  ;
  gname = getenv("GNAME")
  g = addfile(gname,"r")

  ;
  ; Get the time slice to plot from the T environment variable - 0 is the first time in a file
  ;
  iTime = stringtointeger(getenv("T"))


  ;
  ; Center latitude and longitude
  ;
  cenlat = 20.0
  cenlon = 80.0
 

  ;
  ; Set plotting window
  ;
  leftAngle   = 60.0
  rightAngle  = 60.0
  bottomAngle = 60.0
  topAngle    = 60.0


  ;
  ; The field to be plotted
  ;
;  h = f->qv(iTime,:,0)        ; Water vapor mixing ratio at the surface
  h = f->ivgtyp(:)            ; Vegetation type


  ;
  ; The color map to use
  ; (see https://www.ncl.ucar.edu/Document/Graphics/color_table_gallery.shtml)
  ;
  colormap = "vegetation_modis"

  ;
  ; The number of colors in the color map
  ;
  nColors = 21

  ;
  ; The contour intervals
  ; E.g., fspan(1, 10, 10) yields (/1, 2, 3, 4, 5, 6, 7, 9, 10/)
  ; Typically, we have nColors-1 levels
  ;
  cnLevels = fspan(1.0, 20.0, nColors-1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  r2d = 57.2957795             ; radians to degrees

  maxedges = 7

  wks_type = "png"
  wks_type@wkWidth = 2500
  wks_type@wkHeight = 2500 
  wks_type@wkBackgroundOpacityF = 1.0
  wks = gsn_open_wks(wks_type,"cells")
  gsn_define_colormap(wks,colormap)
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
  res@mpLimitMode       = "Angles"
  res@mpLeftAngleF      = leftAngle
  res@mpRightAngleF     = rightAngle
  res@mpBottomAngleF    = bottomAngle
  res@mpTopAngleF       = topAngle
  res@mpOceanFillColor  = 0
  res@mpInlandWaterFillColor  = 0
  res@mpLandFillColor  = 0

  ;
  ; Set field name and units
  ;
  res@gsnLeftString   = h@long_name
  res@gsnRightString  = "["+h@units+"]"
  res@tiMainString    = chartostring(f->xtime(iTime,0:19))


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
     pres@gsFillColor = val_to_index(cnLevels, nColors, h(iCell)) + 2
     gsn_polygon(wks,map,xpoly(0:nEdgesOnCell(iCell)-1),ypoly(0:nEdgesOnCell(iCell)-1),pres);
  end do


  ;
  ; Draw label bar
  ;

  xcb = new((/4/), "float")
  ycb = new((/4/), "float")

  tres = True
  tres@txAngleF = 90.0
  tres@txFontHeightF = 0.010
  tres@txJust = "CenterRight"
  xoffset = 0.125
  barwidth = 0.75
  yoffset = 0.13
  barheight = 0.05
  intervalwidth = barwidth / int2flt(nIntervals)

  xcb(0) = xoffset
  ycb(0) = yoffset
  xcb(1) = xoffset - intervalwidth
  ycb(1) = yoffset + barheight/2.0
  xcb(2) = xoffset
  ycb(2) = yoffset + barheight
  tres@gsFillColor = 2
  gsn_polygon_ndc(wks,xcb(0:2),ycb(0:2),tres);

  labelInt = round(int2flt(nIntervals) / 10.0, 3)

  do i=0,nIntervals-1
     xcb(0) = xoffset + i*intervalwidth
     ycb(0) = yoffset

     xcb(1) = xoffset + (i+1)*intervalwidth
     ycb(1) = yoffset

     xcb(2) = xoffset + (i+1)*intervalwidth
     ycb(2) = yoffset + barheight

     xcb(3) = xoffset + i*intervalwidth
     ycb(3) = yoffset + barheight

     tres@gsFillColor = val_to_index(cnLevels, nColors, cnLevels(i)) + 2

     gsn_polygon_ndc(wks,xcb,ycb,tres);

     if (mod(i, labelInt) .eq. 0) then
        label = sprintf("%5.3g", cnLevels(i))
        gsn_text_ndc(wks, label, xcb(0), 0.98*yoffset, tres)
     end if
  end do

  xcb(0) = xoffset + barwidth
  ycb(0) = yoffset
  xcb(1) = xoffset + barwidth
  ycb(1) = yoffset + barheight
  xcb(2) = xoffset + barwidth + intervalwidth
  ycb(2) = yoffset + barheight/2.0
  tres@gsFillColor = (nColors-1) + 2
  gsn_polygon_ndc(wks,xcb(0:2),ycb(0:2),tres);
  label = sprintf("%5.3g", cnLevels(i))
  xcb(0) = xoffset + nIntervals*intervalwidth
  gsn_text_ndc(wks, label, xcb(0), 0.98*yoffset, tres)


  ;
  ; Draw map outline
  ;
  mres = True
  mres@mpProjection      = "Orthographic"
  mres@mpCenterLatF      = cenlat
  mres@mpCenterLonF      = cenlon
  mres@mpGridAndLimbOn   = True
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

