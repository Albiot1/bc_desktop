if !surface_exists(data.atlas_surface){
    data.atlas_surface = surface_create(data.atlas_size[0],data.atlas_size[1])
    
    buffer_set_surface(data.atlas_backup,data.atlas_surface,0)
}


bc_draw_baked_frame_atlas_new_fixed(data.anim,frame,data.atlas_surface,x,y,0.5)