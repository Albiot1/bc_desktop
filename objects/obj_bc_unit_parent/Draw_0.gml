//if DEBUG_BOXES
//    draw_self()

if !surface_exists(atlas){
    stats_ref.atlas_surface = surface_create(atlas_size[0],atlas_size[1])
    atlas = stats_ref.atlas_surface
    buffer_set_surface(atlas_backup,atlas,0)
}

var _drawme = true
if state == UNIT_STATE.ZOMBIE_DEAD or state == UNIT_STATE.ZOMBIE_DEAD_KNOCKBACK or state == UNIT_STATE.ZOMBIE_BURROW_MOVE
	_drawme = false

if _drawme and surface_exists(atlas){
    
bc_draw_baked_frame_atlas_new_fixed(current_anim,frame,atlas,x,y,0.5*scale,image_alpha)
    
}

var _s = type == UNIT_TYPE.CAT ? -1 : 1

if DEBUG_BOXES{
    draw_set_color(c_blue)
    draw_rectangle(x-(320/5)*_s,y-height,x,y,1)
    draw_set_color(c_red)
    
    if atktype == ATK_TYPE.LONG or atktype == ATK_TYPE.OMNI{
        if distances_number==1{
            var _pnt0 = distances[0]*_s
            var _pnt1 = distances[1]*_s
            
            draw_rectangle(x+_pnt0,y-height,x+_pnt1,y,1)
        }
        else if distances_number>1{
            
            
            draw_rectangle(x,y-5,x+range*_s,y,1)
            
            var _col = [c_orange,c_yellow,c_white]
            
            for(var i = 0; i < distances_number; i ++){
                var _pnt0 = distances[i][0]*_s
                var _pnt1 = distances[i][1]*_s
                
                draw_set_colour(_col[i])
                draw_rectangle(x+_pnt0,y-height,x+_pnt1,y,1)
            }
            
        }
    }
    else{
        draw_rectangle(x,y-5,x+range*_s,y,1)
    }
    
    draw_text(x,y-height-32,$"ATK : {attacked} | MAX : {dmgnumber} | F : {frame} | L : {life}")
    
    if abilities & U_ABILITIES.AKU_SHIELD > 0{
        draw_text(x,y-height-64,$"sh : {shield_hp}, {shield_state}, {effects_active & SHOW_SHIELD_HIT}, {shield_frame}")
    }
    
    draw_set_color(c_white)

}

if state == UNIT_STATE.WARP{
    /*
	if warp.state == 0{
		draw_sprite_ext(spr_warp_in,warp.animframe,x,lastposy-650,_s,1,0,c_white,1)
	}
	else if warp.state == 2{
		draw_sprite_ext(spr_warp_out,warp.animframe,x,lastposy-650,_s,1,0,c_white,1)
	}
    */
}

if state == UNIT_STATE.WARP or state == UNIT_STATE.ZOMBIE_DEAD
	exit;

#region buffs/debuffs
_s*=-1

var _effx = x
var _effy = y-height

if state == UNIT_STATE.ZOMBIE_BURROW_MOVE{
    _effy = y
}

if effects_active & U_EFFECTS.WEAKEN > 0 or effects_active & U_EFFECTS.STRENGTHEN > 0{
    
    if effects & U_EFFECTS.STRENGTHEN > 0 and effects_active & U_EFFECTS.STRENGTHEN > 0{
        draw_sprite_ext(spr_effect_strengthen,strengthen_frame,_effx,_effy,0.5*_s,0.5,0,c_white,1)
    }
    else {
    	draw_sprite_ext(spr_effect_weaken,weaken_frame,_effx,_effy,0.5*_s,0.5,0,c_white,1)
    }
    
    _effx += 31 * _s
}
if effects_active & U_ABILITIES.SURVIVE > 0{

    draw_sprite_ext(spr_ability_survive,survived_frame,_effx,_effy,0.5*_s,0.5,0,c_white,1)
    
    _effx += 48 * _s
    
}
if effects_active & U_EFFECTS.DODGE > 0{
    
    draw_sprite_ext(spr_effect_dodge,dodging_frame,_effx,_effy,0.5*_s,0.5,0,c_white,1)
    
    _effx += 30 * _s
    
}
if effects_active & U_EFFECTS.CURSE > 0{
    
    draw_sprite_ext(spr_effect_curse,curse_frame,_effx,_effy,0.5*_s,0.5,0,c_white,1)
    
    _effx += 19 * _s
    
}
if effects_active & U_EFFECTS.SLOW > 0{
    
    draw_sprite_ext(spr_effect_slow,slowed_frame,_effx,_effy,0.5*_s,0.5,0,c_white,1)
    
    _effx += 41 * _s
    
}

if effects_active & U_EFFECTS.FREEZE > 0{
    
    draw_sprite_ext(spr_effect_freeze,45 * (freezed_frame/freezedmax),_effx,_effy,0.5*_s,0.5,0,c_white,1)
    
    _effx += 23 * _s
    
}

if effects_active & SHOW_EFFECT_IMMUNITY > 0{
	draw_sprite_ext(spr_effect_immune,immunity_frame,x,y-23,0.5*_s,0.5,0,c_white,1)	
}

if effects_active & SHOW_EFFECT_IMMUNITY_TO_SPECATK > 0{
	draw_sprite_ext(spr_ability_waveimmune,immunity_specatk_frame,x,y,0.5*_s,0.5,0,c_white,1)
}

if effects_active & U_ABILITIES.WAVE_SHIELD > 0{
	draw_sprite_ext(spr_waveblock,wave_shield_frame,x,y,0.5*_s,0.5,0,c_white,1)
}

if effects_active & SHOW_BARRIER_HIT > 0{
	var _spr = -1
	
	switch(barrier_state){
		case BARRIER_STATE.HIT: _spr = spr_barrier_hit break;
		case BARRIER_STATE.DESTROY: _spr = spr_barrier_break break;
		case BARRIER_STATE.SHATTER: _spr = spr_barrier_shattered break;
	}
	
	draw_sprite_ext(_spr,barrier_frame,x,y,0.5*-_s,0.5,0,c_white,1)
}

if effects_active & SHOW_SHIELD_HIT > 0{
	var _spr = -1
	
	switch(shield_state){
		case AKU_SHIELD_STATE.HIT: 
				_spr = spr_aku_shield_hit
				if shield_hp <= shield_current_max_hp * 0.5{
					_spr = spr_aku_shield_hit_half_health
				}
		break;
		case AKU_SHIELD_STATE.DESTROY: _spr = spr_aku_shield_destroy break;
		case AKU_SHIELD_STATE.PIERCE: _spr = spr_aku_shield_pierce break;
		case AKU_SHIELD_STATE.REGEN: _spr = spr_aku_shield_recovery break;
	}
	
	draw_sprite_ext(_spr,shield_frame,x,y,0.5*-_s,0.5,0,c_white,1)
}

#endregion
