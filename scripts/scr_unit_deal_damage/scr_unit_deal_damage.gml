function scr_unit_deal_damage(_id,_dmg,_dmgtype = DAMAGE_TYPE.NORMAL){
    var _side = -1
    if type == UNIT_TYPE.DOG{
        _side = 1
    }
    
    switch(_dmgtype){
        case DAMAGE_TYPE.WAVE:
            if _id.resists & U_RESISTS.WAVE > 0{
                var _resist = _id.resist_percent.wave
                
                if _resist < 1{
                    _dmg *= 1 - _resist
                }
                else{
                    _id.effects_active |= SHOW_EFFECT_IMMUNITY_TO_SPECATK
                    _id.immunity_specatk_frame = 0
                }
            }
        break;
        case DAMAGE_TYPE.SURGE:
            var _resist = 0
            if _id.resists & U_RESISTS.SURGE > 0{
                _resist = _id.resist_percent.surge
                
                if _resist < 1{
                    _dmg *= 1 - _resist
                }
                else{
                    _id.effects_active |= SHOW_EFFECT_IMMUNITY_TO_SPECATK
                    _id.immunity_specatk_frame = 0
                }
            }
            
            if _resist<1{
                if _id.abilities & U_ABILITIES.COUNTER_SURGE > 0 and !( ds_list_find_index(_id.surge_list,id)>=0 ){
                    if irandom(100) <= _id.abilities_data.counter_surge.chance{
                        ds_list_add(_id.surge_list,id)
                        
                        var _x = _id.x 
                        if is_array(range){
                            _x -= irandom_range(range[0],range[1]) * _side
                        }
                        else{
                            _x -= range * _side
                        }
                        
                        var _ndmg = 1
                        if _id.dmgnumber>1{
                            _ndmg = _id.dmg[0]
                        }
                        else{
                            _ndmg = _id.dmg
                        }
                        
                        var _apply_effects = false
                        
                        var _oltoxic = _id.is_toxic
                        var _olcrit = _id.is_crit
                        var _olsavageblow = _id.is_savage_blow
                        var _olmetalkill = _id.is_metal_kill
                        var _olknockback = _id.is_knockback
                        var _olfreeze = _id.is_freeze
                        var _olslow = _id.is_slow
                        var _olweaken = _id.is_weaken
                        var _olwarp = _id.is_warp
                        var _olcurse = _id.is_curse
                        //check effects etc.
                        with _id{
                                            
                            if effects_active & U_EFFECTS.WEAKEN > 0{
                                _ndmg = _ndmg * 1-weaken.percent
                            }
                            
                            if effects_active & U_EFFECTS.STRENGTHEN > 0{
                                _ndmg *= effects_data.strengthen.multiplier
                            }
                            
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
                            
                        }
                        
                        create_special_attack(_x,y,atktype,_id,_ndmg,lvl,-51.5,_id.range)
                        
                        //reset the effects
                        with _id{
                            
                            if _apply_effects{
                                is_toxic = _oltoxic
                                is_crit = _olcrit
                                is_savage_blow = _olsavageblow
                                is_metal_kill = _olmetalkill
                                is_knockback = _olknockback
                                is_freeze = _olfreeze
                                is_slow = _olslow
                                is_weaken = _olweaken
                                is_warp = _olwarp
                                is_curse = _olcurse
                            }
                            
                        }
                        
                        with instance_create_depth(x,y,depth,obj_effect_anim){
                            data = global.counter_surge_animation[ _side == 1 ? 1 : 0 ]
                        }
                        
                        if global.audio
                            audio_play_sound(snd_counter_surge,0,0)
                    }
                }
            }
        break;
        case DAMAGE_TYPE.EXPLOSION:
            if _id.resists & U_RESISTS.EXPLOSION > 0{
                var _resist = _id.resist_percent.explosion
                
                if _resist < 1{
                    _dmg *= 1 - _resist
                }
                else{
                    _id.effects_active |= SHOW_EFFECT_IMMUNITY_TO_SPECATK
                    _id.immunity_specatk_frame = 0
                }
            }
        break;
    }
    
    var _atkx = _id.x+(16+irandom_range(-4,4))*_side
    var _atky = _id.y-16+irandom_range(-8,8)
    
    var _apply_trait = false
    var _sageresist = false //+resistances to knockback etc. as sage
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
                    if irandom(100) <= _id.killer_data.behemoth_slayer.chance{
                        _id.dodging_behemoth = killer_data.behemoth_slayer.time
                        _id.effects_active |= U_EFFECTS.DODGE
                        exit;
                    }
                    
                }
            }
            
        }
        
        if _apply_trait{
            
            if _id.curse == 0{
            
                if _id.effects & U_EFFECTS.DODGE > 0{
                    
                    if _id.dodging > 0{
                        exit;
                    }
                    
                    if irandom(100) <= _id.effects_data.dodge.chance{
                        _id.dodging = _id.effects_data.dodge.time
                        _id.effects_active |= U_EFFECTS.DODGE
                        exit;
                    }
                }
            
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
        
        if _id.effects & U_EFFECTS.DODGE{
            if _id.dodging > 0{
                exit;
            }
            
            if irandom(100) <= _id.effects_data.dodge.chance{
                _id.dodging = _id.effects_data.dodge.time
                _id.effects_active |= U_EFFECTS.DODGE
                exit;
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
    
    if _id.abilities & U_ABILITIES.ALN_BARRIER > 0 and _id.barrier_hp > 0{
        var _shattered = false
       
       _id.barrier_frame = 0 
       _id.effects_active |= SHOW_BARRIER_HIT
       _id.barrier_state = BARRIER_STATE.HIT
        
        var _broken = false

        if _dmg >= _id.barrier_hp{
            _id.barrier_state = BARRIER_STATE.DESTROY
            _id.barrier_hp = 0
            _broken = true
        }

        if effects & U_EFFECTS.BARRIER_BREAKER > 0{
            if irandom(100) <= effects_data.barrier_breaker.chance{
                _id.barrier_state = BARRIER_STATE.SHATTER
                _shattered = true
                _broken = true
            }
        }
        
        if global.audio{
            switch(_id.barrier_state){
                case BARRIER_STATE.HIT: audio_play_sound(snd_barrier_attack,0,0) break;
                case BARRIER_STATE.DESTROY: audio_play_sound(snd_barrier_destroy,0,0) break;
                case BARRIER_STATE.SHATTER: audio_play_sound(snd_barrier_breake,0,0) break;
            }
        }
        
        if _broken{
            _id.abilities &= ~U_ABILITIES.ALN_BARRIER
        }
        
        hitanenemy = true
        
        //if not hit by barrier breaker we exclude debuffs and damage to health etc.
        if _shattered == false
            exit;
    }
    if _id.abilities & U_ABILITIES.AKU_SHIELD > 0 and _id.shield_hp > 0{
        var _pierced = false
        
        _id.shield_frame = 0
        _id.effects_active |= SHOW_SHIELD_HIT
        _id.shield_state = AKU_SHIELD_STATE.HIT
        
        if _dmg >= _id.shield_hp{
            _id.shield_state = AKU_SHIELD_STATE.DESTROY
            _id.shield_hp = 0
        }
        
        if effects & U_EFFECTS.SHIELD_BREAKER > 0{
            if irandom(100) <= effects_data.shield_breaker.chance{
                _id.shield_state = AKU_SHIELD_STATE.PIERCE
                _id.shield_hp = 0
                _pierced = true
            }
        }
        
        if _id.shield_hp > 0{
            _id.shield_hp -= _dmg
        }
        
        if global.audio{
            switch(_id.shield_state){
                case AKU_SHIELD_STATE.HIT: audio_play_sound(snd_shield_attacked,0,0) break;
                case AKU_SHIELD_STATE.DESTROY: audio_play_sound(snd_shield_destroy,0,0) break;
                case AKU_SHIELD_STATE.PIERCE: audio_play_sound(snd_shield_pierce,0,0) break;
            }
        }
        
        hitanenemy = true
        
        if _pierced == false
            exit;
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
            state = UNIT_STATE.KNOCKBACK
            current_anim = anim_kb
            frame = 0
            
            knockback.type = KNOCKACK_TYPE.HEALTH
            knockback.distance = 345 / 5
            knockback.time = 0
            knockback.maxtime = 24
            lastpos = x
            
            image_xscale = 0
            image_yscale = 0
        }
    }
    
    if _id.effects & U_EFFECTS.STRENGTHEN > 0 and !(_id.effects_active & U_EFFECTS.STRENGTHEN > 0){
        with _id{
            if life < baselife*effects_data.strengthen.threshold{
                effects_active |= U_EFFECTS.STRENGTHEN
            }
        }
    }
    
    //if its an enemy also apply trait to everyone !
    if _side == 1{
        _apply_trait = true
    }
    
    if is_freeze and curse == 0 and _apply_trait{
        var _time = effects_data.freeze.time
        
        var _resist = 0
        
        if _sageresist or _antisageresist
            _resist += 0.7
        
        if _id.resists & U_RESISTS.FREEZE > 0{
            _resist += _id.resist_percent.freeze/100
        }
        
        if _resist < 1{
            _time *= 1 - _resist
            
            _id.freezed = _time
            _id.freezedmax = _time
            _id.freezed_frame = 0
            _id.effects_active |= U_EFFECTS.FREEZE
        }
        else{
            _id.effects_active |= SHOW_EFFECT_IMMUNITY
        }
            
    }
    
    if is_slow and curse == 0 and _apply_trait{
        var _time = effects_data.slow.time
        var _percent = effects_data.slow.percent
        
        var _resist = 0
        
        if _sageresist or _antisageresist
            _resist += 0.7
        
        if _id.resists & U_RESISTS.SLOW > 0{
            _resist += _id.resist_percent.slow/100
        }
        
        if _resist < 1{
            _time *= 1 - _resist
            
            _id.slow.time = _time
            _id.slow.percent = _percent
            _id.effects_active |= U_EFFECTS.SLOW
            _id.slowed_frame = 0
        }
        else{
            _id.effects_active |= SHOW_EFFECT_IMMUNITY
        }
    }
    
    if is_curse and curse == 0 and _apply_trait{
        var _time = effects_data.curse.time
        
        var _resist = 0
        
        if _sageresist or _antisageresist
            _resist += 0.7
        
        if _id.resists & U_RESISTS.CURSE > 0{
            _resist += _id.resist_percent.curse/100
        }
        
        if _resist < 1{
            _time *= 1 - _resist
            
            _id.curse = _time
            _id.effects_active |= U_EFFECTS.CURSE
        }
        else{
            _id.effects_active |= SHOW_EFFECT_IMMUNITY
        }
    }
    
    if is_weaken and curse == 0 and _apply_trait{
        var _time = effects_data.weaken.time
        var _percent = effects_data.weaken.percent
        
        var _resist = 0
        
        if _sageresist or _antisageresist
            _resist += 0.7
        
        if _id.resists & U_RESISTS.WEAKEN > 0{
            _resist += _id.resist_percent.weaken/100
        }
        
        
        
        if _resist < 1{
            _time *= 1 - _resist
            
            _id.weaken.time = _time
            _id.weaken.percent = _percent
            _id.effects_active |= U_EFFECTS.WEAKEN
        }
        else{
            _id.effects_active |= SHOW_EFFECT_IMMUNITY
        }
        
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
                    state = UNIT_STATE.KNOCKBACK
                    current_anim = anim_kb
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
            else{
                _id.effects_active |= SHOW_EFFECT_IMMUNITY
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
                    lastposy = y
                    
                    warp.time = _time
                    warp.distance = _dist
                    warp.state = 0
                    warp.animframe = 0
                    
                    image_xscale = 0
                    image_yscale = 0
                    
                    if global.audio
                        audio_play_sound(snd_warp_in,0,0)
                }
            }
            else{
                _id.effects_active |= SHOW_EFFECT_IMMUNITY
            }
            
        }
        
    }
    
    if _id.life <= 0{
        
        var _iszombie =  false
        var _revived = false
        
        if _id.type == UNIT_TYPE.DOG{
            if array_contains(_id.traits,U_TRAIT.ZOMBIE) or _id.abilities & U_ABILITIES.ZOMBIE_REVIVE > 0
                _iszombie = true
        }
        else {
        	if _id.abilities & U_ABILITIES.ZOMBIE_REVIVE > 0
                _iszombie = true
        }
        
        
        var _zkill = (killer & U_KILLER.ZOMBIE_KILLER > 0)
        
        if _iszombie{
        
            if _zkill{
                _id.zkilled = true
            }
            
            if _id.abilities & U_ABILITIES.ZOMBIE_REVIVE > 0{
                if _id.revives > 0 and _zkill{
                    _id.revives = 0
                    _id.zkilled = true
                }
                
                if !_zkill and _id.revives > 0{
                    _revived = true
                }
            }
            
        }
        
        if _id.abilities & U_ABILITIES.SURVIVE > 0 and !_revived{
            if irandom(100) <= _id.abilities_data.survive.chance{
                
                if _id.abilities_data.survive.percent<=0{
                    _id.life = 1
                }
                else{
                    _id.life = _id.baselife * _id.abilities_data.survive.percent
                }
                
                _id.abilities &= ~U_ABILITIES.SURVIVE
                _id.effects_active |= U_ABILITIES.SURVIVE
                
                if _iszombie
                    _id.zkilled = false
                
                if global.audio
                    audio_play_sound(snd_survive,0,0)
            }
        }
        
        if _iszombie and _zkill and _id.zkilled{
            var _atk = instance_create_depth(_atkx,_atky,depth,obj_attack)
            _atk.sprite_index = spr_zombie_kill_effect
            _atk.image_xscale = _side*0.5
            if global.audio
                audio_play_sound(snd_zombie_kill,0,0)
        }
        
        if abilities & U_ABILITIES.EXTRA_MONEY > 0 and _id.life<=0 and !_revived{
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