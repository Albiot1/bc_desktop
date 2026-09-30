
if !surface_exists(atlas_surface){
    atlas_surface = surface_create(atlas_size[0],atlas_size[1])
    buffer_set_surface(atlas_backup,atlas_surface,0)
}

if surface_exists(atlas_surface){
    if (shake or life == 0)
        draw_surface_ext(atlas_surface,x-128 * image_xscale+irandom_range(-2,2),drawy,0.30,0.30,0,c_white,1)
    else {
    	draw_surface_ext(atlas_surface,x-128 * image_xscale,drawy,0.30,0.30,0,c_white,1)
    }
}

draw_set_halign(fa_right)
draw_text(1280-8,y-128,$"{life}/{maxlife}")
draw_set_halign(fa_left)

if DEBUG_BOXES{
    draw_rectangle(bbox_left,bbox_top,bbox_right,bbox_bottom,1)
}