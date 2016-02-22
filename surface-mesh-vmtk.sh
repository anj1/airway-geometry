vmtkimagereader -spacing 0.1 0.5125628140703586 0.1 -orientation coronal -ifile ~/airways/scans/mean/avg4-mu0.3/signdist_smth.tif --pipe vmtkimagewriter.py -ofile /tmp/image_volume.vti

vmtkmarchingcubes -l 255.0 -connectivity 1 -ifile /tmp/image_volume.vti -ofile /tmp/model.vtp

vmtksurfacereader -ifile /tmp/model.vtp --pipe vmtksurfacewriter -ofile /tmp/model.stl

# export mesh to OFF