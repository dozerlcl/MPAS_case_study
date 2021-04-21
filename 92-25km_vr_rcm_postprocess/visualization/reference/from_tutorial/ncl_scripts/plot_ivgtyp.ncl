load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Converts a value to a color table index (0-based) according
; to the specified set of levels.
;
; If (val < cnLevels(0)) returns 0
; If (val >= cnLevels(nLevels-1)) returns nColors-1
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
;           j = round(intervalSpan * int2flt(i+1), 3)   ; +1 for left end iterval
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


  fname = getenv("FNAME")
  f = addfile(fname,"r")

;
; Useful parameters
;
  
; Font size for cell labels:
cellLabelSize = 0.0025
 
; Whether cell indices are 0-based or 1-based:
indexBase = 1
 
; The bounding box for the plot
mapLeft   = -180.0   ; longitude
mapRight  = 180.0   ; longitude
mapBottom = -90.0    ; latitude
mapTop    = 90.0    ; latitude

; The field to be plotted
h   = f->ivgtyp(:)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  r2d = 57.2957795             ; radians to degrees

  maxedges = 7

  wks = gsn_open_wks("pdf","IVGTYP")
  gsn_define_colormap(wks,"matlab_hsv")
  nColors = 62
  cnLevels = fspan(1.0, 24.0, 24)
  nLevels = dimsizes(cnLevels)
  nIntervals = nLevels - 1

  nEdgesOnCell = f->nEdgesOnCell(:)
  verticesOnCell = f->verticesOnCell(:,:)
  verticesOnEdge = f->verticesOnEdge(:,:)
  x   = f->lonCell(:) * r2d
  y   = f->latCell(:) * r2d
  lonCell = f->lonCell(:) * r2d
  latCell = f->latCell(:) * r2d
  lonVertex = f->lonVertex(:) * r2d
  latVertex = f->latVertex(:) * r2d

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

  res@mpProjection      = "CylindricalEquidistant"
;  res@mpProjection      = "Orthographic"
  res@mpDataBaseVersion = "MediumRes"
  res@mpCenterLatF      = 0.
  res@mpCenterLonF      = 0.
  res@mpGridAndLimbOn   = False
  res@mpOutlineOn       = False
  res@mpFillOn          = False
  res@mpPerimOn         = False
  res@gsnFrame          = False
  res@mpLimitMode       = "LatLon"
  res@mpMinLonF         = mapLeft
  res@mpMaxLonF         = mapRight
  res@mpMinLatF         = mapBottom
  res@mpMaxLatF         = mapTop

  ;
  ; Set field name and units
  ;
  res@gsnLeftString   = ""
  res@gsnRightString  = ""

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
  cres@txFontHeightF = cellLabelSize


  ;
  ; Add text for min/max of plotted cells
  ;
  xc = 0.50
  yc = 0.80
  ttres = True
  ttres@txFontHeightF = 0.025
  ttres@txJust = "CenterCenter"
  gsn_text_ndc(wks, "Dominant Vegetation Type", xc, yc, ttres)


  ;
  ; Draw polygons for cells
  ;

  pres = True
  minVal = h(1)
  maxVal = h(1)
  do iCell=0,nCells-1
     if (lonCell(iCell) .gt. 180.0) then
        lonCell(iCell) = lonCell(iCell) - 360.0
     end if
     if (latCell(iCell) .ge. mapBottom .and. \
         latCell(iCell) .le. mapTop    .and. \
         lonCell(iCell) .ge. mapLeft   .and. \
         lonCell(iCell) .le. mapRight) then
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
        if (h(iCell) .lt. minVal) then
           minVal = h(iCell)
        end if
        if (h(iCell) .gt. maxVal) then
           maxVal = h(iCell)
        end if
        pres@gsFillColor = val_to_index(cnLevels, nColors, h(iCell)) + 2
        gsn_polygon(wks,map,xpoly(0:nEdgesOnCell(iCell)-1),ypoly(0:nEdgesOnCell(iCell)-1),pres);

; Example of adding text to each cell
;        cellid = sprinti("%3i", pres@gsFillColor)
;        gsn_text(wks,map,cellid,lonCell(iCell),latCell(iCell),cres)
     end if
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

     label = sprintf("%5.3g", cnLevels(i))
     gsn_text_ndc(wks, label, xcb(0), 0.98*yoffset, tres)

  end do

  xcb(0) = xoffset + barwidth
  ycb(0) = yoffset
  xcb(1) = xoffset + barwidth
  ycb(1) = yoffset + barheight
  xcb(2) = xoffset + barwidth + intervalwidth
  ycb(2) = yoffset + barheight/2.0
  tres@gsFillColor = (nColors-1) + 2
  gsn_polygon_ndc(wks,xcb(0:2),ycb(0:2),tres);

  label = sprintf("%5.3g", cnLevels(nLevels-1))
  gsn_text_ndc(wks, label, xcb(0), 0.98*yoffset, tres)

  mres = True
  mres@mpCenterLatF      = 0.
  mres@mpCenterLonF      = 0.
  mres@mpGridAndLimbOn   = False
  mres@mpOutlineOn       = True
  mres@mpFillOn          = False
  mres@mpPerimOn         = False
  mres@gsnFrame          = False
  mres@mpLimitMode       = "LatLon"
  mres@mpMinLonF         = mapLeft
  mres@mpMaxLonF         = mapRight
  mres@mpMinLatF         = mapBottom
  mres@mpMaxLatF         = mapTop
  mres@mpDataBaseVersion = "MediumRes"
  mres@mpOutlineBoundarySets = "GeophysicalAndUSStates"
  mapo = gsn_csm_map(wks,mres)

  frame(wks)

end

