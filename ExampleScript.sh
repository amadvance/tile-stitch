# Example of use with StravaHeatMap, OpenStreetMap and GoogleMap

# Name of the maps to generate
NAME=MonteCantoBergamo

# Coordinates of the zone
# X1,Y1 is the bottom-left corner
# X2,Y2 is the top-right corner
X1=45.70095970
Y1=9.45200482
X2=45.73644927
Y2=9.55567040

# Zoom level. 15 is the most detailed for StravaHeatMap
Z=15

# Get StravaHeatmap
# WARNING Cookies expire after some days. You have to refresh them.
# See: https://nuxx.net/blog/2020/05/24/high-resolution-strava-global-heatmap-in-josm/
# Ensure to replace &amp; with &
URL="https://heatmap-external-a.strava.com/tiles-auth/all/hot/{z}/{x}/{y}.png"
COOKIES="?Key-Pair-Id=APKAIDPUN4QMG7VUQPSA&Signature=g-opHPdHt9G2hCOn8FvuN5~muG96nZ59N49Ie9k8hsOVr1yMI6KhJP6S68hWRY6LUdtnVK0wh~61RAaSby4LQtgENneB2jafsErikbAZntKBeqT243zv-hUErFw-uzfX3eeQYibIC7a~r~tpmZ3g4kfm0ugV40Lrw-uKKxlOncr6tK4X8yJZTuEQqH2P2Estq-KtYi8NAqrH5Ezfg9jvNeex~Yg~m7Twrjw-Y-EUaA2HD7Riw0eA8q13--J8LXIF~LdA1HFH03toZrp2HyuaD~l9rEuGuTTPb4RYJTMhytvpSVolQ14gLvZB5wE7GxFgE1YKGq9tPiZ3zfTa63jR1g__&Policy=eyJTdGF0ZW1lbnQiOiBbeyJSZXNvdXJjZSI6Imh0dHBzOi8vaGVhdG1hcC1leHRlcm5hbC0qLnN0cmF2YS5jb20vKiIsIkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTYzNzQzNjA4Mn0sIkRhdGVHcmVhdGVyVGhhbiI6eyJBV1M6RXBvY2hUaW1lIjoxNjM2MjEyMDgyfX19XX0_"
#./stitch -s 512 -o $NAME.tif -w -f geotiff -- $X1 $Y1 $X2 $Y2 $Z "${URL}${COOKIES}"

# Get OpenStreetMap (one zoom level more than strava due different tile size)
URL="http://a.tile.openstreetmap.org/{z}/{x}/{y}.png"
./stitch -s 256 -o $NAME-OpenStreetMap.tif -w -f geotiff -- $X1 $Y1 $X2 $Y2 $(($Z+1)) "${URL}"

# Get GoogleMap (one zoom level more than strava due different tile size)
URL="https://mt.google.com/vt/lyrs=s&x={x}&y={y}&z={z}"
./stitch -s 256 -o $NAME-GoogleMap.tif -w -f geotiff -- $X1 $Y1 $X2 $Y2 $(($Z+1)) "${URL}"

# Merge OpenStreetMap and StravaHeatMap
gdalwarp $NAME-OpenStreetMap.tif $NAME.tif $NAME-SO.tif

# Merge GoogleMap and StravaHeatMap
gdalwarp $NAME-GoogleMap.tif $NAME.tif $NAME-SG.tif

# Create the JNX with the OpenStreetMap background (works with Basecamp)
qmt_map2jnx -x 782 -q 90 -s 411 -p 0 -m BirdsEye -n $NAME -c StravaHeatmap -z 50 $NAME-SO.tif $NAME.jnx

# Create the KMZ with the GoogleMap background (works with GoogleEarth)
gdal_translate -of KMLSUPEROVERLAY $NAME-SG.tif $NAME.kmz -co FORMAT=JPEG

# Create the VRT from the StravaHeatMap with transparency (works with QMapShack)
gdalbuildvrt $NAME.vrt $NAME.tif

# Create the VRT overlay (images at lower zoom levels)
gdaladdo --config COMPRESS_OVERVIEW LZW $NAME.vrt

