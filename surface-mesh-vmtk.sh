spacing="0.1 0.5125628140703586 0.1"
in_file="../../airways/scans/mean/avg4-mu0.3/signdist_smth.tif"

# original script; would have been great except
# VMTK is buggy and doesn't handle coordinates
# property with orientation=coronal.
#vmtkimagereader -spacing $spacing -orientation coronal -ifile $in_file --pipe vmtkimagewriter.py -ofile /tmp/image_volume.vti
#vmtkmarchingcubes -l 255.0 -connectivity 1 -ifile /tmp/image_volume.vti -ofile /tmp/model.vtp
#vmtksurfacereader -ifile /tmp/model.vtp --pipe vmtksurfacewriter -ofile /tmp/model.stl

# updated script
vmtkimagereader -spacing $spacing -ifile $in_file --pipe vmtkimagewriter.py -ofile /tmp/image_volume.vti
vmtkmarchingcubes -l 255.0 -connectivity 1 -ifile /tmp/image_volume.vti -ofile /tmp/model.vtp
vmtksurfacereader -ifile /tmp/model.vtp --pipe vmtksurfacewriter -ofile /tmp/model.stl


# export mesh to OFF
meshlabserver -i /tmp/model.stl -o /tmp/model.OFF

# clean up
rm /tmp/image_volume.vti
rm /tmp/model.vtp