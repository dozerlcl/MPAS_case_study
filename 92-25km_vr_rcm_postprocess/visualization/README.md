2021.03 数据目录的说明

考虑 49.11 下的数据目录：/raid52/yycheng/MPAS


- /REFERENCE 是参考的观测、再分析数据集
    - /CMORPH/DAILY    降水参考数据  使用目录下的 convert_merge_CMORPH.sh 制作某一年的降水数据的合集
        - /2003~2011       逐年降水
            - /YYYYMM      逐月CMORPH原始降水数据
            - /cdo_merge   CDO进行转换，合并之后的数据
        - /cdo_merge_daily  每年04-08的daily数据合并，sel_CMORPH_03-15.NC合成所有年份
        - /spatialmean      进行空间平均后的数据，以便绘制时间序列

    - /ERA5I_NC                   ERA5I的NC数据集
        - /ERA5I_NC_monthy        ERA5I逐月的各类变量数据
        - /scripts                进行选取出的ERA5I的数据的脚本

    - /TEMP_DATA                  存放了在CN05.1的MASK网格点上进行 pre 和 t2m
        - /mask_*
            - /mask_res           mask的结果存放到这里

    - /CN05.1   CN05.1 precip t2m t2m_max t2m_min 的观测结果
        - /1961-2014
        - /1961-2018
        - sel_03-15 进行选取之后 03-15年的数据

- /RCM_postprocess 是RCM的后处理部分
    - /RCM_model                       原始的进行了转换之后的RCM数据
        - /92-25km_RCM_YYYY            原始数据
            - /out_convert_latlon/     转换之后的数据位置,对应streams的数据输出的类型
                - /diag
                - /history
        - /change_files.sh             添加输出的文件夹的脚本
        - /merge_files.sh              将原始数据处理为 RCM_merge中数据的脚本
    - /RCM_merge                       原始model输出结果在时间上合并的结果
        - /diag                        daily diag，每一年的合并都在此文件夹中
        - /diag_mean_mon               进行月平均处理之后的RCM数据，删除了九月份
        - /pre                         合成之后的降水数据
        - /t2m_hourly                  逐年两米气温的逐小时资料