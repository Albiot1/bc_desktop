/// @function bc_bake_animation(model, maanim, imgcut)
/// @desc Runs the whole clip once (frames 0..max) using a scratch ents
///       array (doesn't touch any live player), and returns the baked
///       struct described above. Call once, cache/save the result -
///       this is not meant to run every frame.
#macro BC_BAKE_F_X 0
#macro BC_BAKE_F_Y 1
#macro BC_BAKE_F_X1 2
#macro BC_BAKE_F_Y1 3
#macro BC_BAKE_F_X2 4
#macro BC_BAKE_F_Y2 5
#macro BC_BAKE_F_X3 6
#macro BC_BAKE_F_Y3 7
#macro BC_BAKE_F_U 8
#macro BC_BAKE_F_V 9 
#macro BC_BAKE_F_U1 10
#macro BC_BAKE_F_V1 11
#macro BC_BAKE_F_OPACITY 12
#macro BC_BAKE_F_COLOR 13
#macro BC_BAKE_F_GLOW 14

function bc_bake_animation_fixed(_model, _maanim, _imgcut, _atlas_surface,_loops = false,_start = 0) {
    
	var _ents = bc_ent_setup(_model);
	var _n = array_length(_ents);
    
    var _frame_count = _maanim.max + 1;
    
    if _start==1{
        _frame_count *=2
    }
    
	var _frames = array_create(_frame_count);
    var _sw = surface_get_width(_atlas_surface)
    var _sh = surface_get_height(_atlas_surface)
    
var _fr = 0
	for (var f = 0; f < (_frame_count+2); f++) {
		bc_maanim_update(_maanim, _ents, _model, f, _loops);
        
		var _cache = array_create(_n, undefined);
		var _size_cache = array_create(_n, undefined);
		var _opa_cache = array_create(_n, undefined);
		var _order = bc_sort_ents_by_z(_ents);
		var _parts = [];

		for (var oi = 0; oi < _n; oi++) {
			var _idx = _order[oi];
			var _e = _ents[_idx];

			if (_e.img < 0 || _e.mid < 0) continue;
			if (_e.img >= _imgcut.n) continue;

			var _alpha = bc_ent_opa(_ents, _model, _idx, _opa_cache);
			if (_alpha <= 0) continue;

			var _cut = _imgcut.cuts[_e.img];
			var _mag = bc_get_size(_ents, _model, _idx, _size_cache); // NOTE: global_scale = 1, baked scale-independent
			var _magx = _mag[0], _magy = _mag[1];
			var _m = bc_get_world_matrix(_ents, _model, _idx, 1, _cache, _size_cache);

			var _entry = array_create(11);
            
            var _col = c_white
            if _e.glow == 3{
                var _g = clamp(_alpha * _alpha, 0, 1)
    			var _gv = round(_g * 255)
    			_col = make_colour_rgb(_gv, _gv, _gv)
                _alpha = 1
            }
            
			_entry[BC_BAKE_F_OPACITY] = _alpha;
			_entry[BC_BAKE_F_GLOW] = _e.glow;
            _entry[BC_BAKE_F_COLOR] = _col;
            
    		var _cutx = _cut[0]
    		var _cuty = _cut[1]
    		var _cutw = _cut[2]
    		var _cuth = _cut[3]

            var _px,_py,_sx,_sy,_rad;
            
			if (_e.extType == 1) {
				_px = _m.tx; 
				_py = _m.ty;
				_rad = degtorad(0)
				_sx = _magx
				_sy = _magy
			} else if (_e.extendX != 0 || _e.extendY != 0) {
				var _dec0 = bc_mat_decompose(_m);
				var _lx0 = -_e.pivx * _magx
				var _ly0 = -_e.pivy * _magy;
				_px = _m.a * _lx0 + _m.c * _ly0 + _m.tx;
				_py = _m.b * _lx0 + _m.d * _ly0 + _m.ty;
				_rad = degtorad(_dec0.angle)
				_sx = _magx
				_sy = _magy * _dec0.yflip;
			} else {
				var _dec = bc_mat_decompose(_m);
				var _lx = -_e.pivx * _magx, _ly = -_e.pivy * _magy;
				_px = _m.a * _lx + _m.c * _ly + _m.tx;
			    _py = _m.b * _lx + _m.d * _ly + _m.ty;
			    _rad = degtorad(_dec.angle)
			    _sx = _magx
			    _sy = _magy * _dec.yflip;
			}
			
			var _ca = cos(_rad), _sa = sin(_rad);
			
    		var _ex = _ca * (_cutw * _sx), _ey = _sa * (_cutw * _sx); // "width" edge, rotated
    		var _fx = -_sa * (_cuth * _sy), _fy = _ca * (_cuth * _sy); // "height" edge, rotated
            
    		var _x0 = _px,             _y0 = _py;
    		var _x1 = _px + _ex,       _y1 = _py + _ey;
    		var _x2 = _px + _ex + _fx, _y2 = _py + _ey + _fy;
    		var _x3 = _px + _fx,       _y3 = _py + _fy;
    
    		var _u0 = _cutx / _sw, _v0 = _cuty / _sh;
    		var _u1 = (_cutx + _cutw) / _sw, _v1 = (_cuty + _cuth) / _sh;
            
            _u0*=2
            _u1*=2
            _v0*=2
            _v1*=2
            
            _entry[BC_BAKE_F_X] = _x0
            _entry[BC_BAKE_F_Y] = _y0
            _entry[BC_BAKE_F_X1] = _x1
            _entry[BC_BAKE_F_Y1] = _y1
            _entry[BC_BAKE_F_X2] = _x2
            _entry[BC_BAKE_F_Y2] = _y2
            _entry[BC_BAKE_F_X3] = _x3
            _entry[BC_BAKE_F_Y3] = _y3
            _entry[BC_BAKE_F_V] = _v0
            _entry[BC_BAKE_F_U] = _u0
            _entry[BC_BAKE_F_V1] = _v1
            _entry[BC_BAKE_F_U1] = _u1

			array_push(_parts, _entry);
		}

		_frames[_fr] = _parts;
        _fr++
	}

	return {
		part_count: _model.n,
		frame_count: _frame_count,
		frames: _frames
	};
}

// ---------- playback path 1: pre-sliced sprites ----------

/// @function bc_draw_baked_frame_atlas(baked, frame_index, atlas_surface, x, y, scale)
/// @desc Same as bc_draw_baked_frame, but samples the atlas surface
///       directly using each entry's embedded cutx/cuty/cutw/cuth - the
///       .imgcut file isn't needed at all for this path, only the baked
///       JSON and the loaded atlas surface. Reconstructs the quad's 4
///       corners from the baked (x,y,angle,sx,sy) since there's no
///       per-cut sprite to hand to draw_sprite_ext here.
function bc_draw_baked_frame_atlas_new_fixed(_baked, _frame_index, _atlas_surface, _x, _y, _scale,_alpha = 1) {
	if (_frame_index < 0 || _frame_index >= array_length(_baked.frames)) return;
	if (!surface_exists(_atlas_surface)) {
		show_debug_message("bc_draw_baked_frame_atlas: atlas surface doesn't exist");
		return;
	}

	var _tex = surface_get_texture(_atlas_surface);

	var _parts = _baked.frames[_frame_index];
	for (var i = 0; i < array_length(_parts); i++) {
		var _pd = _parts[i];
		var _glow = _pd[BC_BAKE_F_GLOW];
		var _opacity = _pd[BC_BAKE_F_OPACITY];
        var _col = _pd[BC_BAKE_F_COLOR];
        var _x0 = _x + _pd[BC_BAKE_F_X]*_scale
        var _y0 = _y + _pd[BC_BAKE_F_Y]*_scale
        var _x1 = _x + _pd[BC_BAKE_F_X1]*_scale
        var _y1 = _y + _pd[BC_BAKE_F_Y1]*_scale
        var _x2 = _x + _pd[BC_BAKE_F_X2]*_scale
        var _y2 = _y + _pd[BC_BAKE_F_Y2]*_scale
        var _x3 = _x + _pd[BC_BAKE_F_X3]*_scale
        var _y3 = _y + _pd[BC_BAKE_F_Y3]*_scale
		var _u0 = _pd[BC_BAKE_F_U]
        var _v0 = _pd[BC_BAKE_F_V]
		var _u1 = _pd[BC_BAKE_F_U1]
        var _v1 = _pd[BC_BAKE_F_V1]
        
        
        switch (_glow) {
        	case 1:
                gpu_set_blendequation(bm_eq_add);
			    gpu_set_blendmode_ext(bm_src_alpha, bm_one);
                
			    if SURFACE_HROMAKEY_OPTIMIZE
			    gpu_set_colorwriteenable(true, true, true, false); 
                
                
                //for teleport part on surface!!
                //gpu_set_blendequation(bm_eq_add);
                //gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_one, bm_src_colour, bm_one);
                //
                

            break;
            case -1:
                gpu_set_blendequation(bm_eq_reverse_subtract);
			    gpu_set_blendmode_ext(bm_src_alpha, bm_one);
			    
			    if SURFACE_HROMAKEY_OPTIMIZE
			    gpu_set_colorwriteenable(true, true, true, false); 
            break;
            case 2:
                gpu_set_blendequation(bm_eq_add);
                gpu_set_blendmode_ext(bm_zero, bm_src_colour);
                shader_set(global.bc_shd_glow2);
                shader_set_uniform_f(global.bc_shd_glow2_u_para, _opacity * _alpha);
                
                if SURFACE_HROMAKEY_OPTIMIZE
                gpu_set_colorwriteenable(true, true, true, false); 
            break;
            case 3:
    			gpu_set_blendequation(bm_eq_add);
    			gpu_set_blendmode_ext(bm_inv_dest_colour, bm_one);
    			
    			if SURFACE_HROMAKEY_OPTIMIZE
    			gpu_set_colorwriteenable(true, true, true, false); 
            default:
    			gpu_set_blendmode(bm_normal);
    			gpu_set_colorwriteenable(true, true, true, true);
            break;
        }

		bc_draw_quad_tex_raw(_tex, _x0, _y0, _x1, _y1, _x2, _y2, _x3, _y3, _u0, _v0, _u1, _v1, _col,_opacity * _alpha);

    	if (_glow == 2) shader_reset();
    	gpu_set_blendequation(bm_eq_add);
    	gpu_set_blendmode(bm_normal);
    	gpu_set_colorwriteenable(true, true, true, true);
	}
}
