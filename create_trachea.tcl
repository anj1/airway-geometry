# first, merge curves and rename to crv.inlet;
# and also rename surface to srf.inlet

# be able to undo this whole operation at once
ic_undo_group_begin

# create new part (inlet)
ic_geo_new_family INLET
ic_boco_set_part_color INLET

# create new point on curve ends
ic_point curve_end INLET pnt.00 {crv.inlet both}

# create new point using Base point + Delta
ic_point {} INLET pnt.02 pnt.00+vector(0,-15,-100)

# create line connecting the two points
ic_curve point INLET crv.trachea {pnt.00 pnt.02}

# create driving surface using line and curve
ic_geo_cre_srf_crv_drv_srf INLET srf.trachea crv.inlet crv.trachea 1
ic_reinit_geom_objects 

# move inlet 
ic_move_geometry surface names srf.inlet translate {0 -10 -100}
ic_geo_reset_data_structures 

# assigning surface to INLET part
ic_geo_set_part surface srf.inlet INLET 0
ic_delete_empty_parts

ic_undo_group_end
