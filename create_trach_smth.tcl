ic_undo_group_begin
#set radius 4.741459155218981
set radius 5.5

ic_geo_new_family INLET
ic_boco_set_part_color INLET

ic_set_global geo_cad 0.07 toler 
ic_geo_modify_curve_reappr crv.inlet 0.1 0

ic_set_global geo_cad 0.07 toler 

ic_point crv_par INLET pnt.02 {topo_curve/8 0.0}  
ic_point crv_par INLET pnt.03 {topo_curve/8 0.125}  
ic_point crv_par INLET pnt.05 {topo_curve/8 0.25}  
ic_point crv_par INLET pnt.06 {topo_curve/8 0.375}  
ic_point crv_par INLET pnt.07 {topo_curve/8 0.5}  
ic_point crv_par INLET pnt.08 {topo_curve/8 0.625}  
ic_point crv_par INLET pnt.09 {topo_curve/8 0.75}  
ic_point crv_par INLET pnt.10 {topo_curve/8 0.875} 

ic_set_global geo_cad 0.07 toler   
#ic_delete_geometry curve names crv.00 0
ic_curve point INLET crv.00 {pnt.02 pnt.03 pnt.05 pnt.06 pnt.07 pnt.08 pnt.09 pnt.10 pnt.02}   

ic_move_geometry curve names crv.00 translate {0 -4.5 -30} 
ic_geo_reset_data_structures  

ic_geo_configure_one_attribute surface shade wire
ic_set_global geo_cad 0.08 toler 
ic_geo_cre_srf_loft_crvs INLET srf.00 0.1 {topo_curve/8 crv.00} 4 0 1
ic_set_global geo_cad 0.08 toler
ic_set_dormant_pickable point 0 {}
ic_set_dormant_pickable curve 0 {} 
ic_set_global geo_cad 0.08 toler
ic_point {} INLET pnt.11 pnt.05+(pnt.09-pnt.05)*0.5      

ic_set_global geo_cad 0.08 toler   
ic_curve arc_ctr_rad INLET crv.01 {pnt.11 INLET.16 pnt.05 radius 0 360}   
ic_set_global geo_cad 0.08 toler  
ic_move_geometry curve names crv.01 translate {0 -9 -60} 
ic_geo_reset_data_structures  
ic_geo_configure_one_attribute surface shade wire
ic_set_global geo_cad 0.09 toler 
ic_geo_cre_srf_loft_crvs INLET srf.01 0.1 {crv.00 crv.01} 4 0 1
ic_set_global geo_cad 0.09 toler
ic_set_dormant_pickable point 0 {}
ic_set_dormant_pickable curve 0 {} 
ic_set_global geo_cad 0.09 toler  
ic_geo_duplicate_set_fam_and_data curve crv.01 crv.01.0 {} _0
ic_move_geometry curve names crv.01.0 translate {0 -9 -60} 
ic_geo_reset_data_structures  
ic_geo_configure_one_attribute surface shade wire
ic_set_global geo_cad 0.1 toler 
ic_geo_cre_srf_loft_crvs INLET srf.02 0.1 {crv.01 crv.01.0} 4 0 1
ic_set_global geo_cad 0.1 toler
ic_set_dormant_pickable point 0 {}
ic_set_dormant_pickable curve 0 {}  
ic_delete_geometry point names {pnt.03 pnt.05 pnt.06 pnt.07 pnt.08 pnt.09 pnt.10} 0 1
ic_set_dormant_pickable point 0 {}  
ic_delete_geometry point names pnt.11 0 1
ic_set_dormant_pickable point 0 {}  s
ic_delete_empty_parts  
ic_undo_group_end