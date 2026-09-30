depth = 10

atlas_surface = surface_create(128*2, 256*2);
var _blend_surface = surface_create(128,256);

gpu_set_tex_filter(false)

surface_set_target(_blend_surface);
draw_clear_alpha(c_black, 0);

gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_one, bm_inv_src_alpha);
draw_sprite_ext(spr_nyanko_castle_bottom, 0, 128, 256, 1, 1, 0, c_white, 1);
draw_sprite_ext(spr_nyanko_castle_decor, 0, 128, 256, 1, 1, 0, c_white, 1);
draw_sprite_ext(spr_nyanko_castle_top, 0, 128, 256, 1, 1, 0, c_white, 1);

surface_reset_target();

surface_set_target(atlas_surface)

draw_clear_alpha(c_black, 0);
gpu_set_tex_filter(true)
gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha)
draw_surface_ext(_blend_surface,0,0,2,2,0,c_white,1)
gpu_set_blendmode(bm_normal)

surface_reset_target()

gpu_set_tex_filter(true)

var _surf_width = surface_get_width(atlas_surface);
var _surf_height = surface_get_height(atlas_surface);

atlas_backup = buffer_create(_surf_width * _surf_height * 4, buffer_fixed, 1);
atlas_size = [_surf_width,_surf_height]

buffer_get_surface(atlas_backup, atlas_surface, 0);
    
traits = [U_TRAIT.BASE]
life = 2500
maxlife = life

shake = false

image_xscale = 0.60
image_yscale = 0.60
drawy = y - 256 * image_yscale