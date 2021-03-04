脚本文件说明：
check_basic 针对ERA5I 的平均态的对比
check_obs   针对观测数据的对比 主要是降水、温度等等量，考虑CMORPH 以及 CN05.1


数据目录的说明文件

考虑 49.11 下的数据目录：/raid52/yycheng/MPAS

    /REFERENCE 是参考的观测、再分析数据集
        /CMORPH/DAILY    降水参考数据  使用目录下的 convert_merge_CMORPH.sh 制作某一年的降水数据的合集
        /2003~2011       逐年降水数据
            /YYYYMM      逐月降水数据
            /cdo_merge   CDO进行转换，合并之后的数据
        /ERA5I                      ERA5I的NC数据集
            /ERA5I_NC_monthy        ERA5I逐月的各类变量数据
            /scripts                进行选取出的ERA5I的数据的脚本




    /RCM_postprocess 是RCM的后处理部分
        /RCM_model                       原始的进行了转换之后的RCM数据
            /92-25km_RCM_YYYY            原始数据
                /out_convert_latlon/     转换之后的数据位置,对应streams的数据输出的类型
                    /diag
                    /history
            /change_files.sh             添加输出的文件夹的脚本
            /merge_files.sh              将原始数据处理为 RCM_merge中数据的脚本
        /RCM_merge                       原始model输出结果在时间上合并的结果
            /diag                        streams数据类型，每一年的合并都在此文件夹中
            /diag_mean_mon               进行月平均处理之后的RCM数据，删除了九月份