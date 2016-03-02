ic_undo_group_begin
# curve method
# #ic_geo_extract_curves AVG_MU0/0 2 45 40
# ic_geo_extract_curves AVG_MU0/0 2 30 0
# ic_geo_create_curve_segment AVG_MU0/0.0 angle angle 20 minedge 1 keep_old 0

# surface method
# extract bounding surfaces
ic_geo_create_surface_segment AVG_MU0/0 angle angle 35 mintri 1000 plane_p {0 0 0} plane_n {0 0 1} keep_old 0 curves {}
# extract curves from surfaces
# ic_geo_extract_curves AVG_MU0/0.1 2 30 0
# ic_geo_extract_curves AVG_MU0/0.2 2 30 0
# ic_geo_extract_curves AVG_MU0/0.3 2 30 0
# ic_geo_extract_curves AVG_MU0/0.4 2 30 0
# ic_geo_extract_curves AVG_MU0/0.5 2 30 0
# ic_geo_extract_curves AVG_MU0/0.6 2 30 0

# delete front and back surfaces
ic_delete_geometry surface names AVG_MU0/0.1 0
ic_delete_geometry surface names AVG_MU0/0.2 0
ic_delete_geometry surface names AVG_MU0/0.3 0
ic_delete_geometry surface names AVG_MU0/0.4 0
ic_delete_geometry surface names AVG_MU0/0.5 0
ic_delete_geometry surface names AVG_MU0/0.6 0

# extract curve that goes around face+trachea
ic_geo_extract_curves AVG_MU0/0.0 2 90 0

# segment curve into four+one parts
ic_geo_create_curve_segment AVG_MU0/0.0.0 angle angle 70 minedge 1 keep_old 0

# rename curves consistently
ic_geo_set_name curve AVG_MU0/0.0.0.5 crv.face.1 1 0
ic_geo_set_name curve AVG_MU0/0.0.0.3 crv.face.2 1 0
ic_geo_set_name curve AVG_MU0/0.0.0.2 crv.face.3 1 0
ic_geo_set_name curve AVG_MU0/0.0.0.6 crv.face.4 1 0
ic_geo_set_name curve AVG_MU0/0.0.0.1 crv.inlet  1 0
# todo: create four points around face using curve-curve intersection method.

ic_point intersect AVG_MU0 pnt.1 {crv.face.1 crv.face.4} tol 0.1
ic_point intersect AVG_MU0 pnt.2 {crv.face.1 crv.face.2} tol 0.1
ic_point intersect AVG_MU0 pnt.3 {crv.face.3 crv.face.4} tol 0.1
ic_point intersect AVG_MU0 pnt.4 {crv.face.2 crv.face.3} tol 0.1

#ic_geo_extract_points <surfname> 70
#ic_geo_extract_curves AVG_MU0/0.6 2 90 0

ic_undo_group_end