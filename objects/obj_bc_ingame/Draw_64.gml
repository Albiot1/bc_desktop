draw_text(0,0,$"PR:{prevmxgui}|NW:{device_mouse_x_to_gui(0)}\nDIF:{prevmxgui-device_mouse_x_to_gui(0)}\nMAX:{max_cam_x}|MIN:{min_cam_x}\n{global.enemy_base_life_percent}")

var _xpos = 0
var _ypos = 0
for (var i = 0; i < 10; i++) {
	draw_sprite(spr_unit_cat,0,16+116*_xpos+337,720-180 + 90 * _ypos)
    _xpos++
    if _xpos==5{
        _xpos = 0
        _ypos ++
    }
}





