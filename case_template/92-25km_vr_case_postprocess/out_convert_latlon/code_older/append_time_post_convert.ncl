;;; 11.08 view time from convert_mpas output
;;;     进行MPAS后处理
;;;     将前一步 使用 convert_mpas 转换出来的 nc 文件，加上正确的时间坐标
;;;     但仍然没法使用 cdo 进行时次的合并
begin
diri   = "/raid52/yycheng/MPAS/92-25km_VR/out_convert_latlon/convert_output/history/"
fili   = systemfunc("cd "+diri+"; ls *.nc")
; print(fili)
nfil   = dimsizes(fili)  ;   放置CMORPH文件夹中所有的文件名
filc   = tochar( fili )
; yyyy   = new(nfil, integer)
; filc   = stringtointeger(filc)
; print(fili(13))
; print((filc(14,8:11)))
do ind_fili = 0,nfil - 1,1;0,nfil - 1,1
print("now at :"+ind_fili)

    f_in = addfile(diri + fili(ind_fili), "w")
    yyyy = stringtointeger(str_get_cols(fili(ind_fili), 8,  11))
    mm   = stringtointeger(str_get_cols(fili(ind_fili), 13, 14))
    dd   = stringtointeger(str_get_cols(fili(ind_fili), 16, 17))
    hh   = stringtointeger(str_get_cols(fili(ind_fili), 19, 20))
    mn   = stringtointeger(str_get_cols(fili(ind_fili), 22, 23))
    ss   = stringtointeger(str_get_cols(fili(ind_fili), 25, 26))
    ; mm   = stringtointeger(filc(ind_fili, 13:14))
    ; dd   = stringtointeger(filc(ind_fili, 16:17))
    ; hh   = stringtointeger(filc(ind_fili, 19:20))
    ; mn   = stringtointeger(filc(ind_fili, 22:23))
    ; ss   = stringtointeger(filc(ind_fili, 25:26))
    tunits    = "hours since 1990-01-01 00:00:0.0"
    time_exact = cd_inv_calendar(yyyy, mm, dd, hh, mn, ss, tunits, 0)
    print("exactly time is: "+time_exact)
 f_in->Time = time_exact
 delete(f_in)
; printVarSummary(sst)
; sst!0=
; sst&Time = 0

end do

end