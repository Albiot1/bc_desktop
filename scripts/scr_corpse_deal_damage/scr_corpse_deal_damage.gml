function scr_corpse_deal_damage(_id,_dmg){
    
    var _side = -1
    if type == UNIT_TYPE.DOG{
        _side = 1
    }
    
    var _atkx = _id.x+(16+irandom_range(-4,4))*_side
    var _atky = _id.y-16+irandom_range(-8,8)
    
    var _apply_trait = false
    var _antisageresist = false //+resistances to debuffs made by sages
    
    //enemy when attacking an unit !
    if _side == 1{
        
        if traits_number>0 and _id.targets_number>0{
            
            for (var i = 0; i < traits_number; i++) {
            	if array_contains(_id.targets,traits[i]){
                    _apply_trait = true
                    break
                }
            }
            
        }
        
        if spectraits_number>0 and _id.killer!=0{
            
            if array_contains(spectraits,U_SPEC_TRAIT.SAGE){
                _sageresist = true
            }
            
            if _id.killer & U_KILLER.WITCH_KILLER > 0{
                if array_contains(spectraits,U_SPEC_TRAIT.WITCH)
                    _dmg *= 0.1
            }
            
            if _id.killer & U_KILLER.VILLAIN_SLAYER > 0{
                if array_contains(spectraits,U_SPEC_TRAIT.SUPERVILLAIN)
                    _dmg *= 0.4
            }
            
            if _id.killer & U_KILLER.SAGE_SLAYER > 0{
                if array_contains(spectraits,U_SPEC_TRAIT.SAGE){
                    _dmg *= 0.5
                    _sageresist = false
                }
            }
            
            if _id.killer & U_KILLER.COLOSSUS_KILLER > 0{
                if array_contains(spectraits,U_SPEC_TRAIT.COLOSSUS)
                    _dmg *= 0.7
            }
            
            if _id.killer & U_KILLER.EVA_KILLER > 0{
                if array_contains(spectraits,U_SPEC_TRAIT.EVA_ANGEL)
                    _dmg *= 0.2
            }
            
            if _id.killer & U_KILLER.BEHEMOTH_SLAYER > 0{
                if _id.dodging_behemoth > 0{
                    exit;
                }
                    
                
                if array_contains(spectraits,U_SPEC_TRAIT.BEHEMOTH){
                    _dmg *= 0.6
                }
            }
            
        }
        
        if _apply_trait{
            
            if _id.curse == 0{
            
                if _id.abilities & U_ABILITIES.RESISTANT > 0{
                    _dmg *= 0.2
                }
                
                if _id.abilities & U_ABILITIES.INSANELY_TOUGH > 0{
                    _dmg /= 7
                }
                
                if _id.abilities & U_ABILITIES.STRONG_AGAINST > 0{
                    _dmg *= 0.4
                }
            
            }
            
        }
        
        
    } //unit when attacking an enemy !
    else {
        
        if abilities & U_ABILITIES.TARGET_ONLY > 0{
            _apply_trait = true
        }
        else {
            if targets_number>0 and _id.traits_number>0{
                
                for (var i = 0; i < targets_number; i++) {
                	if array_contains(_id.traits,targets[i]){
                        _apply_trait = true
                        break
                    }
                }
                
            }
        }
        
        if _id.spectraits_number>0 and killer!=0{
            
            if killer & U_KILLER.WITCH_KILLER > 0{
                if array_contains(_id.spectraits,U_SPEC_TRAIT.WITCH)
                    _dmg *= 5
            }
            
            if killer & U_KILLER.VILLAIN_SLAYER > 0{
                if array_contains(_id.spectraits,U_SPEC_TRAIT.SUPERVILLAIN)
                    _dmg *= 2.5
            }
            
            if killer & U_KILLER.SAGE_SLAYER > 0{
                if array_contains(_id.spectraits,U_SPEC_TRAIT.SAGE){
                    _dmg *= 1.2
                    _antisageresist = true
                }
            }

            if killer & U_KILLER.COLOSSUS_KILLER > 0{
                if array_contains(_id.spectraits,U_SPEC_TRAIT.COLOSSUS)
                    _dmg *= 1.6
            }
            
            if killer & U_KILLER.EVA_KILLER > 0{
                if array_contains(_id.spectraits,U_SPEC_TRAIT.EVA_ANGEL)
                    _dmg *= 5
            }
            
            if killer & U_KILLER.BEHEMOTH_SLAYER > 0{
                if array_contains(_id.spectraits,U_SPEC_TRAIT.BEHEMOTH)
                    _dmg *= 2.5
            }
            
        }
        
        if _apply_trait{
        
            if curse == 0{
                
                
                if abilities & U_ABILITIES.MASSIVE_DAMAGE > 0{
                    _dmg *= 4
                }
                
                if abilities & U_ABILITIES.INSANE_DAMAGE > 0{
                    _dmg *= 6
                }
                
                if abilities & U_ABILITIES.STRONG_AGAINST > 0{
                    _dmg *= 1.8
                }
            
            }
            
        }
        
    }
    //
    

    if is_crit{
        _dmg *= 2
        
        var _atk1 = instance_create_depth(_atkx,_atky,_id.depth-2,obj_attack)
        _atk1.sprite_index = spr_attack_critical
        _atk1.image_xscale = _side*0.5
        
        if global.audio
            audio_play_sound(snd_critical_hit,0,0)
    }
    if is_savage_blow{
        _dmg *= effects_data.savage_blow.multiplier
        
        var _atk1 = instance_create_depth(_atkx,_atky,_id.depth-2,obj_attack)
        _atk1.sprite_index = spr_attack_savage_blow
        _atk1.image_xscale = _side*0.5
        
        if global.audio
            audio_play_sound(snd_savage_blow,0,0)
    }
    if is_toxic and curse == 0{
        
        var _perc = effects_data.toxic.percent
        
        var _resist = 0
        if _id.resists & U_RESISTS.TOXIC > 0{
            _resist = resist_percent.toxic
        }
        _perc *= 1 - _resist
        
        if _resist < 1
        _dmg += _id.baselife * _perc
        
        var _atk1 = instance_create_depth(_atkx,_atky,_id.depth-2,obj_attack)
        _atk1.sprite_index = spr_attack_toxic
        _atk1.image_xscale = _side*0.5
        
        if global.audio
            audio_play_sound(snd_toxic,0,0)
    }
    
    if _id.abilities & U_ABILITIES.METAL > 0{
        if !is_crit and !is_toxic{
            _dmg = 1
        }
        if is_metal_kill{
            _dmg += _id.life * effects_data.metal_killer.percent
            
            if is_metal_kill{
                var _atk1 = instance_create_depth(_atkx,_atky,_id.depth-2,obj_attack)
                _atk1.sprite_index = spr_attack_metal_killer
                _atk1.image_xscale = _side*0.5
            }
            
        }
    }
    
    _id.life-=_dmg
    
    with _id {
        if life<=knockbackhp{
            knockbacks--
            knockbackhp = clamp( life - (baselife/maxknockbacks),0,baselife )
        }
        
        if life<=0{
            state = UNIT_STATE.ZOMBIE_DEAD_KNOCKBACK
            frame = 0
            knockback.type = KNOCKACK_TYPE.HEALTH
            knockback.distance = 345 / 5
            knockback.time = 0
            knockback.maxtime = 24
            lastpos = x
        }
    }
    
    //if its an enemy also apply trait to everyone !
    if _side == 1{
        _apply_trait = true
    }
    
    if _id.state != UNIT_STATE.KNOCKBACK and _id.life > 0{
        
        if is_knockback and curse == 0 and _apply_trait{
            var _dist = effects_data.knockback.distance
            var _time = effects_data.knockback.time
            
            var _resist = 0
            
            if _sageresist or _antisageresist
                _resist += 0.7
            
            if _id.resists & U_RESISTS.KNOCKBACK > 0{
                _resist += _id.resist_percent.knockback/100
            }
            
            if _resist < 1{
                _dist *= 1 - _resist
                
                with _id{
                    state = UNIT_STATE.ZOMBIE_DEAD_KNOCKBACK
                    frame = 0
                    
                    knockback.type = KNOCKACK_TYPE.NORMAL
                    knockback.distance = _dist
                    knockback.time = 0
                    knockback.maxtime = _time
                    lastpos = x
                    
                    image_xscale = 0
                    image_yscale = 0
                }
            }
            
        }
        
        if is_warp and curse == 0 and _apply_trait{
            var _dist = effects_data.warp.distance
            var _time = effects_data.warp.time
            
            var _resist = 0
            
            if _sageresist or _antisageresist
                _resist += 0.7
            
            if _id.resists & U_RESISTS.WARP > 0{
                _resist += _id.resist_percent.warp/100
            }
            
            //_dist *= 1 - _resist
            
            if _resist < 1{
                _time *= 1- _resist
                with _id{
                    state = UNIT_STATE.WARP
                    current_anim = anim_idle
                    frame = 0
                    
                    warp.time = _time
                    warp.distance = _dist
                }
            }
            
        }
        
    }
    
    if _id.life <= 0{

        var _zkill = (killer & U_KILLER.ZOMBIE_KILLER > 0)
        
        var _iszombie = false
        
        if _id.type == UNIT_TYPE.DOG{
            if array_contains(_id.traits,U_TRAIT.ZOMBIE) or _id.abilities & U_ABILITIES.ZOMBIE_REVIVE > 0
                _iszombie = true
        }
        else {
        	if _id.abilities & U_ABILITIES.ZOMBIE_REVIVE > 0
                _iszombie = true
        }
        
        
        if _iszombie and _zkill{
            _id.zkilled = true
        }
        
        if _id.abilities & U_ABILITIES.SURVIVE > 0{
            if irandom(100) <= _id.abilities_data.survive.chance{
                _id.life = 1
                _id.abilities &= ~U_ABILITIES.SURVIVE
                _id.effects_active |= U_ABILITIES.SURVIVE
                
                if _iszombie
                    _id.zkilled = flase
                
                if global.audio
                    audio_play_sound(snd_survive,0,0)
            }
        }
        
        if _iszombie and _zkill and _id.zkilled{
            var _atk = instance_create_depth(_atkx,_atky,depth,obj_attack)
            _atk.sprite_index = spr_zombie_kill
            _atk.image_xscale = _side*0.5
            if global.audio
                audio_play_sound(snd_zombie_kill,0,0)
        }
        
        if abilities & U_ABILITIES.EXTRA_MONEY > 0 and _id.life <= 0{
            _id.cash *= 2
        }
        
    }
    
    hitanenemy = true
    
    if global.audio
        audio_play_sound(choose(snd_sucessful_attack,snd_sucessful_attack_a),0,0 )
    
    var _atk = instance_create_depth(_atkx,_atky,_id.depth-1,obj_attack)
    
    if _side == 1{
        _atk.sprite_index = spr_attack_smoke_dark
    }
    
}