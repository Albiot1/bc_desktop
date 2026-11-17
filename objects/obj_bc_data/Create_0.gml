global.max_x = [ 32,1280-32 ]
#macro DEBUG_BOXES false 
#macro debug:DEBUG_BOXES true 

enum BARRIER_STATE {
    NONE,
    HIT,
    DESTROY,
    SHATTER
}

enum AKU_SHIELD_STATE {
    NONE,
    HIT,
    DESTROY,
    PIERCE,
    REGEN
}

function process_sheet_surface(_sheet_path,_name = "name"){
    var _scale = 2
    
    var _sheet = sprite_add(_sheet_path, 1, false, false, 0, 0);
    var atlas_surface = surface_create(sprite_get_width(_sheet)*_scale, sprite_get_height(_sheet)*_scale);
    var _blend_surface = surface_create(sprite_get_width(_sheet), sprite_get_height(_sheet));
    
    gpu_set_tex_filter(false)
    
    surface_set_target(_blend_surface);
    draw_clear_alpha(c_black, 0);
    
    
    if SURFACE_HROMAKEY_OPTIMIZE{
        gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_zero, bm_one); 
        
        draw_sprite_ext(_sheet, 0,  1,  0, 1, 1, 0, c_white, 1);
        draw_sprite_ext(_sheet, 0, -1,  0, 1, 1, 0, c_white, 1);
        draw_sprite_ext(_sheet, 0,  0,  1, 1, 1, 0, c_white, 1);
        draw_sprite_ext(_sheet, 0,  0, -1, 1, 1, 0, c_white, 1);
    }
    
    gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_one, bm_inv_src_alpha);
    draw_sprite_ext(_sheet, 0, 0, 0, 1, 1, 0, c_white, 1);
    
    surface_reset_target();
    
    surface_set_target(atlas_surface)
    
    draw_clear_alpha(c_black, 0);
    gpu_set_tex_filter(true)
    gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha)
    draw_surface_ext(_blend_surface,0,0,2,2,0,c_white,1)
    gpu_set_blendmode(bm_normal)
    
    surface_reset_target()
    
    var _surf_width = surface_get_width(atlas_surface);
    var _surf_height = surface_get_height(atlas_surface);
    
    var atlas_backup = buffer_create(_surf_width * _surf_height * 4, buffer_fixed, 1);
    var atlas_size = [_surf_width,_surf_height]
    
    buffer_get_surface(atlas_backup, atlas_surface, 0);
    
    surface_free(_blend_surface)
    sprite_delete(_sheet);
    
    return [ atlas_surface,atlas_backup,atlas_size ]
}


function EffectAnimation(_folder,_img,_imgcut,_mamodel,_maanim) constructor{
    var _path = "anims/"+_folder
    var _sheet_path = _path + _img + ".png"
    var _imgcut_path = _path + _imgcut + ".imgcut"
    var _mamodel_path = _path + _mamodel + ".mamodel"
    var _maanim_idle_path = _path + _maanim + ".maanim"
    
    var _data = process_sheet_surface(_sheet_path,_img)
    atlas_surface = _data[0]
    atlas_backup = _data[1]
    atlas_size = _data[2]
    
    var _imgcutdata  = bc_load_imgcut(_imgcut_path);
    var _mamodeldata = bc_load_mamodel(_mamodel_path);
    var _maanim_idle = bc_load_maanim(_maanim_idle_path)

    anim = bc_bake_animation_fixed(_mamodeldata,_maanim_idle,_imgcutdata,atlas_surface)
}

global.death_surge_animation = [
    new EffectAnimation("akudeathsurge/", "battle_demonsoul_00","battle_demonsoul_00","battle_demonsoul_00","battle_demonsoul_00"),
    new EffectAnimation("akudeathsurge/", "battle_demonsoul_01","battle_demonsoul_01","battle_demonsoul_01","battle_demonsoul_01")
]
global.counter_surge_animation = [
    new EffectAnimation("conutersurge_en/", "skill017","skill017","skill_demonsummon_e","skill_demonsummon_e"),
    new EffectAnimation("countersurge/", "skill018","skill018","skill_demonsummon","skill_demonsummon")
]
global.boss_shockwave_animation = new EffectAnimation("boss_shockwave/","000_a","000_a","boss_welcome","boss_welcome")

///
function export_anim(_sheet_path,_imgcut_path,_mamodel_path,_maanim_path,_export_name){
    _sheet_path = "anims/"+_sheet_path+".png"
    _imgcut_path = "anims/"+_imgcut_path+".imgcut"
    _mamodel_path = "anims/"+_mamodel_path+".mamodel"
    _maanim_path = "anims/"+_maanim_path+".maanim"
    
    var _scale = 2
    
    var _sheet = sprite_add(_sheet_path, 1, false, false, 0, 0);
    var _atlas_surface = surface_create(sprite_get_width(_sheet)*_scale, sprite_get_height(_sheet)*_scale);
    var _blend_surface = surface_create(sprite_get_width(_sheet), sprite_get_height(_sheet));
    
    gpu_set_tex_filter(false)
    
    surface_set_target(_blend_surface);
    draw_clear_alpha(c_black, 0);
    gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_zero, bm_one); 
    draw_sprite_ext(_sheet, 0,  1,  0, 1, 1, 0, c_white, 1);
    draw_sprite_ext(_sheet, 0, -1,  0, 1, 1, 0, c_white, 1);
    draw_sprite_ext(_sheet, 0,  0,  1, 1, 1, 0, c_white, 1);
    draw_sprite_ext(_sheet, 0,  0, -1, 1, 1, 0, c_white, 1);
    
    gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_one, bm_inv_src_alpha);
    draw_sprite_ext(_sheet, 0, 0, 0, 1, 1, 0, c_white, 1);
    
    surface_reset_target();
    
    surface_set_target(_atlas_surface)
    
    draw_clear_alpha(c_black, 0);
    gpu_set_tex_filter(true)
    gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha)
    draw_surface_ext(_blend_surface,0,0,2,2,0,c_white,1)
    gpu_set_blendmode(bm_normal)
    
    surface_reset_target()
    
    
    var _surf_width = surface_get_width(_atlas_surface);
    var _surf_height = surface_get_height(_atlas_surface);

    surface_free(_blend_surface)
    sprite_delete(_sheet);
    
    var _imgcut  = bc_load_imgcut(_imgcut_path);
    var _mamodel = bc_load_mamodel(_mamodel_path);
    var _maanim = bc_load_maanim(_maanim_path)

    
    var _bounds = bc_compute_bounds(_mamodel,_maanim,_imgcut,1)
    
    var _anim = bc_bake_animation_fixed(_mamodel,_maanim,_imgcut,_atlas_surface)
    _anim.frame_count = 28
    show_message(_anim.frame_count)
    _bounds.width = round(_bounds.width)


    
    var savesurf = surface_create( round(_bounds.width*(_anim.frame_count) ),_bounds.height+400 )
    
    surface_set_target(savesurf)
    
    for (var i = 0; i < _anim.frame_count; i++) {
    	bc_draw_baked_frame_atlas_new_fixed(_anim,i,_atlas_surface,_bounds.width*(i+1),_bounds.height+48,1)
    }
    
    surface_reset_target()
    surface_save(savesurf,$"{_export_name}_{_bounds.width}_{_anim.frame_count-3}.png")
    
    surface_free(_atlas_surface)
    surface_free(savesurf)
}

/*
export_anim(
    "skill019",
    "skill019",
    "skill_guard_e",
    "skill_guard_e_breaker",
    "bguard"
)
*/

//
global.warp_in = {
    opacity:[ 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0 ],
    py:[ 0,-139,-187,-217,-236,-247,-250,-250,-250,-250,-250,-250,-250,-250,-251,-251,-251,-252,-255,-264,-300,-388,-420,-443,-460,-474,-484,-491,-496,-499,-500,-500,-500 ],
    scale:[ 1,1,1,1,1,1,1,1,1,1,1,0.62,0.51,0.45,0.42,0.41,0.40,0.40,0.40,0.40,0.40,0.10,0.23,0.23,0.23,0.23,0.23,0.23,0.23,0.23,0.23,0.23,0.23 ],
    frames:33
}
global.warp_out = {
    opacity:[ 0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 ],
    py:[ 0,0,0,0,0,0,0,-350,-281,-212,-143,-73,-49,-39,-31,-25,-19,-14,-9,-5,0,0,0 ],
    scale:[ 1,1,1,1,1,0.30,0.31,0.34,0.39,0.47,0.60,0.96,0.98,0.99,1.00,1.00,1,1,1.02,1.01,1,1,1 ],
    frames:23
}
//

enum KNOCKACK_TYPE {
    NORMAL,
    HEALTH,
    BOSS
}

enum UNIT_STATE{
    IDLE,
    MOVE,
    ATTACK,
    KNOCKBACK,
    WARP,
    ZOMBIE_DEAD,
    ZOMBIE_DEAD_KNOCKBACK,
    ZOMBIE_BURROW_DOWN,
    ZOMBIE_BURROW_MOVE,
    ZOMBIE_BURROW_UP
}

enum ATK_TYPE{
    SINGLE,
    AREA,
    LONG,
    OMNI
}

enum UNIT_TYPE{
    CAT,
    DOG
}

enum U_TRAIT {
    RED,
    FLOATING,
    DARK,
    METAL,
    ANGEL,
    ALIEN,
    ZOMBIE,
    AKU,
    RELIC,
    TRAITLESS,
    BASE
}

enum U_SPEC_TRAIT {
    EVA_ANGEL,
    WITCH,
    COLOSSUS,
    BEHEMOTH,
    SAGE,
    SUPERVILLAIN,
}

enum U_ABILITIES {
    TARGET_ONLY = 1,
    RESISTANT = 2,
    INSANELY_TOUGH = 4,
    MASSIVE_DAMAGE = 8,
    INSANE_DAMAGE = 16,
    BASE_DESTROYER = 32,
    EXTRA_MONEY = 64,
    METAL = 128,
    SURVIVE = 256,
    COUNTER_SURGE = 512,
    WAVE_SHIELD = 1024,
    CONJURE = 2048,
    AKU_SHIELD = 4096,
    ALN_BARRIER = 8192,
    DEATH_SURGE = 16384,
    STRONG_AGAINST = 32768,
    ZOMBIE_REVIVE = 65536,
    ZOMBIE_BURROW = 131072
}

enum U_RESISTS {
    WEAKEN = 1,
    FREEZE = 2,
    SLOW = 4,
    KNOCKBACK = 8,
    WAVE = 16,
    SURGE = 32,
    EXPLOSION = 64,
    WARP = 128,
    CURSE = 256,
    TOXIC = 512,
    BOSS_WAVE = 1024
}

enum U_KILLER {
    ZOMBIE_KILLER = 1,
    WITCH_KILLER = 2,
    EVA_KILLER = 4,
    COLOSSUS_KILLER = 8,
    CORPSE_KILLER = 16,
    SAGE_SLAYER = 32,
    VILLAIN_SLAYER = 64,
    BEHEMOTH_SLAYER = 128
}

enum U_EFFECTS {
    WEAKEN = 1,
    FREEZE = 2,
    SLOW = 4,
    KNOCKBACK = 8,
    WARP = 16,
    CURSE = 32,
    DODGE = 64,
    STRENGTHEN = 128,
    CRITICAL = 256,
    METAL_KILLER = 512,
    BARRIER_BREAKER = 1024,
    SHIELD_BREAKER = 2048,
    SAVAGE_BLOW = 4096,
    KAMIKAZE = 8192,
    TOXIC = 16384
}

enum DAMAGE_TYPE {
    NORMAL,
    WAVE,
    SURGE,
    EXPLOSION
}

#macro SHOW_BARRIER_HIT 4096
#macro SHOW_SHIELD_HIT 8192
#macro SHOW_EFFECT_IMMUNITY 16384
#macro SHOW_EFFECT_IMMUNITY_TO_SPECATK 32768

enum U_SPEC_ATTACKS {
    MINI_WAVE = 1,
    WAVE = 2,
    MINI_SURGE = 4,
    SURGE = 8,
    EXPLOSION = 16
}




function unit(_unitid,_unitform,_type = UNIT_TYPE.CAT,_anim_multi = 0,_burrow = false) constructor 
{
    type = _type
    
    var _rid = string(_unitid)
    while (string_length(_rid)<3) {
        _rid = "0"+_rid
    }
    
    var _ftypes = ["f","c","s","u"]
    
    
    if _type == UNIT_TYPE.CAT{
        var _path = "E:\\unit\\" + _rid + "\\" + _ftypes[_unitform] + "\\"
        var _main_name = _rid+"_"+_ftypes[_unitform]
    }
    else {
        var _path = "E:\\enemy\\" + _rid + "\\"
        var _main_name = _rid+"_e"
    }
    
    var _sheet_path = _path + _main_name + ".png"
    
    var _imgcut_path = _path + _main_name + ".imgcut"
    var _mamodel_path = _path + _main_name + ".mamodel"
    
    var _maanim_idle_path = _path + _main_name + "01.maanim"
    var _maanim_move_path = _path + _main_name + "00.maanim"
    var _maanim_attk_path = _path + _main_name + "02.maanim"
    var _maanim_knoc_path = _path + _main_name + "03.maanim"
    
    if _burrow{
        var _maanim_burrow_down_path = _path + _main_name + "_zombie00.maanim"
        var _maanim_burrow_up_path = _path + _main_name + "_zombie02.maanim"
    }
    
    var _scale = 2
    
    var _sheet = sprite_add(_sheet_path, 1, false, false, 0, 0);
    atlas_surface = surface_create(sprite_get_width(_sheet)*_scale, sprite_get_height(_sheet)*_scale);
    var _blend_surface = surface_create(sprite_get_width(_sheet), sprite_get_height(_sheet));
    
    gpu_set_tex_filter(false)
    
    surface_set_target(_blend_surface);
    draw_clear_alpha(c_black, 0);
    
    if SURFACE_HROMAKEY_OPTIMIZE{
        gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_zero, bm_one); 
        
        draw_sprite_ext(_sheet, 0,  1,  0, 1, 1, 0, c_white, 1);
        draw_sprite_ext(_sheet, 0, -1,  0, 1, 1, 0, c_white, 1);
        draw_sprite_ext(_sheet, 0,  0,  1, 1, 1, 0, c_white, 1);
        draw_sprite_ext(_sheet, 0,  0, -1, 1, 1, 0, c_white, 1);
    }
    
    gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_one, bm_inv_src_alpha);
    draw_sprite_ext(_sheet, 0, 0, 0, 1, 1, 0, c_white, 1);
    
    surface_reset_target();
    
    surface_set_target(atlas_surface)
    
    draw_clear_alpha(c_black, 0);
    gpu_set_tex_filter(true)
    gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha)
    draw_surface_ext(_blend_surface,0,0,2,2,0,c_white,1)
    gpu_set_blendmode(bm_normal)
    
    surface_reset_target()
    
    var _surf_width = surface_get_width(atlas_surface);
    var _surf_height = surface_get_height(atlas_surface);
    
    atlas_backup = buffer_create(_surf_width * _surf_height * 4, buffer_fixed, 1);
    atlas_size = [_surf_width,_surf_height]
    
    buffer_get_surface(atlas_backup, atlas_surface, 0);

    surface_free(_blend_surface)
    sprite_delete(_sheet);
    
    
    var _imgcut  = bc_load_imgcut(_imgcut_path);
    var _mamodel = bc_load_mamodel(_mamodel_path);
    var _maanim_idle = bc_load_maanim(_maanim_idle_path)
    var _maanim_move = bc_load_maanim(_maanim_move_path)
    var _maanim_attk = bc_load_maanim(_maanim_attk_path)
    var _maanim_kb = bc_load_maanim(_maanim_knoc_path)
    
    
    height = bc_compute_bounds(_mamodel,_maanim_idle,_imgcut,0.5).height
    
    idle_anim = bc_bake_animation_fixed(_mamodel,_maanim_idle,_imgcut,atlas_surface,,_anim_multi)
    move_anim = bc_bake_animation_fixed(_mamodel,_maanim_move,_imgcut,atlas_surface,,_anim_multi)
    atk_anim = bc_bake_animation_fixed(_mamodel,_maanim_attk,_imgcut,atlas_surface)
    kb_anim = bc_bake_animation_fixed(_mamodel,_maanim_kb,_imgcut,atlas_surface)
    
    if _type == UNIT_TYPE.DOG{
        limit = ((_mamodel.confs[0][2] - _mamodel.parts[0][6]) * _mamodel.parts[0][8]) / _mamodel.ints[0]
    }
    else {
    	limit = ((_mamodel.confs[1][2] - _mamodel.parts[0][6]) * _mamodel.parts[0][8]) / _mamodel.ints[0]
        price = 0 //for sending
        cooldown = 0 //for sending
    }
    limit = floor( limit * 0.5 )
    
    if _burrow{
        var _maanim_burrow_up = bc_load_maanim(_maanim_burrow_up_path)
        var _maanim_burrow_down = bc_load_maanim(_maanim_burrow_down_path)
        
        burrow_up_anim = bc_bake_animation_fixed(_mamodel,_maanim_burrow_up,_imgcut,atlas_surface)
        burrow_down_anim = bc_bake_animation_fixed(_mamodel,_maanim_burrow_down,_imgcut,atlas_surface)
    }
    
    dmg = 1
    knockbacks = 1
    atktype = ATK_TYPE.SINGLE
    range = 1
    attacks = 1
    life = 1
    atkspd = 0
    spd = 0.1
    
    if _type == UNIT_TYPE.DOG{
        traits = []
        traits_number = 0
        spectraits = []
        spectraits_number = 0
        cash = 0
    }
    
    if _type == UNIT_TYPE.CAT{
        targets = []
        targets_number = 0
    }
    
    abilities = 0
    abilities_data = {}
    effects = 0
    effects_data = {}
    resists = 0
    resist_percent = {}
    killer = 0
    killer_data = {}
    specattacks = 0
    specattacks_data = {}
    effectonattacks = 0 // 0 - all attacks have effect 
    
    static SetCooldown = function(_amount){
        cooldown = _amount
        
        return self
    }
    
    static SetPrice = function(_amount){
        price = _amount
        
        return self
    }
    
    static AddBurrow = function(_amount,_distance){
        abilities |= U_ABILITIES.ZOMBIE_BURROW
        
        abilities_data.burrow = { amount: _amount, distance:_distance/5 }
    }
    
    static AddRevives = function(_amount,_hp_percent,_time){
        abilities |= U_ABILITIES.ZOMBIE_REVIVE
        
        abilities_data.revive = { amount: _amount, percent: _hp_percent/100, time: _time }
    }
    
    static SetCashDrop = function(_value){
        cash = _value
        
        return self
    }
    
    static SetEffectOnAttacks = function(_value){
        effectonattacks = _value
        
        return self
    }
    
    static AddDeathSurge = function(_chance,_lvl,_range,_type = U_SPEC_ATTACKS.SURGE){
        abilities |= U_ABILITIES.DEATH_SURGE
        
        if is_array(_range){
            for(var i = 0; i < array_length(_range); i++){
                _range[i] /=5
            }
        }
        else{
            _range /= 5
        }
        
        abilities_data.death_surge = { chance: _chance, lvl: _lvl, range: _range, type : _type }
    
        return self
    }

    static AddAlienBarrier = function(_health){
        abilities |= U_ABILITIES.ALN_BARRIER
        abilities_data.barrier = { hp: _health }
        
        return self
    }

    static AddAkuShield = function(_health,_health_percent_regenration){
        abilities |= U_ABILITIES.AKU_SHIELD
        abilities_data.aku_shield = { hp: _health, regen: _health_percent_regenration/100 }
    
        return self
    }

    static AddConjure = function(_conjureid){
        abilities |= U_ABILITIES.CONJURE
        abilities_data.conjure = { myid : _conjureid }
        
        return self
    }

    static AddWaveShield = function(){
        abilities |= U_ABILITIES.WAVE_SHIELD
        
        return self
    }

    static AddCounterSurge = function(_chance = 100){
        abilities |= U_ABILITIES.COUNTER_SURGE
        
        abilities_data.counter_surge = { chance: _chance }
        
        return self
    }

    static AddMetal = function(){
        abilities |= U_ABILITIES.METAL
        
        return self
    }

    static AddExtraMoney = function(){
        abilities |= U_ABILITIES.EXTRA_MONEY
        
        return self
    }

    static AddBaseDestroyer = function(){
        abilities |= U_ABILITIES.BASE_DESTROYER
        
        return self
    }
    
    static AddStrongAgainst = function (){
        abilities |= U_ABILITIES.STRONG_AGAINST
        
        return self
    }

    static AddSurvive = function(_chance,_health_percent = 0){
        abilities |= U_ABILITIES.SURVIVE
        abilities_data.survive = { chance:_chance, percent:_health_percent }
        
        return self
    }

    static AddInsaneDamage = function(){
        abilities |= U_ABILITIES.INSANE_DAMAGE
        
        return self
    }

    static AddMassiveDamage = function(){
        abilities |= U_ABILITIES.MASSIVE_DAMAGE
        
        return self
    }

    static AddInsanelyTough = function(){
        abilities |= U_ABILITIES.INSANELY_TOUGH
        
        return self
    }

    static AddResists = function(){
        abilities |= U_ABILITIES.RESISTANT
        
        return self
    }
    
    static AddTargetOnly = function(){
        abilities |= U_ABILITIES.TARGET_ONLY
        
        return self
    }

    static AddBossWaveImmune = function(){
        resists |= U_RESISTS.BOSS_WAVE
        
        return self 
    }


    static AddSavageBlow = function(_chance,_multiplier = 3){
        effects |= U_EFFECTS.SAVAGE_BLOW
        effects_data.savage_blow = { chance:_chance, multiplier:_multiplier }
        
        return self
    }

    static AddShieldBreaker = function(_chance){
        effects |= U_EFFECTS.SHIELD_BREAKER
        effects_data.shield_breaker = { chance:_chance}
        
        return self
    }

    static AddBarrierBreaker = function(_chance){
        effects |= U_EFFECTS.BARRIER_BREAKER
        effects_data.barrier_breaker = { chance:_chance }
    
        return self
    }

    static AddToxic = function(_chance,_percent){
        effects |= U_EFFECTS.TOXIC
        effects_data.toxic = { chance:_chance, percent: _percent }
        
        return self
    }

    static AddMetalKiller = function(_chance,_percent){
        effects |= U_EFFECTS.METAL_KILLER
        effects_data.metal_killer = { chance:_chance, percent:_percent }
    
        return self
    }

    static AddCritical = function(_chance){
        effects |= U_EFFECTS.CRITICAL
        effects_data.critical = { chance:_chance }
        
        return self
    }
    
    static AddStrengthen = function(_health,_multiplier){
        effects |= U_EFFECTS.STRENGTHEN
        effects_data.strengthen = { threshold:_health, multiplier: _multiplier }
    
        return self
    }

    static AddDodge = function(_chance,_time){
        effects |= U_EFFECTS.DODGE
        effects_data.dodge = { chance:_chance, time:_time }
    
        return self
    }

    static AddCurse = function(_chance,_time){
        effects |= U_EFFECTS.CURSE
        effects_data.curse = { chance:_chance, time:_time } 
    
        return self
    }

    static AddWarp = function(_chance,_time,_distance){
        effects |= U_EFFECTS.WARP
        effects_data.warp = { chance:_chance, time:_time, distance:_distance }
    
        return self
    }

    static AddKnockback = function(_chance,_distance = 165,_time = 12){
        effects |= U_EFFECTS.KNOCKBACK
        effects_data.knockback = { chance:_chance, distance:_distance/5, time:_time }
    
        return self
    }

    static AddSlow = function(_chance,_time,_percent = 99){
        effects |= U_EFFECTS.SLOW
        effects_data.slow = { chance:_chance, time:_time, percent: _percent/100 }
    
        return self
    }

    static AddFreeze = function(_chance,_time){
        effects |= U_EFFECTS.FREEZE
        effects_data.freeze = { chance:_chance, time:_time }
    
        return self
    }

    static AddWeaken = function(_chance,_time,_percent){
        effects |= U_EFFECTS.WEAKEN
        effects_data.weaken = { chance:_chance, time:_time, percent:_percent }
    
        return self
    }
    
    static AddKamikaze = function(){
        effects |= U_EFFECTS.KAMIKAZE
        
        return self
    }
    
    static AddZombieKiller = function(){
        killer |= U_KILLER.ZOMBIE_KILLER
        
        return self
    }
    
    static AddWitchKiller = function(){
        killer |= U_KILLER.WITCH_KILLER
        
        return self
    }
    
    static AddEvaKiller = function(){
        killer |= U_KILLER.EVA_KILLER
        
        return self
    }
    
    static AddCollosusSlayer = function(){
        killer |= U_KILLER.COLOSSUS_KILLER
        
        return self
    }
    
    static AddCorpseKiller = function(){
        killer |= U_KILLER.CORPSE_KILLER
        
        return self
    }
    
    static AddSageSlayer = function(){
        killer |= U_KILLER.SAGE_SLAYER
        
        return self
    }
    
    static AddVillainSlayer = function(){
        killer |= U_KILLER.VILLAIN_SLAYER
        
        return self
    }
    
    static AddBehemothSlayer = function(_dodge_chance,_dodge_time){
        killer |= U_KILLER.BEHEMOTH_SLAYER
        killer_data.behemoth_slayer = { chance: _dodge_chance, time: _dodge_time }
    
        return self
    }
    
    static AddResistEffect = function(_type,_percent){
        resists |= _type
        
        var _name = ""
        
        switch(_type){
            case U_RESISTS.WEAKEN: _name = "weaken" break;
            case U_RESISTS.FREEZE: _name = "freeze" break;
            case U_RESISTS.SLOW: _name = "slow" break;
            case U_RESISTS.KNOCKBACK: _name = "knockback" break;
            case U_RESISTS.WAVE: _name = "wave" break;
            case U_RESISTS.SURGE: _name = "surge" break;
            case U_RESISTS.EXPLOSION: _name = "explosion" break;
            case U_RESISTS.WARP: _name = "warp" break;
            case U_RESISTS.CURSE: _name = "curse" break;
            case U_RESISTS.TOXIC: _name = "toxic" break;
        }
        
        resist_percent[$ _name] = _percent
        
        return self
    }

    static AddExplosion = function(_chance,_range){
        specattacks |= U_SPEC_ATTACKS.EXPLOSION
        
        if is_array(_range){
            for(var i = 0; i < array_length(_range); i ++){
                _range[i] /= 5
            }
        }
        else{
            _range/=5
        }
        
        specattacks_data.explosion = { chance:_chance, range:_range }
        return self
    }
    
    static AddMiniSurge = function(_level,_chance,_range){
        
        if is_array(_range){
            for(var i = 0; i < array_length(_range); i ++){
                _range[i] /= 5
            }
        }
        else{
            _range/=5
        }
        
        specattacks |= U_SPEC_ATTACKS.MINI_SURGE
        specattacks_data.mini_surge = { lvl:_level, chance:_chance, range:_range }
        return self
    }
    
    static AddSurge = function(_level,_chance,_range){
        
        if is_array(_range){
            for(var i = 0; i < array_length(_range); i ++){
                _range[i] /= 5
            }
        }
        else{
            _range/=5
        }
        
        specattacks |= U_SPEC_ATTACKS.SURGE
        specattacks_data.surge = { lvl:_level, chance:_chance, range:_range }
        return self
    }
    
    static AddMiniWaveAttack = function(_level,_chance){
        specattacks |= U_SPEC_ATTACKS.MINI_WAVE
        specattacks_data.mini_wave = { lvl:_level, chance:_chance }
        return self
    }
    
    static AddWaveAttack = function(_chance,_level){
        self.specattacks |= U_SPEC_ATTACKS.WAVE
        self.specattacks_data.wave = { lvl:_level, chance:_chance }
        return self
    }
    
    static SetTraits = function(_value){
        traits = _value
        traits_number = array_length(_value)
        return self
    }
    
    static SetSpecTraits = function(_value){
        spectraits = _value
        spectraits_number = array_length(_value)
        return self
    }
    
    static SetTargets = function(_value){
        targets = _value
        targets_number = array_length(_value)
        return self
    }
    
    static SetHp = function (_value){
        life = _value
        return self
    }
    static SetDmg = function (_value){
        dmg = _value
        
        dmgnumber = 1
        
        if is_array(_value){
            dmgnumber = array_length(_value)
        }
        
        return self
    }
    static SetKnockback = function (_value){
        knockbacks = _value
        return self
    }
    static SetAttackTypeSingle = function (){
        atktype = ATK_TYPE.SINGLE
        return self
    }
    static SetAttackTypeArea = function (){
        atktype = ATK_TYPE.AREA
        return self
    }
    static SetAttackTypeLongRange = function (_ranges){
        atktype = ATK_TYPE.LONG
        distances = _ranges
        
        for (var i = 0; i < array_length(distances); i++) {
        	if is_array(distances[i]){
                for (var c = 0; c < array_length(distances[i]); c++) {
                	distances[i][c] = distances[i][c]/5
                }
            }
            else {
            	distances[i] = distances[i]/5
            }
        }
        
        distances_number = is_array(_ranges[0]) ? array_length(_ranges) : 1
        
        return self
    }
    static SetAttackTypeOmniStrike = function (_ranges){
        atktype = ATK_TYPE.OMNI
        distances = _ranges
        
        for (var i = 0; i < array_length(distances); i++) {
        	if is_array(distances[i]){
                for (var c = 0; c < array_length(distances[i]); c++) {
                	distances[i][c] = distances[i][c]/5
                }
            }
            else {
            	distances[i] = distances[i]/5
            }
        }
        
        distances_number = is_array(_ranges[0]) ? array_length(_ranges) : 1
        return self
    }
    static SetRange = function (_value){
        range = _value/5
        return self
    }
    static SetAttackFrame = function (_value){
        attacks = _value
        return self
    }
    static SetAtkSpd = function (_value){
        atkspd = _value
        return self
    }
    static SetSpeed = function (_value){
        spd = _value/10
        return self
    }
    
    
}

global.units = {
}

global.enemies = {
}

#region UNITS
var _cat = new unit(0,0)
                _cat.SetHp(100).SetKnockback(3)
                _cat.SetDmg(8).SetRange(140)
                _cat.SetAttackFrame(8).SetAtkSpd(30)
                _cat.SetSpeed(10)

global.units.cat = _cat

var _cat = new unit(0,0)
                _cat.SetHp(100).SetKnockback(3)
                _cat.SetDmg(50).SetRange(140)
                _cat.SetAttackFrame(8).SetAtkSpd(10)
                _cat.SetSpeed(65).AddZombieKiller()
                

global.units.cat2 = _cat

var _cat = new unit(1,0)
                _cat.SetHp(400).SetKnockback(3)
                _cat.SetDmg(35).SetRange(140)
                _cat.SetAttackFrame(8).SetAtkSpd(80)
                _cat.SetSpeed(8)

global.units.tank2 = _cat

var _cat = new unit(33,0)
                _cat.SetHp(400).SetKnockback(1)
                _cat.SetDmg(2).SetAttackTypeArea().SetRange(110)
                _cat.SetAttackFrame(8).SetAtkSpd(4)
                _cat.SetSpeed(10)
                _cat.SetTargets([U_TRAIT.TRAITLESS])
                    
global.units.wall_cat = _cat

var _cat = new unit(73,0)
                _cat.SetHp(1000).SetKnockback(5)
                _cat.SetDmg(1).SetRange(110)
                _cat.SetAttackFrame(82).SetAtkSpd(30)
                _cat.SetSpeed(25)
                _cat.AddCounterSurge()
                //_cat.AddAlienBarrier(25000)
                //_cat.AddAkuShield(200,100)
                    
global.units.testlr = _cat


#endregion

#region ENEMIES

var _doge = new unit(0,0,UNIT_TYPE.DOG)
                    _doge.SetHp(90).SetKnockback(3)
                    _doge.SetDmg(6).SetRange(110)
                    _doge.SetAttackFrame(8).SetAtkSpd(5)
                    _doge.SetTraits([U_TRAIT.TRAITLESS])
                    _doge.AddBarrierBreaker(15)
                    //_doge.AddWaveAttack(100,8)
                    //_doge.AddSurge(5,100,400)
                    //_doge.AddExplosion(100,400)
                    //_doge.AddMiniWaveAttack(12,100)
                    //_doge.AddCritical(100).AddSavageBlow(100)
                    _doge.SetSpeed(5)

                        
global.enemies.doge = _doge

var _doge = new unit(1,0,UNIT_TYPE.DOG)
                    _doge.SetHp(100).SetKnockback(3)
                    _doge.SetDmg(15).SetRange(110)
                    _doge.SetAttackFrame(8).SetAtkSpd(30)
                    _doge.SetTraits([U_TRAIT.TRAITLESS])
                    _doge.SetSpeed(8)
                        
global.enemies.snache = _doge

var _doge = new unit(2,0,UNIT_TYPE.DOG)
                    _doge.SetHp(200).SetKnockback(1)
                    _doge.SetDmg(1).SetRange(110)
                    _doge.SetAttackTypeOmniStrike([50,220])
                    _doge.SetAttackFrame(10).SetAtkSpd(5)
                    _doge.SetTraits([U_TRAIT.TRAITLESS])
                    _doge.SetSpeed(25)
                    _doge.AddKnockback(100,650)
                        
global.enemies.those_guys = _doge


var _doge = new unit(284,0,UNIT_TYPE.DOG,,true)
                    _doge.SetHp(100).SetKnockback(3)
                    _doge.SetDmg(15).SetRange(110)
                    _doge.SetAttackFrame(8).SetAtkSpd(30)
                    _doge.SetTraits([U_TRAIT.ZOMBIE])
                    _doge.SetSpeed(8)
                    _doge.AddDeathSurge(100,4,100)
                        
global.enemies.zoge = _doge

#endregion

