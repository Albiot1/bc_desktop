function draw_button_new(_x,_y,_text,_color = c_black,_key = undefined){
    var _mx = device_mouse_x_to_gui(0)
    var _my = device_mouse_y_to_gui(0)
    
    var _pressed = false
    
    var _text_w = string_width(_text) + 16
    var _text_h = string_height(_text) + 16
    
    draw_set_alpha(0.5)
    draw_roundrect_colour(_x,_y,_x+_text_w,_y+_text_h,_color,_color,false)
    draw_set_alpha(1)
    
    draw_text(_x+8,_y+8,_text)
    
    if global.ui_layer == 0 and point_in_rectangle(_mx,_my,_x,_y,_x+_text_w,_y+_text_h){
        draw_roundrect_colour(_x,_y,_x+_text_w,_y+_text_h,c_white,c_white,true)
        if mouse_check_button_pressed(mb_left){
            _pressed = true
        }
    }
    
    if global.ui_layer == 0 and _key!=undefined and keyboard_check_pressed(_key){
        _pressed = true
    }
    
    return _pressed
}

enum BUTTON_ALIGNMENT {
    LEFT,MIDDLE,RIGHT
}
