draw_self()

draw_text(x,y-32,time)

if DEBUG_BOXES{
    
switch(atktype){
    case U_SPEC_ATTACKS.WAVE:
    case U_SPEC_ATTACKS.MINI_WAVE:
        var _range = 400/5
        if side == 1{
            _range = 500/5
        }
        var _x = x - (200/5) * side
        draw_rectangle_colour(_x-_range/2,y-4,_x+_range/2,y,c_red,c_red,c_red,c_red,1)
        
        if time==0{
            draw_rectangle_colour(_x-_range/2,y-4,_x+_range/2,y,c_red,c_red,c_red,c_red,0)
        }
    break;
    case U_SPEC_ATTACKS.SURGE:
    case U_SPEC_ATTACKS.MINI_SURGE:
        
        var _surgew = 250/5
        var _surgepierce = 125/5
        
        draw_rectangle_colour(x-_surgew*side,y-4,x+_surgepierce*side,y,c_red,c_red,c_red,c_red,1)
        
        if initial_hit == true and lvl > 0 and time == 20{
            draw_rectangle_colour(x-_surgew*side,y-4,x+_surgepierce*side,y,c_red,c_red,c_red,c_red,0)
        }
    break;
    case U_SPEC_ATTACKS.EXPLOSION:
        
        var _size = 150/5
        var _posdiff = 100/5
        
        if time>=15 and time <= 25{
            
            draw_rectangle_colour(x-_size/2,y-4,x+_size/2,y,c_red,c_red,c_red,c_red, time == 15 )

        }
        if time>=20 and time <= 35{
            var _x = x-_posdiff
            draw_rectangle_colour(_x-_size/2,y-4,_x+_size/2,y,c_red,c_red,c_red,c_red, time == 20 )
            _x = x+_posdiff
            draw_rectangle_colour(_x-_size/2,y-4,_x+_size/2,y,c_red,c_red,c_red,c_red, time == 20 )
        }
        if time>=30 and time <= 45{
            var _x = x-_posdiff*2
            draw_rectangle_colour(_x-_size/2,y-4,_x+_size/2,y,c_red,c_red,c_red,c_red, time == 30 )
            _x = x+_posdiff*2
            draw_rectangle_colour(_x-_size/2,y-4,_x+_size/2,y,c_red,c_red,c_red,c_red, time == 30 )
        }
        
    break;
}
    
}