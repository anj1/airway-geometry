# Create density region around nasal cavity

# width, ratio, maximum size 
# (see ICEM CFD 12.1 help manual, page 292)
set d_width 5
set d_ratio 1.2
set d_size

ic_undo_group_begin 
ic_geo_new_family CAVITY 
ic_boco_set_part_color CAVITY 

# create new points using base point+delta
ic_point {} CAVITT pnt.d.1 pnt.1+vector(-10,-90,-10)
ic_point {} CAVITT pnt.d.2 pnt.2+vector( 10,-90,-10)
ic_point {} CAVITT pnt.d.3 pnt.3+vector(-10,-90,-10)
ic_point {} CAVITT pnt.d.4 pnt.4+vector( 10,-90,-10)

# create new density
ic_geo_create_density density.cavity 0.3 {pnt.1 pnt.2 pnt.3 pnt.4 pnt.d.1 pnt.d.2 pnt.d.3 pnt.d.4} d_width d_ratio

ic_undo_group_end 
