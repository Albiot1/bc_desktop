if state != UNIT_STATE.WARP{

	if effects_active & U_EFFECTS.FREEZE > 0{
	    freezed-=0.5
	    
	    freezed_frame+=0.5
	    
	    if freezed==0{
	        freezed_frame = 0
	        effects_active &= ~U_EFFECTS.FREEZE
	    }
	}
	else {
		tm++
	}
	
	if tm==2{
	    tm=0
	    frame++
	    if frame>=current_anim.frame_count{
	        frame=0
	    }
	}
	
	if effects_active & SHOW_BARRIER_HIT > 0{
		var _maxframe = 0
		switch(barrier_state){
			case BARRIER_STATE.HIT: _maxframe = 10 break;
			case BARRIER_STATE.DESTROY: _maxframe = 37 break;
			case BARRIER_STATE.SHATTER: _maxframe = 31 break;
		}
		
		barrier_frame+=0.5
		
		if barrier_frame==_maxframe{
			barrier_frame = 0
			effects_active &= ~SHOW_BARRIER_HIT
		}
	}
	
	if effects_active & SHOW_SHIELD_HIT > 0{
		var _maxframe = 0
		switch(shield_state){
			case AKU_SHIELD_STATE.HIT: _maxframe = 11 break;
			case AKU_SHIELD_STATE.DESTROY: _maxframe = 37 break;
			case AKU_SHIELD_STATE.PIERCE: _maxframe = 40 break;
			case AKU_SHIELD_STATE.REGEN: _maxframe = 10 break;
		}
		
		shield_frame+=0.5
		
		if shield_frame==_maxframe{
			shield_frame = 0
			effects_active &= ~SHOW_SHIELD_HIT
		}
	}
	
	if effects_active & SHOW_EFFECT_IMMUNITY > 0{
		immunity_frame+=0.5
		
		if immunity_frame==5{
			immunity_frame = 0
			effects_active &= ~SHOW_EFFECT_IMMUNITY
		}
	}
	
	if effects_active & U_ABILITIES.WAVE_SHIELD > 0{
		wave_shield_frame+=0.5
		
		if wave_shield_frame==19{
			wave_shield_frame = 0
			effects_active &= ~U_ABILITIES.WAVE_SHIELD
		}
	}
	
	if effects_active & SHOW_EFFECT_IMMUNITY_TO_SPECATK > 0{
		immunity_specatk_frame+=0.5
		
		if immunity_specatk_frame==18{
			immunity_specatk_frame = 0
			effects_active &= ~SHOW_EFFECT_IMMUNITY_TO_SPECATK
		}
	}
	
	if effects_active & U_EFFECTS.SLOW > 0{
	    slow.time-=0.5
	    slowed_frame+=0.5
	    
	    if slowed_frame==8{
	        slowed_frame = 4
	    }
	    
	    if slow.time==0{
	        effects_active &= ~U_EFFECTS.SLOW
	        slowed_frame = 0
	    }
	}
	
	if effects_active & U_EFFECTS.WEAKEN > 0{
	    weaken.time-=0.5
	    weaken_frame+=0.5
	    
	    if weaken_frame==15{
	        weaken_frame = 0
	    }
	    
	    if weaken.time==0{
	        weaken_frame = 0
	        effects_active &= ~U_EFFECTS.WEAKEN
	    }
	}
	
	if effects_active & U_EFFECTS.STRENGTHEN > 0{
	    strengthen_frame+=0.5
	    if strengthen_frame==18{
	        strengthen_frame = 0
	    }
	}
	
	if effects_active & U_ABILITIES.SURVIVE > 0{
	    survived_frame+=0.5
	    if survived_frame==35{
	        survived_frame = 0
	        effects_active &= ~U_ABILITIES.SURVIVE
	    }
	}
	
	if effects_active & U_EFFECTS.DODGE > 0{
	    if dodging>0
	        dodging--
	    if dodging_behemoth>0
	        dodging_behemoth--
	    
	    dodging_frame+=0.5
	    if dodging_frame==117{
	        dodging_frame = 78
	    }
	    
	    if dodging == 0 and dodging_behemoth == 0{
	        effects_active &= ~U_EFFECTS.DODGE
	        dodging_frame = 0
	    }
	}
	
	if effects_active & U_EFFECTS.CURSE > 0{
	    if curse>0
	        curse--
	    
	    curse_frame+=0.5
	    if curse_frame==30{
	        curse_frame = 8
	    }
	    
	    if curse == 0{
	        effects_active &= ~U_EFFECTS.CURSE
	        curse_frame = 0
	    }
	}
	
}

scr_unit_step()