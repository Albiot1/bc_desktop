///@desc Set the game resolutions, also resizes application surface and sets gui size
///@arg {Int} Width
///@arg {Int} Height
///@arg {Real} Window_scale
///@arg {Bool} High_res sets application surface based on windows size if true
///@arg {Real} Resolution_scale
///@arg {Bool} Gui_maximize
///@arg {Bool} Texture_filtering
function set_resolution(_base_width, _base_height, _window_scale=1, _high_res=false, _resolution_scale=1, _gui_maximize=true, _tex_filter=false) {
	window_set_size(_base_width*_window_scale, _base_height*_window_scale);
	call_later(1, time_source_units_frames, window_center);
	
	// surface
	if (_high_res) {
		surface_resize(application_surface, window_get_width()*_resolution_scale, window_get_height()*_resolution_scale);
	} else {
		surface_resize(application_surface, _base_width*_resolution_scale, _base_height*_resolution_scale);
	}
	gpu_set_tex_filter(_tex_filter);

	// gui
	if (_gui_maximize) {
		display_set_gui_maximize(1, 1, 0, 0);
	} else {
		display_set_gui_size(_base_width, _base_height);
	}
}

function set_resolution_new(){
    
    // In a Room Start event
    var base_w = 1280; // Your base width
    var base_h = 720; // Your base height
    var aspect = base_w / base_h; // Get the game aspect ratio
    
    // Determine the screen size
    var ww = display_get_width();
    var hh = display_get_height();
    
    ww = hh * aspect;
    
}