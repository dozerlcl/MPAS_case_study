#!/usr/bin/env python
# First created by Nanshui, May 16, 2019
import cdsapi

c = cdsapi.Client()

c.retrieve(
    'reanalysis-era5-pressure-levels',
    {
        'product_type': 'reanalysis',
        'variable': [
            'divergence', 'fraction_of_cloud_cover', 'geopotential',
            'ozone_mass_mixing_ratio', 'potential_vorticity', 'relative_humidity',
            'specific_cloud_ice_water_content', 'specific_cloud_liquid_water_content', 'specific_humidity',
            'specific_rain_water_content', 'specific_snow_water_content', 'temperature',
            'u_component_of_wind', 'v_component_of_wind', 'vertical_velocity',
            'vorticity',
        ],
        'pressure_level': [
            '1', '2', '3',
            '5', '7', '10',
            '20', '30', '50',
            '70', '100', '125',
            '150', '175', '200',
            '225', '250', '300',
            '350', '400', '450',
            '500', '550', '600',
            '650', '700', '750',
            '775', '800', '825',
            '850', '875', '900',
            '925', '950', '975',
            '1000',
        ],
        'year': '2020',
        'month': '07',
        'day': [
            '15', '16', '17',
            '18', '19',
        ],
        'time': [
            '00:00', 
            '06:00', 
            '12:00',
            '18:00', 
        ],
        'format': 'netcdf',
    },
    'download.nc')