function scr_unit_step(){
    
    if effects_active & U_EFFECTS.FREEZE > 0{
        if state != UNIT_STATE.KNOCKBACK{
            exit
        }
    }
    
    var _side = -1
    var _enemy = obj_bc_enemy
    var _enemybase = obj_bc_enemycastle
    var _enemycorpse = obj_bc_unit_corpse_enemy
    
    if type == UNIT_TYPE.DOG{
        _side = 1
        _enemy = obj_bc_unit
        _enemybase = obj_bc_nyankocastle
        _enemycorpse = obj_bc_unit_corpse_unit 
        if x > 1280 + 500{
            instance_destroy()
        }
    }
    else {
    	if x < -500{
            instance_destroy()
        }
    }
    
    var _touch = false
    var _touchbase = false
    var _corpsecheck = (killer & U_KILLER.CORPSE_KILLER > 0)
    
    if collision_rectangle(x-width*_side,y-4,x+range*_side,y,_enemy,false,true)
        _touch = true
        
    if _corpsecheck{
        if collision_rectangle(x-width*_side,y-4,x+range*_side,y,_enemycorpse,false,true)
            _touch = true
    }
    
    //attack only stops when sees any enemy that it can't attack!!!
    
    //long/omni range base reach
    if atktype == ATK_TYPE.LONG or atktype == ATK_TYPE.OMNI{
        var _range = 0
        
        if distances_number==1{
            _range = max( range,distances[0] )
        }
        else {
        	_range = max( range,distances[0][0] )
        }
        
        if collision_rectangle(x,y-4,x+_range*_side,y,_enemybase,false,true){
            _touch = true
            _touchbase = true
        }
    }
    else{
        if collision_rectangle(x-width*_side,y-4,x+range*_side,y,_enemybase,false,true){
            _touch = true
            _touchbase = true
        }
        
    }
    
    switch (state) {
    	case UNIT_STATE.IDLE:
    	
    	    if abilities & U_ABILITIES.ZOMBIE_BURROW > 0 and burrows > 0 and !_touchbase and _touch{
    	        state = UNIT_STATE.ZOMBIE_BURROW_DOWN
    	        burrows--
    	        current_anim = burrow_down_anim
    	        frame = 0
    	        exit;
    	    }
    	
            if _touch{
                atkcdwn+=0.5
                
                var _canattack = true
                
                if abilities & U_ABILITIES.TARGET_ONLY > 0{
                    //if no targets or cursed then can't attack anyone other than base
                    if targets_number==0 or curse==0{
                        if !_touchbase
                            _canattack = false
                    }
                    else{
                        if _touchbase{
                            _canattack = true
                        }
                        else{
                            ds_list_clear(enemylist)
                            
                            var _num = 0
                            if _corpsecheck{
                                _num = collision_rectangle_list(x-width*_side,y-4,x+range*_side,y,[_enemy,_enemycorpse],false,true,enemylist,true)
                            }
                            else{
                                _num = collision_rectangle_list(x-width*_side,y-4,x+range*_side,y,_enemy,false,true,enemylist,true)
                            }
                            
                            for(var i = 0; i < _num; i ++){
                                var _id = enemylist[| i].id
                               
                                for(var c = 0; c < targets_number; c ++){
                                    if _id.traits_number>0 and array_contains(_id.traits,targets[c]){
                                        _canattack = true
                                        break;
                                    }
                                    else{
                                        continue
                                    }
                                }
                                
                            }
                            
                        }
                    }
                }
                
                if atkcdwn>=atkspd and _canattack{
                    state = UNIT_STATE.ATTACK
                    current_anim = anim_attk
                    frame = 0
                    attacked = 0
                    atkcdwn = 0
                }
            }
            else {
            	state = UNIT_STATE.MOVE
                current_anim = anim_move
                frame = 0
            }
        break;
        case UNIT_STATE.MOVE:
            if _touch{
                
        	    if abilities & U_ABILITIES.ZOMBIE_BURROW > 0 and burrows > 0 and !_touchbase{
        	        state = UNIT_STATE.ZOMBIE_BURROW_DOWN
        	        burrows--
        	        current_anim = burrow_down_anim
        	        frame = 0
        	        exit;
        	    }
                
            	state = UNIT_STATE.IDLE
                current_anim = anim_idle
                frame = 0
            }
            else {
                var _cspd = spd
                
                if effects_active & U_EFFECTS.SLOW > 0{
                    _cspd *= 1 - slow.percent
                }
                
            	x+=_cspd*_side
            }
        break;
        case UNIT_STATE.WARP:
            if warp.state == 0{
                warp.animframe += 0.5
                var _fr = floor(warp.animframe)
                
                y = lastposy + global.warp_in.py[_fr]
                image_alpha = global.warp_in.opacity[_fr]
                scale = global.warp_in.scale[_fr]
                
                if warp.animframe==25{
                    warp.state = 1
                    warp.animframe = 0
                }
            }
            else if warp.state == 1{
                warp.time-=0.5
                if warp.time<=0{
                    if global.audio
                        audio_play_sound(snd_warp_out,0,0)
                    warp.state = 2
                    
                    if _side == 1{
                        x -= warp.distance
                        x = clamp( x,32,99_999 )
                    }
                    else {
                        x += warp.distance
                    	x = clamp(x,-99_999,1280-32)
                    }
                    
                }
            }
            else if warp.state == 2{
                warp.animframe += 0.5
                var _fr = floor(warp.animframe)
                
                y = lastposy + global.warp_out.py[_fr]
                image_alpha = global.warp_out.opacity[_fr]
                scale = global.warp_out.scale[_fr]
                
                if warp.animframe==22{
                    warp.state = 0
                    warp.animframe = 0
                    state = UNIT_STATE.IDLE
                    warp.time = 0
                    warp.distance = 0
        	        image_xscale = width/2
        	        image_yscale = 1
                }
                
            }
        break;
        case UNIT_STATE.ATTACK:
            if attacked == dmgnumber and frame == 0{
                //if kamikaze unit just die
                if effects & U_EFFECTS.KAMIKAZE > 0{
                    life = 0
                    instance_destroy()
                }
                
                if _touch{
                	state = UNIT_STATE.IDLE
                    current_anim = anim_idle
                    frame = 0
                }
                else {
                	state = UNIT_STATE.MOVE
                    current_anim = anim_move
                    frame = 0
                }
            }
            
            var _nextframe = 99_999
            var _dmg = 0
            if attacked <= dmgnumber - 1{
                if dmgnumber>1{
                    _nextframe = attackframes[attacked]
                    _dmg = dmg[attacked]
                }
                else{
                    _nextframe = attackframes
                    _dmg = dmg
                }
            }
            
            if effects_active & U_EFFECTS.WEAKEN > 0{
                _dmg = _dmg * 1-weaken.percent
            }
            
            if effects_active & U_EFFECTS.STRENGTHEN > 0{
                _dmg *= effects_data.strengthen.multiplier
            }
            
            
            if frame>=_nextframe and attacked <= dmgnumber - 1{

            var _waveatk = false
            var _miniawaveatk = false
            var _surgeatk = false
            var _minisurgeatk = false
            var _explatk = false
                
                hitanenemy = false
                
                var _apply_effects = false
                
                if effectonattacks == 0{
                    _apply_effects = true
                }
                else{
                    if effectonattacks[attacked] == 1{
                        _apply_effects = true
                    }
                }
                
                if _apply_effects{
                
                    if specattacks & U_SPEC_ATTACKS.WAVE > 0{
                        if irandom(100) <= specattacks_data.wave.chance
                            _waveatk = true
                    }
                    if specattacks & U_SPEC_ATTACKS.MINI_WAVE > 0{
                        if irandom(100) <= specattacks_data.mini_wave.chance
                            _miniawaveatk = true
                    }
                    if specattacks & U_SPEC_ATTACKS.SURGE > 0{
                        if irandom(100) <= specattacks_data.surge.chance
                            _surgeatk = true
                    }
                    if specattacks & U_SPEC_ATTACKS.MINI_SURGE > 0{
                        if irandom(100) <= specattacks_data.mini_surge.chance
                            _minisurgeatk = true
                    }
                    if specattacks & U_SPEC_ATTACKS.EXPLOSION > 0{
                        if irandom(100) <= specattacks_data.explosion.chance
                            _explatk = true
                    }
                    
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
                
                switch (atktype) {
                	case ATK_TYPE.SINGLE:

                        
                        ds_list_clear(enemylist)
                        var _base = collision_rectangle(x-width*_side,y-4,x+range*_side,y,_enemybase,false,true)
                        
                        var _num = 0
                        if _corpsecheck{
                            _num = collision_rectangle_list(x-width*_side,y-4,x+range*_side,y,[_enemy,_enemycorpse],false,true,enemylist,true)
                        }
                        else{
                            _num = collision_rectangle_list(x-width*_side,y-4,x+range*_side,y,_enemy,false,true,enemylist,true)
                        }
                        
                        if abilities & U_ABILITIES.TARGET_ONLY > 0{
                            if _num>0 or _base != noone{
                                
                                var _retid = noone
                                var _corpse = false
                                for(var i = 0; i < _num; i ++){
                                    var _id = enemylist[| i].id
                                    
                                    _corpse = false
                                    if _corpsecheck and _id.object_index==_enemycorpse{
                                        _id = _id.creator
                                        _corpse = true
                                    }
                                    
                                    if curse == 0
                                    for(var c = 0; c < targets_number; c ++){
                                        if _id.traits_number>0 and array_contains(_id.traits,targets[c]){
                                            _retid = _id
                                            
                                            if _base != noone and point_distance(_id.x,0,x,0) > point_distance(_base.x,0,x,0){
                                                continue
                                            }
                                            else{
                                                break
                                            }
                                        }
                                        else{
                                            continue
                                        }
                                    }
                                    
                                }
                                
                                if _retid != noone{
                                    if point_distance(_id.x,0,x-64*_side,0) > point_distance(_base.x,0,x-64*_side,0){
                                        scr_base_deal_damage(_base.id,_dmg)
                                    }
                                    else {
                                        if _corpse
                                            scr_corpse_deal_damage(_retid,_dmg)
                                        else {
                                        	scr_unit_deal_damage(_retid,_dmg)
                                        }
                                    }
                                    
                                }
                                else{
                                    if _base != noone{
                                        scr_base_deal_damage(_base.id,_dmg)
                                    }
                                }
                                
                            }
                        }
                        else{
                            if _num>0 or _base != noone{
                                
                                if _num > 0{
                                    var _id = enemylist[| 0].id
                                    
                                    var _corpse = false
                                    if _corpsecheck and _id.object_index == _enemycorpse{
                                        _id = _id.creator
                                        _corpse = true
                                    }
                                    
                                    if _base != noone{
                                        
                                        if point_distance(_id.x,0,x-64*_side,0) > point_distance(_base.x,0,x-64*_side,0){
                                            scr_base_deal_damage(_base.id,_dmg)
                                        }
                                        else {
                                            if _corpse
                                                scr_corpse_deal_damage(_id,_dmg)
                                            else {
                                            	scr_unit_deal_damage(_id,_dmg)
                                            }
                                        }
                                    }
                                    else {
                                        if _corpse
                                            scr_corpse_deal_damage(_id,_dmg)
                                        else {
                                        	scr_unit_deal_damage(_id,_dmg)
                                        }
                                    }
                                    
                                }
                                else{
                                    if _base != noone{
                                        scr_base_deal_damage(_base.id,_dmg)
                                    }
                                }
                            }
                        }
                        
                    break;
                    case ATK_TYPE.AREA:
                        
                        ds_list_clear(enemylist)
                        
                        var _num = 0
                        if _corpsecheck{
                            _num = collision_rectangle_list(x-width*_side,y-4,x+range*_side,y,[_enemycorpse,_enemy],false,true,enemylist,true)
                        }
                        else{
                            _num = collision_rectangle_list(x-width*_side,y-4,x+range*_side,y,_enemy,false,true,enemylist,true)
                        }

                        var _base = collision_rectangle(x-width*_side,y-4,x+range*_side,y,_enemybase,false,true)
                    
                        if abilities & U_ABILITIES.TARGET_ONLY > 0{
                            if _num>0 or _base != noone{
                                
                                var _corpse = false
                                
                                for (var i = 0; i < _num; i++) {
                                    var _id = enemylist[| i].id
                                    
                                    
                                    if _corpsecheck and _id.object_index==_enemycorpse{
                                        _id = _id.creator
                                        _corpse = true
                                    }
                                    else {
                                    	_corpse = false
                                    }
                                    
                                    if curse == 0
                        			for(var c = 0; c < targets_number; c ++){
                        				if _id.traits_number>0 and array_contains(_id.traits,targets[c]){
                                            if _corpse
                                                scr_corpse_deal_damage(_id,_dmg)
                                            else {
                                            	scr_unit_deal_damage(_id,_dmg)
                                            }
                        					continue
                        				}
                        				else{
                        					continue
                        				}
                        			}
                                    
                                }
                                if _base != noone{
                                    scr_base_deal_damage(_base.id,_dmg)
                                }
                            }
                        }
                        else{
                            if _num>0 or _base != noone{
                                
                                var _corpse = false
                                
                                for (var i = 0; i < _num; i++) {
                                    var _id = enemylist[| i].id
                                    
                                    
                                    if _corpsecheck and _id.object_index==_enemycorpse{
                                        _id = _id.creator
                                        _corpse = true
                                    }
                                    else {
                                    	_corpse = false
                                    }
                                    
                                	if instance_exists(_id){
                                        if _corpse
                                            scr_corpse_deal_damage(_id,_dmg)
                                        else {
                                        	scr_unit_deal_damage(_id,_dmg)
                                        }
                                    }
                                }
                                if _base != noone{
                                    scr_base_deal_damage(_base.id,_dmg)
                                }
                            }
                        }

                    break;
                    case ATK_TYPE.LONG:
                    case ATK_TYPE.OMNI:
                        
                        var _range0 = 0
                        var _range1 = 0
                        if dmgnumber>1 and distances_number>1{
                            _range0 = distances[attacked][0]
                            _range1 = distances[attacked][1]
                        }
                        else{
                            _range0 = distances[0]
                            _range1 = distances[1]
                        }
                        
                        var _point0 = x + _range0 * _side
                        var _point1 = x + _range1 * _side
                        
                        ds_list_clear(enemylist)
                        
                        var _num = 0
                        if _corpsecheck{
                            _num = collision_rectangle_list(_point0,y-4,_point1,y,[_enemycorpse,_enemy],false,true,enemylist,true)
                        }
                        else{
                            _num = collision_rectangle_list(_point0,y-4,_point1,y,_enemy,false,true,enemylist,true)
                        }
                        
                        var _base = collision_rectangle(_point0,y-4,_point1,y,_enemybase,false,true)
                        
                        if abilities & U_ABILITIES.TARGET_ONLY > 0{
                            if _num>0 or _base != noone{
                                
                                var _corpse = false
                                
                                for (var i = 0; i < _num; i++) {
                                    var _id = enemylist[| i].id
                                    
                                    if _corpsecheck and _id.object_index==_enemycorpse{
                                        _id = _id.creator
                                        _corpse = true
                                    }
                                    else {
                                    	_corpse = false
                                    }
                                    
                                    if curse == 0
                        			for(var c = 0; c < targets_number; c ++){
                        				if _id.traits_number>0 and array_contains(_id.traits,targets[c]){
                                            if _corpse
                                                scr_corpse_deal_damage(_id,_dmg)
                                            else {
                                            	scr_unit_deal_damage(_id,_dmg)
                                            }
                        					continue
                        				}
                        				else{
                        					continue
                        				}
                        			}
                                    
                                }
                                if _base != noone{
                                    scr_base_deal_damage(_base.id,_dmg)
                                }
                            }
                        }
                        else{
                            
                            var _corpse = false
                            
                            if _num>0 or _base != noone{
                                for (var i = 0; i < _num; i++) {
                                    var _id = enemylist[| i].id
                                    
                                    if _corpsecheck and _id.object_index==_enemycorpse{
                                        _id = _id.creator
                                        _corpse = true
                                    }
                                    else {
                                    	_corpse = false
                                    }
                                    
                                	if instance_exists(_id){
                                        if _corpse
                                            scr_corpse_deal_damage(_id,_dmg)
                                        else {
                                        	scr_unit_deal_damage(_id,_dmg)
                                        }
                                    }
                                }
                                if _base != noone{
                                    scr_base_deal_damage(_base.id,_dmg)
                                }
                            }
                        }
                    
                    break;
                }
                
                if hitanenemy{
                    
                    if _waveatk{
                        var _px = 0
                        if _side == 1{
                            _px = x -6.55 + 50
                        }
                        else{
                            _px = x + 13.5 - 40
                        }
                        var _lvl = specattacks_data.wave.lvl
                        create_special_attack(_px,y,U_SPEC_ATTACKS.WAVE,id,_dmg,_lvl)
                    }
                    if _miniawaveatk{
                        var _px = 0
                        if _side == 1{
                            _px = x - 6.55 + 50
                        }
                        else{
                            _px = x + 13.5 - 40
                        }
                        var _lvl = specattacks_data.mini_wave.lvl
                        create_special_attack(_px,y,U_SPEC_ATTACKS.MINI_WAVE,id,_dmg*0.2,_lvl)
                    }
                    if _surgeatk{
                        var _srange = specattacks_data.surge.range
                        var _lvl = specattacks_data.surge.lvl
                        
                        if is_array(_srange){
                            _px = x + irandom_range(_srange[0],_srange[1])*_side
                        }
                        else{
                            _px = x + _srange*_side
                        }
                        
                        create_special_attack(_px,y,U_SPEC_ATTACKS.SURGE,id,_dmg,_lvl,0,_srange)
                    }
                    if _minisurgeatk{
                        var _srange = specattacks_data.mini_surge.range
                        var _lvl = specattacks_data.mini_surge.lvl
                        
                        if is_array(_srange){
                            _px = x + irandom_range(_srange[0],_srange[1])*_side
                        }
                        else{
                            _px = x + _srange*_side
                        }
                        
                        create_special_attack(_px,y,U_SPEC_ATTACKS.MINI_SURGE,id,_dmg,_lvl,0,_srange)
                    }
                    if _explatk{
                        var _srange = specattacks_data.explosion.range
                        
                        if is_array(_srange){
                            _px = x + irandom_range(_srange[0],_srange[1])*_side
                        }
                        else{
                            _px = x + _srange*_side
                        }
                        
                        create_special_attack(_px,y,U_SPEC_ATTACKS.EXPLOSION,id,_dmg,0)
                    }
                    
                }
                
                is_toxic = false
                is_crit = false
                
                is_savage_blow = false
                is_metal_kill = false
                
                //
                is_knockback = false
                is_freeze = false
                is_slow = false
                is_weaken = false
                is_warp = false
                is_curse = false
                //
                
                attacked++
            }
        break;
        case UNIT_STATE.KNOCKBACK:
            var _mult = knockback.time/knockback.maxtime
            
            var _pos = animcurve_channel_evaluate(knockback.anims,_mult)
            
            
            if _side == 1{
                x = clamp(lastpos - ((knockback.distance*_side) * _pos),limit,99_999)
            }
            else {
            	x = clamp(lastpos - ((knockback.distance*_side) * _pos),-99_999,room_width-limit)
            }
            
            if knockback.type == KNOCKACK_TYPE.BOSS or knockback.type == KNOCKACK_TYPE.HEALTH{
                var _ypos = animcurve_channel_evaluate(knockback.anim,_mult)
                y = ystart - 20 * _ypos
            }
            else {
                var _ypos = animcurve_channel_evaluate(knockback.anmsmall,_mult)
                y = ystart - 5 * _ypos
            }
            
            if knockback.time>=knockback.maxtime{
                
                if life <= 0 and abilities & U_ABILITIES.ZOMBIE_REVIVE and revives > 0{
                    revives--
                    
                    life = baselife * abilities_data.revive.percent
                    knockbacks = maxknockbacks
                    knockbackhp = life - (life/maxknockbacks)
                    
                    var _revtime = abilities_data.revive.time
                    
                    image_xscale = 0
                    image_yscale = 0
                    
                    var _corpse = noone
                    with instance_create_depth(x-13*_side,y,depth,_side == 1 ? obj_bc_unit_corpse_enemy : obj_bc_unit_corpse_unit ){
                        creator = other.id
                        side = _side
                        revive_time = _revtime
                        _corpse = id
                    }
                    corpse_ref = _corpse
                    
                    state = UNIT_STATE.ZOMBIE_DEAD
                    
                    exit;
                }
                
                if life<=0{
                    instance_destroy()
                
                    var _soulspawn = true
                    
                    if effects & U_EFFECTS.KAMIKAZE > 0{
                        _soulspawn = false
                    }
                    if abilities & U_ABILITIES.ZOMBIE_REVIVE > 0{
                        if zkilled{
                            _soulspawn = false
                        }
                    }

                    if _soulspawn
                        instance_create_depth(x,y,depth+1,obj_soul)
                }
                
                if knockback.type == KNOCKACK_TYPE.HEALTH and life > 0{
                    
                    if abilities & U_ABILITIES.AKU_SHIELD > 0{
                        shield_hp = shield_max_hp * shield_regen
                        shield_current_max_hp = shield_hp
                        shield_frame = 0
                        effects_active |= SHOW_SHIELD_HIT
                        shield_state = AKU_SHIELD_STATE.REGEN
                        
                        if global.audio
                            audio_play_sound(snd_shield_regen,0,0)
                    }
                    
                }
                
                image_xscale = width/2
                image_yscale = 1
                
                if _touch{
                    state = UNIT_STATE.IDLE
                    current_anim = anim_idle
                    frame = 0
                }
                else {
                	state = UNIT_STATE.MOVE
                    current_anim = anim_move
                    frame = 0
                }
            }
            
            knockback.time+=0.5
        break;
        case UNIT_STATE.ZOMBIE_DEAD:

        break;
        case UNIT_STATE.ZOMBIE_DEAD_KNOCKBACK:
            var _mult = knockback.time/knockback.maxtime
            
            var _pos = animcurve_channel_evaluate(knockback.anims,_mult)
            
            
            if _side == 1{
                x = clamp(lastpos - ((knockback.distance*_side) * _pos),limit,99_999)
            }
            else {
            	x = clamp(lastpos - ((knockback.distance*_side) * _pos),-99_999,room_width-limit)
            }
            
            if knockback.type == KNOCKACK_TYPE.BOSS or knockback.type == KNOCKACK_TYPE.HEALTH{
                var _ypos = animcurve_channel_evaluate(knockback.anim,_mult)
                y = ystart - 20 * _ypos
            }
            else {
                var _ypos = animcurve_channel_evaluate(knockback.anmsmall,_mult)
                y = ystart - 5 * _ypos
            }
            
            if knockback.time >= knockback.maxtime{
                
                if life<=0{
                    
                    if corpse_ref!=noone{
                        instance_destroy(corpse_ref)
                        corpse_ref = noone
                    }
                
                    var _soulspawn = true
                    
                    if effects & U_EFFECTS.KAMIKAZE > 0{
                        _soulspawn = false
                    }

                    if zkilled{
                        _soulspawn = false
                    }

                    if _soulspawn
                        instance_create_depth(x,y,depth+1,obj_soul)
                    
                    instance_destroy()
                }
                
            }
            
            if corpse_ref!=noone{
                corpse_ref.x = x - 13 * _side
                corpse_ref.y = y
            }
            
            knockback.time+=0.5
        break;
        case UNIT_STATE.ZOMBIE_BURROW_DOWN:
    	    if frame>=current_anim.frame_count-1{
    	        state = UNIT_STATE.ZOMBIE_BURROW_MOVE
    	        lastpos = x
    	        image_xscale = 0
    	        image_yscale = 0
    	    }
        break;
        case UNIT_STATE.ZOMBIE_BURROW_MOVE:
            var _cspd = spd
            
            if effects_active & U_EFFECTS.SLOW > 0{
                _cspd *= 1 - slow.percent
            }
            
        	if point_in_rectangle(x+_cspd*_side,y,_enemybase.bbox_left,_enemybase.bbox_top,_enemybase.bbox_right,_enemybase.bbox_right){
    	        state = UNIT_STATE.ZOMBIE_BURROW_UP
    	        current_anim = burrow_up_anim
        	}
        	else{
            	x+=_cspd*_side
            	
            	if _side==1{
            	    if x >= lastpos + abilities_data.burrow.distance{
            	        state = UNIT_STATE.ZOMBIE_BURROW_UP
            	        current_anim = burrow_up_anim
            	    }
            	}
            	else{
            	    if x <= lastpos - abilities_data.burrow.distance{
            	        state = UNIT_STATE.ZOMBIE_BURROW_UP
            	        current_anim = burrow_up_anim
            	    }
            	}
        	}
        break;
        case UNIT_STATE.ZOMBIE_BURROW_UP:
    	    if frame>=current_anim.frame_count-1{
    	        state = UNIT_STATE.IDLE
    	        current_anim = anim_idle
    	        frame = 0
    	        image_xscale = width/2
    	        image_yscale = 1
    	    }
        break;
    }
    
    
}

function create_special_attack(_x,_y,_type,_creator,_dmg,_level = 1,_spawn_time = 0,_range = 0){
    with instance_create_depth(_x,_y,_creator.depth-1,obj_specialattak){
        atktype = _type
        dmg = _dmg
        lvl = _level
        time = _spawn_time

        type = _creator.type
        is_crit = _creator.is_crit
        is_savage_blow = _creator.is_savage_blow
        is_toxic = _creator.is_toxic
        is_metal_kill = _creator.is_metal_kill
        
        is_knockback = _creator.is_knockback
        is_freeze = _creator.is_freeze
        is_slow = _creator.is_slow
        is_weaken = _creator.is_weaken
        is_warp = _creator.is_warp
        is_curse = _creator.is_curse
        

        if _type == U_SPEC_ATTACKS.SURGE or _type == U_SPEC_ATTACKS.MINI_SURGE{
            range = _range
        }

            
        if _creator.type == UNIT_TYPE.DOG{
            traits = variable_clone( _creator.traits )
            traits_number = _creator.traits_number
            spectraits = variable_clone ( _creator.spectraits )
            spectraits_number = _creator.spectraits_number
            cash = _creator.cash
            side = 1
        }
        else {
        	targets = variable_clone( _creator.targets )
            targets_number = _creator.targets_number
            side = -1
        }
        
        curse = 0
        
        abilities = _creator.abilities
        abilities_data = _creator.abilities_data
        
        effects = _creator.effects
        effects_data = _creator.effects_data
        
        resists = _creator.resists
        resist_percent = _creator.resist_percent
        
        killer = _creator.killer
        killer_data = _creator.killer_data
    }
}