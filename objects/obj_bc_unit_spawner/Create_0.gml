
function spawn_unit(_x,_type,_hp_multi = 1,_atk_multi = 1){

    with instance_create_depth(_x,720,depth,obj_bc_unit){
        
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

    	targets = variable_clone( _type.targets )
        targets_number = _type.targets_number
    
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
        
        image_xscale = round( width/2 )
    }
}

tm = 0