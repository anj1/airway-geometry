# note: if lofted surface is deformed/twisted, undo and then
# reverse the direction of crv.inlet and try again.

ic_undo_group_begin

# create new part (inlet)
ic_geo_new_family INLET
ic_boco_set_part_color INLET

# create five points at (hopefully) equally-spaced portions of curve
ic_point crv_par INLET pnt.11 {crv.inlet 0.0}
ic_point crv_par INLET pnt.12 {crv.inlet 0.2}
ic_point crv_par INLET pnt.13 {crv.inlet 0.4}
ic_point crv_par INLET pnt.14 {crv.inlet 0.6}
ic_point crv_par INLET pnt.15 {crv.inlet 0.8}

# take average point
ic_point {} INLET pnt.center (pnt.11+pnt.12+pnt.13+pnt.14+pnt.15)*0.2
# delete unneeded points (we still need the others to make our circle)
ic_delete_geometry point names {pnt.13 pnt.14 pnt.15} 0 1

# create our circle
#set radius 6.18
set radius 5.0
set height 50.0
ic_curve arc_ctr_rad INLET crv.circ.trachea {pnt.center pnt.11 pnt.12 $radius 0 360}
# delete extra unneeded points
ic_delete_geometry point names {pnt.11 pnt.12} 0 1

# move circle
ic_move_geometry curve names crv.circ.trachea translate {0 -30 4.5}

# delete tracheal surface
ic_delete_geometry surface names srf.inlet 0

# loft between trachea and circle
ic_geo_cre_srf_loft_crvs INLET srf.loft.trachea 0.1 {crv.inlet crv.circ.trachea} 4 0 1

# create end circle for final extension part
ic_geo_duplicate_set_fam_and_data curve crv.circ.trachea crv.circ.inlet {} _0
ic_move_geometry curve names crv.circ.inlet translate {0 -100 15}
ic_geo_reset_data_structures

# loft and create final extension part
ic_geo_cre_srf_loft_crvs INLET srf.loft.inlet 0.1 {crv.circ.trachea crv.circ.inlet} 4 0 1

# create inlet surface
ic_surface bsinterp INLET srf.inlet crv.circ.inlet

ic_undo_group_end
