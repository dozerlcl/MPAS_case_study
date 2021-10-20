#!/usr/bin/env python

"""
 Vertically interpolate MPAS-Atmosphere fields to a specified set
 of isobaric levels. The interpolation is linear in log-pressur.

 Variables to be set in this script include:
    - levs_hPa : a list of isobaric levels, in hPa
    - field_names : a list of names of fields to be vertically interpolated
                    these fields must be dimensioned by ('Time', 'nCells', 'nVertLevels')
    - fill_val : a value to use in interpolated fields to indicate values below
                 the lowest model layer midpoint or above the highest model layer midpoint
"""


from netCDF4 import Dataset
from scipy.interpolate import interp1d
import sys
import numpy as np


if len(sys.argv) < 2 or len(sys.argv) > 3:
    print('')
    print('Usage: isobaric_interp.py <input filename> [output filename]')
    print('')
    print('       Where <input filename> is the name of an MPAS-Atmosphere netCDF file')
    print('       containing a 3-d pressure field as well as all 3-d fields to be vertically')
    print('       interpolated to isobaric levels, and [output filename] optionally names')
    print('       the output file to be written with vertically interpolated fields.')
    print('')
    print('       If an output filename is not given, interpolated fields will be written')
    print('       to a file named isobaric.nc.')
    print('')
    exit()

filename = sys.argv[1]
if len(sys.argv) == 3:
    outfile = sys.argv[2]
else:
    outfile = 'isobaric.nc'

#
# Set list of isobaric levels (in hPa)
#
levs_hPa = [ 1000.0, 975.0, 950.0, 925.0, 900.0,
              850.0, 800.0, 750.0, 700.0, 650.0,
              600.0, 550.0, 500.0, 450.0, 400.0,
              350.0, 300.0, 250.0, 200.0, 150.0,
              100.0,  70.0,  50.0,  30.0,  20.0,
               10.0 ]

field_names = [ 'uReconstructZonal', 'uReconstructMeridional' ]

#
# Set the fill value to be used for points that are below ground
# or above the model top
#
fill_val = -1.0e30

#
# Read 3-d pressure, zonal wind, and meridional wind fields
# on model zeta levels
#
f = Dataset(filename)

nCells = f.dimensions['nCells'].size
nVertLevels = f.dimensions['nVertLevels'].size

pressure = f.variables['pressure'][:]

xtime = f.variables['xtime'][:]

fields = []
for field in field_names:
    fields.append(f.variables[field][:])

f.close()

#
# Convert pressure from Pa to hPa
#
pressure = pressure * 0.01


#
# Compute logarithm of isobaric level values and 3-d pressure field
#
pressure = np.log(pressure)
levs = np.log(levs_hPa)
nlevs_hPa = levs.shape[0]
# levs_hPa
#
# Allocate list of output fields
#
isobaric_fields = []
isobaric_fieldnames = []
for field in field_names:
    # for lev in levs_hPa:
    isobaric_fields.append( np.zeros([1, nCells, nlevs_hPa]) )
    isobaric_fieldnames.append(field)

#
# Create netCDF output file
#

f = Dataset(outfile, 'w', clobber=False)

f.createDimension('Time', size=None)
f.createDimension('nCells', size=nCells)
f.createDimension('plevels', size=nlevs_hPa)
for field in isobaric_fieldnames:
    # print(field.shape)
    f.createVariable(field, 'f', dimensions=('Time','nCells', 'plevels'), fill_value=fill_val)


#

for t in range(len(xtime)):

    timestring = xtime[t,0:19].tostring()
    print('Interpolating fields at time '+timestring.decode('utf-8'))

    #
    # Vertically interpolate
    #
    print("----- start interpolation -----")
    for iCell in range(nCells):

        i = 0
        for field in fields:
            
            isobaric_fields[i][t,iCell,:] = np.interp(levs, pressure[t,iCell,::-1], field[t,iCell,::-1],\
            left=fill_val, right=fill_val)
            i = i + 1



    print("----- finish interpolation -----")

    #
    # Save interpolated fields
    #
    for i in range(len(isobaric_fieldnames)):
        # print("---write---")
        # print(i)
        f.variables[isobaric_fieldnames[i]][t,:,:] = isobaric_fields[i][t,:,:]

f.close()