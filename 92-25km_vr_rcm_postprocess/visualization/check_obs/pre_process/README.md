进行cn05.1比较的前处理的部分
- ncl_mask.ncl 将准备数据进行mask处理，到CN05.1的插值点上
- precip_count.ncl 拆分MPAS日降水（从history中获取）
- precip_count_diag.ncl 拆分MPAS日降水（从diag中获取）
- precip_count_loop_year.sh loop上述脚本
- t2m_dailystats.sh 将逐小时的气温数据，计算为逐日的 最高 最低 平均 温度
- merge_cmorph_cn051.ipynb 将cmorph和CN05.1的数据进行合并