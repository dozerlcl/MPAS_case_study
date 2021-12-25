从MPAS网格转换到普通经纬度网格的脚本合集

在另外的数据储存的服务器上使用，不一定齐全，暂时将这个版本存放到此处；

使用的代码来自：https://github.com/mgduda/convert_mpas

注意使用nohup运行，避免输出大量文本到命令行

在官方的脚本的基础上，添加了:

- convert_mpas.sh 
按一定年份批量进行转换，串行运行

- change_time_one_file.ncl 
NCL代码，结合convert_mpas.sh 将转换后的错误的时间纬度赋值正确（适用于单个文件单个时次

- change_time_from_xtime.ncl 
NCL代码，批量转换xtime到数据文件中

注意，暂时没法使用并发进行，因为需要在运行脚本的目录下生成一个临时文件latlon.nc，在修改了时间之后才能被转移走；因为转换时间不算太长，先逐个文件来做。