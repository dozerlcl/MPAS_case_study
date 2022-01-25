此文件夹放置了MPAS的一些运行案例以及相应的后处理集

2022.01.25
将平均态的AM JJA两个时段，改为 MJJA 的平均态
```
MPAS_overview.md
    简单的MPAS使用手册，对应的使用例在case中可以找到

92-25km_vr_case 
    92-25km变分辨率 4-8月的模拟
92-25km_rcm_case
    与上述相同，其中包含了使用 MPAS-Limit-Area 制作有限区域的部分（只是给出了区域
92-25km_vr_rcm_postprocess
    92-25km 03-15年模拟的后处理部分，包含 convert、计算、合成观测、绘图等各种，具体详见里面的README

---------
cptp_60-3km_vr_postprocess
    cptp 2012/2015 july ，模拟前准备了一下降水的时间序列，确定高原MCS模拟的时间，case暂时没有搬运

```