
if (abilities & U_ABILITIES.DEATH_SURGE > 0){
    if irandom(100) <= abilities_data.death_surge.chance{
        
        var _dmg = 0
        if dmgnumber > 1{
            _dmg = dmg[0]
        }
        else{
            _dmg = dmg
        }
        
        if effects_active & U_EFFECTS.STRENGTHEN > 0{
            _dmg *= effects_data.strengthen.multiplier
        }
        
        var _apply_effects = false
        
        if effectonattacks == 0{
            _apply_effects = true
        }
        else{
            if effectonattacks[0] == 1{
                _apply_effects = true
            }
        }
        
        if _apply_effects{
        
            if effects & U_EFFECTS.TOXIC > 0{
                if irandom(100) <= effects_data.toxic.chance{
                    is_toxic = true
                }
            }
            if effects & U_EFFECTS.CRITICAL > 0{
                if irandom(100) <= effects_data.critical.chance{
                    is_crit = true
                }
            }
            if effects & U_EFFECTS.SAVAGE_BLOW > 0{
                if irandom(100) <= effects_data.savage_blow.chance{
                    is_savage_blow = true
                }
            }
            if effects & U_EFFECTS.METAL_KILLER > 0{
                if irandom(100) <= effects_data.metal_killer.chance{
                    is_metal_kill = true
                }
            }
            
            if effects & U_EFFECTS.KNOCKBACK > 0{
                if irandom(100) <= effects_data.knockback.chance{
                    is_knockback = true
                }
            }
            if effects & U_EFFECTS.FREEZE > 0{
                if irandom(100) <= effects_data.freeze.chance{
                    is_freeze = true
                }
            }
            if effects & U_EFFECTS.SLOW > 0{
                if irandom(100) <= effects_data.slow.chance{
                    is_slow = true
                }
            }
            if effects & U_EFFECTS.WEAKEN > 0{
                if irandom(100) <= effects_data.weaken.chance{
                    is_weaken = true
                }
            }
            if effects & U_EFFECTS.WARP > 0{
                if irandom(100) <= effects_data.warp.chance{
                    is_warp = true
                }
            }
            if effects & U_EFFECTS.CURSE > 0{
                if irandom(100) <= effects_data.curse.chance{
                    is_curse = true
                }
            }
        
        }
               
        var _side = type == UNIT_TYPE.DOG ? 1 : -1
        
        var _x = x
        if is_array(abilities_data.death_surge.range){
            _x += irandom_range(abilities_data.death_surge.range[0],abilities_data.death_surge.range[1]) * _side
        }
        else{
            _x += abilities_data.death_surge.range * _side
        }
        
        create_special_attack(_x,y,abilities_data.death_surge.type,id,_dmg,abilities_data.death_surge.lvl,0,abilities_data.death_surge.range)
        
        with instance_create_depth(x,y,depth,obj_effect_anim){
            data = global.death_surge_animation[ _side == 1 ? 0 : 1 ]
        }

        
        if global.audio
            audio_play_sound(snd_death_surge,0,0)
    exit;
    }
}