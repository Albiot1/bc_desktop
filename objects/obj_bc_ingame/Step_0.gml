//var _siz = base_w/base_h
if mouse_wheel_down(){
    if zoom<2
    zoom+=0.1
    update_size()
}
if mouse_wheel_up(){
    if zoom>1
    zoom-=0.1
    update_size()
}

if mouse_check_button(mb_left) and !dragging{
    held++
    if held>=5{
        held = 0
        dragging = true
        dragx = device_mouse_x_to_gui(0)
        camspd = 0
    }
}


if dragging{
    var _pos = clamp( camx+(dragx - device_mouse_x_to_gui(0)),min_cam_x,max_cam_x)
    camera_set_view_pos(view_camera[0],_pos,730-cam_h+92*(zoom-1))
    
    if !mouse_check_button(mb_left){
        dragging = false
        camx = _pos
        var _diff = prevmxgui-device_mouse_x_to_gui(0)
        show_debug_message(_diff)
        if abs(_diff)>=40{
            camspd = _diff/40
            show_debug_message($"CSPD:{camspd}")
        }
    }
}

if !dragging{
    var _pos = clamp( camx+camspd,min_cam_x,max_cam_x )
    
    if _pos == min_cam_x or _pos == max_cam_x{
        camspd = 0
    }
    
    camx = _pos
    camera_set_view_pos(view_camera[0],_pos,730-cam_h+92*(zoom-1))
}

if keyboard_check_pressed(ord("F")){
    if window_get_fullscreen(){
        window_set_fullscreen(false)
    }
    else {
    	window_set_fullscreen(true)
    }
}
