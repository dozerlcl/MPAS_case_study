进行CN05.1和模式数据的对比的脚本
remark：CN05.1使用了MASK的数据，因此这里都是直接分析mask后的nc文件，限制在了中国区域
    
- pre/ 进行降水的后处理
    - time_series/    mask后进行的空间平均，绘制降水的时间序列，使用ipynb实现
    - space/  处理时间平均，绘制等值线图，使用NCL实现

- t2m/  进行温度的后处理
        
- partial_preporcess/ 进行降水和温度的不同分区拆分的前处理部分    