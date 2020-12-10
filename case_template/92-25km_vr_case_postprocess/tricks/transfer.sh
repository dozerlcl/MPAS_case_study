selectyear=2006
# modtype=RCM
modtype=VR
# part=
# part=postprocess
part=out

# .19
here=/raid52/yycheng/MPAS/92-25km_${modtype}_${selectyear}/
# .11
# here=/raid51/yycheng/MPAS/92-25km_${modtype}_${selectyear}/
#.132
# here=/data2/yycheng/MPAS/92-25km_${modtype}_${selectyear}/${part}

# .19
# there=/raid52/yycheng/MPAS/92-25km_${modtype}_${selectyear}/${part}
# .11
there=/raid51/yycheng/MPAS/92-25km_${modtype}_${selectyear}/
#.132
# there=/data2/yycheng/MPAS/92-25km_${modtype}_${selectyear}/

# .19
# scp -r ${here} yycheng@114.212.49.19:${there}
# .11
scp -r ${here} yycheng@114.212.49.11:${there}
# .132
# scp -r ${here} yycheng@114.212.49.132:${there}


