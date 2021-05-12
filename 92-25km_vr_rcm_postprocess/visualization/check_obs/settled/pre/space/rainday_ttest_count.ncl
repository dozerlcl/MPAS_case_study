;;; 21.03.05
;;;     修改为进行CN05.1 CMORPH 的降水后处理的读取文件
;;;     在 TEMP_DATA下先进行的了 mask 处理
;;;     处理的 ncl脚本（其中顺带使用了 cdo 命令） 在 ../precip_preprocess/ncl_mask.ncl 文件之中
;;; 21.03.18
;;;   修改绘图方式，将 gsn_csm_contour overlay到 map上，需要单独绘制每个map，为之后的统计检验做准备
;;;   进行均值差异的 t 检验
;;; 21.04.07
;;;   指绘制平均图的差异,添加shapefile,是我国一级河流的shp文件
;;; 21.04.21
;;;   添加输出的pictype，修改输出文件名为bias_test
load "./shapefile_utils.ncl"
function count_rainday(cn051, cmorph, vr, rcm)
begin

;;;-----count wet day-----

  cn051_flitter = where(cn051.gt.0.1, cn051, cn051@_FillValue)
  cmorph_flitter = where(cmorph.gt.0.1, cmorph, cmorph@_FillValue)
  vr_flitter    = where(vr.gt.0.1, vr, vr@_FillValue)
  rcm_flitter   = where(rcm.gt.0.1, vr, vr@_FillValue)

  cn051_rainday_intensity = dim_avg_n_Wrap(cn051_flitter, 0)
  cmorph_rainday_intensity = dim_avg_n_Wrap(cmorph_flitter, 0)
  vr_rainday_intensity    = dim_avg_n_Wrap(vr_flitter, 0)
  rcm_rainday_intensity   = dim_avg_n_Wrap(rcm_flitter, 0)
  
  copy_VarCoords(cn051(0,: ,:), cn051_rainday_intensity)
  copy_VarCoords(cmorph(0,: ,:), cmorph_rainday_intensity)
  copy_VarCoords(vr(0,: ,:), vr_rainday_intensity)
  copy_VarCoords(rcm(0,: ,:), rcm_rainday_intensity)
  ; pre_vr = where(pre_vr.gt.0.1, pre_vr, pre_vr@_FillValue)
  ; pre_rcm = where(pre_rcm.gt.0.1, pre_rcm, pre_vr@_FillValue)
  cn051_rainday = where(cn051.gt.0.1, 1, 0)
  cmorph_rainday = where(cmorph.gt.0.1, 1, 0)
  vr_rainday    = where(vr.gt.0.1, 1, 0)
  rcm_rainday   = where(rcm.gt.0.1, 1, 0)

  cn051_rainday_mean = dim_avg_n_Wrap(cn051_rainday, 0)
  cmorph_rainday_mean = dim_avg_n_Wrap(cmorph_rainday, 0)
  vr_rainday_mean = dim_avg_n_Wrap(vr_rainday, 0)
  rcm_rainday_mean = dim_avg_n_Wrap(rcm_rainday, 0)
  copy_VarCoords(cn051(0, :, :), cn051_rainday_mean)
  copy_VarCoords(cmorph(0, :, :), cmorph_rainday_mean)
  copy_VarCoords(vr(0, :, :), vr_rainday_mean)
  copy_VarCoords(rcm(0, :, :), rcm_rainday_mean)
  return ([/cn051_rainday_mean, cn051_rainday_intensity, cmorph_rainday_mean, cmorph_rainday_intensity,\
  vr_rainday_mean, vr_rainday_intensity, rcm_rainday_mean, rcm_rainday_intensity/])
end

begin

;;;>>>plot set
  fignum = 8
  plot = new(fignum,graphic) ;定义子图数组
  pictype = "png"
  ; wks_type = "png"
  pictype@wkWidth = 1600 
  pictype@wkHeight = 1600
  wks = gsn_open_wks(pictype,"./output_pic/"+"precip_98-17_rainday_ttest")
;;;<<<data reader
  ;   mask 之后集中存放降水数据的位置：   /raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/mask_pre/mask_res
  dir_cn051 = "/raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/mask_pre/mask_res/"
  filename_cn051 = "mask_sel_CN05.1_Pre_1961_2018_daily_025x025.nc"
  
  dir_cmorph = "/raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/mask_pre/mask_res/"
  filename_cmorph = "mask_sel_CMORPH_98-17.nc"
  
  dir_vr = "/raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/mask_pre/mask_res/"
  filename_vr = "mask_vr_pre_98-17.nc"
  
  dir_rcm = "/raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/mask_pre/mask_res/"
  filename_rcm = "mask_rcm_pre_98-17.nc"

  f = addfile(dir_cn051 + filename_cn051, "r") 
  cn051 = f->$"pre"$

  f = addfile(dir_cmorph + filename_cmorph, "r") 
  cmorph = f->$"cmorph"$(:,0,:,:)

  f = addfile(dir_vr + filename_vr, "r") 
  vr   = f->$"precip_MPAS"$

  f = addfile(dir_rcm + filename_rcm, "r") 
  rcm  = f->$"precip_MPAS"$
  
;;;-----select time index -----
  time_all = cd_calendar(pre_vr&Time, 0)
  ind_am  = ind( (time_all(:,1).eq.4) .or. (time_all(:,1).eq.5) )
  ind_jja = ind( (time_all(:,1).eq.6) .or. (time_all(:,1).eq.7) .or. (time_all(:,1).eq.8) )
;;;----- count rainday -----
list_test = count_rainday(cn051(ind_am, :, :), cmorph(ind_am, :, :), vr(ind_am, :, :), rcm(ind_am, :, :))

  am_cn051_rainday = list_test[0]
  am_cn051_rainday_intensity = list_test[1]
  am_cmorph_rainday = list_test[2]
  am_cmorph_rainday_intensity = list_test[3]
  am_vr_rainday = list_test[4]
  am_vr_rainday_intensity = list_test[5]
  am_rcm_rainday = list_test[6]
  am_rcm_rainday_intensity = list_test[7]
  delete(list_test)
list_test = count_rainday(cn051(ind_jja, :, :), cmorph(ind_jja, :, :), vr(ind_jja, :, :), rcm(ind_jja, :, :))
  jja_cn051_rainday = list_test[0]
  jja_cn051_rainday_intensity = list_test[1]
  jja_cmorph_rainday = list_test[2]
  jja_cmorph_rainday_intensity = list_test[3]
  jja_vr_rainday = list_test[4]
  jja_vr_rainday_intensity = list_test[5]
  jja_rcm_rainday = list_test[6]
  jja_rcm_rainday_intensity = list_test[7]
  delete(list_test)
;;;>>> output preprocess refine

  diro = "/m2data2/yycheng/playground/MPAS_case_study/92-25km_vr_rcm_postprocess/visualization/check_obs/settled/pre/space/output_nc/"
  filo = "rainday_mean.nc"
  system("rm -f "+ diro + filo) ;删除目录下的同名文件
  ncdf = addfile(diro + filo, "c") ; c表示创建netcdf文件
  ncdf->$"am_cn051_rainday"$      = am_cn051_rainday_mean
  ncdf->$"am_cn051_intensity"$    = am_cn051_rainday_intensity
  ncdf->$"am_cmorph_rainday"$     = am_cmorph_rainday_mean
  ncdf->$"am_cmorph_intensity"$   = am_cmorph_rainday_intensity
  ncdf->$"am_vr_rainday"$         = am_vr_rainday_mean
  ncdf->$"am_vr_intensity"$       = am_vr_rainday_intensity
  ncdf->$"am_rcm_rainday"$        = am_rcm_rainday_mean
  ncdf->$"am_rcm_intensity"$      = am_rcm_rainday_intensity

  ncdf->$"jja_cn051_rainday"$      = jja_cn051_rainday_mean
  ncdf->$"jja_cn051_intensity"$    = jja_cn051_rainday_intensity
  ncdf->$"jja_cmorph_rainday"$     = jja_cmorph_rainday_mean
  ncdf->$"jja_cmorph_intensity"$   = jja_cmorph_rainday_intensity
  ncdf->$"jja_vr_rainday"$         = jja_vr_rainday_mean
  ncdf->$"jja_vr_intensity"$       = jja_vr_rainday_intensity
  ncdf->$"jja_rcm_rainday"$        = jja_rcm_rainday_mean
  ncdf->$"jja_rcm_intensity"$      = jja_rcm_rainday_intensity


  
  delete(ncdf)

end