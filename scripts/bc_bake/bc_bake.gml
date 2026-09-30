// ============================================================
// bc_bake.gml
// Precomputes a whole .maanim clip into plain per-frame draw data, so a
// consumer (this project or another tool entirely) can play it back by
// just applying numbers - no keyframe interpolation, no easing, no
// parent-hierarchy walk, no opacity cascade.
//
// Requires bc_render.gml's bc_ent_setup/bc_maanim_update/bc_sort_ents_by_z/
// bc_ent_opa/bc_get_size/bc_get_world_matrix/bc_glow_begin/bc_glow_end/
// bc_glow_needs_alpha_stamp/bc_alpha_stamp_begin/bc_alpha_stamp_end/
// bc_draw_quad_tex_raw to already be loaded (baking and glow both reuse
// that logic rather than duplicating it).
//
// Baked JSON shape:
// {
//   part_count: <int>,
//   frame_count: <int>,          // maanim.max + 1
//   frames: [
//     [ [p, img, cutx, cuty, cutw, cuth, x, y, angle, sx, sy, opacity, glow, special], ... ],
//     ...
//   ]
// }
//
// Per-part entries are fixed-order ARRAYS rather than named-key structs -
// JSON repeats every key name in every object, which adds up fast across
// many frames x many parts. Arrays drop all of that overhead; use the
// BC_BAKE_* macros below instead of magic numbers when reading them.
//
//   BC_BAKE_P        mamodel part index
//   BC_BAKE_IMG      imgcut index (-1 never appears - hidden parts are
//                    just omitted from the frame's list entirely)
//   BC_BAKE_CUTX/Y/W/H   raw pixel rect in the ORIGINAL sprite sheet -
//                    embedded so the atlas playback path doesn't need
//                    the .imgcut file at all
//   BC_BAKE_X/Y      world pos of sprite's top-left corner, at scale=1
//   BC_BAKE_ANGLE    degrees
//   BC_BAKE_SX/SY    signed magnitude scale, at scale=1 (negative sy = v-flip)
//   BC_BAKE_OPACITY  0..1, already cascaded through parent chain
//   BC_BAKE_GLOW     raw glow value; both playback functions apply it
//                    via bc_glow_begin/bc_glow_end
//   BC_BAKE_SPECIAL  0 = normal, 1 = extend (tiled/stretched - only
//                    approximated, see bc_render.gml's bc_draw_extend_2d
//                    comment), 2 = curse (random-cycling - frozen to
//                    whichever image the bake happened to roll, since
//                    the real thing is inherently non-deterministic)
//
// Already z-sorted per frame - just iterate each frame's array in order.
// ============================================================

#macro BC_BAKE_CUTX 0
#macro BC_BAKE_CUTY 1
#macro BC_BAKE_CUTW 2
#macro BC_BAKE_CUTH 3
#macro BC_BAKE_X 4
#macro BC_BAKE_Y 5
#macro BC_BAKE_ANGLE 6
#macro BC_BAKE_SX 7
#macro BC_BAKE_SY 8
#macro BC_BAKE_OPACITY 9
#macro BC_BAKE_GLOW 10
#macro BC_BAKE_SPECIAL 11
#macro BC_BAKE_COLOR 12

#macro BC_BAKE_SPECIAL_NONE 0
#macro BC_BAKE_SPECIAL_EXTEND 1
#macro BC_BAKE_SPECIAL_CURSE 2

/// @function bc_mat_decompose(m)
/// @desc Exact for these matrices (always pure rotation, or rotation
///       composed with exactly one axis reflection - see bc_render.gml's
///       header notes on why). Only used here at bake time, not in the
///       live per-frame renderer.
function bc_mat_decompose(_m) {
	var _det = _m.a * _m.d - _m.b * _m.c;
	var _angle = radtodeg(arctan2(_m.b, _m.a)); // arctan2 returns RADIANS - must convert
	var _yflip = (_det < 0) ? -1 : 1;
	return { angle: _angle, yflip: _yflip };
}

/// @function bc_bake_animation(model, maanim, imgcut)
/// @desc Runs the whole clip once (frames 0..max) using a scratch ents
///       array (doesn't touch any live player), and returns the baked
///       struct described above. Call once, cache/save the result -
///       this is not meant to run every frame.
function bc_bake_animation(_model, _maanim, _imgcut) {
	var _ents = bc_ent_setup(_model);
	var _n = array_length(_ents);
	var _frame_count = _maanim.max + 1;
	var _frames = array_create(_frame_count);

	for (var f = 0; f < _frame_count + 2; f++) {
		bc_maanim_update(_maanim, _ents, _model, f, false);

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

			var _entry = array_create(14);
			_entry[BC_BAKE_CUTX] = _cut[0]; _entry[BC_BAKE_CUTY] = _cut[1];
			_entry[BC_BAKE_CUTW] = _cut[2]; _entry[BC_BAKE_CUTH] = _cut[3];
            
            var _col = c_white
            if _e.glow == 3{
                var _g = clamp(_alpha * _alpha, 0, 1)
    			var _gv = round(_g * 255)
    			_col = make_colour_rgb(_gv, _gv, _gv)
                _alpha = 1
            }
            
			_entry[BC_BAKE_OPACITY] = _alpha;
			_entry[BC_BAKE_GLOW] = _e.glow;
            _entry[BC_BAKE_COLOR] = _col;

			if (_e.extType == 1) {
				_entry[BC_BAKE_SPECIAL] = BC_BAKE_SPECIAL_CURSE;
				_entry[BC_BAKE_X] = _m.tx; _entry[BC_BAKE_Y] = _m.ty;
				_entry[BC_BAKE_ANGLE] = 0; _entry[BC_BAKE_SX] = _magx; _entry[BC_BAKE_SY] = _magy;
			} else if (_e.extendX != 0 || _e.extendY != 0) {
				_entry[BC_BAKE_SPECIAL] = BC_BAKE_SPECIAL_EXTEND;
				var _dec0 = bc_mat_decompose(_m);
				var _lx0 = -_e.pivx * _magx, _ly0 = -_e.pivy * _magy;
				_entry[BC_BAKE_X] = _m.a * _lx0 + _m.c * _ly0 + _m.tx;
				_entry[BC_BAKE_Y] = _m.b * _lx0 + _m.d * _ly0 + _m.ty;
				_entry[BC_BAKE_ANGLE] = _dec0.angle;
				_entry[BC_BAKE_SX] = _magx; _entry[BC_BAKE_SY] = _magy * _dec0.yflip;
			} else {
				_entry[BC_BAKE_SPECIAL] = BC_BAKE_SPECIAL_NONE;
				var _dec = bc_mat_decompose(_m);
				var _lx = -_e.pivx * _magx, _ly = -_e.pivy * _magy;
				_entry[BC_BAKE_X] = _m.a * _lx + _m.c * _ly + _m.tx;
				_entry[BC_BAKE_Y] = _m.b * _lx + _m.d * _ly + _m.ty;
				_entry[BC_BAKE_ANGLE] = _dec.angle;
				_entry[BC_BAKE_SX] = _magx;
				_entry[BC_BAKE_SY] = _magy * _dec.yflip;
			}

			array_push(_parts, _entry);
		}

		_frames[f] = _parts;
	}

	return {
		part_count: _model.n,
		frame_count: _frame_count,
		frames: _frames
	};
}

/// @function bc_save_baked_json(baked, filename)
/// @desc filename is relative to the game's working/save directory
///       (GameMaker's sandboxed file area) - move/rename it from there
///       for use elsewhere (e.g. hand it to another tool, or bundle it
///       back in as an Included File). Saved compressed (buffer_compress)
///       - bc_load_baked_json decompresses on the way back in, so always
///       load baked files through that function, not a raw buffer_load.
function bc_save_baked_json(_baked, _filename) {
	var _str = json_stringify(_baked, false);
	var _buff = buffer_create(string_byte_length(_str) + 1, buffer_grow, 1);
	buffer_write(_buff, buffer_text, _str);

	var _buff_compressed = buffer_compress(_buff, 0, buffer_tell(_buff));

	buffer_save(_buff_compressed, _filename);

	buffer_delete(_buff_compressed);
	buffer_delete(_buff);
}

/// @function bc_load_baked_json(filename)
/// @desc Reverses bc_save_baked_json's buffer_compress step before
///       parsing. Won't work on a baked file saved with the old
///       uncompressed bc_save_baked_json - re-bake and re-save if you
///       have any of those lying around.
function bc_load_baked_json(_filename) {
	var _buff_compressed = buffer_load(_filename);
	if (_buff_compressed < 0) {
		show_debug_message("bc_load_baked_json: could not open " + string(_filename));
		return undefined;
	}

	var _buff = buffer_decompress(_buff_compressed);
	buffer_delete(_buff_compressed);

	if (_buff < 0) {
		show_debug_message("bc_load_baked_json: decompression failed for " + string(_filename));
		return undefined;
	}

	var _str = buffer_read(_buff, buffer_text);
	buffer_delete(_buff);
	return json_parse(_str);
}

// ---------- playback path 1: pre-sliced sprites ----------

/// @function bc_draw_baked_frame_atlas(baked, frame_index, atlas_surface, x, y, scale)
/// @desc Same as bc_draw_baked_frame, but samples the atlas surface
///       directly using each entry's embedded cutx/cuty/cutw/cuth - the
///       .imgcut file isn't needed at all for this path, only the baked
///       JSON and the loaded atlas surface. Reconstructs the quad's 4
///       corners from the baked (x,y,angle,sx,sy) since there's no
///       per-cut sprite to hand to draw_sprite_ext here.
function bc_draw_baked_frame_atlas_new(_baked, _frame_index, _atlas_surface, _x, _y, _scale) {
	if (_frame_index < 0 || _frame_index >= array_length(_baked.frames)) return;
	if (!surface_exists(_atlas_surface)) {
		show_debug_message("bc_draw_baked_frame_atlas: atlas surface doesn't exist");
		return;
	}

	var _sw = surface_get_width(_atlas_surface);
	var _sh = surface_get_height(_atlas_surface);
	var _tex = surface_get_texture(_atlas_surface);

	var _parts = _baked.frames[_frame_index];
	for (var i = 0; i < array_length(_parts); i++) {
		var _pd = _parts[i];
		var _glow = _pd[BC_BAKE_GLOW];
		var _opacity = _pd[BC_BAKE_OPACITY];
        var _col = _pd[BC_BAKE_COLOR];
        
        switch (_glow) {
        	case 1:
                gpu_set_blendequation(bm_eq_add);
			    gpu_set_blendmode_ext(bm_src_alpha, bm_one);
            break;
            case -1:
                gpu_set_blendequation(bm_eq_reverse_subtract);
			    gpu_set_blendmode_ext(bm_src_alpha, bm_one);
            break;
            case 2:
                gpu_set_blendequation(bm_eq_add);
                gpu_set_blendmode_ext(bm_zero, bm_src_colour);
                shader_set(global.bc_shd_glow2);
                shader_set_uniform_f(global.bc_shd_glow2_u_para, _opacity);
            case 3:
    			gpu_set_blendequation(bm_eq_add);
    			gpu_set_blendmode_ext(bm_inv_dest_colour, bm_one);
            default:
    			gpu_set_blendmode(bm_normal);
    			gpu_set_colorwriteenable(true, true, true, true);
            break;
        }
        
		var _cutx = _pd[BC_BAKE_CUTX], _cuty = _pd[BC_BAKE_CUTY];
		var _cutw = _pd[BC_BAKE_CUTW], _cuth = _pd[BC_BAKE_CUTH];

		var _sx = _pd[BC_BAKE_SX] * _scale, _sy = _pd[BC_BAKE_SY] * _scale;
		var _px = _x + _pd[BC_BAKE_X] * _scale, _py = _y + _pd[BC_BAKE_Y] * _scale;
		var _rad = degtorad(_pd[BC_BAKE_ANGLE]);
		var _ca = cos(_rad), _sa = sin(_rad);

		// reconstruct the other 3 corners by rotating the (w,h) pixel-space
		// edge vectors (already scaled by sx/sy) around the baked top-left corner
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

		bc_draw_quad_tex_raw(_tex, _x0, _y0, _x1, _y1, _x2, _y2, _x3, _y3, _u0, _v0, _u1, _v1, _col,_opacity);

		bc_glow_end(_glow);
	}
}


// ---------- playback path 2: direct atlas-surface sampling ----------

/// @function bc_draw_baked_frame_atlas(baked, frame_index, atlas_surface, x, y, scale)
/// @desc Same as bc_draw_baked_frame, but samples the atlas surface
///       directly using each entry's embedded cutx/cuty/cutw/cuth - the
///       .imgcut file isn't needed at all for this path, only the baked
///       JSON and the loaded atlas surface. Reconstructs the quad's 4
///       corners from the baked (x,y,angle,sx,sy) since there's no
///       per-cut sprite to hand to draw_sprite_ext here.

/// @function bc_draw_baked_frame_atlas(baked, frame_index, atlas_surface, x, y, scale)
/// @desc Same as bc_draw_baked_frame, but samples the atlas surface
///       directly using each entry's embedded cutx/cuty/cutw/cuth - the
///       .imgcut file isn't needed at all for this path, only the baked
///       JSON and the loaded atlas surface. Reconstructs the quad's 4
///       corners from the baked (x,y,angle,sx,sy) since there's no
///       per-cut sprite to hand to draw_sprite_ext here.
function bc_draw_baked_frame_atlas(_baked, _frame_index, _atlas_surface, _x, _y, _scale) {
	if (_frame_index < 0 || _frame_index >= array_length(_baked.frames)) return;
	if (!surface_exists(_atlas_surface)) {
		show_debug_message("bc_draw_baked_frame_atlas: atlas surface doesn't exist");
		return;
	}

	var _sw = surface_get_width(_atlas_surface);
	var _sh = surface_get_height(_atlas_surface);
	var _tex = surface_get_texture(_atlas_surface);

	var _parts = _baked.frames[_frame_index];
	for (var i = 0; i < array_length(_parts); i++) {
		var _pd = _parts[i];
		var _glow = _pd[BC_BAKE_GLOW];
		var _opacity = _pd[BC_BAKE_OPACITY];
		var _cd = bc_glow_begin(_glow, _opacity);

		var _cutx = _pd[BC_BAKE_CUTX], _cuty = _pd[BC_BAKE_CUTY];
		var _cutw = _pd[BC_BAKE_CUTW], _cuth = _pd[BC_BAKE_CUTH];

		var _sx = _pd[BC_BAKE_SX] * _scale, _sy = _pd[BC_BAKE_SY] * _scale;
		var _px = _x + _pd[BC_BAKE_X] * _scale, _py = _y + _pd[BC_BAKE_Y] * _scale;
		var _rad = degtorad(_pd[BC_BAKE_ANGLE]);
		var _ca = cos(_rad), _sa = sin(_rad);

		// reconstruct the other 3 corners by rotating the (w,h) pixel-space
		// edge vectors (already scaled by sx/sy) around the baked top-left corner
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

		bc_draw_quad_tex_raw(_tex, _x0, _y0, _x1, _y1, _x2, _y2, _x3, _y3, _u0, _v0, _u1, _v1, _cd[0], _cd[1]);

		bc_glow_end(_glow);
	}
}
