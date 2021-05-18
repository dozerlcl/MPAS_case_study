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
;;; 21.05.12
;;;   将原本的计算绘图的脚本拆分为两份，此为part1计算部分
;;;   计算结果保存到当前目录下面
;;; 21.05.13
;;;   添加为两米气温的平均态的绘制 part1 计算部分
load "./shapefile_utils.ncl"
undef("count_range")
function count_range(cn051_max, cn051_min, vr_max, vr_min, rcm_max, rcm_min)
begin
;;;-----count time mean-----
  range_cn051  = dim_avg_n_Wrap(cn051_max - cn051_min, (/0/) )
  range_vr     = dim_avg_n_Wrap(vr_max - vr_min, (/0/) )
  range_rcm    = dim_avg_n_Wrap(rcm_max - rcm_min, (/0/) )
  copy_VarCoords(cn051_max(0,:,:), range_cn051)
  copy_VarCoords(vr_max(0,:,:), range_vr)
  copy_VarCoords(rcm_max(0,:,:), range_rcm)

;;;-----count variance and ttest using prob ---------
;;; 使用CN05.1进行平均值的显著性检验
  ; cn051_variance= dim_variance_n(range_cn051, 0)
  ; vr_variance   = dim_variance_n(range_vr, 0)
  ; rcm_variance  = dim_variance_n(range_rcm, 0)
  ; dims_vr       = dimsizes(vr_max)
  ; series_num    = dims_vr(0)
  ; vr_prob       = ttest(pre_cn051_mean, cn051_variance, series_num, pre_vr_mean, vr_variance, series_num, True, False)
  ; rcm_prob      = ttest(pre_cn051_mean, cn051_variance, series_num, pre_rcm_mean, rcm_variance, series_num, True, False)
  ; copy_VarCoords(range_vr, vr_prob)
  ; copy_VarCoords(range_rcm, rcm_prob)
  ; ----- count bias -----
  vr_error_cn051  = range_vr - range_cn051
  rcm_error_cn051 = range_rcm - range_cn051
  copy_VarMeta(range_vr, vr_error_cn051)
  copy_VarMeta(range_rcm, rcm_error_cn051)
  return ([/range_cn051, range_vr, range_rcm, vr_error_cn051, rcm_error_cn051/])
end

begin
;;;>>>data reader
  ;   mask 之后集中存放降水数据的位置：   /raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/mask_pre/mask_res
  dir_cn051 = "/raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/mask_t2m/mask_res/"
  filename_cn051_max = "mask_sel_CN05.1_Tmax_1961_2018_daily_025x025.nc"
  filename_cn051_min = "mask_sel_CN05.1_Tmin_1961_2018_daily_025x025.nc"
  
  dir_vr = "/raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/mask_t2m/mask_res/"
  filename_vr_max = "mask_max_t2m_98-17_VR.nc"
  filename_vr_min = "mask_min_t2m_98-17_VR.nc"
  
  dir_rcm = "/raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/mask_t2m/mask_res/"
  filename_rcm_max = "mask_max_t2m_98-17_RCM.nc"
  filename_rcm_min = "mask_min_t2m_98-17_RCM.nc"

  f = addfile(dir_cn051 + filename_cn051_max, "r") 
  cn051_max = f->$"tmax"$

  f = addfile(dir_cn051 + filename_cn051_min, "r") 
  cn051_min = f->$"tmin"$

  f = addfile(dir_vr + filename_vr_max, "r") 
  vr_max  = f->$"t2m"$
  vr_max  = vr_max - 273.15

  f = addfile(dir_vr + filename_vr_min, "r") 
  vr_min  = f->$"t2m"$
  vr_min  = vr_min - 273.15

  f = addfile(dir_rcm + filename_rcm_max, "r") 
  rcm_max  = f->$"t2m"$
  rcm_max  = rcm_max - 273.15

  f = addfile(dir_rcm + filename_rcm_min, "r") 
  rcm_min  = f->$"t2m"$
  rcm_min  = rcm_min - 273.15

;;;-----select time index -----
  time_all = cd_calendar(vr_max&Time, 0)
  ind_am  = ind( (time_all(:,1).eq.4) .or. (time_all(:,1).eq.5) )
  ind_jja = ind( (time_all(:,1).eq.6) .or. (time_all(:,1).eq.7) .or. (time_all(:,1).eq.8) )
;;;-----count by months-----
  ; am
  list_test = count_range(cn051_max(ind_am,:,:), cn051_min(ind_am,:,:), \
  vr_max(ind_am,:,:), vr_min(ind_am,:,:),rcm_max(ind_am,:,:),rcm_min(ind_am,:,:))
  ; return ([/range_cn051, range_vr, range_rcm, vr_prob, rcm_prob, vr_error_cn051, rcm_error_cn051/])
  am_range_cn051 = list_test[0]
  am_range_vr    = list_test[1]
  am_range_rcm   = list_test[2]
  ; am_vr_prob     = list_test[3]
  ; am_rcm_prob    = list_test[4]
  am_vr_error_cn051 = list_test[3]
  am_rcm_error_cn051 = list_test[4]
  delete(list_test)

  list_test = count_range(cn051_max(ind_jja,:,:), cn051_min(ind_jja,:,:), \
  vr_max(ind_jja,:,:), vr_min(ind_jja,:,:),rcm_max(ind_jja,:,:),rcm_min(ind_jja,:,:))
  ; return ([/range_cn051, range_vr, range_rcm, vr_prob, rcm_prob, vr_error_cn051, rcm_error_cn051/])
  jja_range_cn051 = list_test[0]
  jja_range_vr    = list_test[1]
  jja_range_rcm   = list_test[2]
  ; jja_vr_prob     = list_test[3]
  ; jja_rcm_prob    = list_test[4]
  jja_vr_error_cn051 = list_test[3]
  jja_rcm_error_cn051 = list_test[4]
  delete(list_test)



;;;<<<output variable
  diro = "/m2data2/yycheng/playground/MPAS_case_study/92-25km_vr_rcm_postprocess/visualization/check_obs/settled/t2m/space/output_nc/"
  filo = "range.nc"
  system("rm -f "+ diro + filo) ;删除目录下的同名文件
  ncdf = addfile(diro + filo, "c") ; c表示创建netcdf文件

  ; am
  ncdf->$"am_range_cn051"$      = am_range_cn051
  ncdf->$"am_range_vr"$         = am_range_vr
  ncdf->$"am_range_rcm"$        = am_range_rcm
  ncdf->$"am_vr_error_cn051"$   = am_vr_error_cn051
  ncdf->$"am_rcm_error_cn051"$  = am_rcm_error_cn051

  ; jja
  ncdf->$"jja_range_cn051"$     = jja_range_cn051
  ncdf->$"jja_range_vr"$        = jja_range_vr
  ncdf->$"jja_range_rcm"$       = jja_range_rcm
  ncdf->$"jja_vr_error_cn051"$  = jja_vr_error_cn051
  ncdf->$"jja_rcm_error_cn051"$ = jja_rcm_error_cn051

  delete(ncdf)



end