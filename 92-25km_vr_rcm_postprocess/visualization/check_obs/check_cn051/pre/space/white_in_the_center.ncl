begin
;************************************************
; read in netCDF file
;************************************************
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
  u = a->U(1,:,:)                                ; read July zonal winds
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","color")             ; send graphics to PNG file
  gsn_define_colormap(wks,"ncl_default")
  cmap = read_colormap_file("ncl_default")

  res                      = True               ; plot mods desired
  res@tiMainString         = "Default Color"    ; main title
  res@cnFillOn             = True               ; turn on color fill
  res@gsnDraw = False
  res@gsnFrame = False
  res@lbLabelBarOn = False

  plot = gsn_csm_contour_map(wks,u, res)     ; create plot

  getvalues plot@contour    ; retrieve colors/levels from plot
    "cnFillColors" : colors
    "cnLevels"     : levels
  end getvalues

  ncolors = dimsizes(colors)
  colors(ncolors/2-1) = 0    ; set two middle colors to white
  colors(ncolors/2) = 0       ; if you have odd number of colors this should be modified

  print(colors)

  setvalues plot@contour
     "cnFillColors" : colors       ; reset the colors
  end setvalues

  lbres                    = True
  lbres@vpWidthF           = 0.55
  lbres@vpHeightF          = 0.075

  lbres@lbPerimOn          = False            ; Turn off perimeter.
  lbres@lbOrientation      = "Horizontal"     ; Default is vertical.
  lbres@lbFillColors       = colors
  lbres@lbMonoFillPattern  = True             ; Fill them all solid.
  lbres@lbLabelFontHeightF = 0.020            ; Label font height
  lbres@lbLabelAlignment   = "InteriorEdges"
  lbid = gsn_create_labelbar(wks,dimsizes(levels),levels,lbres)       ; create the labelbar


  amres                  = True
  amres@amJust           = "BottomCenter"
  amres@amParallelPosF   =  0.0
  amres@amOrthogonalPosF = 0.75
  annoid = gsn_add_annotation(plot,lbid,amres)    ; attach the labelbar to the plot
  draw(plot)
  frame(wks)
end
