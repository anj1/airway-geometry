# airway-geometry

Scripts for processing human airway geometries for CFD simulation

* **create_trachea.tcl** : [ICEM](http://resource.ansys.com/Products/Other+Products/ANSYS+ICEM+CFD) script for attaching tracheal flow extension to mesh. To use, rename the curve around the tracheal opening to crv.inlet and its corresponding surface to srf.inlet; then run the script.
* **create_trach_cyl.tcl** : [ICEM](http://resource.ansys.com/Products/Other+Products/ANSYS+ICEM+CFD) script for attaching tracheal flow extension with circular cross-section to mesh. To use, rename the curve around the tracheal opening to crv.inlet and its corresponding surface to srf.inlet; then run the script.
* **triangle-io.jl** : [Julia](http://julialang.org/) functions for loading and saving in Jonathan Shewchuk's [Triangle](https://www.cs.cmu.edu/~quake/triangle.html) format.
* **remove-dup.xml** : [MeshLab](http://meshlab.sourceforge.net/) filter script for removing duplicate vertices (useful on output of mesh-plane-cut.jl)
* **cut-mean-mesh.sh** : Script for cutting a box around the mean mesh and also cutting the tracheal plane (requires [MeshLab](http://meshlab.sourceforge.net/) and [Julia](http://julialang.org/)).
* **cut-mesh-plane.jl** : [Julia](http://julialang.org/) script to cut a mesh along a plane. Identical to [MeshMixer](http://www.meshmixer.com/)'s 'plane cut' function easier to automate. Requires installation of [Triangle](https://www.cs.cmu.edu/~quake/triangle.html).
* **OFF.jl** : Julia functions for loading/saving [OFF](https://en.wikipedia.org/wiki/OFF_(file_format)) files.
