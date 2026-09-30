// ============================================================
// bc_render_atlas.gml
// Alternative to bc_build_sprites_from_surface + bc_draw_player: instead
// of slicing the loaded sprite sheet into one small GameMaker sprite per
// .imgcut entry, this samples the atlas surface directly, computing UV
// rects straight from imgcut pixel coordinates. Requires
// bc_render.gml's bc_get_size/bc_get_world_matrix/bc_sort_ents_by_z/
// bc_ent_opa/bc_glow_begin/bc_glow_end/bc_draw_quad_tex_raw and
// bc_runtime.gml's bc_rand_series_get to already be loaded.
//
// Trade-offs vs the sprite-slicing path:
//   + No per-cut sprite resources to create/manage/free - useful if an
//     imgcut has hundreds of tiny entries.
//   + Nothing to rebuild if you swap the atlas at runtime.
//   - The atlas surface must stay alive for as long as you're drawing
//     from it, and surfaces can be invalidated (window losing focus,
//     some platforms, memory pressure) - always guard with
//     surface_exists() and be ready to redraw the atlas if it's gone.
//     Sprites made via sprite_create_from_surface don't have this
//     problem (they're their own independent copy once created).
//   - Point/nearest-neighbour filtering for crisp pixel art needs to be
//     set explicitly (gpu_set_tex_filter(false) before drawing), same
//     requirement either path but easy to forget with raw surfaces.
//
// Everything else (parsing, keyframe math, hierarchy, glow, bake/export)
// is identical between the two paths - only how the final textured quad
// gets its texture+UV differs.
// =========================== =================================

/// @function bc_draw_quad_local_atlas(tex, sw, sh, cutx, cuty, cutw, cuth, lx, ly, lw, lh, m, ox, oy, colour, alpha)
function bc_draw_quad_local_atlas(_tex, _sw, _sh, _cutx, _cuty, _cutw, _cuth, _lx, _ly, _lw, _lh, _m, _ox, _oy, _colour, _alpha) {
	var _lx1 = _lx + _lw, _ly1 = _ly + _lh;

	var _wx0 = _m.a * _lx  + _m.c * _ly  + _m.tx, _wy0 = _m.b * _lx  + _m.d * _ly  + _m.ty;
	var _wx1 = _m.a * _lx1 + _m.c * _ly  + _m.tx, _wy1 = _m.b * _lx1 + _m.d * _ly  + _m.ty;
	var _wx2 = _m.a * _lx1 + _m.c * _ly1 + _m.tx, _wy2 = _m.b * _lx1 + _m.d * _ly1 + _m.ty;
	var _wx3 = _m.a * _lx  + _m.c * _ly1 + _m.tx, _wy3 = _m.b * _lx  + _m.d * _ly1 + _m.ty;

	var _u0 = _cutx / _sw, _v0 = _cuty / _sh;
	var _u1 = (_cutx + _cutw) / _sw, _v1 = (_cuty + _cuth) / _sh;

	bc_draw_quad_tex_raw(_tex,
		_ox + _wx0, _oy + _wy0, _ox + _wx1, _oy + _wy1,
		_ox + _wx2, _oy + _wy2, _ox + _wx3, _oy + _wy3,
		_u0, _v0, _u1, _v1, _colour, _alpha);
}

/// @function bc_draw_quad_cropped_atlas(surface, sw, sh, cutx, cuty, cutw, cuth, crop_frac_w, crop_frac_h, lx, ly, disp_w, disp_h, m, ox, oy, colour, alpha)
/// @desc For the fractional "extend" tiles.
function bc_draw_quad_cropped_atlas(_tex, _sw, _sh, _cutx, _cuty, _cutw, _cuth, _crop_frac_w, _crop_frac_h, _lx, _ly, _disp_w, _disp_h, _m, _ox, _oy, _colour, _alpha) {
	var _lx1 = _lx + _disp_w, _ly1 = _ly + _disp_h;

	var _wx0 = _m.a * _lx  + _m.c * _ly  + _m.tx, _wy0 = _m.b * _lx  + _m.d * _ly  + _m.ty;
	var _wx1 = _m.a * _lx1 + _m.c * _ly  + _m.tx, _wy1 = _m.b * _lx1 + _m.d * _ly  + _m.ty;
	var _wx2 = _m.a * _lx1 + _m.c * _ly1 + _m.tx, _wy2 = _m.b * _lx1 + _m.d * _ly1 + _m.ty;
	var _wx3 = _m.a * _lx  + _m.c * _ly1 + _m.tx, _wy3 = _m.b * _lx  + _m.d * _ly1 + _m.ty;

	var _u0 = _cutx / _sw, _v0 = _cuty / _sh;
	var _u1 = (_cutx + _cutw * clamp(_crop_frac_w, 0, 1)) / _sw;
	var _v1 = (_cuty + _cuth * clamp(_crop_frac_h, 0, 1)) / _sh;

	bc_draw_quad_tex_raw(_tex,
		_ox + _wx0, _oy + _wy0, _ox + _wx1, _oy + _wy1,
		_ox + _wx2, _oy + _wy2, _ox + _wx3, _oy + _wy3,
		_u0, _v0, _u1, _v1, _colour, _alpha);
}

function bc_draw_extend_2d_atlas(_tex, _sw, _sh, _cutx, _cuty, _w, _h, _pivx, _pivy, _magx, _magy, _extendX, _extendY, _m, _ox, _oy, _colour, _alpha) {
	var _scx = _w * _magx, _scy = _h * _magy;
	var _x = -_pivx * _magx;
	var _y = -_pivy * _magy;

	if (_extendY == 0) {
		while (_extendX > 1) {
			bc_draw_quad_local_atlas(_tex, _sw, _sh, _cutx, _cuty, _w, _h, _x, _y, _scx, _scy, _m, _ox, _oy, _colour, _alpha);
			_x += _scx;
			_extendX--;
		}
	} else {
		var _extendXBackup = _extendX;
		while (_extendY > 1) {
			if (_extendX == 0) {
				bc_draw_quad_local_atlas(_tex, _sw, _sh, _cutx, _cuty, _w, _h, _x, _y, _scx, _scy, _m, _ox, _oy, _colour, _alpha);
			} else {
				_x = -_pivx * _magx;
				_extendX = _extendXBackup;
				while (_extendX > 1) {
					bc_draw_quad_local_atlas(_tex, _sw, _sh, _cutx, _cuty, _w, _h, _x, _y, _scx, _scy, _m, _ox, _oy, _colour, _alpha);
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
			bc_draw_quad_cropped_atlas(_tex, _sw, _sh, _cutx, _cuty, _w, _h, _extendX, 1, _x, _y, _scx * _extendX, _scy, _m, _ox, _oy, _colour, _alpha);
		} else {
			if (_extendX == 0) {
				bc_draw_quad_cropped_atlas(_tex, _sw, _sh, _cutx, _cuty, _w, _h, 1, _extendY, _x, _y, _scx, _scy * _extendY, _m, _ox, _oy, _colour, _alpha);
			} else {
				// SIMPLIFIED (matches bc_draw_extend_2d in bc_render.gml) - see
				// that file's comment for what's approximated here.
				bc_draw_quad_cropped_atlas(_tex, _sw, _sh, _cutx, _cuty, _w, _h, _extendX, 1, _x, -_pivy * _magy, _scx * _extendX, _scy, _m, _ox, _oy, _colour, _alpha);
				bc_draw_quad_cropped_atlas(_tex, _sw, _sh, _cutx, _cuty, _w, _h, 1, _extendY, -_pivx * _magx, _y, _scx, _scy * _extendY, _m, _ox, _oy, _colour, _alpha);
			}
		}
	}
}

function bc_draw_curse_atlas(_tex, _sw, _sh, _imgcut, _e, _magx, _magy, _ox, _oy, _m, _colour, _alpha) {
	var _cut0 = _imgcut.cuts[3];
	var _w = _cut0[2] * 2, _h = _cut0[3] * 2;
	var _scx = _w * _magx, _scy = _h * _magy;

	if (_e.extendX == 0) {
		bc_draw_quad_local_atlas(_tex, _sw, _sh, _cut0[0] * 2, _cut0[1] * 2, _w, _h, -_e.pivx * _magx, -_e.pivy * _magy, _scx, _scy, _m, _ox, _oy, _colour, _alpha);
		return;
	}

	var _x = -_e.pivx * _magx;
	var _ex = _e.extendX;
	var _i = 0;
	while (_ex > 1) {
		var _pick = bc_rand_series_get(_i);
		var _cutp = _imgcut.cuts[3 + _pick];
		bc_draw_quad_local_atlas(_tex, _sw, _sh, _cutp[0] * 2, _cutp[1] * 2, _w, _h, _x, -_e.pivy * _magy, _scx, _scy, _m, _ox, _oy, _colour, _alpha);
		_x += _scx;
		_ex--;
		_i++;
	}

	if (_ex > 0) {
		bc_draw_quad_cropped_atlas(_tex, _sw, _sh, _cut0[0] * 2, _cut0[1] * 2, _w, _h, _ex, 1, _x, -_e.pivy * _magy, _scx * _ex, _scy, _m, _ox, _oy, _colour, _alpha);
	}
}

/// @function bc_draw_ent_geometry_atlas(tex, sw, sh, imgcut, e, magx, magy, m, x, y, colour, alpha)
function bc_draw_ent_geometry_atlas(_tex, _sw, _sh, _imgcut, _e, _magx, _magy, _m, _x, _y, _colour, _alpha) {
    var _cut_scale = 2
    
	if (_e.extType == 1) {
		bc_draw_curse_atlas(_tex, _sw, _sh, _imgcut, _e, _magx, _magy, _x, _y, _m, _colour, _alpha);
	} else if (_e.extendX == 0 && _e.extendY == 0) {
		var _cut = _imgcut.cuts[_e.img];
		bc_draw_quad_local_atlas(_tex, _sw, _sh, _cut[0] * _cut_scale, _cut[1] * _cut_scale, _cut[2] * _cut_scale, _cut[3] * _cut_scale,
			-_e.pivx * _magx, -_e.pivy * _magy, _cut[2] * _magx, _cut[3] * _magy, _m, _x, _y, _colour, _alpha);
	} else {
		var _cut2 = _imgcut.cuts[_e.img];
		bc_draw_extend_2d_atlas(_tex, _sw, _sh, _cut2[0] * _cut_scale, _cut2[1] * _cut_scale, _cut2[2] * _cut_scale, _cut2[3] * _cut_scale,
			_e.pivx, _e.pivy, _magx, _magy, _e.extendX, _e.extendY, _m, _x, _y, _colour, _alpha);
	}
}

/// @function bc_draw_player_atlas(player, imgcut, atlas_surface, x, y, global_scale)
/// @desc Same behaviour as bc_draw_player, but samples the atlas surface
///       directly instead of using pre-sliced sprites. Call
///       gpu_set_tex_filter(false) beforehand if your art is pixel art
///       and you don't want it blurred.
function bc_draw_player_atlas(_p, _imgcut, _atlas_surface, _x, _y, _global_scale) {
	if (!surface_exists(_atlas_surface)) {
		show_debug_message("bc_draw_player_atlas: atlas surface doesn't exist - recreate/redraw it before calling this");
		return;
	}

	var _sw = surface_get_width(_atlas_surface);
	var _sh = surface_get_height(_atlas_surface);
	var _tex = surface_get_texture(_atlas_surface); // fetched once - not per quad/per part

	var _ents = _p.ents;
	var _model = _p.model;
	var _n = array_length(_ents);
	var _cache = array_create(_n, undefined);
	var _size_cache = array_create(_n, undefined);
	var _opa_cache = array_create(_n, undefined);
	var _order = bc_get_sorted_order(_p);

	for (var oi = 0; oi < _n; oi++) {
		var _idx = _order[oi];
		var _e = _ents[_idx];

		if (_e.img < 0 || _e.mid < 0) continue;
		if (_e.img >= _imgcut.n) continue;

		var _rawAlpha = bc_ent_opa(_ents, _model, _idx, _opa_cache);
		if (_rawAlpha <= 0) continue;

		var _mag = bc_get_size(_ents, _model, _idx, _size_cache);
		var _magx = _mag[0] * _global_scale;
		var _magy = _mag[1] * _global_scale;

		var _m = bc_get_world_matrix(_ents, _model, _idx, _global_scale, _cache, _size_cache);

		var _cd = bc_glow_begin(_e.glow, _rawAlpha);
		bc_draw_ent_geometry_atlas(_tex, _sw, _sh, _imgcut, _e, _magx, _magy, _m, _x, _y, _cd[0], _cd[1]);
		bc_glow_end(_e.glow);
	}
}
