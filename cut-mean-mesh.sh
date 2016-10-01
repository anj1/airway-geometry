#!/bin/bash
set -e

# check for correct number of input arguments
if [ "$#" -ne 3 ]; then
    echo "Usage: cut-mean-mesh.sh <input mesh> <output mesh> <extension mesh>"
    exit
fi

# save file as OFF file
meshlabserver -i $1 -o mm-solid-cut0.off

# front, top, bottom, side1, side2, inlet
julia mesh-cut-plane.jl  0.0  -1.0    0.0  50.0  false mm-solid-cut0.off mm-solid-cut1.off
julia mesh-cut-plane.jl  0.0  -0.2   -1.0  48.0  false mm-solid-cut1.off mm-solid-cut2.off
julia mesh-cut-plane.jl  0.0  -0.2    1.0  14.0  false mm-solid-cut2.off mm-solid-cut3.off
julia mesh-cut-plane.jl -1.0  -0.001  0.0  28.1  true  mm-solid-cut3.off mm-solid-cut4.off
julia mesh-cut-plane.jl  1.0  -0.001  0.0  28.1  true  mm-solid-cut4.off mm-solid-cut5.off
julia mesh-cut-plane-extend.jl  0.0   0.15   1.0  35.0  false -80.0 mm-solid-cut5.off mm-solid-cut.off mm-solid-ext.off

# remove temporary files
rm mm-solid-cut0.off
rm mm-solid-cut1.off
rm mm-solid-cut2.off
rm mm-solid-cut3.off
rm mm-solid-cut4.off
rm mm-solid-cut5.off

# remove duplicated vertices and save as STL
meshlabserver -i mm-solid-cut.off -o $2 -s remove-smallcomp.xml
meshlabserver -i mm-solid-ext.off -o mm-solid-ext.off -s remove-dup.xml
meshlabserver -i mm-solid-ext.off -o $3 -s remove-smallcomp.xml
rm mm-solid-cut.off
rm mm-solid-ext.off