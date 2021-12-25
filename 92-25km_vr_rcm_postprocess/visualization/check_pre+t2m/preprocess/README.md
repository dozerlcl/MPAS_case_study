# 进行cn05.1比较的前处理的部分
2021.12.25 重新整理

---------------

- ncl_mask.ncl

    将准备数据进行mask处理，到CN05.1的有值的点上，去除CN05.1中NAN的部分，用于后续对比

- merge_cmorph_cn051.ipynb

    将cmorph和CN05.1的数据进行合并，用CMORPH填充CN05.1中NAN的部分

-----------------

- precip_count.ncl

    从累计降水中拆分计算MPAS日降水（从history中获取）
- precip_count_diag.ncl
    从累计降水中拆分计算拆分MPAS日降水（从diag中获取）
- precip_count_loop_year.sh

    传入文件位置的shell脚本，loop上述拆分ncl脚本

- hourlyprecip_increment.ipynb
    从模式的累计降水结果中，并发地计算一小时降水的增量

-----------------

- t2m_dailystats.sh

    将逐小时的气温数据，计算为逐日的 最高 最低 平均 温度

-----------------

