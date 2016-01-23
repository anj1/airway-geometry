# airway-geometry

Scripts for processing human airway geometries for CFD simulation

* create_trachea.tcl : ICEM script for attaching tracheal flow extension to mesh. To use, rename the curve around the tracheal opening to crv.inlet and its corresponding surface to srf.inlet; then run the script.
* create_trach_cyl.tcl : ICEM script for attaching tracheal flow extension with circular cross-section to mesh. To use, rename the curve around the tracheal opening to crv.inlet and its corresponding surface to srf.inlet; then run the script.
* triangle-io.jl : Julia functions for loading and saving in Jonathan Shewchuk's Triangle format.
* remove-dup.mlx : MeshLab filter script for removing duplicate vertices (useful on output of mesh-plane-cut.jl)
* cut-mean-mesh.sh : Script for cutting a box around the mean mesh and also cutting the tracheal plane (requires Meshlab and Julia).
* cut-mesh-plane.jl : Julia script to cut a mesh along a plane. Identical to MeshMixer's 'plane cut' function easier to automate.
