;**********************************
; taylor_4.ncl
;**********************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
;
; These files still have to be loaded manually
load "./taylor_diagram.ncl"
load "./taylor_metrics_table.ncl"
;**********************************
begin
;**********************************
; Assume the following have already been computed:
;   _ratio are the ratio:  Case_Variance/Reference_Variance
;   _cc    are the cross correlation coef of Case to Reference
; In this example, these are derived for annual mean climatologies.
;**********************************

; Cases [Model]
  case      = (/ "Case A", "Case B" /) 
  nCase     = dimsizes(case )                 ; # of Cases [Cases]

; variables compared
  var       = (/ "SLP","Tsfc" ,"Prc","Prc 30S-30N","LW","SW", "U300", "Guess" \ 
               , "RH" ,"LHFLX","TWP","CLDTOT"     ,"O3","Q" , "PBLH", "Omega" /) 
  nVar      = dimsizes(var)                   ; # of Variables

; more info to be added [all are bogus]
  source    = (/ "ERA40", "ERA40","GPCP" , "GPCP", "ERS" , "ERS", "ERA40", "BOGUS" \
               , "NCEP",  "ERA40","ERA40", "NCEP", "NASA", "JMA", "JMA"  , "CAS"  /)

; "Case A"                        
  CA_ratio   = (/1.230, 0.988, 1.092, 1.172, 1.064, 0.966, 1.079, 0.781 \
                ,1.122, 1.000, 0.998, 1.321, 0.842, 0.978, 0.998, 0.811 /)
  CA_cc      = (/0.958, 0.973, 0.740, 0.743, 0.922, 0.982, 0.952, 0.433 \
                ,0.971, 0.831, 0.892, 0.659, 0.900, 0.933, 0.912, 0.633 /)

; "Case B" 
  CB_ratio   = (/1.129, 0.996, 1.016, 1.134, 1.023, 0.962, 1.048, 0.852 \ 
                ,0.911, 0.835, 0.712, 1.122, 0.956, 0.832, 0.900, 1.311 /)
  CB_cc      = (/0.963, 0.975, 0.801, 0.814, 0.946, 0.984, 0.968, 0.647 \ 
                ,0.832, 0.905, 0.751, 0.822, 0.932, 0.901, 0.868, 0.697 /)

; arrays to be passed to taylor_diagram. It will calculate the x xnd y coordinates.
  ratio      = new ((/nCase, nVar/),typeof(CA_cc) )  
  cc         = new ((/nCase, nVar/),typeof(CA_cc) ) 

  ratio(0,:) = CA_ratio 
  ratio(1,:) = CB_ratio

  cc(0,:)    = CA_cc 
  cc(1,:)    = CB_cc

;**********************************
; create plot
;**********************************
  varSource = var +"_"+ source              ; add extra info [*not* required]

  ty_opt   = True                           ; taylor diagram with options
        
  ty_opt@Markers       = (/16, 16/)         ; make all solid fill
  ty_opt@Colors        = (/"red", "blue" /)          
  ty_opt@varLabels     = varSource
  ty_opt@caseLabels    = case

  ty_opt@varLabelsYloc = 1.5                ; Move location of variable labels [default 0.45]
  ty_opt@caseLabelsFontHeightF = 0.14       ; make slight larger   [default=0.12 ]
  ty_opt@varLabelsFontHeightF  = 0.011      ; make slight smaller  [default=0.013]
 
  ty_opt@tiMainString  = "Annual"           ; title
  ty_opt@stnRad        = (/ 0.5, 1.5 /)     ; additional standard radii
  ty_opt@ccRays        = (/ 0.6, 0.9 /)     ; correllation rays
  ty_opt@centerDiffRMS = True               ; RMS 'circles'

  wks   = gsn_open_wks("png","./output_pic/taylor.000001")      ; send graphics to PNG file
  plot  = taylor_diagram(wks,ratio,cc,ty_opt)

;**************************************************
; fill an array for a "taylor metrics table"
;**************************************************

  season    = (/ "ANN" /)
  nSeason   = dimsizes(season)

  table     = new ( (/nCase,nSeason,nVar/), typeof(ratio) )
  table(0,0,:) = CA_ratio
  table(1,0,:) = CB_ratio

  tt_opt        = True
  tt_opt@pltType= "png"                  ; "eps" [default], "pdf", "ps"
                                         ; "png", "gif" [if you have ImageMajik 'convert']
  tt_opt@color0 = "palegreen2"
  tt_opt@color1 = "tomato2"


  taylor_metrics_table("taylor.000002", varSource, case ,season, table, tt_opt)
end 