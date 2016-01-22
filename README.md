# airway-geometry

Scripts for processing human airway geometries for CFD simulation

* create_trachea.tcl : ICEM script for attaching tracheal flow extension to mesh. To use, rename the curve around the tracheal opening to crv.inlet and its corresponding surface to srf.inlet; then run the script.
* create_trach_cyl.tcl : ICEM script for attaching tracheal flow extension with circular cross-section to mesh. To use, rename the curve around the tracheal opening to crv.inlet and its corresponding surface to srf.inlet; then run the script.
* triangle-io.jl : Julia functions for loading and saving in Jonathan Shewchuk's Triangle format.
