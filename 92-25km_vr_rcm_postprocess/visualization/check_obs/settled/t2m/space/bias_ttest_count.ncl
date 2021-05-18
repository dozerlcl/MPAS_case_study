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
;;; 21.05.16
;;;   添加两米最高最低气温的绘制文件的创建
load "./shapefile_utils.ncl"
undef("count_bias")
function count_bias(pre_cn051, pre_vr, pre_rcm)
begin
;;;-----count time mean-----
  pre_cn051_mean  = dim_avg_n_Wrap(pre_cn051, (/0/) )
  pre_vr_mean     = dim_avg_n_Wrap(pre_vr, (/0/) )
  pre_rcm_mean    = dim_avg_n_Wrap(pre_rcm, (/0/) )

;;;-----count variance and ttest using prob ---------
;;; 使用CN05.1进行平均值的显著性检验
  cn051_variance= dim_variance_n(pre_cn051, 0)
  vr_variance   = dim_variance_n(pre_vr, 0)
  rcm_variance  = dim_variance_n(pre_rcm, 0)
  dims_vr       = dimsizes(pre_vr)
  series_num    = dims_vr(0)
  vr_prob       = ttest(pre_cn051_mean, cn051_variance, series_num, pre_vr_mean, vr_variance, series_num, True, False)
  rcm_prob      = ttest(pre_cn051_mean, cn051_variance, series_num, pre_rcm_mean, rcm_variance, series_num, True, False)
  copy_VarCoords(pre_cn051_mean, vr_prob)
  copy_VarCoords(pre_cn051_mean, rcm_prob)
  return ([/pre_cn051_mean, pre_vr_mean, pre_rcm_mean, vr_prob, rcm_prob/])
end

begin
;;;>>>plot set
  fignum = 10
  plot = new(fignum,graphic) ;定义子图数组
  pictype = "png"
  ; wks_type = "png"
  pictype@wkWidth = 1600 
  pictype@wkHeight = 1600
  wks = gsn_open_wks(pictype,"./output_pic/"+"precip_98-17_bias_ttest")
;;;>>>data reader
  ;   mask 之后集中存放降水数据的位置：   /raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/mask_pre/mask_res
  dir_cn051 = "/raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/mask_t2m/mask_res/"
  filename_cn051 = "mask_sel_CN05.1_Tmin_1961_2018_daily_025x025.nc"
  
  dir_vr = "/raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/mask_t2m/mask_res/"
  filename_vr = "mask_min_t2m_98-17_VR.nc"
  
  dir_rcm = "/raid52/yycheng/MPAS/REFERENCE/TEMP_DATA/mask_t2m/mask_res/"
  filename_rcm = "mask_min_t2m_98-17_RCM.nc"

  f = addfile(dir_cn051 + filename_cn051, "r") 
  pre_cn051 = f->$"tmin"$

  f = addfile(dir_vr + filename_vr, "r") 
  pre_vr  = f->$"t2m"$
  pre_vr  = pre_vr - 273.15
  f = addfile(dir_rcm + filename_rcm, "r") 
  pre_rcm  = f->$"t2m"$
  pre_rcm  = pre_rcm - 273.15
;;;-----select time index -----
  time_all = cd_calendar(pre_vr&Time, 0)
  ind_am  = ind( (time_all(:,1).eq.4) .or. (time_all(:,1).eq.5) )
  ind_jja = ind( (time_all(:,1).eq.6) .or. (time_all(:,1).eq.7) .or. (time_all(:,1).eq.8) )
;;;-----count by months-----
  ; am
  list_test = count_bias(pre_cn051(ind_am,:,:), pre_vr(ind_am,:,:), pre_rcm(ind_am,:,:))
    ; [pre_cn051_mean, pre_cmorph_mean, pre_vr_mean, pre_rcm_mean, vr_prob, rcm_prob] = \
  am_cn051_mean  = list_test[0]
  am_vr_mean     = list_test[1]
  am_rcm_mean    = list_test[2]
  am_vr_prob         = list_test[3]
  am_rcm_prob        = list_test[4]
  delete(list_test)
  ; jja
  list_test = count_bias(pre_cn051(ind_jja,:,:), pre_vr(ind_jja,:,:), pre_rcm(ind_jja,:,:))
    ; [pre_cn051_mean, pre_cmorph_mean, pre_vr_mean, pre_rcm_mean, vr_prob, rcm_prob] = \
  jja_cn051_mean  = list_test[0]
  jja_vr_mean     = list_test[1]
  jja_rcm_mean    = list_test[2]
  jja_vr_prob         = list_test[3]
  jja_rcm_prob        = list_test[4]

  delete(list_test)
  ;;;-----count bias -----
  am_vr_error_cn051  = am_vr_mean - am_cn051_mean
  am_rcm_error_cn051 = am_rcm_mean - am_cn051_mean
  copy_VarMeta(am_vr_mean, am_vr_error_cn051)
  copy_VarMeta(am_rcm_mean, am_rcm_error_cn051)

  jja_vr_error_cn051  = jja_vr_mean - jja_cn051_mean
  jja_rcm_error_cn051 = jja_rcm_mean - jja_cn051_mean
  copy_VarMeta(jja_vr_mean, jja_vr_error_cn051)
  copy_VarMeta(jja_rcm_mean, jja_rcm_error_cn051)


;;;------count space patterm coef and add on pic leftstring -----
  ; am
  ; cn05.1
  ; vr_cn051_bias = dim_avg_n(ndtooned(vr_error_cn051), 0)
  ; rcm_cn051_bias = dim_avg_n(ndtooned(rcm_error_cn051), 0)
  am_vr_cn051_rmsd = dim_rmsd_n(ndtooned(am_vr_mean), ndtooned(am_cn051_mean), 0)
  am_rcm_cn051_rmsd = dim_rmsd_n(ndtooned(am_rcm_mean), ndtooned(am_cn051_mean), 0)
  am_vr_cn051_coef = escorc_n(ndtooned(am_vr_mean), ndtooned(am_cn051_mean), 0, 0)
  am_rcm_cn051_coef = escorc_n(ndtooned(am_rcm_mean), ndtooned(am_cn051_mean), 0, 0)
  ; jja
  ; cn05.1
  ; vr_cn051_bias = dim_avg_n(ndtooned(vr_error_cn051), 0)
  ; rcm_cn051_bias = dim_avg_n(ndtooned(rcm_error_cn051), 0)
  jja_vr_cn051_rmsd = dim_rmsd_n(ndtooned(jja_vr_mean), ndtooned(jja_cn051_mean), 0)
  jja_rcm_cn051_rmsd = dim_rmsd_n(ndtooned(jja_rcm_mean), ndtooned(jja_cn051_mean), 0)
  jja_vr_cn051_coef = escorc_n(ndtooned(jja_vr_mean), ndtooned(jja_cn051_mean), 0, 0)
  jja_rcm_cn051_coef = escorc_n(ndtooned(jja_rcm_mean), ndtooned(jja_cn051_mean), 0, 0)


;;;<<<output variable
  diro = "/m2data2/yycheng/playground/MPAS_case_study/92-25km_vr_rcm_postprocess/visualization/check_obs/settled/t2m/space/output_nc/"
  filo = "min_ttest_bias.nc"
  system("rm -f "+ diro + filo) ;删除目录下的同名文件
  ; am
  ncdf = addfile(diro + filo, "c") ; c表示创建netcdf文件
  ncdf->$"am_cn051_mean"$  = am_cn051_mean
  ncdf->$"am_vr_mean"$     = am_vr_mean
  ncdf->$"am_rcm_mean"$    = am_rcm_mean

  ncdf->$"am_vr_prob"$     = am_vr_prob
  ncdf->$"am_rcm_prob"$    = am_rcm_prob

  ncdf->$"am_vr_error_cn051"$    = am_vr_error_cn051
  ncdf->$"am_rcm_error_cn051"$    = am_rcm_error_cn051

  ; 作为leftstring的统计量
  ncdf->$"am_vr_cn051_rmsd"$    = am_vr_cn051_rmsd
  ncdf->$"am_rcm_cn051_rmsd"$    = am_rcm_cn051_rmsd
  ncdf->$"am_vr_cn051_coef"$    = am_vr_cn051_coef
  ncdf->$"am_rcm_cn051_coef"$    = am_rcm_cn051_coef

  
  ; jja
  ncdf->$"jja_cn051_mean"$ = jja_cn051_mean
  ncdf->$"jja_vr_mean"$    = jja_vr_mean
  ncdf->$"jja_rcm_mean"$   = jja_rcm_mean

  ncdf->$"jja_vr_prob"$    = jja_vr_prob
  ncdf->$"jja_rcm_prob"$   = jja_rcm_prob

  ncdf->$"jja_vr_error_cn051"$    = jja_vr_error_cn051
  ncdf->$"jja_rcm_error_cn051"$    = jja_rcm_error_cn051

  ; 作为leftstring的统计量
  ncdf->$"jja_vr_cn051_rmsd"$    = jja_vr_cn051_rmsd
  ncdf->$"jja_rcm_cn051_rmsd"$    = jja_rcm_cn051_rmsd
  ncdf->$"jja_vr_cn051_coef"$    = jja_vr_cn051_coef
  ncdf->$"jja_rcm_cn051_coef"$    = jja_rcm_cn051_coef

  delete(ncdf)



end