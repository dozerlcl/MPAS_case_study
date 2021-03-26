# MPAS 简易操作流程
​		yycheng 2021.01.31

## 参考资料：

关于MPAS的教程主要由三部分构成

1.来自于MPAS官网的tutorial部分，包含一个网页的教程说明，以及相应的数据文件[MPAS网页教程](https://www2.mmm.ucar.edu/projects/mpas/tutorial/Boulder2019/index.html)

2.MPAS可以下载的PPT部分，和上述链接相同，是19年进行模式教学所使用的15个PPT，跳跃性地罗列了一些模式特点和操作（自定义诊断量之类的部分会有，手册相对较少，这部分和tutorial有配合）

3.MPAS手册，namelist参数，XML输出文件参数在这里相对最全（同样在官网进行下载）

## 简明步骤：

编译完成MPAS之后，共包含两个可执行文件*init_atmosphere_model* 和 *atmosphere_model*   ,

MPAS可以拆分到多个步骤进行模式的前处理以及运行，可以将可执行文件夹 link -s 到相应的步骤的文件中来分步运行；

init_atmosphere_model 部分用于前处理、atmosphere_model 部分运行模式；考虑一个案例文件夹包含以下部分：

```
92-25km_vr_set/2003_tutor
	######################################init_atmosphere_model#####################################
	/static		制作静态场
		/init_atmosphere_model -> ...		软连接到可执行文件
		/namelist.init_atmosphere			fortran namelist文件，模式控制参数
		/streams.init_atmosphere			XML文件，进行输出输出的控制
	/init		制作初始场
	/sfc		制作底边界
	/lbcs		制作侧边界（如果进行有限区域模拟）
	#####################################atmosphere_model############################################
	/run		运行模式
		atmosphere_model -> ...
		namelist.atmosphere
		streams.atmosphere					...前三个部分和init_atmosphere_model 的内容一致
		stream_list.atmosphere.diagnostics	诊断量的输出变量控制文件
		stream_list.atmosphere.output		模式场的变量输出文件
		stream_list.atmosphere.surface		输入的边界输出的控制文件（对应sfc的输出）
		
	/restart 	重启模式
```

所有的步骤进行模拟后都会输出一个 log.atmosphere.0000.out 文件，以及 log.atmosphere.????.err 文件（如果遇到错误）

可使用 tail -f log.atmosphere.0000.out 对模式的运行情况进行跟踪

下面逐步给出一些简明操作:

### 基本网格的处理

（可选）使用grid_rotate工具将初始变分辨率网格进行旋转，将加密区域放置在感兴趣的位置；

（可选）使用 MPAS-Limited-Area 工具将初始网格截断到需要的区域部分）

```
git clone https://github.com/MPAS-Dev/MPAS-Tools.git
git clone https://github.com/MiCurry/MPAS-Limited-Area.git
```

两个工具的详细使用方法见相应README

​	输入文件：网格文件，比如这个四倍缩放的 x4.163842.grid.nc（从92km-25km）

​	输出文件：旋转、截取后的网格文件，后续命名为 ea.grid.nc

### 拆分MPI文件

将x4.163842.graph.info文件进行拆分（这是进行mpi文件拆分的网格连通性文件）到需求的MPI拆分数上；

使用[METIS软件](http://glaros.dtc.umn.edu/gkhome/views/metis) 进行拆分，考虑下面的命令拆分到相应的mpi任务数N：

```
# 其中N即是拆分数
gpmetis -minconn -contig -niter=200 graph.info N 
```

​	输入文件：x4.163842.graph.info

​	输出文件：x4.163842.graph.info.NaSZq

之后可在namelist中设置

```
&decomposition
config_block_decomp_file_prefix ='graph.info.part.' ! 设置graph.info.part 的路径
```

以便启用MPI拆分

### statics步骤，制作静态数据

#### 串行进行

static在模式中是串行进行的，因此会花费较多的时间（但对于同一网格可以在之后重复使用）

但对于过高的分辨率的网格（例如60-3km的变分辨率网格）可以反注释掉模式的一些部分，再重新编译，官方在网格的下载位置上，附加有如下说明：

1) comment-out the code between [lines 217 and 222](https://github.com/MPAS-Dev/MPAS-Model/blob/v7.0/src/core_init_atmosphere/mpas_init_atm_cases.F#L217-L222) in src/core_init_atmosphere/mpas_init_atm_cases.F that ordinarily prevents the parallel processing of static fields; and

(2) ensure that the "cvt" partition file prefix (e.g., x1.65536002.cvt.part.) is specified in the config_block_decomp_file_prefix variable in namelist.init_atmosphere.

这样就可以使用网格附带的特殊cvt拆分文件，进行256核的并行运行，来制作static，相比串行更快。

#### 所需文件

下面是具体步骤，考虑要使用下面的文件，该步骤需要使用模式编译位置（后面称为模式目录）的下面文件（有一个模板，是240km mesh的教程所使用的）：

```
$ ln -s ${HOME}/MPAS-Model/init_atmosphere_model .
$ cp ${HOME}/MPAS-Model/namelist.init_atmosphere .
$ cp ${HOME}/MPAS-Model/streams.init_atmosphere .
```

下面是官方提供的namelist模板：

```
&nhyd_model
    config_init_case = 7
/
&data_sources
    config_geog_data_path = '/classroom/wrfhelp/mpas/geog/'
    config_landuse_data = 'MODIFIED_IGBP_MODIS_NOAH'
    config_topo_data = 'GMTED2010'
    config_vegfrac_data = 'MODIS'
    config_albedo_data = 'MODIS'
    config_maxsnowalbedo_data = 'MODIS'
    config_supersample_factor = 3
/
&preproc_stages
    config_static_interp = true
    config_native_gwd_static = true
    config_vertical_grid = false
    config_met_interp = false
    config_input_sst = false
    config_frac_seaice = false
/
```

需要对namelist进行修改，添加拆分文件和tutorial中包含的地形文件，&data_sources 部分需要考虑使用的tutorial中的WPS文件（这部分和WRF的WPS之中的数据有一些区别，不方便直接使用（会有一些文件无法找到），使用教程中的提供部分会比较方便）

其次 &preproc_stages 部分会有一些使用混合地形的选项（如果使用具有侧边界的有限区域模式），以及输入的处理方式

对于XML文件有下面的输入输出控制：

```
<immutable_stream name="input"
                  type="input"
                  filename_template="ea.grid.nc"
                  input_interval="initial_only"/>
<immutable_stream name="output"
                  type="output"
                  filename_template="ea.static.nc"
                  packages="initial_conds"
                  output_interval="initial_only" />
```

​	输入数据：grid文件，例如原始的网格文件，或者经过前一步（旋转、截取）后的ea.grid.nc

​	输出数据：static文件，用于制作init文件

这部分XML的文件填法在用户手册的第五章， “configuring Model Input and Output” 中会有详细论述

填写好 namelist 和 streams 的XML文件之后就可以直接进行运行：

```
./init_atmosphere_model
```

这里可以使用nohup或者&将模式挂到后台，再使用tail -f 查看相应的模式执行情况

```
tail -f log.init_atmosphere.0000.out
```

运行过程中，在log.init_atmosphere.0000.out 有如下输出

```
 ${MPAS_TUTORIAL}/geog/topo_gmted2010_30s/28801-30000.03601-04800
 ${MPAS_TUTORIAL}/geog/topo_gmted2010_30s/30001-31200.03601-04800
 ${MPAS_TUTORIAL}/geog/topo_gmted2010_30s/31201-32400.03601-04800
 ${MPAS_TUTORIAL}/geog/topo_gmted2010_30s/32401-33600.03601-04800
 ${MPAS_TUTORIAL}/geog/topo_gmted2010_30s/33601-34800.03601-04800
 ${MPAS_TUTORIAL}/geog/topo_gmted2010_30s/34801-36000.03601-04800
```

最后如果出现下面说明，就说明成功完成了static步骤

```
 ********************************************************
    Finished running the init_atmosphere core
 ********************************************************


  Timer information:
     Globals are computed across all threads and processors

  Columns:
     total time: Global max of accumulated time spent in timer
     calls: Total number of times this timer was started / stopped.
     min: Global min of time spent in a single start / stop
     max: Global max of time spent in a single start / stop
     avg: Global max of average time spent in a single start / stop
     pct_tot: Percent of the timer at level 1
     pct_par: Percent of the parent timer (one level up)
     par_eff: Parallel efficiency, global average total time / global max total time


    timer_name                                            total       calls        min            max            avg      pct_tot   pct_par     par_eff
  1 total time                                        1974.67635         1     1974.67635     1974.67635     1974.67635   100.00       0.00       1.00
  2  initialize                                         40.95301         1       40.95301       40.95301       40.95301     2.07       2.07       1.00

 -----------------------------------------
 Total log messages printed:
    Output messages =                 3935
    Warning messages =                  10
    Error messages =                     0
    Critical error messages =            0
 -----------------------------------------
 Logging complete.  Closing file at 2020/11/10 01:48:15

```

可见，static步骤相对来说比较花费时间，约执行了32分钟；但之后就使用static制作出的文件，不再重复执行这个步骤。

### init步骤，制作初始场（进行真实案例的模拟）

#### ungrib

MPAS可以使用WRF WPS的ungrib部分来准备大气数据集，使用WPS输出的 intermediate format

ungrib部分可以参考[WRF官方教程](https://www2.mmm.ucar.edu/wrf/users/docs/user_guide_v4/v4.1/users_guide_chap3.html)

制作初始场需要至少ungrib一个时次的驱动场， ungrib之后输入给MPAS的中间文件的路径填写在namelist之中

（remark：模式自己输出的文件通常写在XML之中，外部数据（例如WPS的静态数据，ungrib之后的数据，MPI任务的拆分数据等）通常都写在namelist之中）

#### 需求文件

init步骤和static步骤需求的文件相同（namelist和xml文件），下面给出模板：

*namelist.init_atmosphere* 文件

```
&nhyd_model
    config_init_case = 7
    config_start_time = '2014-09-10_00:00:00'
/
&dimensions
    config_nvertlevels = 41
    config_nsoillevels = 4
    config_nfglevels = 38
    config_nfgsoillevels = 4
/
&data_sources
    config_met_prefix = 'GFS'
    config_use_spechumd = false
/
&vertical_grid
    config_ztop = 30000.0
    config_nsmterrain = 1
    config_smooth_surfaces = true
    config_dzmin = 0.3
    config_nsm = 30
    config_tc_vertical_grid = true
    config_blend_bdy_terrain = false
/
&interpolation_control
    config_extrap_airtemp = 'linear'
/
&preproc_stages
    config_static_interp = false
    config_native_gwd_static = false
    config_vertical_grid = true
    config_met_interp = true
    config_input_sst = false
    config_frac_seaice = true
/
```

下面是通过XML文件来控制输入输出：

```
<immutable_stream name="input"
                  type="input"
                  filename_template="x1.10242.static.nc"
                  input_interval="initial_only"/>
                  
<immutable_stream name="output"
                  type="output"
                  filename_template="x1.10242.init.nc"
                  packages="initial_conds"
                  output_interval="initial_only" />
```

之后，就可以直接运行链接过来的 init_atmosphere_model 

```
./init_atmosphere_model
```

制作初始场的运行时间很快，一两分钟内就能运行完毕。

### 制作海温和海冰数据 sfc部分

MPAS_A 仅仅是大气模型，并没有考虑海温和海冰的预报方程；因此对于超过一周时间的*模拟*，使用外部数据对SST进行更新是非常有必要的。

更新的海温数据同样可通过ungrib部分进行准备

#### ungrib

ungrib海温数据并不需要全部的变量，可以考虑至少包含下面变量的Vtable，以便节省ungrib的时间以及空间消耗

```
GRIB | Level| Level| Level| metgrid  |  metgrid | metgrid                                  |
Code | Code |   1  |   2  | Name     |  Units   | Description                              |
-----+------+------+------+----------+----------+------------------------------------------+
 172 |  1   |   0  |      | LANDSEA  | 0/1 Flag | Land/Sea flag                            |
  31 |  1   |   0  |      | SEAICE   | fraction | Sea-Ice Fraction                         |
  34 |  1   |   0  |      | SST      | K        | Sea-Surface Temperature                  |
-----+------+------+------+----------+----------+------------------------------------------+
```

（此Vtable来源于ERA5I的一部分）

后续ungrib的namelist填写为：

```
&share
 wrf_core = 'ARW',
 start_date = '2003-04-01_00:00:00','2003-04-01_00:00:00',
 end_date   = '2003-04-03_00:00:00','2003-04-03_00:00:00',
 interval_seconds = 86400,
 io_form_geogrid = 2,
/
&geogrid
/

&ungrib
 out_format = 'WPS',
 prefix = '/PATH/TO/YOUR/DATA/sst',
/

&metgrid
/
```

namelist除了进行前处理海温数据的时间，并没有太多内容需要填写，注意考虑使用 sst 作为海温的ungrib后的中间文件的前缀。海温的更新时间为 84600秒，即通过interval_seconds = 86400来设置

#### MPAS namelist部分

下面更改MPAS的namelist，需要将 config_init_case = 8 来制作海温数据

```
&nhyd_model
    config_init_case = 8
    config_start_time = '2014-04-01_00:00:00'
    config_stop_time = '2014-04-03_00:00:00'
/

&data_sources
    config_sfc_prefix = 'sst'
    config_fg_interval = 86400
/

&preproc_stages
    config_static_interp = false
    config_static_interp = false
    config_vertical_grid = false
    config_met_interp = false
    config_input_sst = true
    config_frac_seaice = true
/
```

上面的namelis要注意前一步ungrib使用的海温中间文件的前缀：config_sfc_prefix = 'sst'，以及海温文件的时间间隔config_fg_interval = 86400

#### streams XM文件部分

```
<streams>
<immutable_stream name="input"
                  type="input"
                  filename_template="ea.static.nc"
                  input_interval="initial_only" />

<immutable_stream name="output"
                  type="output"
                  filename_template=""
                  packages="initial_conds"
                  output_interval="initial_only" />

<immutable_stream name="surface"
                  type="output"
                  filename_template="ea.sfc_update.nc"
                  filename_interval="none"
                  packages="sfc_update"
                  output_interval="84600" />

<immutable_stream name="lbc"
                  type="output"
                  filename_template="lbc.$Y-$M-$D_$h.$m.$s.nc"
                  filename_interval="output_interval"
                  packages="lbcs"
                  output_interval="3:00:00" />

</streams>

```

上述XML文件需要将static部分生成的静态数据 ea.static.nc 作为输入来获取网格信息，surface一栏中的需要将 output_interval="84600" 以便和此前准备的ungrib数据，以及MPAS的namelist的控制相同

输出数据则是更新的海温数据 ea.sfc_update.nc

更新好上述的文件后就可以直接运行

```
./init_atmosphere_model
```

### 模式积分 run部分

如果不进行侧边界条件的制作，在这前三步的基础上就可以直接运行MPAS全球模式

在运行之前，需要准备如下文件（在运行目录 run）

```
ln -s ${HOME}/MPAS-Model/atmosphere_model .
cp ${HOME}/MPAS-Model/namelist.atmosphere .
cp ${HOME}/MPAS-Model/streams.atmosphere .
cp ${HOME}/MPAS-Model/stream_list.atmosphere.* .
```

这一部分包含模式编译出来的二进制文件，控制的namelist，控制的输入输出的XML文件streams_atmosphere，控制输入输出变量(history和diag)的变量表stream_list

前面的和init部分相似，但run部分还需要一些 tables 和 其他数据文件来支持各种参数化方案，考虑在模式目录下 ln -s 下面的文件到当前目录

```
ln -s ${HOME}/MPAS-Model/src/core_atmosphere/physics/physics_wrf/files/* .
```

#### 模式控制 namelist部分

在运行模式之前，调整namelist时有一些关键参数

​	config_dt 模式积分的时间步长

​	config_len_disp 水平扩散的空间尺度（单位 merters）

以及模式运行的开始时间和时间长度

​	config_start_time

​	config_run_duration

最后需要填写拆分的MPI网格文件（如果并行地运行）

​	config_block_decomp_file_prefix

下面是一个namelist的模板:

```
&nhyd_model
    config_time_integration_order = 3
    config_dt = 120.0
    config_start_time = '2003-04-01_00:00:00'
    config_run_duration = '2_00:00:00'
    config_len_disp = 25000.0
/
&damping
    config_zd = 22000.0
    config_xnutr = 0.2
/
&limited_area
    config_apply_lbcs = false
/
&io
    config_pio_num_iotasks = 0
    config_pio_stride = 1
/
&decomposition
    config_block_decomp_file_prefix = 'x4.163842.graph.info.part.'
/
&restart
    config_do_restart = false
/
&printout
    config_print_global_minmax_vel = true
    config_print_detailed_minmax_vel = false
/
&IAU
    config_IAU_option = 'off'
    config_IAU_window_length_s = 86400.
/
&physics

```

namelist的控制选项在user_guide中相对全面

#### XML文件

XML的填写需要指定上之前制作的所有文件，下面是一个范例，数据文件均存放在 /raid52/yycheng/MPAS/VR_set/92-25km_VR_2003_tutor/下

```
<streams>
<immutable_stream name="input"
                  type="input"
                  filename_template="/raid52/yycheng/MPAS/VR_set/92-25km_VR_2003_tutor/ea.init.nc"
                  input_interval="initial_only" />

<immutable_stream name="restart"
                  type="input;output"
                  filename_template="/raid52/yycheng/MPAS/VR_set/92-25km_VR_2003_tutor/out/restart/restart.$Y-$M-$D_$h.$m.$s.nc"
                  input_interval="initial_only"
                  output_interval="30_00:00:00" />

<stream name="output"
        type="output"
        filename_template="/raid52/yycheng/MPAS/VR_set/92-25km_VR_2003_tutor/out/history/history.$Y-$M-$D_$h.$m.$s.nc"
        output_interval="24:00:00" >

	<file name="stream_list.atmosphere.output"/>
</stream>

<stream name="sfcwinds"
        type="output"
        filename_template="/raid52/yycheng/MPAS/VR_set/92-25km_VR_2003_tutor/out/wind/wind.$Y-$M-$D.nc"
        filename_interval="24:00:00"
        output_interval="01:00:00" >
        <var name="t2m"/>
        <var name="u10"/>
        <var name="v10"/>
</stream>

<stream name="diagnostics"
        type="output"
        filename_template="/raid52/yycheng/MPAS/VR_set/92-25km_VR_2003_tutor/out/diag/diag.$Y-$M-$D_$h.$m.$s.nc"
        output_interval="24:00:00" >

	<file name="stream_list.atmosphere.diagnostics"/>
</stream>

<stream name="diagnostics_1hr"
        type="output"
        filename_template="/raid52/yycheng/MPAS/VR_set/92-25km_VR_2003_tutor/out/diag_1hr/diag.$Y-$M-$D_$h.$m.$s.nc"
        output_interval="1:00:00" >

	<file name="stream_list.atmosphere.diagnostics"/>
</stream>

<stream name="surface"
        type="input"
        filename_template="/raid52/yycheng/MPAS/VR_set/92-25km_VR_2003_tutor/ea.sfc_update_4to8.nc"
        filename_interval="none"
        input_interval="24:00:00" >

	<file name="stream_list.atmosphere.surface"/>
</stream>

<immutable_stream name="iau"
                  type="input"
                  filename_template="x1.40962.AmB.$Y-$M-$D_$h.$m.$s.nc"
                  filename_interval="none"
                  packages="iau"
                  input_interval="initial_only" />

<immutable_stream name="lbc_in"
                  type="input"
                  filename_template="lbc.$Y-$M-$D_$h.$m.$s.nc"
                  filename_interval="input_interval"
                  packages="limited_area"
                  input_interval="3:00:00" />

</streams>
```

注意，history 和 diag 的部分会按照之前 cp 的 stream_list* 对应的变量输出（自定义的变量diagnostic变量也需要在这里添加，history是直接的模式变量）

name="sfc_wind"部分是自定义的变量，需要的变量名补充在后面

文件的时间间隔 filename_interval 和 记录的时间间隔 output_interval 需要进行调整（这部分在手册chapter5 configuring model input and output 中有对XML中各种要素控制的详细说明）

文件要素

| stream name | function                                                |
| ----------- | ------------------------------------------------------- |
| input       | 冷启动模式时使用的输出（前面制作出的ea.init.nc部分）    |
| restart     | 存档点，既是输入也是输出                                |
| output      | 将模式的预报量 和 诊断量 输出为 history文件的部分       |
| diagnostics | 输出2D诊断量的部分，尤其是比history的时间间隔更小的情况 |
| surface     | 读入周期性更新的 sea-ice 和 SST 底边界                  |
| iau         | 读入 analysis increments (for iau)                      |
| lbc_in      | 进行区域模式模拟，更新侧边界                            |

运行过程中，会在 log.atmosphere.0000.out 中输出每个时次的信息（可在namelist中控制）

```
Begin timestep 2003-04-01_00:40:00
 --- time to run the LW radiation scheme L_RADLW =F
 --- time to run the SW radiation scheme L_RADSW =F
 --- time to run the convection scheme L_CONV    =T
 --- time to apply limit to accumulated rainc and rainnc L_ACRAIN   =F
 --- time to apply limit to accumulated radiation diags. L_ACRADT   =F
 --- time to calculate additional physics_diagnostics               =F
  split dynamics-transport integration 3
```

没有严重问题报错，则记录到模式运行完毕

```
 -----------------------------------------
 Total log messages printed:
    Output messages =              1664469
    Warning messages =                   3
    Error messages =                     0
    Critical error messages =            0
 -----------------------------------------
```

#### 其他运行选项：restart

调整 namelist 中restart开关

```
&restart
config do restart = true
```

再调整xml文件中restart的开始时间，和存档点时间相对应

后从restart时间点开始冷启动（其他 sfc 还有lbc部分仍然需要提供）

#### 其他运行选项：limited-area simulation

为了进行有限区域的模拟，大部分工作将会集中在制作有限区域的网格数据，地形数据上，以及准备区域对应的侧边界条件，即运行lbcs部分；模式运行上的差别不大，打开相应的开关即可。

##### 定义有限区域 以及制作相应 static fields

需要先从github上克隆有限区域工具：

```
git clone https://github.com/MiCurry/MPAS-Limited-Area.git
```

此工具能对初始网格进行处理，按照 circular, elliptical, channel, polyon 等方式截取出需要的区域， 具体的范例可以参考此工具的README文件，以及 *docs/points-examples/* 下的脚本

在截取前先进行旋转来处理网格，然后用下面类似的 pts 文件来截取（截取一个确定中心点、长轴短轴的椭圆区域）：

```
Name: Mediterranean
Type: ellipse
Point: 37.9, 18.0
Semi-major-axis: 3200000
Semi-minor-axis: 1700000
Orientation-angle: 100
```

用 pts 文件定义好上述区域后，就可以运行 create_region 工具来截取 ea.static.nc地形数据；

```
./create_region mediterranean.pts region_ea.static.nc
```

运行之后，能输出一个新的地形数据，以及和它相对应的MPI任务拆分文件：

```
region_ea.static.nc
region_ea.graph.info
```

可以使用MPAS提供的 regional_terrain.ncl 脚本来绘图观察下此时的截取的区域，从而对区域进行微调

进行后续步骤的时候如果需要并行运行，则需要按之前使用METIS的那样，对 graph.info 进行MPI拆分

##### 制作初始场 init 部分

​	截取可以对 网格(ea.grid.nc) 静态数据(ea.static.nc) 进行，但地形的边界数据需要在原始数据的基础上进行平滑，避免积分崩溃；

​	一个示例的制作 init 的namelist：

```
&vertical_grid
config_ztop = 30000.0
config_nsmterrain = 1
config_smooth_surfaces = true
config_dzmin = 0.3
config_nsm = 30
config_tc_vertical_grid = true
config_blend_bdy_terrain = true
/
```

注意 config_blend_bdy_terrain = *true* 

（static 不需要进行混合地形的操作，因为static的信息会通过制作初始场被添加到 init 之中，所以节省一些时间，不再进行全球的static的制作）

##### 制作侧边界 lbcs 部分

制作侧边界相对来说需要更大的存储空间：因为需要将驱动场整个进行一次 ungrib；相对耗时较多

侧边界的插值方式和制作 init 的时候相似，需要的文件也相同，这里就不再赘述，按此前准备好文件后，注意和init有一些区别：

（1）侧边界的插值是在一些连续的时间上进行的（需要准备多个时间数据，并输出到多个文件）

（2）需要的变量仅是初始条件的一部分子集（并且是在垂直层上进行插值，因此需要具有垂直层信息的网格，XML文件中输入使用了region_ea.init.nc）

调整config_init_case = 9即是切换init_atmosphere_model部分到lbc的制作，下面给出关键的namelist部分：（考虑ungrib ERA5I数据前缀是 ERA5，更新的时间间隔是6小时）

```
&nhyd model
configg_init_case = 9 the LBCs processing case
config_start_time = '2003-04-01 00:00:00' time to begin processing LBC data
config_stop_time = '2010-04-03 00:00:00' time to end processing LBC data
&dimensions
config_nfglevels = 38 number of vertical levels in intermediate file
/
&data sources
config_met_prefix = 'ERA5' the prefix of intermediate data files to be used for
LBCs
config_fg_interval = 21600 interval between intermediate files
/
&decomposition
config_block_decomp_file_prefix ='graph.info.part.' if running in parallel, needs to match the grid decomposition file prefix
/
```

对应的XML文件是：

```
<streams>
<immutable_stream name="input"
                  type="input"
                  filename_template="region_ea.init.nc"
                  input_interval="initial_only" />

<immutable_stream name="output"
                  type="output"
                  filename_template="foo.nc"
                  packages="initial_conds"
                  output_interval="initial_only" />

<immutable_stream name="surface"
                  type="output"
                  filename_template="sfc_update.nc"
                  filename_interval="none"
                  packages="sfc_update"
                  output_interval="86400" />

<immutable_stream name="lbc"
                  type="output"
                  filename_template="lbc.$Y-$M-$D_$h.$m.$s.nc"
                  filename_interval="output_interval"
                  packages="lbcs"
                  output_interval="6:00:00" />

</streams>
```

注意到 immutable_stream 的 output部分其实没有输出（但不能输出，因为是不可更改部分，它不会被启用） 输出填写到lbc的路径下，每个时次 按照output_interval 输出到不同的文件中

后面同样直接运行 init_atmosphere_model 即可（和init一样尽量并行地运行）

制作完成之后会存在下面的这些文件：

```
[yycheng@gcrc lbc]$ ll
total 200625092
-rw-rw-r--. 1 yycheng yycheng 335137280 Dec 14 18:41 lbc.2003-04-01_00.00.00.nc
-rw-rw-r--. 1 yycheng yycheng 335137280 Dec 14 18:41 lbc.2003-04-01_06.00.00.nc
-rw-rw-r--. 1 yycheng yycheng 335137280 Dec 14 18:41 lbc.2003-04-01_12.00.00.nc
```

##### 运行有限区域模拟

最后进行模拟的部分需要打开几个关键namelist参数即可；

*remark:*

config_dt 需要按照最小格距来考虑，和WRF一样，5~6倍于最小格距

confif_len_disp 同样也需要调整（显式水平混合尺度，需要填写为最小格距，单位：米）

*config_block_decomp_file_prefix* 填写为之前生成的 MPI 拆分文件

最重要的部分，是调整 &limited_area 的 *config_apply_lbcs = true*

下面是一个范例:

```
&nhyd_model
    config_time_integration_order = 2
    config_dt = 120.0
    config_start_time = '2003-04-01_00:00:00'
    config_run_duration = '3_00:00:00'
    config_split_dynamics_transport = true
    config_number_of_sub_steps = 2
    config_dynamics_split_steps = 3
    config_h_mom_eddy_visc2 = 0.0
    config_h_mom_eddy_visc4 = 0.0
    config_v_mom_eddy_visc2 = 0.0
    config_h_theta_eddy_visc2 = 0.0
    config_h_theta_eddy_visc4 = 0.0
    config_v_theta_eddy_visc2 = 0.0
    config_horiz_mixing = '2d_smagorinsky'
    config_len_disp = 60000.0
    config_visc4_2dsmag = 0.05
    config_w_adv_order = 3
    config_theta_adv_order = 3
    config_scalar_adv_order = 3
    config_u_vadv_order = 3
    config_w_vadv_order = 3
    config_theta_vadv_order = 3
    config_scalar_vadv_order = 3
    config_scalar_advection = true
    config_positive_definite = false
    config_monotonic = true
    config_coef_3rd_order = 0.25
    config_epssm = 0.1
    config_smdiv = 0.1
/
&damping
    config_zd = 22000.0
    config_xnutr = 0.2
/
&limited_area
    config_apply_lbcs = true
/
&io
    config_pio_num_iotasks = 0
    config_pio_stride = 1
/
&decomposition
    config_block_decomp_file_prefix = 'region_ea.info.part.'
/
&restart
    config_do_restart = false
/
&printout
    config_print_global_minmax_vel = true
    config_print_detailed_minmax_vel = false
/
&IAU
    config_IAU_option = 'off'
    config_IAU_window_length_s = 21600.
/
&physics
    config_sst_update = false
    config_sstdiurn_update = false
    config_deepsoiltemp_update = false
    config_radtlw_interval = '00:30:00'
    config_radtsw_interval = '00:30:00'
    config_bucket_update = 'none'
    config_physics_suite = 'mesoscale_reference'
/
&soundings
    config_sounding_interval = 'none'
/
```

XML文件和此前填写的相同，需要添加 lbcs 部分（和之前制作的填写相同，不过这里作为输入，而前文作为输出）


