;;; 11.08 view time from convert_mpas output
;;;     进行MPAS后处理
;;;     将前一步 使用 convert_mpas 转换出来的 nc 文件，加上正确的时间坐标
;;;     但仍然没法使用 cdo 进行时次的合并
;;;     这个NCL脚本只对单个文件添加了时间坐标
begin
diri   = "/m2data2/yycheng/MPAS/case_test/240km_uniform_run/out/output/convert/convert_output/"
fili   = systemfunc("cd "+diri+"; ls *.nc")
; print(fili)
nfil   = dimsizes(fili)  ;   放置CMORPH文件夹中所有的文件名
filc   = tochar( fili )

time_exact = new(nfil, double)
do ind_fili = 0,nfil - 1,1;0,nfil - 1,1
; print("now at :"+ind_fili)
    yyyy = stringtointeger(str_get_cols(fili(ind_fili), 8,  11))
    mm   = stringtointeger(str_get_cols(fili(ind_fili), 13, 14))
    dd   = stringtointeger(str_get_cols(fili(ind_fili), 16, 17))
    hh   = stringtointeger(str_get_cols(fili(ind_fili), 19, 20))
    mn   = stringtointeger(str_get_cols(fili(ind_fili), 22, 23))
    ss   = stringtointeger(str_get_cols(fili(ind_fili), 25, 26))

    tunits    = "hours since 1990-01-01 00:00:0.0"
    time_exact(ind_fili) = cd_inv_calendar(yyyy, mm, dd, hh, mn, ss, tunits, 0)

end do
printVarSummary(time_exact)
;;; add time to one files(combined by convert_mpas)
diro   = "/m2data2/yycheng/MPAS/case_test/240km_uniform_run/out/output/convert/"
f_in = addfile(diro + "history_test1.nc", "w")
f_in->Time = time_exact
end