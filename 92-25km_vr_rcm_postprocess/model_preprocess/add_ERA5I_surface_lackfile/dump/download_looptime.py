import numpy as np
import xarray as xr
import pandas as pd
from ecmwfapi import ECMWFDataServer

import sys

# make a copy of original stdout route
stdout_backup = sys.stdout
# define the log file that receives your log info
log_file = open("message.log", "w")
# redirect print output to log file
sys.stdout = log_file


time_3hr    = pd.date_range('1994-04-01T00:00', '1994-04-03T00:00', freq = '3h')
time_3hr_da = xr.DataArray(time_3hr, name = "time")
datestring  = time_3hr.strftime("%Y-%m-%dT%H:%M")

print("----- start download script! -----\n")
server = ECMWFDataServer()
for ind,single_datestring in enumerate(time_3hr[0:-1]): # loop到倒数第二个
    
    start_date = single_datestring.strftime("%Y-%m-%d")
    end_date   = time_3hr[ind+1].strftime("%Y-%m-%d")

    print("Time step: NO.[ " + str(ind+1) + "/" + str(time_3hr.size) + " ] " + " -----dealing:" + "./download_files/ERA5I_SFC1_" + str(single_datestring) + ".grb")
    
    server.retrieve({
        "class": "ei",
        "dataset": "interim",
    #     "date": "1994-04-01/to/1994-04-03",
        "date": start_date + "/to/" + end_date,
        "expver": "1",
        "grid": "0.75/0.75",
        "levtype": "sfc",
        "param": "31.128/32.128/33.128/34.128/35.128/36.128/37.128/38.128/39.128/40.128/41.128/42.128/53.162/54.162/55.162/56.162/57.162/58.162/59.162/60.162/61.162/62.162/63.162/64.162/65.162/66.162/67.162/68.162/69.162/70.162/71.162/72.162/73.162/74.162/75.162/76.162/77.162/78.162/79.162/80.162/81.162/82.162/83.162/84.162/85.162/86.162/87.162/88.162/89.162/90.162/91.162/92.162/134.128/136.128/137.128/139.128/141.128/148.128/151.128/164.128/165.128/166.128/167.128/168.128/170.128/173.128/174.128/183.128/186.128/187.128/188.128/198.128/206.128/234.128/235.128/236.128/238.128",
        "step": "0",
        "stream": "oper",
        "time": "00:00:00/06:00:00/12:00:00/18:00:00",
        "type": "an",
        "target": "./download_files/ERA5I_SFC1_" + str(single_datestring) + ".grb",
    })
    server.retrieve({
        "class": "ei",
        "dataset": "interim",
        "date": start_date + "/to/" + end_date,
        "expver": "1",
        "grid": "0.75/0.75",
        "levtype": "sfc",
        "param": "20.128/31.128/32.128/33.128/34.128/35.128/36.128/37.128/38.128/39.128/40.128/41.128/42.128/44.128/45.128/49.128/50.128/57.128/58.128/59.128/78.128/79.128/134.128/136.128/137.128/139.128/141.128/142.128/143.128/144.128/145.128/146.128/147.128/148.128/151.128/159.128/164.128/165.128/166.128/167.128/168.128/169.128/170.128/175.128/176.128/177.128/178.128/179.128/180.128/181.128/182.128/183.128/186.128/187.128/188.128/189.128/195.128/196.128/197.128/198.128/201.128/202.128/205.128/206.128/208.128/209.128/210.128/211.128/212.128/228.128/229.128/230.128/231.128/232.128/235.128/236.128/238.128/239.128/240.128/243.128/244.128/245.128",
        "step": "3",
        "stream": "oper",
        "time": "00:00:00/12:00:00",
        "type": "fc",
        "target": "./download_files/ERA5I_SFC2_" + str(single_datestring) + ".grb",
    })
    server.retrieve({
        "class": "ei",
        "dataset": "interim",
        "date": start_date + "/to/" + end_date,
        "expver": "1",
        "grid": "0.75/0.75",
        "levtype": "sfc",
        "param": "229.140/230.140/232.140",
        "step": "0",
        "stream": "wave",
        "time": "00:00:00/06:00:00/12:00:00/18:00:00",
        "type": "an",
        "target": "./download_files/ERA5I_SFC3_" + str(single_datestring)+ ".grb",
    })
