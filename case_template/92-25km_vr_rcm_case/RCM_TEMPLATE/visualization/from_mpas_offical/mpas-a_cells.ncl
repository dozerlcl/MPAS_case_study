;;; 11.9 
;;; https://www2.mmm.ucar.edu/projects/mpas/visualization/ncl/
;;;   绘制变量在原始网格上的情况 选取 history 中的 变量 qv
;;;    简单调整了下绘图范围
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

  r2d = 57.2957795             ; radians to degrees

  maxedges = 8 

  wks = gsn_open_wks("png","./output_pic/atm_cells")
  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

;   fname = getenv("FNAME")
;   filedir = "/m2data2/yycheng/MPAS/MESH/x1.40962/"
;   filename = "x1.40962.grid.nc"
  filedir = "/raid52/yycheng/MPAS/92-25km_VR/out/history_24hr/"
  filename = "history.2003-08-31.nc"
  f = addfile(filedir + filename,"r")

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
  ; res@gsnMaximize          = True

  res@sfXArray             = x
  res@sfYArray             = y

  res@cnFillOn             = True
  res@cnFillMode           = "RasterFill"
  res@cnLinesOn            = False
  res@cnLineLabelsOn       = False
  res@cnInfoLabelOn        = False

  res@lbLabelAutoStride    = False
  res@lbOrientation        = "vertical"
  res@lbBoxLinesOn         = False

  res@mpProjection      = "CylindricalEquidistant"
;  res@mpProjection      = "Orthographic"
  ; res@mpDataBaseVersion = "MediumRes"

  ; res@mpDataBaseVersion = "Ncarg4_1"   ;地图采用中等分辨率
  ;   ; res@mpDataSetName="Earth..4"
  ;   ; /m2data2/yycheng/playground/NCL-noob-s-practices/till2020.06/NCL-Chinamap-master
  ; res@mpDataSetName = "/m2data2/yycheng/playground/NCL-noob-s-practices/till2020.06/NCL-Chinamap-master/database/Earth..4" ; 使用大气所的dataset数据
  ; res@mpOutlineOn=True

  res@mpCenterLatF      = 0.
  res@mpCenterLonF      = 0.
  res@mpGridAndLimbOn   = False
  res@mpOutlineOn       = False
  res@mpFillOn          = False
  res@mpPerimOn         = False
  res@gsnFrame          = False

  
  ;;; add limit
   res@mpProjection        = "CylindricalEquidistant"
   res@mpMinLonF           = 120
   res@mpMaxLonF           = 122
   res@mpMinLatF           = 22
   res@mpMaxLatF           = 26
   res@pmTickMarkDisplayMode = "Always"   ; better map tickmarks

  ;
  ; The purpose of this section is simply to set up a graphic ('map')
  ;    that uses the projection specified above, and over which we
  ;    can draw polygons
  ;
  h   = f->areaCell(:)
  sizes = dimsizes(h)
  nCells = sizes(0)
  xpoly = new((/maxedges/), "double")
  ypoly = new((/maxedges/), "double")
  res@cnConstFLabelOn = False
  res@lbLabelBarOn = False
  map = gsn_csm_contour_map(wks,h,res)

;   t = stringtointeger(getenv("T"))

  ;
  ; Set the field to be plotted here
  ;
  pres = True
  pres@lbOrientation  = "vertical"
  pres@pmLabelBarSide = "Left"
  pres@pmLabelBarParallelPosF = 2.
  ; pres@gsnMaximize          = True
  h   = f->t2m(:,:)
  h   = h - 273.15
  ; minfld = min(h)
  ; maxfld = max(h)
  minfld = 14.
  maxfld = 30.
  fldrange = maxfld - minfld
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
  pres@gsFillColor = doubletointeger(198*(h(iCell) - minfld)/fldrange+2)
  gsn_polygon(wks,map,xpoly(0:nEdgesOnCell(iCell)-1),ypoly(0:nEdgesOnCell(iCell)-1),pres);
;   printVarSummary(h(iCell))
;   print(tostring(h(iCell)))
  txres               =  True
  txres@txFontHeightF = 0.008
  txres@txFontColor   = 0
;   print(sprintf("%2.1f", h(iCell)))
;   print(tostring(doubletointeger(h(iCell*10))/10.))
  gsn_text(wks, map, tostring(sprintf("%2.1f", h(iCell))), x(iCell), y(iCell), txres)
;   gsn_text(wks, map, tostring(sprintf("%2.1f", h(iCell))), xpoly(0:nEdgesOnCell(iCell)-1), ypoly(0:nEdgesOnCell(iCell)-1), txres)
  end do


  ;
  ; Draw label bar
  ;

  xcb = new((/4/), "float")
  ycb = new((/4/), "float")

  tres = True
  tres@txAngleF = 90.0
  tres@txFontHeightF = 0.015
  do i=2,200
     xcb(0) = 0.125 + i*0.75/198
     ycb(0) = 0.11

     xcb(1) = 0.125 + (i+1)*0.75/198
     ycb(1) = 0.11

     xcb(2) = 0.125 + (i+1)*0.75/198
     ycb(2) = 0.16

     xcb(3) = 0.125 + i*0.75/198
     ycb(3) = 0.16

     tres@gsFillColor = i
    ; turn individual labels
    ;  gsn_polygon_ndc(wks,xcb,ycb,tres);

     j = (i-2) % 20
     if ((j .eq. 0) .or. (i .eq. 200)) then
        ff = minfld + int2flt(i-2) * fldrange / 198.0
        label = sprintf("%5.3g", ff)
    ; turn individual labels
        ; gsn_text_ndc(wks, label, xcb(0), 0.060, tres)
     end if

  end do

  mres = True
  ; mres@gsnMaximize       = True
  mres@mpCenterLatF      = 0.
  mres@mpCenterLonF      = 0.
  mres@mpGridAndLimbOn   = False
  mres@mpOutlineOn       = True
  mres@mpFillOn          = False
  mres@mpPerimOn         = False
  mres@gsnFrame          = False

  mres@mpProjection      = res@mpProjection
  mres@mpMinLonF         = res@mpMinLonF
  mres@mpMaxLonF         = res@mpMaxLonF
  mres@mpMinLatF         = res@mpMinLatF
  mres@mpMaxLatF         = res@mpMaxLatF
  mres@pmTickMarkDisplayMode = "Always"   ; better map tickmarks

    mres@mpDataBaseVersion = "Ncarg4_1"   ;地图采用中等分辨率
    res@mpDataSetName="Earth..4"
    ; /m2data2/yycheng/playground/NCL-noob-s-practices/till2020.06/NCL-Chinamap-master
    mres@mpDataSetName = "/m2data2/yycheng/playground/NCL-noob-s-practices/till2020.06/NCL-Chinamap-master/database/Earth..4" ; 使用大气所的dataset数据
    mres@mpOutlineOn=True
    ; mres@mpCountyLineThicknessF =
  ;;
  mapo = gsn_csm_map(wks,mres)

  frame(wks)

end

