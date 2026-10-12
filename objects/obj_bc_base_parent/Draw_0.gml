
if !surface_exists(atlas_surface){
    atlas_surface = surface_create(atlas_size[0],atlas_size[1])
    buffer_set_surface(atlas_backup,atlas_surface,0)
}

if surface_exists(atlas_surface){
    if (shake or life == 0)
        draw_surface_ext(atlas_surface,x+irandom_range(-2,2),drawy,0.30*side,0.30,0,c_white,1)
    else {
    	draw_surface_ext(atlas_surface,x,drawy,0.30*side,0.30,0,c_white,1)
    }
}

var _txt = $"{life}/{maxlife}"
var _str_w = string_width(_txt)
var _str_h = string_height(_txt)

var _x = x+sprite_width/2
var _y = bbox_top - 16

if shake or life == 0{
    _x += irandom_range(-2,2)
}

draw_set_halign(fa_middle)
draw_set_valign(fa_center)

draw_set_colour(c_black) draw_set_alpha(0.5)
draw_rectangle(_x-_str_w/2,_y-_str_h/2,_x+_str_w/2,_y+_str_h/2,false)
draw_set_colour(c_white) draw_set_alpha(1)

draw_text(_x,_y,$"{life}/{maxlife}")

draw_set_halign(fa_left)
draw_set_valign(fa_top)


if DEBUG_BOXES{
    draw_rectangle(bbox_left,bbox_top,bbox_right,bbox_bottom,1)
}