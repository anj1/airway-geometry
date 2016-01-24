#!/bin/bash
set -e

# check for correct number of input arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: cut-mean-mesh.sh <input mesh> <output mesh>"
    exit
fi

# save file as OFF file
meshlabserver -i $1 -o mm-solid-cut0.off

# front
~/src/julia-0.4/julia mesh-cut-plane.jl 0 0 1 0 false mm-solid-cut0.off mm-solid-cut1.off

# top
~/src/julia-0.4/julia mesh-cut-plane.jl 0 -1 0.2 -22 false mm-solid-cut1.off mm-solid-cut2.off
# bottom
~/src/julia-0.4/julia mesh-cut-plane.jl 0 1 0.3 70 false mm-solid-cut2.off mm-solid-cut3.off

# sides
~/src/julia-0.4/julia mesh-cut-plane.jl -1 0 0 -4.1 true mm-solid-cut3.off mm-solid-cut4.off
~/src/julia-0.4/julia mesh-cut-plane.jl 1 0 0 57.1 true mm-solid-cut4.off mm-solid-cut5.off

# inlet
~/src/julia-0.4/julia mesh-cut-plane.jl 0 1 -0.15 100 false mm-solid-cut5.off mm-solid-cut.off

# remove temporary files
rm mm-solid-cut0.off
rm mm-solid-cut1.off
rm mm-solid-cut2.off
rm mm-solid-cut3.off
rm mm-solid-cut4.off
rm mm-solid-cut5.off

# remove duplicated vertices and save as STL
meshlabserver -i mm-solid-cut.off -o $2 -s remove-dup.xml
