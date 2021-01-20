这里存放进行月平均结果 和 ERA5I 的对比的NCL绘图，以空间图为主

data_read.ncl

        一个读取数据的模板

every_years_hgt/ 

        绘制全部数据（每年每个月一张图）的 RCM 和 VR （区分） 的文件

every_years_hgt_combine/ 

        将RCM和VR的误差放在一起（combine） 同时进行了年平均（绘制13年） 整个时间平均 的绘制 

remains:
将ERA5I中能对比的数据尽可能的绘制，不需要太多图，先将平均图全部绘制一遍