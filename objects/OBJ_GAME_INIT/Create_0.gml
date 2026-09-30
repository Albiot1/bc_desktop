//load all default textures to have no hiccup on first showing them...
var _tex_array = texturegroup_get_textures( "default");
for (var i = 0; i < array_length(_tex_array); ++i)
{
   texture_prefetch(_tex_array[i]);
}
//

global.audio = 1


#macro SURFACE_HROMAKEY_OPTIMIZE true
depth = 50

randomize()

global.mouse_px = 0
global.mouse_py = 0

draw_set_font(fnt_main_big)

room_goto(rm_game)

base_size = [1280,720]