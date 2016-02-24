ic_set_global geo_cad 0.07 toler

# select 4 points; left->right, top->bottom
# pnt.1, pnt.2, pnt.3, pnt.4
# and they should be in a new part: OPENING

# also, the four curves forming the front of the face should be:
# crv.face.1 .. 4

# create new points using Base point + delta
ic_undo_group_begin
ic_point {} OPENING pnt.1.1 pnt.1+vector(0,50,-10)
ic_point {} OPENING pnt.2.1 pnt.2+vector(0,50,-10)
ic_point {} OPENING pnt.3.1 pnt.3+vector(0,55,-30)
ic_point {} OPENING pnt.4.1 pnt.4+vector(0,55,-30)

# create curves from face to box
ic_curve point OPENING crv.opening.1 {pnt.1 pnt.1.1}
ic_curve point OPENING crv.opening.2 {pnt.2 pnt.2.1}
ic_curve point OPENING crv.opening.3 {pnt.3 pnt.3.1}
ic_curve point OPENING crv.opening.4 {pnt.4 pnt.4.1}

# close front box
ic_curve point OPENING crv.opening.5 {pnt.1.1 pnt.2.1}
ic_curve point OPENING crv.opening.6 {pnt.2.1 pnt.4.1}
ic_curve point OPENING crv.opening.7 {pnt.4.1 pnt.3.1}
ic_curve point OPENING crv.opening.8 {pnt.3.1 pnt.1.1}

# create 5 new surfaces for box
# top
ic_surface 2-4crvs OPENING srf.1 {0.01 {crv.face.1 crv.opening.1 crv.opening.5 crv.opening.2}}
# left (as seen from perspective of face)
ic_surface 2-4crvs OPENING srf.1 {0.01 {crv.face.2 crv.opening.2 crv.opening.6 crv.opening.4}}
# bottom
ic_surface 2-4crvs OPENING srf.1 {0.01 {crv.face.3 crv.opening.3 crv.opening.7 crv.opening.4}}
# right
ic_surface 2-4crvs OPENING srf.1 {0.01 {crv.face.4 crv.opening.3 crv.opening.8 crv.opening.1}}
# front
ic_surface 2-4crvs OPENING srf.1 {0.01 {crv.opening.5 crv.opening.6 crv.opening.7 crv.opening.8}}

ic_undo_group_end