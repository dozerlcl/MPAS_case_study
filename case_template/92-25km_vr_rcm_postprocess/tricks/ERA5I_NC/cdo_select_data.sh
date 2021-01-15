#!/bin/bash
NCDATA=/raid63/ERA5/netcdf/Monthly
NCNAME=

for IFILE in `ls ${NCDATA}/*.nc`;do
echo "${IFILE} ok"
##NCNAME=`basename ${IFILE}`
##cdo -selyear,2003/2004 $NCDATA/hgt.mon.mean.nc temp1.nc
##cdo -selmon,04/08 temp1.nc temp2.nc
cdo -L -remapbil,grid_info -selmon,4/8 -selyear,2003/2015 $IFILE sel_`basename ${IFILE}` &
##mv temp1.nc sel_$NCNAME
echo "-----finish convert-----"
##break
done
