atktype = U_SPEC_ATTACKS.MINI_WAVE

lvl = 0
time = 0
initial_hit = false
init = false
side = 1
dmg = 0

hit_list = ds_list_create()
enemylist = ds_list_create()
corpselist = ds_list_create()

image_xscale = 0.5
image_yscale = 0.5


function deal_area_damage(_pos0,_pos1,_hitbase = false,_dmg_percent = 1,_hlist = hit_list,_dmgatktype = DAMAGE_TYPE.NORMAL){
    var _enemy = obj_bc_enemy
    var _enemybase = obj_bc_enemycastle
    var _enemycorpse = obj_bc_unit_corpse_enemy
    
    if side == 1{
        _enemy = obj_bc_unit
        _enemybase = obj_bc_nyankocastle
        _enemycorpse = obj_bc_unit_corpse_unit
    }
    
    ds_list_clear(enemylist)
    
    var _base = noone
    
    var _num1 = 0
    if killer & U_KILLER.CORPSE_KILLER > 0{
        _num1 = collision_rectangle_list(_pos0,y-4,_pos1,y,_enemycorpse,false,true,corpselist,false)
    }
    
    _num = collision_rectangle_list(_pos0,y-4,_pos1,y,_enemy,false,true,enemylist,false)

    
    if _hitbase
        _base = collision_rectangle(_pos0,y-4,_pos1,y,_enemybase,false,true)

    var _dmg = dmg * _dmg_percent

    if _num>0 or _base != noone{
        
        if _dmgatktype == DAMAGE_TYPE.WAVE
        for (var i = 0; i < _num; i++) {
            var _id = enemylist[| i].id
            //wave blocker
            if _dmgatktype == DAMAGE_TYPE.WAVE and _id.abilities & U_ABILITIES.WAVE_SHIELD > 0{
                _id.effects_active |= U_ABILITIES.WAVE_SHIELD
                _id.wave_shield_frame = 0
                instance_destroy()
                exit;
            }
            //
        }
        
        if killer & U_KILLER.CORPSE_KILLER > 0{
            for (var i = 0; i < _num1; i++) {
                var _id = enemylist[| i].creator
                
                if ds_list_find_index(_hlist,_id)>=0{
                    continue
                }
                
            	if instance_exists(_id){
                    scr_corpse_deal_damage(_id,_dmg)
                    ds_list_add(_hlist,_id)
                }
            }
        }
        
        for (var i = 0; i < _num; i++) {
            var _id = enemylist[| i].id
            
            //wave blocker
            if _dmgatktype == DAMAGE_TYPE.WAVE and _id.abilities & U_ABILITIES.WAVE_SHIELD > 0{
                _id.effects_active |= U_ABILITIES.WAVE_SHIELD
                _id.wave_shield_frame = 0
                instance_destroy()
                exit;
            }
            //
            
            if ds_list_find_index(_hlist,_id)>=0{
                continue
            }
            
        	if instance_exists(_id){
                scr_unit_deal_damage(_id,_dmg,_dmgatktype)
                ds_list_add(_hlist,_id)
            }
        }
        if _base != noone and !(ds_list_find_index(_hlist,_base.id)>=0){
            scr_base_deal_damage(_base.id,_dmg)
            ds_list_add(_hlist,_base.id)
        }
    }

}