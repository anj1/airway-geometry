set -e 

# check for correct number of input arguments
if [ "$#" -ne 4 ]; then
    echo "Usage: cut-out-trachea.sh <input mesh> <landmark file> <output mesh> <centerline-out.dat>"
    exit
fi

meshlabserver -i $1 -o input.off
~/src/julia-0.4/julia align_to_landmarks.jl input.off aligned.off $2
rm input.off

# obtain z-axis minimum of mesh
ZMIN=`~/src/julia-0.4/julia mesh_z_minimum.jl aligned.off`
# add 1 cm safety factor to this
ZMIN=`echo "-($ZMIN)-10.0" | bc -l`

# cut out trachea; first top then bottom
# we use mesh-cut-plane-extend simply because it can give us
# open ends; we discard the extension.
#~/src/julia-0.4/julia mesh-cut-plane-extend.jl 0.0 -0.15 -1.0  -20.0 false 0.0 aligned.off cut-inlet.off /dev/null
~/src/julia-0.4/julia mesh-cut-plane-extend.jl 0.0 -1.0 -1.0  -60.0 false 0.0 aligned.off cut-inlet.off /dev/null
~/src/julia-0.4/julia mesh-cut-plane-extend.jl 0.0  0.0  1.0  $ZMIN false 0.0 cut-inlet.off trachea.off /dev/null
# cut out remains of front of face as well
~/src/julia-0.4/julia mesh-cut-plane.jl 0.0 -1.0 0.0  -40.0 false trachea.off trachea.off /dev/null
rm aligned.off
rm cut-inlet.off

# convert to stl then vtp
meshlabserver -i trachea.off -o $3
vmtksurfacereader -ifile $3 -ofile trachea.vtp
# use vmtk to interactively label trachea inlet and outlet
vmtkcenterlines -seedselector openprofiles -ifile trachea.vtp -ofile trachea_cl.vtp
vmtksurfacewriter -ifile trachea_cl.vtp -ofile $4
rm trachea.off
rm trachea.vtp
rm trachea_cl.vtp

# call on all airways with:
# for i in ~/airways/scans/landmarks/*.csv; do bn=$(basename --suffix=.csv "$i"); echo $bn; for j in ~/airways/scans/segs/$bn*.stl; do ./cut-out-trachea.sh $j $i /tmp/$bn.stl /tmp/$bn-cl.dat; done; done