#!/bin/bash
cat <<EOF > ASCDATA.CFG
-90.0	-180.0	lat/lon of lower left corner (last record in file)
1.0	1.0	lat/lon spacing in degrees between data points
180	360	lat/lon number of data points
2		default land use category
0.2		default roughness length (meters)
'/Applications/Hysplit4/bdyfiles/'      directory location of data files
EOF
cat <<EOF > SETUP.CFG
 &SETUP
 tratio = 0.75,
 mgmin = 10,
 khmax = 9999,
 kmixd = 0,
 kmsl = 0,
 nstr = 0,
 mhrs = 9999,
 nver = 0,
 tout = 60,
 tm_tpot = 1,
 tm_tamb = 0,
 tm_rain = 0,
 tm_mixd = 0,
 tm_relh = 0,
 tm_sphu = 1,
 tm_mixr = 0,
 tm_dswf = 0,
 tm_terr = 0,
 dxf = 1.0,
 dyf = 1.0,
 dzf = 0.01,
 /
EOF