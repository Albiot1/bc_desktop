// ============================================================
// bc_parser.gml
// Text parsers for .imgcut / .mamodel / .maanim files.
// Each function mirrors the matching Java constructor line-for-line
// (ImgCut(Queue<String>), MaModel(Queue<String>), MaAnim(Queue<String>,bool),
//  Part(Queue<String>,bool)) so the on-disk format is read identically.
//
// Assumes a modern GML runtime (string_split, string_trim available).
// Uses file_text_* since the format is strictly line-based - this
// mirrors the Java Queue<String> "poll one line at a time" approach.
// ============================================================

/// @function bc_load_imgcut(path)
/// @desc Mirrors ImgCut(Queue<String>) in ImgCut.java
function bc_load_imgcut(_path) {
	var _f = file_text_open_read(_path);
	if (_f == -1) {
		show_debug_message("bc_load_imgcut: could not open " + string(_path));
		return undefined;
	}

	file_text_readln(_f); // "[imgcut]"
	file_text_readln(_f); // "0"
	var _name = file_text_readln(_f);
	var _n = real(string_trim(file_text_readln(_f)));

	var _cuts = array_create(_n);
	var _strs = array_create(_n);

	for (var i = 0; i < _n; i++) {
		var _tok = string_split(file_text_readln(_f), ",");
		var _cut = array_create(4);
		for (var j = 0; j < 4; j++) _cut[j] = real(string_trim(_tok[j]));
		_cuts[i] = _cut;
		_strs[i] = (array_length(_tok) >= 5) ? string_trim(_tok[4]) : "";
	}

	file_text_close(_f);

	return { name: _name, n: _n, cuts: _cuts, strs: _strs };
}

/// @function bc_load_mamodel(path)
/// @desc Mirrors MaModel(Queue<String>) in MaModel.java
function bc_load_mamodel(_path) {
	var _f = file_text_open_read(_path);
	if (_f == -1) {
		show_debug_message("bc_load_mamodel: could not open " + string(_path));
		return undefined;
	}

	file_text_readln(_f); // "[mamodel]"
	file_text_readln(_f); // "3"
	var _n = real(string_trim(file_text_readln(_f)));

	var _parts = array_create(_n);
	var _strs0 = array_create(_n);

	for (var i = 0; i < _n; i++) {
		var _tok = string_split(file_text_readln(_f), ",");
		var _p = array_create(13);
		for (var j = 0; j < 13; j++) _p[j] = real(string_trim(_tok[j]));
		_parts[i] = _p;
		_strs0[i] = (array_length(_tok) == 14) ? string_trim(_tok[13]) : "";
	}

	var _itok = string_split(file_text_readln(_f), ",");
	var _ints = [
		real(string_trim(_itok[0])),
		real(string_trim(_itok[1])),
		real(string_trim(_itok[2]))
	];

	var _m = real(string_trim(file_text_readln(_f)));
	var _confs = array_create(_m);
	var _strs1 = array_create(_m);

	for (var i = 0; i < _m; i++) {
		var _ctok = string_split(file_text_readln(_f), ",");
		var _c = array_create(6);
		for (var j = 0; j < 6; j++) _c[j] = real(string_trim(_ctok[j]));
		_confs[i] = _c;
		_strs1[i] = (array_length(_ctok) == 7) ? string_trim(_ctok[6]) : "";
	}

	file_text_close(_f);

	return { n: _n, m: _m, ints: _ints, parts: _parts, confs: _confs, strs0: _strs0, strs1: _strs1 };
}

/// @function bc_load_part(file_handle)
/// @desc Mirrors Part(Queue<String>, isOld) in Part.java. isOld handling
///       (remap old modtype 8 -> 53) is NOT applied here - add it if you
///       are reading legacy-format files.
function bc_load_part(_f) {
	var _tok = string_split(file_text_readln(_f), ",");
	var _ints = array_create(5);
	for (var i = 0; i < 5; i++) _ints[i] = real(string_trim(_tok[i]));
	var _name = (array_length(_tok) == 6) ? string_trim(_tok[5]) : "";

	var _n = real(string_trim(file_text_readln(_f)));
	var _moves = array_create(_n);
	for (var i = 0; i < _n; i++) {
		var _mtok = string_split(file_text_readln(_f), ",");
		var _mv = array_create(4);
		for (var j = 0; j < 4; j++) _mv[j] = real(string_trim(_mtok[j]));
		_moves[i] = _mv;
	}

	var _part = { ints: _ints, name: _name, n: _n, moves: _moves, off: 0, fir: 0, max: 0 };
	bc_part_validate(_part);
	return _part;
}

/// @function bc_part_validate(part)
/// @desc Mirrors Part.validate() in Part.java
function bc_part_validate(_part) {
	var _doff = 0;
	if (_part.n != 0 && (_part.moves[0][0] - _part.off < 0 || _part.ints[2] != 1))
		_doff -= _part.moves[0][0];

	for (var i = 0; i < _part.n; i++) _part.moves[i][0] += _doff;
	_part.off += _doff;

	_part.fir = (array_length(_part.moves) == 0) ? 0 : _part.moves[0][0];
	_part.max = (_part.n > 0) ? _part.moves[_part.n - 1][0] : 0;
}

/// @function bc_load_maanim(path)
/// @desc Mirrors MaAnim(Queue<String>, isOld) + MaAnim.validate() in MaAnim.java
function bc_load_maanim(_path) {
	var _f = file_text_open_read(_path);
	if (_f == -1) {
		show_debug_message("bc_load_maanim: could not open " + string(_path));
		return undefined;
	}

	file_text_readln(_f); // "[maanim]"
	file_text_readln(_f); // "1"
	var _n = real(string_trim(file_text_readln(_f)));

	var _parts = array_create(_n);
	for (var i = 0; i < _n; i++) _parts[i] = bc_load_part(_f);

	file_text_close(_f);

	// mirrors MaAnim.validate(): clamp negative imgcut-index keyframes on modtype 2,
	// then compute overall clip length as max of each part's effective length.
	for (var i = 0; i < _n; i++) {
		var _p = _parts[i];
		if (_p.ints[1] == 2) {
			for (var j = 0; j < array_length(_p.moves); j++)
				if (_p.moves[j][1] < 0) _p.moves[j][1] = 0;
		}
	}

	var _max = 1;
	for (var i = 0; i < _n; i++) _max = max(_max, bc_part_get_max(_parts[i]));

	return { n: _n, parts: _parts, max: _max };
}
