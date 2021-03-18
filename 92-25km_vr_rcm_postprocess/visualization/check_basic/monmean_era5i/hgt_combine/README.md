这里的脚本主要是将 hgt 的VR和RCM部分的图进行合并之后绘图

    loop_years.sh 配合 hgt_monmean_combine.ncl 批量绘制每个月的情况
    hgt_yearmean_combine.ncl 绘制每一年的情况，因为年份很长，所以拆分成了两部分来进行绘图（03-08，09-15年）
    hgt_timemean_combine.ncl 计算整个时间上的平均

    remark：1-6没标注的小图就是不同的高度
