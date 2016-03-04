# airway-geometry

Scripts for processing human airway geometries for CFD simulation

* **extract\_topo.tcl** : [ICEM](http://resource.ansys.com/Products/Other+Products/ANSYS+ICEM+CFD) script for extracting useful topology (face curves, tracheal curve, etc.) from a input STL geometry.
* **create\_trachea.tcl** : ICEM script for attaching tracheal flow extension to mesh. To use, rename the curve around the tracheal opening to crv.inlet and its corresponding surface to srf.inlet; then run the script.
* **create\_trach\_cyl.tcl** : ICEM script for attaching tracheal flow extension with circular cross-section to mesh. To use, rename the curve around the tracheal opening to crv.inlet and its corresponding surface to srf.inlet; then run the script.
* **create\_trach\_smth.tcl** : ICEM script for attaching a tracheal flow extension. Use after using extract_topo.tcl. The major difference with the above script is that the attached flow extension has a smoother transition.
* **surf\_from\_pts.tcl** : ICEM script for creating an extended box around the face. To use, rename the curves around the face crv.face.1, ... , crv.face.2 (in counter-clockwise order from the perspective of the face) and the points pnt.1, ... , pnt.4 in top->bottom, right->left order.
* **triangle-io.jl** : [Julia](http://julialang.org/) functions for loading and saving in Jonathan Shewchuk's [Triangle](https://www.cs.cmu.edu/~quake/triangle.html) format.
* **remove-dup.xml** : [MeshLab](http://meshlab.sourceforge.net/) filter script for removing duplicate vertices (useful on output of mesh-plane-cut.jl)
* **cut-mean-mesh.sh** : Script for cutting a box around the mean mesh and also cutting the tracheal plane (requires MeshLab and  Julia).
* **cut-mesh-plane.jl** : Julia script to cut a mesh along a plane. Identical to [MeshMixer](http://www.meshmixer.com/)'s 'plane cut' function easier to automate. Requires installation of [Triangle](https://www.cs.cmu.edu/~quake/triangle.html).
* **bend-mesh.jl** : One step in processing meshes is to take angled cross-sections across different parts of the mesh. This script takes a mesh generated with such cross-sections and transforms it back to a straightened mesh.
* **OFF.jl** : Julia functions for loading/saving [OFF](https://en.wikipedia.org/wiki/OFF_(file_format)) files.
* **signed_distance.ijm** : [ImageJ/Fiji](http://fiji.sc/Fiji) [script](http://rsbweb.nih.gov/ij/docs/macro_reference_guide.pdf) to compute the signed distance of a stack of images and save it as 32-bit TIFF. Requires input stack to be named 'avg'.
* **smooth_mask.ijm** : Used by `signed_distance.ijm`, this is an ImageJ script that reads `smooth_maska.png` and `smooth_maskb.png` and constructs a smoothing mask with more gradual transition between non-smoothed and smoothed regions.