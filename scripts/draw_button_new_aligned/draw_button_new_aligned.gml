
function draw_button_new_aligned(_x,_y,_text,_color = c_black,_key = undefined,_alignment = BUTTON_ALIGNMENT.LEFT){
    var _mx = device_mouse_x_to_gui(0)
    var _my = device_mouse_y_to_gui(0)
    
    var _pressed = false
    
    var _text_w = string_width(_text) + 16
    var _text_h = string_height(_text) + 16
    
    var _x1,_x2;
    var _y1 = _y
    var _y2 = _y+_text_h
    var _txt_xplus = 0;
    var _halign = fa_left;
    
    switch(_alignment){
        case BUTTON_ALIGNMENT.LEFT:
            _txt_xplus = 8
            _x1 = _x
            _x2 = _x+_text_w
        break;
        case BUTTON_ALIGNMENT.MIDDLE:
            _x1 = _x-_text_w/2
            _x2 = _x+_text_w/2
        break;
        case BUTTON_ALIGNMENT.RIGHT:
            _txt_xplus = -8
            _x1 = _x-_text_w
            _x2 = _x
        break;
    }
    
    draw_set_alpha(0.5)
    draw_roundrect_colour(_x1,_y1,_x2,_y2,_color,_color,false)
    draw_set_alpha(1)
    
    draw_set_halign(_halign)
    draw_text(_x+_txt_xplus,_y-8,_text)
    draw_set_halign(fa_left)
    
    if global.ui_layer == 0 and point_in_rectangle(_mx,_my,_x1,_y1,_x2,_y2){
        draw_roundrect_colour(_x1,_y1,_x2,_y2,c_white,c_white,false)
        if mouse_check_button_pressed(mb_left){
            _pressed = true
        }
    }
    
    if global.ui_layer == 0 and _key!=undefined and keyboard_check_pressed(_key){
        _pressed = true
    }
    
    return _pressed
}