/*
var _disp_w = display_get_width()
var _disp_h = display_get_height()
camera_set_view_size(view_camera[0],_disp_w,_disp_h)
view_set_wport(view_current,_disp_w)
view_set_hport(view_current,_disp_h)
*/

timer = 90

function spawn_enemy(_x,_type,_hp_multi = 1,_atk_multi = 1,_is_boss = false){

    if _is_boss{
        _x = obj_bc_enemycastle.bbox_right+5
        with instance_create_depth(_x, SPAWN_Y, depth, obj_effect_anim){
            data = global.boss_shockwave_animation
        }
        if global.audio
            audio_play_sound(snd_boss_wave,1,0)
    }
    
    with instance_create_depth(_x,720,depth,obj_bc_enemy){
        
        anim_idle = _type.idle_anim
        anim_move = _type.move_anim
        anim_attk = _type.atk_anim
        anim_kb = _type.kb_anim
        atlas = _type.atlas_surface
        
        atlas_backup = _type.atlas_backup
        atlas_size = _type.atlas_size
        
        stats_ref = _type
        
        current_anim = anim_move
        
        spd = _type.spd
        dmg = variable_clone( _type.dmg )
        dmgnumber = _type.dmgnumber
        
        if variable_struct_exists(_type,"distances"){
            distances = variable_clone( _type.distances )
            distances_number = _type.distances_number
        }
        
        if dmgnumber>1{
            for(var i = 0;i < dmgnumber;i++){
                dmg[i] = dmg[i]*_atk_multi   
            }
        }
        else{
            dmg *= _atk_multi
        }
        
        limit = _type.limit
        
        if _is_boss{
            limit = _x + limit
        }
        
        knockbacks = _type.knockbacks
        maxknockbacks = knockbacks
        atktype = _type.atktype
        range = _type.range
        attackframes = _type.attacks
        life = _type.life * _hp_multi
        baselife = life
        atkspd = _type.atkspd
        atkcdwn = atkspd
        type = _type.type
        effectonattacks = _type.effectonattacks
        
        
        knockbackhp = life - (life/maxknockbacks)
        
        width = 320/5
        height = _type.height
        
        
        traits = variable_clone( _type.traits )
        traits_number = _type.traits_number
        spectraits = variable_clone ( _type.spectraits )
        spectraits_number = _type.spectraits_number
        cash = _type.cash

        
        abilities = variable_clone( _type.abilities )
        abilities_data = variable_clone( _type.abilities_data )
        
        effects = variable_clone( _type.effects )
        effects_data = variable_clone( _type.effects_data )
        
        resists = variable_clone( _type.resists )
        resist_percent = variable_clone( _type.resist_percent )
        
        killer = variable_clone( _type.killer )
        killer_data = variable_clone( _type.killer_data )
        
        specattacks = variable_clone( _type.specattacks )
        specattacks_data = variable_clone( _type.specattacks_data )
        
        if abilities & U_ABILITIES.ALN_BARRIER > 0{
            barrier_hp = abilities_data.barrier.hp
            barrier_state = BARRIER_STATE.NONE
            barrier_frame = 0
        }
        
        if abilities & U_ABILITIES.AKU_SHIELD > 0{
            shield_hp = abilities_data.aku_shield.hp
            shield_max_hp = shield_hp
            shield_current_max_hp = shield_hp
            shield_regen = abilities_data.aku_shield.regen
            shield_state = AKU_SHIELD_STATE.NONE
            shield_frame = 0
        }
        
        if abilities & U_ABILITIES.COUNTER_SURGE > 0{
            surge_list = ds_list_create()
        }
        
        if (array_contains(traits,U_TRAIT.ZOMBIE)) or abilities & U_ABILITIES.ZOMBIE_REVIVE > 0{
            zkilled = false
        }
        
        if abilities & U_ABILITIES.ZOMBIE_REVIVE > 0{
            revives = abilities_data.revive.amount
            corpse_ref = noone
        }
        
        if abilities & U_ABILITIES.ZOMBIE_BURROW > 0{
            burrow_up_anim = _type.burrow_up_anim
            burrow_down_anim = _type.burrow_down_anim
            burrows = abilities_data.burrow.amount
        }
        
        image_xscale = round( width/2 )
    }
}

enum BOSS_TYPE {
    NONE,
    BOSS,
    BOSS_SHOCKWAVE
}

enum KILLS_TYPE {
    NONE,
    ALL,
    UNIT,
    ENEMY
} 

SpawnerList = function(_enemy,_start_spawn,_respawn_time,_amount = 1,_boss = BOSS_TYPE.NONE) constructor{
    atk_multi = 1
    hp_multi = 1
    is_boss = _boss
    spawn_start_time = _start_spawn
    respawn_time = _respawn_time
    base_health_amount = 1
    spawn_amount = _amount
    kills_to_spawn = 0
    kills_type = KILLS_TYPE.NONE
    enemy = _enemy
    
    static SetAtkMulti = function(_multi){
        atk_multi = _multi
        
        return self
    }
    static SetHpMulti = function(_multi){
        hp_multi = _multi
        
        return self
    }
    static SetBaseHealth = function(_value){
        base_health_amount = _value
        
        return self
    }
    static AddKillCondition = function(_kills_type,_kills_amount){
        kills_to_spawn = _kills_amount
        kills_type = _kills_type
        
        return self
    }
}

spawner = {
    limit : -1,
    list:[],
    timers:[],
    spawned:[], //if it spawned once
    num:0,
    step:function(){
        for(var i = num - 1; i>=0; i--){
            var _data = list[i]
            var _spawn = false
            
            if global.enemy_base_life_percent <= _data.base_health_amount{
                
                timers[i]+=0.5
                
                if _data.kills_to_spawn != 0{
                    if _data.kills_type == KILLS_TYPE.ALL and global.units_killed+global.enemies_killed < _data.kills_to_spawn{
                        continue
                    }
                    else if _data.kills_type == KILLS_TYPE.UNIT and global.units_killed < _data.kills_to_spawn{
                        continue
                    }
                    else if _data.kills_type == KILLS_TYPE.ENEMY and global.enemies_killed < _data.kills_to_spawn{
                        continue
                    }
                }
                
                if limit > 0 and instance_number(obj_bc_enemy) >= limit{
                    continue
                }
                
                if spawned[i] == 0{
                    if timers[i]>=_data.spawn_start_time{
                        _spawn = true
                        spawned[i] = 1
                        timers[i] = 0
                    }
                }
                else{
                    if timers[i]>=_data.respawn_time{
                        _spawn = true
                        timers[i] = 0
                        spawned[i] ++
                    }
                }
                
                if _spawn {
                    //
                    
                    spawn_enemy(obj_bc_enemycastle.x+58,global.enemies[$ _data.enemy],_data.hp_multi,_data.atk_multi,_data.is_boss)
                    
                    //
                }
                
                if spawned[i] >= _data.spawn_amount{
                    array_delete(list,i,1)
                    array_delete(timers,i,1)
                    array_delete(spawned,i,1)
                    num--
                }
                
            }
            
        }
    }
}

