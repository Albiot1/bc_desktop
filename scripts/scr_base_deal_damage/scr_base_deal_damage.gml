function scr_base_deal_damage(_id,_dmg){
    
    //abilities !!!
    if curse == 0 {
    
        if abilities & U_ABILITIES.BASE_DESTROYER > 0
            _dmg = _dmg * 3
        
    }
    
    var _apply_effects = false
    
    if effectonattacks == 0{
        _apply_effects = true
    }
    else{
        if effectonattacks[attacked] == 1{
            _apply_effects = true
        }
    }
    
    var _side = -1
    if type == UNIT_TYPE.DOG{
        _side = 1
    }
    
    var _atkx = irandom_range(_id.bbox_left+8,_id.bbox_right-8)//_id.x+(16+irandom_range(-4,4))*_side
    var _atky = irandom_range(_id.bbox_top+8,_id.bbox_bottom-8)
    
    if is_crit and _apply_effects{
        _dmg *= 2
        
        var _atk1 = instance_create_depth(_atkx,_atky,_id.depth-2,obj_attack)
        _atk1.sprite_index = spr_attack_critical
        _atk1.image_xscale = _side*0.5
    }
    if is_savage_blow and _apply_effects{
        _dmg *= effects_data.savage_blow.multiplier
        
        var _atk1 = instance_create_depth(_atkx,_atky,_id.depth-2,obj_attack)
        _atk1.sprite_index = spr_attack_savage_blow
        _atk1.image_xscale = _side*0.5
    }
    
    
    _id.life -= _dmg
    
    if _id.life<0{
        _id.life = 0
        _id.shake = true
        _id.alarm[0]=-1
    }
    
    if _id.life>0{
        _id.shake = true
        _id.alarm[0] = 4
    }
    
    var _atk = instance_create_depth(_atkx,_atky,_id.depth-1,obj_attack)
    
    if type == UNIT_TYPE.DOG{
        _atk.sprite_index = spr_attack_smoke_dark
    }
    else{
        if global.enemy_base_life_percent > 0{
            global.enemy_base_life_percent = _id.maxlife/_id.life
        }
    }
    
    if global.audio
        audio_play_sound(snd_attack_base,0,0)
    
    hitanenemy = true
    
}