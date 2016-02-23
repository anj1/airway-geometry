set -e 

in_file="../../airways/scans/mean/avg4-mu0.3/signdist_smth.tif"

# original script; would have been great except
# VMTK is buggy and doesn't handle coordinates
# property with orientation=coronal.
#spacing="0.1 0.5125628140703586 0.1"
#vmtkimagereader -spacing $spacing -orientation coronal -ifile $in_file --pipe vmtkimagewriter.py -ofile /tmp/image_volume.vti
#vmtkmarchingcubes -l 255.0 -connectivity 1 -ifile /tmp/image_volume.vti -ofile /tmp/model.vtp
#vmtksurfacereader -ifile /tmp/model.vtp --pipe vmtksurfacewriter -ofile /tmp/model.stl

# updated script
spacing="0.1 0.1 0.5125628140703586"
vmtkimagereader -spacing $spacing -ifile $in_file --pipe vmtkimagewriter.py -ofile /tmp/image_volume.vti
vmtkmarchingcubes -l 255.0 -connectivity 1 -ifile /tmp/image_volume.vti -ofile /tmp/model.vtp
vmtksurfacereader -ifile /tmp/model.vtp --pipe vmtksurfacewriter -ofile /tmp/model.stl

# export mesh to OFF
meshlabserver -i /tmp/model.stl -o /tmp/model.off -s remove-dup.xml

# clean up
rm /tmp/image_volume.vti
rm /tmp/model.vtp
rm /tmp/model.stl

~/src/julia-0.4/julia bend-mesh.jl ../airway/data/slicexforms.hdf5 /tmp/model.off /tmp/modelb.off
rm /tmp/model.off

meshlabserver -i /tmp/modelb.off -o /tmp/modelb.ply
rm /tmp/modelb.off