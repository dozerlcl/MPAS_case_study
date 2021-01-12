# 2020.11.30 处理cmorph，合并为NC文件，并且进行裁剪

year=2008
cd ${year}
# bzip -d for new files
bzip2 -d ${year}*/*
mkdir cdo_merge
cat > CMORPH_V1.0_RAW_0.25deg-DLY_00Z.ctl <<endctl
DSET /raid52/yycheng/CMORPH/DAILY/${year}/%y4%m2/CMORPH_V1.0_ADJ_0.25deg-DLY_00Z_%y4%m2%d2  
TITLE  CMORPH Version 1.0BETA Version, daily precip from 00Z-24Z 
OPTIONS template little_endian
UNDEF  -999.0
XDEF 1440 LINEAR    0.125  0.25
YDEF  480 LINEAR  -59.875  0.25
ZDEF   01 LEVELS 1
TDEF 99999 LINEAR  01apr${year} 1dy 
VARS 1
cmorph   1   99 yyyyy CMORPH Version 1.o daily precipitation (mm)  
ENDVARS
endctl
cdo -f nc -import_binary ./CMORPH_V1.0_RAW_0.25deg-DLY_00Z.ctl ./cdo_merge/CMORPH_${year}04-08.nc
cdo -sellonlatbox,60,140,15,55 ./cdo_merge/CMORPH_${year}04-08.nc ./cdo_merge/CMORPH_${year}04-08_sellon.nc