///@desc Draws the text with specificed outline
///@arg {Real} x
///@arg {Real} y
///@arg {Constant.Color} outline_color
///@arg {Constant.Color} string_color
///@arg {String} string
function draw_text_outline(_x,_y,_outline_color,_string_color,_string,_distance = 1){
	var _old_color = draw_get_color()

		draw_set_color(_outline_color)
		
		draw_text(_x+1,_y+1*_distance,_string)
		draw_text(_x-1*_distance,_y-1*_distance,_string)
		
		draw_text(_x,_y+1*_distance,_string)
		draw_text(_x+1*_distance,_y,_string)
		
		draw_text(_x,_y-1*_distance,_string) 
		draw_text(_x-1*_distance,_y,_string)
		
		draw_text(_x-1*_distance,_y+1*_distance,_string)
		draw_text(_x+1*_distance,_y-1*_distance,_string)
		
		draw_text(_x,_y+2*_distance,_string)
		draw_text(_x+2*_distance,_y,_string)
		
		draw_text(_x+2*_distance,_y+2*_distance,_string)
		draw_text(_x+1*_distance,_y+2*_distance,_string)
		
		draw_text(_x+2*_distance,_y+1*_distance,_string)
		
		draw_set_color(_string_color)

		draw_text(_x,_y,_string)

	    draw_set_color(_old_color)
}