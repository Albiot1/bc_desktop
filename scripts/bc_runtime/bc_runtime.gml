// ============================================================
// bc_runtime.gml  (updated: id -> mid, curse-cycle rotation added)
// ============================================================

/// @function bc_jmod(a, n)
/// @desc Java-style truncated modulo: result keeps the sign of `a` (or is
///       0), matching Java's `%` exactly - e.g. bc_jmod(-5,30) == -5, NOT
///       25. This matters because MaAnim.update()/Part.off rely on that
///       exact truncation behavior (a part's `off` can be negative when
///       its first keyframe isn't at frame 0, and the frame math is
///       supposed to stay negative - i.e. "before the first keyframe" -
///       until the global counter catches up). GML's own `mod`/`%` may or
///       may not floor negative results depending on version, so this
///       sidesteps the question entirely instead of trusting it.
function bc_jmod(_a, _n) {
	if (_n == 0) return 0;
	var _q = _a / _n;
	var _qt = (_q >= 0) ? floor(_q) : ceil(_q); // truncate toward zero
	return _a - _n * _qt;
}

function bc_part_get_max(_part) {
	if (_part.ints[2] != -1) {
		return (_part.ints[2] > 1)
			? _part.fir + (_part.max - _part.fir) * _part.ints[2] - _part.off
			: _part.max - _part.off;
	} else {
		return _part.max - min(_part.off, 0);
	}
}

function bc_ent_setup(_model) {
	var _n = _model.n;
	var _ents = array_create(_n);
	for (var i = 0; i < _n; i++) {
		_ents[i] = {
			par: -1, mid: 0, img: 0, z: 0,
			posx: 0, posy: 0, pivx: 0, pivy: 0,
			scax: 0, scay: 0, angle: 0, opacity: 0,
			glow: 0, gsca: 1, hf: 1, vf: 1,
			extType: 0, extendX: 0, extendY: 0
		};
	}
	bc_ent_reset(_ents, _model);
	return _ents;
}

function bc_ent_reset(_ents, _model) {
	var _n = array_length(_ents);
	for (var i = 0; i < _n; i++) {
		var _args = _model.parts[i];
		var _e = _ents[i];

		_e.par = (_args[0] >= _n) ? 0 : _args[0];
		_e.mid = _args[1];
		_e.img = _args[2];
		_e.z = _args[3] * _n + i;
		_e.posx = _args[4]; _e.posy = _args[5];
		_e.pivx = _args[6]; _e.pivy = _args[7];
		_e.scax = _args[8]; _e.scay = _args[9];
		_e.angle = _args[10];
		_e.opacity = _args[11];
		_e.glow = _args[12];
		_e.gsca = _model.ints[0];
		_e.hf = 1; _e.vf = 1;
		_e.extType = 0;
		_e.extendX = 0; _e.extendY = 0;
	}
}

function bc_is_parent_valid(_ents, _start_idx) {
	var _visited = ds_list_create();
	var _cur = _start_idx;
	var _ok = true;
	while (true) {
		if (ds_list_find_index(_visited, _cur) != -1) { _ok = false; break; }
		ds_list_add(_visited, _cur);
		var _fa = _ents[_cur].par;
		if (_fa == -1 || _fa == 0) { _ok = true; break; }
		_cur = _fa;
	}
	ds_list_destroy(_visited);
	return _ok;
}

// ---------- shared "curse" random-image cycle state ----------
// Mirrors ImgCore's `protected static List<Integer> randSeries` - a single
// list shared by every curse-type (extType==1) part in the whole game,
// exactly like the Java static field. Entries are lazily created (with a
// random 0-3 pick) the first time bc_render draws a given tile index, and
// rotated +1 (mod 4) here whenever that part's displayed image changes.
function bc_rand_series_ensure_init() {
	if (!variable_global_exists("bc_rand_series")) global.bc_rand_series = [];
}

function bc_rand_series_rotate_all() {
	bc_rand_series_ensure_init();
	for (var i = 0; i < array_length(global.bc_rand_series); i++) {
		var _r = global.bc_rand_series[i] + 1;
		if (_r > 3) _r = 0;
		global.bc_rand_series[i] = _r;
	}
}

/// @function bc_ent_alter(ents, model, idx, m, v)
/// @desc Mirrors EPart.alter(int m, float v) in EPart.java
function bc_ent_alter(_ents, _model, _idx, _m, _v) {
	var _e = _ents[_idx];
	var _args = _model.parts[_idx];
	var _n = array_length(_ents);

	switch (_m) {
		case 0:
			if (_v < _n && _v >= 0 && _v != _idx) {
				_e.par = _v;
				if (!bc_is_parent_valid(_ents, _idx)) _e.par = 0;
			} else {
				_e.par = 0;
			}
			break;
		case 1: _e.mid = _v; break;
		case 2:
			// mirrors: if (extType==1 && img != v) rotate randSeries entries
			if (_e.extType == 1 && _e.img != _v) bc_rand_series_rotate_all();
			_e.img = _v;
			break;
		case 3: _e.z = _v * _n + _idx; break;
		case 4: _e.posx = _args[4] + _v; break;
		case 5: _e.posy = _args[5] + _v; break;
		case 6: _e.pivx = _args[6] + _v; break;
		case 7: _e.pivy = _args[7] + _v; break;
		case 8:
			_e.scax = _args[8] * _v / _model.ints[0];
			_e.scay = _args[9] * _v / _model.ints[0];
			break;
		case 53: _e.gsca = _v; break;
		case 9:  _e.scax = _args[8] * _v / _model.ints[0]; break;
		case 10: _e.scay = _args[9] * _v / _model.ints[0]; break;
		case 11: _e.angle = _args[10] + _v; break;
		case 12: _e.opacity = _v * _args[11] / _model.ints[2]; break;
		case 13: _e.hf = (_v == 0) ? 1 : -1; break;
		case 14: _e.vf = (_v == 0) ? 1 : -1; break;
		case 50: _e.extendX = _v; _e.extType = 0; break;
		case 51: _e.extendX = _v; _e.extType = 1; break;
		case 52: _e.extendY = _v; _e.extType = 0; break;
		default:
			show_debug_message("bc_ent_alter: unhandled modification " + string(_m));
			break;
	}
}

function bc_ease3(_part, _i, _frame) {
	var _moves = _part.moves;
	var _low = _i, _high = _i;

	for (var j = _i - 1; j >= 0; j--) {
		if (_moves[j][2] == 3) _low = j; else break;
	}
	for (var j = _i + 1; j < array_length(_moves); j++) {
		_high = j;
		if (_moves[j][2] != 3) break;
	}

	var _sum = 0;
	for (var j = _low; j <= _high; j++) {
		var _val = _moves[j][1] * 4096; //check if multiplying is needed... (as i think its some java nonsense thingy)
		for (var k = _low; k <= _high; k++) {
			if (j != k) _val *= (_frame - _moves[k][0]) / (_moves[j][0] - _moves[k][0]);
		}
		_sum += _val;
	}
	return floor(_sum / 4096); //check if dividing is needed...
}

function bc_ensure_last(_part, _ents, _model) {
	if (_part.n == 0) return;
	var _last = _part.moves[_part.n - 1];
	bc_ent_alter(_ents, _model, _part.ints[0], _part.ints[1], _last[1]);
}

function bc_part_update(_part, _frame, _ents, _model) {
	var _n = _part.n;
	var _moves = _part.moves;
	var _target = _part.ints[0];
	var _modtype = _part.ints[1];

	for (var i = 0; i < _n; i++) {
		var _mv = _moves[i];

		if (_frame == _mv[0]) {
			bc_ent_alter(_ents, _model, _target, _modtype, _mv[1]);
		} else if (i < _n - 1 && _frame > _mv[0] && _frame < _moves[i + 1][0]) {
			if (_modtype > 1) {
				var _f0 = _mv[0], _v0 = _mv[1];
				var _nv = _moves[i + 1];
				var _f1 = _nv[0], _v1 = _nv[1];

				var _realFrame = _frame;
				if (_f1 - _f0 == 1) _realFrame = floor(_frame);

				var _easing = _mv[2];
				var _param = _mv[3];
				var _ti;

				if (_easing == 1 || _modtype == 13 || _modtype == 14) {
					_ti = 0;
				} else if (_easing == 0) {
					_ti = (_realFrame - _f0) / (_f1 - _f0);
				} else if (_easing == 2) {
					_ti = (_realFrame - _f0) / (_f1 - _f0);
					var _easePower = (_param != 0) ? _param : 1;
					var _tiC = clamp(_ti, 0, 1);
					var _easeFactor;
					if (_easePower >= 0)
						_easeFactor = 1 - sqrt(1 - power(_tiC, _easePower));
					else
						_easeFactor = sqrt(1 - power(1 - _tiC, -_easePower));
					if (!is_nan(_easeFactor)) _ti = _easeFactor;
				} else if (_easing == 3) {
					var _vd3 = bc_ease3(_part, i, _realFrame);
					bc_ent_alter(_ents, _model, _target, _modtype, _vd3);
					break;
				} else if (_easing == 4) {
					_ti = (_realFrame - _f0) / (_f1 - _f0);
					if (_param > 0) _ti = 1 - cos(_ti * pi / 2);
					else if (_param < 0) _ti = sin(_ti * pi / 2);
					else _ti = (1 - cos(_ti * pi)) / 2;
				} else {
					_ti = 1;
				}

				var _vd;
				if (_modtype == 2) {
					_vd = (_v1 - _v0 < 0) ? ceil((_v1 - _v0) * _ti + _v0) : floor((_v1 - _v0) * _ti + _v0);
				} else {
					_vd = _v0 + floor((_v1 - _v0) * _ti);
				}

				bc_ent_alter(_ents, _model, _target, _modtype, _vd);
				break;
			} else if (_modtype == 0) {
				bc_ent_alter(_ents, _model, _target, _modtype, _mv[1]);
			}
		}
	}

	if (_n > 0 && _frame > _moves[_n - 1][0]) {
		bc_ensure_last(_part, _ents, _model);
	}
}

function bc_maanim_update(_maanim, _ents, _model, _f, _rotate) {
	var _max = _maanim.max;
	var _frameF = _f;
	if (_rotate) _frameF = bc_jmod(_frameF, _max + 1);

	if (_frameF == 0) bc_ent_reset(_ents, _model);

	for (var i = 0; i < _maanim.n; i++) {
		var _part = _maanim.parts[i];
		var _loop = _part.ints[2];
		var _smax = _part.max;
		var _fir = _part.fir;
		var _lmax = _smax - _fir;
		var _prot = _rotate || (_loop == -1);

		var _frame;
		if (_prot) {
			var _mf = (_loop == -1) ? _smax : (_max + 1);
			_frame = (_mf == 0) ? 0 : bc_jmod(_frameF + _part.off, _mf);
		} else {
			_frame = _frameF + _part.off;
		}

		if (_loop > 0 && _lmax != 0) {
			if (_frame > _fir + _loop * _lmax) {
				bc_ensure_last(_part, _ents, _model);
				continue;
			}
			if (_frame <= _fir) {
				// no-op, matches Java's empty branch
			} else if (_frame < _fir + _loop * _lmax) {
				_frame = _fir + bc_jmod(_frame - _fir, _lmax);
			} else {
				_frame = _smax;
			}
		}

		bc_part_update(_part, _frame, _ents, _model);
	}
}

// ------------------------------------------------------------
// Player wrapper
// ------------------------------------------------------------

function bc_player_create(_model, _maanim) {
    return {
		model: _model,
		maanim: _maanim,
		ents: bc_ent_setup(_model),
		f: -1,
		z_order: undefined,
		z_snapshot: undefined
	};
}

function bc_player_setup(_p) {
	_p.f = 0;
	bc_maanim_update(_p.maanim, _p.ents, _p.model, 0, false);
}

function bc_player_set_time(_p, _value) {
	if (_p.f == -1) bc_player_setup(_p);
	_p.f = _value;
	bc_maanim_update(_p.maanim, _p.ents, _p.model, _value, true);
}

function bc_player_step(_p, _rotate) {
	if (_p.f == -1) {
		_p.f = 0;
	} else {
		_p.f += 1;
	}
	bc_maanim_update(_p.maanim, _p.ents, _p.model, _p.f, _rotate);
}

function bc_player_done(_p) {
	return _p.f >= _p.maanim.max;
}
