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

  t = stringtointeger(getenv("T"))
  fname = getenv("FNAME")
  f = addfile(fname,"r")
  gname = getenv("GNAME")
  g = addfile(gname,"r")

;
; Useful parameters
;
  
; Font size for cell labels:
cellLabelSize = 0.0025
 
; The bounding box for the plot
leftAngle   = -80.0
rightAngle  = -65.0
bottomAngle = -30.0
topAngle    = -5.0

; The field to be plotted
h   = f->wind_speed_level1_max(0,:)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  r2d = 57.2957795             ; radians to degrees

  maxedges = 7

; export NCARG_COLORMAPS=`pwd`:$NCARG_ROOT/lib/ncarg/colormaps

  wks_type = "png"
  wks_type@wkWidth = 2500
  wks_type@wkHeight = 2500 
  wks_type@wkBackgroundOpacityF = 0.0
  wks = gsn_open_wks(wks_type,"fig6")
  gsn_define_colormap(wks,"duda")
  nColors = 252
  cnLevels = fspan(0,30,50)
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
  res@mpCenterLonF      = -72.5
  res@mpCenterLatF      = -17.5
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
  res@mpOceanFillColor  = 2
  res@mpInlandWaterFillColor  = 2
  res@mpLandFillColor  = 3

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
  ; Draw polygons for cells
  ;

  pres = True
  minVal = h(1)
  maxVal = h(1)
  do iCell=0,nCells-1
     if (lonCell(iCell) .gt. 180.0) then
        lonCell(iCell) = lonCell(iCell) - 360.0
     end if
;     if (h(iCell) .le. 5) then
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
        pres@gsFillColor = val_to_index(cnLevels, nColors, h(iCell)) + 4
        gsn_polygon(wks,map,xpoly(0:nEdgesOnCell(iCell)-1),ypoly(0:nEdgesOnCell(iCell)-1),pres);

; Example of adding text to each cell
;        cellid = sprinti("%3i", pres@gsFillColor)
;        gsn_text(wks,map,cellid,lonCell(iCell),latCell(iCell),cres)

;     end if
  end do


  ;
  ; Draw mesh outline from global mesh
  ;
  glname = getenv("GNAME")
  global = addfile(glname,"r")

  glonEdge = global->lonEdge(:) * r2d
  glatEdge = global->latEdge(:) * r2d
  glonVertex = global->lonVertex(:) * r2d
  glatVertex = global->latVertex(:) * r2d
  gverticesOnEdge = global->verticesOnEdge(:,:)

  lres = True
  lres@gsLineThicknessF = 2.75

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


  mres = True
  mres@mpProjection      = "Orthographic"
  mres@mpCenterLonF      = -72.5
  mres@mpCenterLatF      = -17.5
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

