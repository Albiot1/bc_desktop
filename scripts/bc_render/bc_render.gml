// ============================================================
// bc_render.gml
// Authoritative reference confirmed: MainBCU.USE_JOGL == false, so the
// real rendering path is BufferedAnim (AWT/FG2D), and the ground-truth
// glow formulas are Blender.comp3() in Blender.java - NOT the GLSL
// shaders (those back the unused JOGL path). Converter/Masker (AWT
// GRAY/MASK composites) aren't ported here since nothing in the normal
// animation draw path uses them (they're editor-only, e.g. IconBox UI).
//
// Quad drawing now goes through draw_primitive + per-vertex UV/colour
// instead of draw_sprite_pos/draw_sprite_general. Two benefits:
//   1. glow==3 needs alpha premultiplied into colour before blending
//      (fixed-function blend factors can't reference alpha AND
//      dest-colour at once) - a vertex-colour tint does this with no
//      shader.
//   2. The fractional "extend" crop tiles now just sample a partial UV
//      rect instead of needing a rotation/flip decomposition - so
//      bc_mat_decompose is gone entirely, and nothing here relies on
//      matrix decomposition being "exact" (it's just corner math now).
// ============================================================

// ---------- size / base-size (mirrors EPart.getSize / getBaseSize) ----------

/// @function bc_get_size(ents, model, idx, cache)
/// @desc Mirrors EPart.getSize() - cumulative component-wise scale.
///       `cache` is an array sized array_length(ents), filled with
///       `undefined`, created fresh once per draw call/frame (same
///       lifetime as bc_get_world_matrix's cache - do NOT reuse a cache
///       across frames, ent values change).
function bc_get_size(_ents, _model, _idx, _cache) {
	if (_cache[_idx] != undefined) return _cache[_idx];

	var _e = _ents[_idx];
	var _mi = 1 / _model.ints[0];
	var _result;
	if (_e.par == -1) {
		_result = [_e.scax * _e.gsca * _mi * _mi, _e.scay * _e.gsca * _mi * _mi];
	} else {
		var _pSize = bc_get_size(_ents, _model, _e.par, _cache);
		_result = [_pSize[0] * _e.scax * _e.gsca * _mi * _mi, _pSize[1] * _e.scay * _e.gsca * _mi * _mi];
	}

	_cache[_idx] = _result;
	return _result;
}

function bc_get_base_size(_ents, _model, _idx, _use_parent) {
	if (_model.m <= 0) return [1, 1];
	var _mi = 1 / _model.ints[0];
	var _e = _ents[_idx];

	if (_use_parent) {
		var _sx = sign(_model.parts[_idx][8]);
		var _sy = sign(_model.parts[_idx][9]);
		if (_e.par != -1) {
			var _fb = bc_get_base_size(_ents, _model, _e.par, true);
			return [_fb[0] * _sx, _fb[1] * _sy];
		}
		return [_sx, _sy];
	} else {
		var _c0 = _model.confs[0][0];
		if (_c0 == -1) {
			return [_model.parts[0][8] * _mi, _model.parts[0][9] * _mi];
		} else if (_c0 == _idx) {
			return [_model.parts[_c0][8] * _mi, _model.parts[_c0][9] * _mi];
		} else {
			var _ab = bc_get_base_size(_ents, _model, _c0, true);
			return [_ab[0] * _model.parts[_c0][8] * _mi, _ab[1] * _model.parts[_c0][9] * _mi];
		}
	}
}

// ---------- 2x3 affine matrix helpers ----------

function bc_mat_identity() {
	return { a: 1, b: 0, c: 0, d: 1, tx: 0, ty: 0 };
}

function bc_mat_translate(_x, _y) {
	return { a: 1, b: 0, c: 0, d: 1, tx: _x, ty: _y };
}

function bc_mat_scale(_sx, _sy) {
	return { a: _sx, b: 0, c: 0, d: _sy, tx: 0, ty: 0 };
}

function bc_mat_rotate_rad(_rad) {
	var _c = cos(_rad), _s = sin(_rad);
	return { a: _c, b: _s, c: -_s, d: _c, tx: 0, ty: 0 };
}

function bc_mat_mul(_m1, _m2) {
	return {
		a: _m1.a * _m2.a + _m1.c * _m2.b,
		b: _m1.b * _m2.a + _m1.d * _m2.b,
		c: _m1.a * _m2.c + _m1.c * _m2.d,
		d: _m1.b * _m2.c + _m1.d * _m2.d,
		tx: _m1.a * _m2.tx + _m1.c * _m2.ty + _m1.tx,
		ty: _m1.b * _m2.tx + _m1.d * _m2.ty + _m1.ty
	};
}

// ---------- world transform per part (mirrors EPart.transform()) ----------

/// @function bc_get_world_matrix(ents, model, idx, global_scale, cache, size_cache)
/// @desc `size_cache` is a second cache array (same length/lifetime as
///       `cache`) passed through to bc_get_size so parent-size lookups
///       shared across many parts (e.g. several siblings hanging off the
///       same parent) aren't recomputed from scratch for each one.
function bc_get_world_matrix(_ents, _model, _idx, _global_scale, _cache, _size_cache) {
	if (_cache[_idx] != undefined) return _cache[_idx];

	var _e = _ents[_idx];
	var _parent_m = (_e.par == -1)
		? bc_mat_identity()
		: bc_get_world_matrix(_ents, _model, _e.par, _global_scale, _cache, _size_cache);

	var _offx, _offy;

	if (_idx == 0) {
		_offx = 0; _offy = 0;
		if (_model.m > 0) {
			var _base = bc_get_base_size(_ents, _model, 0, false);
			var _conf = _model.confs[0];
			_offx -= _base[0] * _conf[2] * _global_scale * _e.hf;
			_offy -= _base[1] * _conf[3] * _global_scale * _e.vf;
		}
		var _size0 = bc_get_size(_ents, _model, 0, _size_cache);
		_offx += _size0[0] * _global_scale * _e.pivx * _e.hf;
		_offy += _size0[1] * _global_scale * _e.pivy * _e.vf;
	} else {
		var _psize = bc_get_size(_ents, _model, _e.par, _size_cache);
		_offx = _psize[0] * _global_scale * _e.posx;
		_offy = _psize[1] * _global_scale * _e.posy;
	}

	var _local = bc_mat_mul(bc_mat_translate(_offx, _offy), bc_mat_scale(_e.hf, _e.vf));
	if (_e.angle != 0) {
		var _angleRad = (2 * pi * _e.angle) / _model.ints[1];
		_local = bc_mat_mul(_local, bc_mat_rotate_rad(_angleRad));
	}

	var _world = bc_mat_mul(_parent_m, _local);
	_cache[_idx] = _world;
	return _world;
}

// ---------- z-sort ----------

function bc_sort_ents_by_z(_ents) {
	var _n = array_length(_ents);
	var _order = array_create(_n);
	for (var i = 0; i < _n; i++) _order[i] = i;

	for (var i = 1; i < _n; i++) {
		var _key = _order[i];
		var _keyZ = _ents[_key].z;
		var _j = i - 1;
		while (_j >= 0 && _ents[_order[_j]].z > _keyZ) {
			_order[_j + 1] = _order[_j];
			_j--;
		}
		_order[_j + 1] = _key;
	}
	return _order;
}

/// @function bc_get_sorted_order(player)
/// @desc Cached wrapper around bc_sort_ents_by_z - only actually re-sorts
///       when at least one ent's z value has changed since the last call
///       (z only changes via modtype 3 keyframes or the z-order default
///       computed at reset, so most frames of most animations don't
///       touch it at all). Requires the player struct (not just ents),
///       since the cache lives there. Not used by bc_bake_animation -
///       baking visits every distinct frame exactly once anyway, so
///       there's nothing to cache.
function bc_get_sorted_order(_p) {
	var _ents = _p.ents;
	var _n = array_length(_ents);

	if (_p.z_snapshot == undefined) {
		_p.z_order = bc_sort_ents_by_z(_ents);
		_p.z_snapshot = array_create(_n);
		for (var i = 0; i < _n; i++) _p.z_snapshot[i] = _ents[i].z;
		return _p.z_order;
	}

	var _changed = false;
	for (var i = 0; i < _n; i++) {
		if (_ents[i].z != _p.z_snapshot[i]) { _changed = true; break; }
	}

	if (_changed) {
		_p.z_order = bc_sort_ents_by_z(_ents);
		for (var i = 0; i < _n; i++) _p.z_snapshot[i] = _ents[i].z;
	}

	return _p.z_order;
}

// ---------- atlas slicing ----------

function bc_build_sprites_from_surface(_surface, _imgcut) {
	var _n = _imgcut.n;
	var _sprites = array_create(_n);
	for (var i = 0; i < _n; i++) {
		var _cut = _imgcut.cuts[i];
		_sprites[i] = sprite_create_from_surface(_surface, _cut[0], _cut[1], _cut[2], _cut[3], false, false, 0, 0);
	}
	return _sprites;
}

function bc_free_sprites(_sprites) {
	for (var i = 0; i < array_length(_sprites); i++) {
		if (sprite_exists(_sprites[i])) sprite_delete(_sprites[i]);
	}
}

// ---------- core textured-quad primitive ----------

/// @function bc_draw_quad_tex(sprite, x0,y0,x1,y1,x2,y2,x3,y3, u0,v0,u1,v1, colour, alpha)
/// @desc Draws an arbitrary quad (corners in room space, winding
///       TL,TR,BR,BL) sampling the given UV sub-rect of `sprite`, tinted
///       by `colour` (multiplies texture RGB) and `alpha` (multiplies
///       texture alpha). Replaces draw_sprite_pos/draw_sprite_general so
///       glow modes needing premultiplied colour don't need a shader.
/// @function bc_draw_quad_tex_raw(tex, x0,y0,...,x3,y3, u0,v0,u1,v1, colour, alpha)
/// @desc Lowest-level primitive: draws an arbitrary quad sampling the
///       given UV rect of a raw texture pointer. Both the sprite-atlas
///       path (bc_draw_quad_tex) and the direct-surface path
///       (bc_render_atlas.gml) funnel through this.
function bc_draw_quad_tex_raw(_tex, _x0, _y0, _x1, _y1, _x2, _y2, _x3, _y3, _u0, _v0, _u1, _v1, _colour, _alpha) {
	draw_primitive_begin_texture(pr_trianglelist, _tex);
	draw_vertex_texture_colour(_x0, _y0, _u0, _v0, _colour, _alpha);
	draw_vertex_texture_colour(_x1, _y1, _u1, _v0, _colour, _alpha);
	draw_vertex_texture_colour(_x2, _y2, _u1, _v1, _colour, _alpha);

	draw_vertex_texture_colour(_x0, _y0, _u0, _v0, _colour, _alpha);
	draw_vertex_texture_colour(_x2, _y2, _u1, _v1, _colour, _alpha);
	draw_vertex_texture_colour(_x3, _y3, _u0, _v1, _colour, _alpha);
	draw_primitive_end();
}

/// @function bc_draw_quad_tex(sprite, x0,y0,...,x3,y3, u0,v0,u1,v1, colour, alpha)
/// @desc Sprite-backed version of bc_draw_quad_tex_raw. u0..v1 are in
///       0..1 SPRITE-local space; this maps them into the sprite's
///       actual sub-rect within GameMaker's shared texture page via
///       texture_get_uvs, so it's correct even if GM batches these many
///       small per-cut sprites onto one page (a real possibility that a
///       hardcoded 0,0,1,1 UV would get wrong).
function bc_draw_quad_tex(_sprite, _x0, _y0, _x1, _y1, _x2, _y2, _x3, _y3, _u0, _v0, _u1, _v1, _colour, _alpha) {
	var _tex = sprite_get_texture(_sprite, 0);
	var _page_uv = texture_get_uvs(_tex); // [left, top, right, bottom] within the shared page
	var _pu0 = _page_uv[0], _pv0 = _page_uv[1], _pu1 = _page_uv[2], _pv1 = _page_uv[3];

	var _ru0 = lerp(_pu0, _pu1, _u0);
	var _rv0 = lerp(_pv0, _pv1, _v0);
	var _ru1 = lerp(_pu0, _pu1, _u1);
	var _rv1 = lerp(_pv0, _pv1, _v1);

	bc_draw_quad_tex_raw(_tex, _x0, _y0, _x1, _y1, _x2, _y2, _x3, _y3, _ru0, _rv0, _ru1, _rv1, _colour, _alpha);
}

/// @function bc_draw_quad_local(sprite, lx, ly, lw, lh, m, ox, oy, colour, alpha)
/// @desc Full (uncropped) sprite, local axis-aligned rect (lx,ly,lw,lh)
///       transformed through world matrix m, offset by (ox,oy).
function bc_draw_quad_local(_sprite, _lx, _ly, _lw, _lh, _m, _ox, _oy, _colour, _alpha) {
	var _lx1 = _lx + _lw, _ly1 = _ly + _lh;

	var _wx0 = _m.a * _lx  + _m.c * _ly  + _m.tx, _wy0 = _m.b * _lx  + _m.d * _ly  + _m.ty;
	var _wx1 = _m.a * _lx1 + _m.c * _ly  + _m.tx, _wy1 = _m.b * _lx1 + _m.d * _ly  + _m.ty;
	var _wx2 = _m.a * _lx1 + _m.c * _ly1 + _m.tx, _wy2 = _m.b * _lx1 + _m.d * _ly1 + _m.ty;
	var _wx3 = _m.a * _lx  + _m.c * _ly1 + _m.tx, _wy3 = _m.b * _lx  + _m.d * _ly1 + _m.ty;

	bc_draw_quad_tex(_sprite,
		_ox + _wx0, _oy + _wy0, _ox + _wx1, _oy + _wy1,
		_ox + _wx2, _oy + _wy2, _ox + _wx3, _oy + _wy3,
		0, 0, 1, 1, _colour, _alpha);
}

/// @function bc_draw_quad_cropped(sprite, crop_frac_w, crop_frac_h, lx, ly, disp_w, disp_h, m, ox, oy, colour, alpha)
/// @desc For the fractional "extend" tiles - samples only the left
///       crop_frac_w / top crop_frac_h fraction of the sprite (0..1),
///       displayed at local rect (lx,ly,disp_w,disp_h). No rotation
///       decomposition needed - this is just a partial UV rect.
function bc_draw_quad_cropped(_sprite, _crop_frac_w, _crop_frac_h, _lx, _ly, _disp_w, _disp_h, _m, _ox, _oy, _colour, _alpha) {
	var _lx1 = _lx + _disp_w, _ly1 = _ly + _disp_h;

	var _wx0 = _m.a * _lx  + _m.c * _ly  + _m.tx, _wy0 = _m.b * _lx  + _m.d * _ly  + _m.ty;
	var _wx1 = _m.a * _lx1 + _m.c * _ly  + _m.tx, _wy1 = _m.b * _lx1 + _m.d * _ly  + _m.ty;
	var _wx2 = _m.a * _lx1 + _m.c * _ly1 + _m.tx, _wy2 = _m.b * _lx1 + _m.d * _ly1 + _m.ty;
	var _wx3 = _m.a * _lx  + _m.c * _ly1 + _m.tx, _wy3 = _m.b * _lx  + _m.d * _ly1 + _m.ty;

	bc_draw_quad_tex(_sprite,
		_ox + _wx0, _oy + _wy0, _ox + _wx1, _oy + _wy1,
		_ox + _wx2, _oy + _wy2, _ox + _wx3, _oy + _wy3,
		0, 0, clamp(_crop_frac_w, 0, 1), clamp(_crop_frac_h, 0, 1), _colour, _alpha);
}

// ---------- glow / composite (mirrors Blender.comp3() - the AWT path,
// confirmed authoritative since USE_JOGL == false) ----------
//
// Each mode below returns {colour, alpha} to feed into the quad-draw
// calls, and sets whatever blend mode/equation is needed as a side
// effect. Call bc_glow_end(glow) right after drawing.
//
//   0        normal alpha blend
//   1        dst = min(255, dst + src*a)            -> additive, factors (SRC_ALPHA, ONE)
//   2        dst -= dst*(255-src)*a  (multiply-ish)  -> needs shd_bc_glow2 shader (unchanged from before)
//   3        dst = d + A^2*(1-d)*s   (screen, A^2!)  -> factors (INV_DEST_COLOUR, ONE) + colour tint = alpha^2
//  -1        dst = max(0, dst - src*a)               -> equation REVERSE_SUBTRACT, factors (SRC_ALPHA, ONE)
//  -2        alpha-blended Overlay (dst-dependent)   -> NOT achievable with fixed-function blending;
//                                                        would need a two-pass surface+shader read of the
//                                                        destination. Falls back to normal draw + one-time warning.

function bc_glow_begin(_glow, _alpha) {
	var _glow_support = (_glow >= 1 && _glow <= 3) || _glow == -1 || _glow == -2;

	if (!_glow_support) {
		gpu_set_blendmode(bm_normal);
		gpu_set_colorwriteenable(true, true, true, true);
		return [c_white,_alpha]
	}

	// Non-normal blend equations/factors also get applied to the ALPHA
	// channel by default. That's invisible when drawing straight to the
	// screen (nobody reads the screen's own alpha), but when the target
	// IS a surface, it corrupts that surface's alpha - typically pushing
	// it toward fully opaque across the whole sprite's bounding box - and
	// a later draw_surface() of that surface then shows a solid block of
	// whatever RGB accumulated there instead of the intended shaped glow.
	// Disabling alpha writes here means glow draws only affect RGB,
	// leaving the surface's alpha exactly as prior (normal-blended) draws
	// left it. Safe to do unconditionally - harmless when the target is
	// the screen instead of a surface.
	
    gpu_set_colorwriteenable(true, true, true, false);

	switch (_glow) {
		case 1:
			gpu_set_blendequation(bm_eq_add);
			gpu_set_blendmode_ext(bm_src_alpha, bm_one);
			return [c_white,_alpha]

		case 3:
			gpu_set_blendequation(bm_eq_add);
			gpu_set_blendmode_ext(bm_inv_dest_colour, bm_one);
			var _g = clamp(_alpha * _alpha, 0, 1); // A^2, per comp3's derived formula
			var _gv = round(_g * 255);
			return [make_colour_rgb(_gv, _gv, _gv),1];

		case 2:
				gpu_set_blendequation(bm_eq_add);
				gpu_set_blendmode_ext(bm_zero, bm_src_colour);
				shader_set(global.bc_shd_glow2);
				shader_set_uniform_f(global.bc_shd_glow2_u_para, _alpha);
				return [c_white,_alpha]
		case -1:
			gpu_set_blendequation(bm_eq_reverse_subtract);
			gpu_set_blendmode_ext(bm_src_alpha, bm_one);
			return [c_white,_alpha]

		case -2:
			if (!variable_global_exists("bc_warned_glow_neg2")) {
				global.bc_warned_glow_neg2 = true;
				show_debug_message("bc_glow_begin: glow==-2 (alpha-blended Overlay) can't be done with fixed-function blending - needs a surface-read shader. Falling back to normal draw.");
			}
			gpu_set_blendmode(bm_normal);
			gpu_set_colorwriteenable(true, true, true, true); // plain normal blend - fine to write alpha
			return [c_white,_alpha]

		default:
			gpu_set_blendmode(bm_normal);
			gpu_set_colorwriteenable(true, true, true, true);
			return [ c_white,_alpha]
	}
}

function bc_glow_end(_glow) {
	if (_glow == 2) shader_reset();
	gpu_set_blendequation(bm_eq_add);
	gpu_set_blendmode(bm_normal);
	gpu_set_colorwriteenable(true, true, true, true);
}

// ---------- extend tiling (mirrors ImgCore.drawImg's extendX/extendY loop) ----------

function bc_draw_extend_2d(_sprite, _w, _h, _pivx, _pivy, _magx, _magy, _extendX, _extendY, _m, _ox, _oy, _colour, _alpha) {
	var _scx = _w * _magx, _scy = _h * _magy;
	var _x = -_pivx * _magx;
	var _y = -_pivy * _magy;

	if (_extendY == 0) {
		while (_extendX > 1) {
			bc_draw_quad_local(_sprite, _x, _y, _scx, _scy, _m, _ox, _oy, _colour, _alpha);
			_x += _scx;
			_extendX--;
		}
	} else {
		var _extendXBackup = _extendX;
		while (_extendY > 1) {
			if (_extendX == 0) {
				bc_draw_quad_local(_sprite, _x, _y, _scx, _scy, _m, _ox, _oy, _colour, _alpha);
			} else {
				_x = -_pivx * _magx;
				_extendX = _extendXBackup;
				while (_extendX > 1) {
					bc_draw_quad_local(_sprite, _x, _y, _scx, _scy, _m, _ox, _oy, _colour, _alpha);
					_x += _scx;
					_extendX--;
				}
			}
			_y += _scy;
			_extendY--;
		}
	}

	if (_w > 0) {
		if (_extendY == 0) {
			bc_draw_quad_cropped(_sprite, _extendX, 1, _x, _y, _scx * _extendX, _scy, _m, _ox, _oy, _colour, _alpha);
		} else {
			if (_extendX == 0) {
				bc_draw_quad_cropped(_sprite, 1, _extendY, _x, _y, _scx, _scy * _extendY, _m, _ox, _oy, _colour, _alpha);
			} else {
				// SIMPLIFIED: see note in previous revision - the real
				// ImgCore.drawImg fills a full right-edge column + bottom-edge
				// row of tiles here (re-looping over every original row/column),
				// not just one strip each. Only matters when BOTH extendX and
				// extendY are simultaneously non-integer AND >1.
				bc_draw_quad_cropped(_sprite, _extendX, 1, _x, -_pivy * _magy, _scx * _extendX, _scy, _m, _ox, _oy, _colour, _alpha);
				bc_draw_quad_cropped(_sprite, 1, _extendY, -_pivx * _magx, _y, _scx, _scy * _extendY, _m, _ox, _oy, _colour, _alpha);
			}
		}
	}
}

// ---------- curse / random-image cycling (mirrors ImgCore.drawRandom) ----------

function bc_rand_series_get(_i) {
	bc_rand_series_ensure_init();
	while (array_length(global.bc_rand_series) <= _i) {
		array_push(global.bc_rand_series, irandom(3));
	}
	return global.bc_rand_series[_i];
}

function bc_draw_curse(_sprites, _imgcut, _e, _magx, _magy, _ox, _oy, _m, _colour, _alpha) {
	var _cut0 = _imgcut.cuts[3];
	var _w = _cut0[2], _h = _cut0[3];
	var _scx = _w * _magx, _scy = _h * _magy;

	if (_e.extendX == 0) {
		bc_draw_quad_local(_sprites[3], -_e.pivx * _magx, -_e.pivy * _magy, _scx, _scy, _m, _ox, _oy, _colour, _alpha);
		return;
	}

	var _x = -_e.pivx * _magx;
	var _ex = _e.extendX;
	var _i = 0;
	while (_ex > 1) {
		var _pick = bc_rand_series_get(_i);
		bc_draw_quad_local(_sprites[3 + _pick], _x, -_e.pivy * _magy, _scx, _scy, _m, _ox, _oy, _colour, _alpha);
		_x += _scx;
		_ex--;
		_i++;
	}

	if (_ex > 0) {
		bc_draw_quad_cropped(_sprites[3], _ex, 1, _x, -_e.pivy * _magy, _scx * _ex, _scy, _m, _ox, _oy, _colour, _alpha);
	}
}

// ---------- effective (parent-cascaded) opacity, mirrors EPart.opa() ----------

/// @function bc_ent_opa(ents, model, idx, cache)
/// @desc `cache` is an array sized array_length(ents), filled with
///       `undefined`, created fresh once per draw call/frame.
function bc_ent_opa(_ents, _model, _idx, _cache) {
	if (_cache[_idx] != undefined) return _cache[_idx];

	var _e = _ents[_idx];
	var _result;
	if (_e.opacity == 0) {
		_result = 0;
	} else if (_e.par == -1) {
		_result = _e.opacity / _model.ints[2];
	} else {
		_result = bc_ent_opa(_ents, _model, _e.par, _cache) * _e.opacity / _model.ints[2];
	}

	_cache[_idx] = _result;
	return _result;
}

// ---------- bounding box (walks every frame, tracks corner extents) ----------

/// @function bc_compute_bounds(model, maanim, imgcut, global_scale)
/// @desc Returns {min_x, min_y, max_x, max_y, width, height} - the exact
///       axis-aligned bounding box of every visible part across every
///       frame of this clip, in the same local space bc_draw_player uses
///       (i.e. relative to whatever (x,y) you'll later pass it - add
///       your own offset, don't add room coords here). Uses a scratch
///       ents array so it doesn't disturb a player mid-playback. Cheap
///       to call once at load time and cache the result; not meant to
///       run every frame (it evaluates the WHOLE clip each call).
///       extend-tiled and curse parts are approximated using their
///       un-tiled/slot-3 size times max(1,extend) - fine for sizing a
///       surface, not pixel-exact for those specific parts.
function bc_compute_bounds(_model, _maanim, _imgcut, _global_scale) {
	var _ents = bc_ent_setup(_model);
	var _n = array_length(_ents);
	var _minx = 999999, _miny = 999999, _maxx = -999999, _maxy = -999999;

	for (var f = 0; f <= _maanim.max; f++) {
		bc_maanim_update(_maanim, _ents, _model, f, false);
		var _cache = array_create(_n, undefined);
		var _size_cache = array_create(_n, undefined);
		var _opa_cache = array_create(_n, undefined);

		for (var i = 0; i < _n; i++) {
			var _e = _ents[i];
			if (_e.img < 0 || _e.mid < 0 || _e.glow != 0) continue;
			if (_e.img >= _imgcut.n) continue;
			if (bc_ent_opa(_ents, _model, i, _opa_cache) <= 0) continue;

			var _cut = _imgcut.cuts[_e.img];
			var _w = _cut[2] * max(1, _e.extendX);
			var _h = _cut[3] * max(1, _e.extendY);

			var _mag = bc_get_size(_ents, _model, i, _size_cache);
			var _magx = _mag[0] * _global_scale;
			var _magy = _mag[1] * _global_scale;
			var _m = bc_get_world_matrix(_ents, _model, i, _global_scale, _cache, _size_cache);

			var _lx = -_e.pivx * _magx, _ly = -_e.pivy * _magy;
			var _lx1 = _lx + _w * _magx, _ly1 = _ly + _h * _magy;

			var _cxs = [_lx, _lx1, _lx1, _lx];
			var _cys = [_ly, _ly, _ly1, _ly1];

			for (var c = 0; c < 4; c++) {
				var _wx = _m.a * _cxs[c] + _m.c * _cys[c] + _m.tx;
				var _wy = _m.b * _cxs[c] + _m.d * _cys[c] + _m.ty;
				if (_wx < _minx) _minx = _wx;
				if (_wx > _maxx) _maxx = _wx;
				if (_wy < _miny) _miny = _wy;
				if (_wy > _maxy) _maxy = _wy;
			}
		}
	}

	if (_maxx < _minx) return { min_x: 0, min_y: 0, max_x: 0, max_y: 0, width: 0, height: 0 };

	return {
		min_x: _minx, min_y: _miny, max_x: _maxx, max_y: _maxy,
		width: _maxx - _minx, height: _maxy - _miny
	};
}

// ---------- main draw ----------

/// @function bc_draw_ent_geometry(imgcut, sprites, e, magx, magy, m, x, y, colour, alpha)
/// @desc Dispatches to the right quad-drawing function (plain/curse/
///       extend) for one part. Factored out so it can be called twice
///       per part when the alpha-stamp pass is needed (see
///       bc_glow_needs_alpha_stamp) without duplicating the dispatch
///       logic.
function bc_draw_ent_geometry(_imgcut, _sprites, _e, _magx, _magy, _m, _x, _y, _colour, _alpha) {
	if (_e.extType == 1) {
		bc_draw_curse(_sprites, _imgcut, _e, _magx, _magy, _x, _y, _m, _colour, _alpha);
	} else if (_e.extendX == 0 && _e.extendY == 0) {
		var _cut = _imgcut.cuts[_e.img];
		bc_draw_quad_local(_sprites[_e.img], -_e.pivx * _magx, -_e.pivy * _magy, _cut[2] * _magx, _cut[3] * _magy, _m, _x, _y, _colour, _alpha);
	} else {
		var _cut2 = _imgcut.cuts[_e.img];
		bc_draw_extend_2d(_sprites[_e.img], _cut2[2], _cut2[3], _e.pivx, _e.pivy, _magx, _magy, _e.extendX, _e.extendY, _m, _x, _y, _colour, _alpha);
	}
}
