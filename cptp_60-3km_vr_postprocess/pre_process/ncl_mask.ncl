;   2021.03.05
;   进行数据的mask处理，将其他数据处理的和 CN05.1 相似，考虑下一步使用CDO
;       有 T2M 和 PRE 两部分需要mask，注意修改路径,变量名等
;   2021.04.17
;   把输出部分改为了文件夹内所有.nc文件的循环
begin

    pathin = "/raid52/yycheng/MPAS/TP_60-3km/pre_daily/ordata/"
    f = addfile(pathin+"CN05.1_2012_07.nc","r")
    v = f->$"pre"$
    v@lat = f->lat
    v@lon = f->lon

    ;-- resources for the shapefile_mask_data function
opt = True
opt@return_mask = True    ;-- this forces the return of a 0s and 1s mask array
opt@delta_kilometers = 300
          
mask_array = v
;-- create the mask based on the given shapefile; add coordinates
; mask_array         =  shapefile_mask_data(v, shp_name, opt) # do not use
; mask_array!0       = "lat"
; mask_array!1       = "lon"
; mask_array&lat     =  f->lat
; mask_array&lon     =  f->lon
; mask_array@comment = "Mask shapefile: DEU_adm/DEU_adm0.shp"
        
;-- set value 0 to missing value

mask_array = where(mask_array .ne. mask_array@_FillValue, 1, mask_array@_FillValue)
print("-----check FillValue-----")
print(mask_array@_FillValue)        
;-- delete, create, and write mask array to new file
pathout = "/raid52/yycheng/MPAS/TP_60-3km/pre_daily/mask_res/"
system("rm -f " + pathout + "mask_template.nc")
fout = addfile(pathout+ "mask_template.nc","c")
fout->mask_array = mask_array



; cdo comand to mask, choose mask file 

; mask_file = "vr_pre_03-15.nc"
mask_files = systemfunc("ls " + pathin + "*.nc" + " | xargs -n 1 basename")
print(mask_files)
dims_mask_files = dimsizes(mask_files)
print("-----check mask template by CDO-----")
do i = 0, dims_mask_files -1, 1
mask_file = mask_files(i)
; print("cdo -mul " + pathin + mask_file +" " + pathout + "mask_template.nc " + pathout + "mask_" + mask_file)
; system("cdo -mul " + pathin + mask_file +" " + pathout +"mask_template.nc " + pathout + "mask_" + mask_file)
print("cdo -f nc ifthen " + pathout + "mask_template.nc " + pathin + mask_file + " " + pathout + "mask_" + mask_file)
system("cdo -f nc ifthen " + pathout +"mask_template.nc " + pathin + mask_file + " " + pathout + "mask_" + mask_file)

end do

end