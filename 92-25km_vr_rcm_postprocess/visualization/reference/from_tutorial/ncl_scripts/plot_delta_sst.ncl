load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

  ;
  ; Whether to do color-filled plot (filled=True) or
  ;   to plot contours of height field (filled=False)
  ;
  filled   = True
;  filled   = False

  ;
  ; The (lat,lon) the plot is to be centered over
  ;
  cenLat   = 0.0
  cenLon   = 0.0

  ;
  ; Projection to use for plot
  ;
;  projection = "Orthographic"
  projection = "CylindricalEquidistant"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  r2d = 57.2957795             ; radians to degrees

  wks = gsn_open_wks("pdf","delta_sst")
  gsn_define_colormap(wks,"gui_default")

  fname = getenv("FNAME")
  f = addfile(fname,"r")
  gname = getenv("GNAME")
  g = addfile(gname,"r")

  lonCell   = g->lonCell(:) * r2d
  latCell   = g->latCell(:) * r2d
  lonVertex = g->lonVertex(:) * r2d
  latVertex = g->latVertex(:) * r2d
  lonEdge = g->lonEdge(:) * r2d
  latEdge = g->latEdge(:) * r2d
  verticesOnCell = g->verticesOnCell(:,:)
  alpha = g->angleEdge(:)

  res                      = True
  res@gsnMaximize          = True
  res@gsnSpreadColors      = True

  res@sfXArray             = lonCell
  res@sfYArray             = latCell

  res@cnFillMode           = "AreaFill"

  if (filled) then
     res@cnFillOn             = True
     res@cnLinesOn            = False
     res@cnLineLabelsOn       = False
  else
     res@cnFillOn             = False
     res@cnLinesOn            = True
     res@cnLineLabelsOn       = True
  end if

  res@cnInfoLabelOn        = True

  res@lbLabelAutoStride    = True
  res@lbBoxLinesOn         = False

  res@mpProjection      = projection
  res@mpDataBaseVersion = "MediumRes"
  res@mpCenterLatF      = cenLat
  res@mpCenterLonF      = cenLon
  res@mpGridAndLimbOn   = True
  res@mpGridAndLimbDrawOrder = "PreDraw"
  res@mpGridLineColor   = "Background"
  res@mpOutlineOn       = True
  res@mpDataBaseVersion = "Ncarg4_1"
  res@mpDataSetName     = "Earth..3"
  res@mpOutlineBoundarySets = "Geophysical"
  res@mpFillOn          = True
  res@mpPerimOn         = True
  res@gsnFrame          = False
  res@cnLineThicknessF  = 2.0
  res@cnLineColor       = "NavyBlue"
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF = -2.0
  res@cnMaxLevelValF =  2.0
  res@cnLevelSpacingF =  0.2
  res@mpLimitMode = "LatLon"
;  res@mpMinLonF = 90.0
;  res@mpMaxLonF = 170.0
;  res@mpMinLatF = -10.0
;  res@mpMaxLatF = 40.0
  res@mpMinLonF = -180.0
  res@mpMaxLonF = 180.0
  res@mpMinLatF = -90.0
  res@mpMaxLatF = 90.0

  res@mpFillOn              = True         ; Turn on map fill.
  res@mpFillAreaSpecifiers  = (/"Land"/)
  res@mpSpecifiedFillColors = (/0/)
  res@mpAreaMaskingOn       = True            ; Indicate we want to 
  res@cnFillDrawOrder       = "Predraw"       ; Draw contours first.

  dims = dimsizes(f->xtime)
  nTimes  = dims(0)   ; number of ouput time.

  res@tiMainString = "SST difference from "+f->xtime(0,0:12)+" to "+f->xtime(nTimes-1,0:12)+" (K)"

  fld = f->sst(nTimes-1,:) - f->sst(0,:)
  res@cnLineDashPattern = 0
  map = gsn_csm_contour_map(wks,fld,res)

  frame(wks)

end

