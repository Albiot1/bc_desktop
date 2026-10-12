time+=0.5

if time<0
    exit;

switch(atktype){
    case U_SPEC_ATTACKS.WAVE:
        if time==3{
            var _spr = spr_attack_wave
            var _range = 400/5
            if side == 1{
                _spr = spr_attack_wave_enemy
                _range = 500/5
            }
            
            deal_area_damage(x-_range/2,x+_range/2,,,,DAMAGE_TYPE.WAVE)
            var _atk = instance_create_depth(x,y,depth,obj_attack)
            _atk.sprite_index = _spr
            
            x+=(200/5)*side
            time = 0
            lvl--
            
            if global.audio
                audio_play_sound(snd_wave_attack,0,0)
            
            if lvl==0
                instance_destroy()
        }
    break;
    case U_SPEC_ATTACKS.MINI_WAVE:
        if time==1{
            var _spr = spr_attack_mini_wave
            var _range = 400/5
            if side == 1{
                _spr = spr_attack_mini_wave_enemy
                _range = 500/5
            }
            
            deal_area_damage(x-_range/2,x+_range/2,,,,DAMAGE_TYPE.WAVE)
            var _atk = instance_create_depth(x,y,depth,obj_attack)
            _atk.sprite_index = _spr
            
            x+=(200/5)*side
            time = 0
            lvl--
            
            if global.audio
                audio_play_sound(snd_wave_attack,0,0)
            
            if lvl==0
                instance_destroy()
        }
    break;
    case U_SPEC_ATTACKS.SURGE:
    case U_SPEC_ATTACKS.MINI_SURGE:
        if initial_hit == true and image_index >=48 and lvl > 0{
            image_index = 17
        }
        if lvl == 0 and image_index >= 9{
            instance_destroy()
        }
        
        if init == false{
            
            if side == 1{
                if atktype == U_SPEC_ATTACKS.SURGE
                    sprite_index = spr_attack_surge_start_enemy
                else
                    sprite_index = spr_attack_minisurge_start_enemy
            }
            else{
                if atktype == U_SPEC_ATTACKS.SURGE
                    sprite_index = spr_attack_surge_start
                else
                    sprite_index = spr_attack_minisurge_start
            }
            
            surge_audio = noone
            audio_play_sound(snd_surge_start,0,0,global.audio)
            init = true
        }
        
        if initial_hit == false and time == 15{
            

            initial_hit = true
            time = 0
            image_index = 0
            
            surge_audio = audio_play_sound(snd_surge_loop_main,0,true,global.audio)
            
            if side == 1{
                if atktype == U_SPEC_ATTACKS.SURGE
                    sprite_index = spr_attack_surge_loop_enemy
                else
                    sprite_index = spr_attack_minisurge_loop_enemy
            }
            else{
                if atktype == U_SPEC_ATTACKS.SURGE
                    sprite_index = spr_attack_surge_loop
                else
                    sprite_index = spr_attack_minisurge_loop
            }
            
        }
        
        if initial_hit == true and time == 20 and lvl > 0{
            
            time = 0
            lvl --
            
            ds_list_clear(hit_list)
            
            if lvl == 0{
                audio_stop_sound(surge_audio)
                if global.audio
                    audio_play_sound(snd_surge_loop_end,0,0)
                
                image_index = 0
                if side == 1{
                    if atktype == U_SPEC_ATTACKS.SURGE
                        sprite_index = spr_attack_surge_end_enemy
                    else
                        sprite_index = spr_attack_minisurge_end_enemy
                }
                else{
                    if atktype == U_SPEC_ATTACKS.SURGE
                        sprite_index = spr_attack_surge_end
                    else
                        sprite_index = spr_attack_minisurge_end
                }
            }
        }
        
        var _surgew = 250/5
        var _surgepierce = 125/5
        
        if initial_hit == true and lvl > 0 and frac(time)==0{
            deal_area_damage( x-_surgew*side,x+_surgepierce*side,,,,DAMAGE_TYPE.SURGE )
        }
    break;
    case U_SPEC_ATTACKS.EXPLOSION:
        if init == false{
            hit_list1 = ds_list_create()
            hit_list2 = ds_list_create()
            hit_list1_1 = ds_list_create()
            hit_list1_2 = ds_list_create()
            
            init = true
            changed = false
            
            sound = 0
            
            if side == 1{
                sprite_index = spr_attack_explosion_start_enemy
            }
            else{
                sprite_index = spr_attack_explosion_start
            }
        }
        
        if changed == false and image_index>=10{
            changed = true
            if side == 1{
                image_index = 0
                sprite_index = spr_attack_explosion_enemy
            }
            else{
                image_index = 0
                sprite_index = spr_attack_explosion
            }
        }
        
        if image_index>=32{
            image_speed = 0
        }
        
        var _size = 150/5
        var _posdiff = 100/5
        
        if time>=10 and time <= 25{
            if sound == 0{
                if global.audio
                    audio_play_sound(snd_explosion,0,0)
                sound++
            }
            
            deal_area_damage(x-_size/2,x+_size/2,,,,DAMAGE_TYPE.EXPLOSION)
        }
        if time>=20 and time <= 35{
            if sound == 1{
                if global.audio
                    audio_play_sound(snd_explosion_1,0,0)
                sound++
            }
            
            var _x = x-_posdiff
            deal_area_damage(_x-_size/2,_x+_size/2,false,0.7,hit_list1,DAMAGE_TYPE.EXPLOSION)
            _x = x+_posdiff
            deal_area_damage(_x-_size/2,_x+_size/2,false,0.7,hit_list2,DAMAGE_TYPE.EXPLOSION)
        }
        if time>=30 and time <= 45{
            if sound == 2{
                if global.audio
                    audio_play_sound(snd_explosion_2,0,0)
                sound++
            }
            
            var _x = x-_posdiff*2
            deal_area_damage(_x-_size/2,_x+_size/2,false,0.4,hit_list1_1,DAMAGE_TYPE.EXPLOSION)
            _x = x+_posdiff*2
            deal_area_damage(_x-_size/2,_x+_size/2,false,0.4,hit_list1_2,DAMAGE_TYPE.EXPLOSION)
        }
        
        if time > 45{
            instance_destroy()
        }
    break;
}