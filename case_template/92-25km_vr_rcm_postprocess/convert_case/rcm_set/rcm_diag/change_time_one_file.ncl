;;;11.14 MPAS后处理部分
;;;     从原始数据 or_diri 读入 xtime 转换为正常的时间坐标之后写入需要使用的数据
;;;     暂时写入转变为经纬度网格的数据中
;;;     可参考同级目录下的code_older文件，也有些从文件名获取时间变量的方法
;;;     11.29    处理 2005
;;;     21.01.11 链接mpas convert脚本，将转换后的latlon.nc的时间修改，然后放置到正确的为止
; year = 2013

begin

;;; diro of Time coordinate wanted to change
    diro = "./latlon.nc"
    ; diri      = "/raid52/yycheng/MPAS/92-25km_VR_"+year+"/postprocess/out_convert_latlon/convert_output/history/"
    ; fili      = systemfunc("cd "+diri+"; ls *.nc")
    ;;; ordiri for origin coordinate : xtime
    ; or_diri   = "/raid52/yycheng/MPAS/92-25km_VR_"+year+"/out/history/"
    ; or_fili   = systemfunc("cd "+or_diri+"; ls *.nc")
    or_diri = getenv("OR_NCFILE_PATH")
    ; nfil   = dimsizes(fili)  ;  
    ; do ind_fili = 0,nfil - 1,1;0,nfil - 1,1
        f_out = addfile(diro, "w")
        f_or = addfile(or_diri , "r")
        or_xtime = f_or->xtime
        yyyy   = stringtointeger(charactertostring(or_xtime(:,0:3)))
        mm     = stringtointeger(charactertostring(or_xtime(:,5:6)))
        dd     = stringtointeger(charactertostring(or_xtime(:,8:9)))
        hh     = stringtointeger(charactertostring(or_xtime(:,11:12)))
        mn     = stringtointeger(charactertostring(or_xtime(:,14:15)))
        ss     = stringtointeger(charactertostring(or_xtime(:,17:18)))
        tunits    = "hours since 1990-01-01 00:00:0.0"

        time_exact = cd_inv_calendar((/yyyy/), (/mm/), (/dd/), (/hh/), (/mn/), (/ss/), (/tunits/), 0)
        print("exactly time is: "+time_exact)
        print("or I can say:"+or_xtime)
        ;;; add attributes
        ; float time(time) ;
        ; time:standard_name = "time" ;
        ; time:units = "hours since 1800-1-1 00:00:0.0" ;
        ; time:calendar = "standard" ;
        ; time:axis = "T" ;
;---------------------------------------------------------------------
        time_exact!0 = "Time"
        time_exact@standard_name = "time"
        time_exact@axis = "T"
        f_out->Time = time_exact
    ; end do
end

