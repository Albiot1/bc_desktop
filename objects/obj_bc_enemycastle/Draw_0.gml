
if !surface_exists(atlas_surface){
    atlas_surface = surface_create(atlas_size[0],atlas_size[1])
    buffer_set_surface(atlas_backup,atlas_surface,0)
}

if surface_exists(atlas_surface){
    if (shake or life == 0)
        draw_surface_ext(atlas_surface,x+irandom_range(-2,2),drawy,0.30,0.30,0,c_white,1)
    else {
    	draw_surface_ext(atlas_surface,x,drawy,0.30,0.30,0,c_white,1)
    }
}

draw_text(8,y-sprite_height,$"{life}/{maxlife}")

if DEBUG_BOXES{
    draw_rectangle(bbox_left,bbox_top,bbox_right,bbox_bottom,1)
}