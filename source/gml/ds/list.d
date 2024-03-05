module gml.ds.list;

import gml.ds, gml.maths;

import core.exception;
import std.algorithm.sorting, std.conv, std.math, std.random, std.sumtype, std.typecons, std.uni;
import ic.calc, ic.mem;

struct DSList{
	private DSVal[] _data = null;
	private size_t _length = 0;
	
	@property length() nothrow @nogc pure @safe => _length;
	@property length(size_t val) nothrow @nogc @trusted{
		if(val == 0){
			freeData();
			return;
		}
		if(_data is null){
			_data = alloc!DSVal(val + 16);
		}else if(val > _data.length){
			_data = _data.resize(val + 16);
		}else if(val < cast(long)(_data.length) - 8L){
			_data = _data.resize(val + 8);
		}
		_length = val;
	}
	@property capacity() nothrow @nogc pure @safe => _data.length;
	
	enum opApplyTempl(string attribs) = `
	int opApply(scope int delegate(ref DSVal item) `~attribs~` dg) `~attribs~`{
		foreach(item; _data){
			int result = dg(item);
			if(result) return result;
		}
		return 0;
	}
	int opApply(scope int delegate(size_t i, ref DSVal item) `~attribs~` dg) `~attribs~`{
		foreach(i, item; _data){
			int result = dg(i, item);
			if(result) return result;
		}
		return 0;
	}`;
	mixin(opApplyTempl!q{});
	mixin(opApplyTempl!q{nothrow});
	mixin(opApplyTempl!q{@nogc});
	mixin(opApplyTempl!q{pure});
	mixin(opApplyTempl!q{@safe});
	mixin(opApplyTempl!q{nothrow @nogc});
	mixin(opApplyTempl!q{@nogc pure});
	mixin(opApplyTempl!q{@nogc @safe});
	mixin(opApplyTempl!q{pure @safe});
	mixin(opApplyTempl!q{@nogc pure @safe});
	mixin(opApplyTempl!q{nothrow @nogc pure});
	mixin(opApplyTempl!q{nothrow pure});
	mixin(opApplyTempl!q{nothrow @safe});
	mixin(opApplyTempl!q{nothrow @nogc @safe});
	mixin(opApplyTempl!q{nothrow @nogc pure});
	mixin(opApplyTempl!q{nothrow pure @safe});
	mixin(opApplyTempl!q{nothrow @nogc pure @safe});
	
	DSVal opIndex(size_t i) nothrow @nogc pure @safe =>
		i < _length ? _data[i] : DSVal(null);
	
	size_t[2] opSlice() nothrow @nogc pure @safe =>
		[0, _length];
	size_t[2] opSlice(size_t i, size_t j) pure @safe =>
		[i, j];
	
	DSVal opIndexAssign(T)(T val) nothrow @nogc pure @safe{
		const dsVal = DSVal(val);
		_data[] = dsVal;
		return dsVal;
	}
	DSVal opIndexAssign(T)(T val, size_t i) nothrow @nogc @safe{
		if(i >= _length){
			length = i+1;
		}
		return (() @trusted => _data[i] = DSVal(val))();
	}
	DSVal opIndexAssign(T)(T val, size_t[2] r) nothrow @nogc @safe{
		if(r[1] >= _length){
			length = r[1]+1;
		}
		const dsVal = DSVal(val);
		_data[r[0]..r[1]] = dsVal;
		return dsVal;
	}
	
	private void freeData() nothrow @nogc @trusted{
		if(_data !is null){
			free(_data);
			_data = null;
			_length = 0;
		}
	}
	
	string toString() pure @safe =>
		text(_data[0.._length]);
	
	~this() nothrow @nogc @safe{
		freeData();
	}
}

DSList* dsListCreate() nothrow @nogc @safe =>
	alloc!DSList;
alias ds_list_create = dsListCreate;

void dsListDestroy(DSList* id) nothrow @nogc{
	free(id);
}
alias ds_list_destroy = dsListDestroy;

void dsListClear(DSList* id) nothrow @nogc @safe{
	id.freeData();
}
alias ds_list_clear = dsListClear;

bool dsListEmpty(DSList* id) nothrow @nogc pure @safe =>
	id._length == 0;
alias ds_list_empty = dsListEmpty;

size_t dsListSize(DSList* id) nothrow @nogc pure @safe =>
	id._length;
alias ds_list_size = dsListSize;

void dsListAdd(A...)(DSList* id, A vals) nothrow @nogc @safe{
	const start = id._length;
	if(id.capacity < id._length + vals.length){
		id.length = id._length + vals.length;
	}
	() @trusted{
		static foreach(i, val; vals){
			id._data[start+i] = DSVal(val);
		}
	}();
}
alias ds_list_add = dsListAdd;

void dsListSet(T)(DSList* id, size_t pos, T val) nothrow @nogc pure @safe{
	id[pos] = val;
}
alias ds_list_set = dsListSet;

void dsListDelete(DSList* id, size_t pos) nothrow @nogc pure @safe{
	if(pos < id._length){
		id._data[pos..id._length-1] = id._data[pos+1..id._length];
		id._length--;
	}
}
alias ds_list_delete = dsListDelete;
unittest{
	auto list = dsListCreate();
	dsListAdd(list, 10, 20, 30, 40, 50);
	dsListDelete(list, 3);
	assert(list._data[0..list._length] == [DSVal(10), DSVal(20), DSVal(30), DSVal(50)]);
}

ptrdiff_t dsListFindIndex(T)(DSList* id, T val) nothrow @nogc @safe{
	const dsVal = DSVal(val);
	foreach(ind, item; *id){
		if(match!(
			(long a, long b) => a == b,
			(double a, double b) => a.eqEps(b, dsPrecision),
			(string a, string b) => a == b,
			(a, b) => false,
		)(item, dsVal)){
			return ind;
		}
	}
	return -1;
}
alias ds_list_find_index = dsListFindIndex;
unittest{
	auto list = dsListCreate();
	dsListAdd(list, 1, 5, 7.5, "a", "b", "c", "d", "e", "f");
	assert(dsListFindIndex(list, "d") == 6);
}

DSVal dsListFindValue(DSList* id, size_t pos) nothrow @nogc pure @safe =>
	(*id)[pos];
alias ds_list_find_value = dsListFindValue;

void dsListInsert(T)(DSList* id, size_t pos, T val) nothrow @nogc @safe{
	if(pos < id._length){
		const size_t endPos = id._length;
		id.length = endPos+1;
		() @trusted{
			foreach_reverse(i; pos..endPos){
				id._data[i+1] = id._data[i];
			}
			id._data[pos] = DSVal(val);
		}();
	}else{
		(*id)[pos] = val;
	}
}
alias ds_list_insert = dsListInsert;
unittest{
	auto list = dsListCreate();
	dsListAdd(list, 8, 7, 6, 5, 3, 2);
	dsListInsert(list, 4, 4);
	assert(list._data[0..list._length] == [DSVal(8), DSVal(7), DSVal(6), DSVal(5), DSVal(4), DSVal(3), DSVal(2)]);
	dsListInsert(list, 8, 0);
	assert(list._data[0..list._length] == [DSVal(8), DSVal(7), DSVal(6), DSVal(5), DSVal(4), DSVal(3), DSVal(2), DSVal(null), DSVal(0)]);
}

void dsListReplace(T)(DSList* id, size_t pos, T val) pure @safe{
	if(pos >= id._length) throw new ArrayIndexError(pos, id._length);
	() @trusted{
		id._data[pos] = DSVal(val);
	}();
}
alias ds_list_replace = dsListReplace;
unittest{
	auto list = dsListCreate();
	dsListAdd(list, 0.0, 0.4, 0.8, 1.2, 1.6, 2.0);
	dsListReplace(list, 4, 1.92);
	assert(list._data[0..list._length] == [DSVal(0.0), DSVal(0.4), DSVal(0.8), DSVal(1.2), DSVal(1.92), DSVal(2.0)]);
}

void dsListShuffle(DSList* id) nothrow @nogc @safe{
	randomShuffle(id._data[0..id._length], gml.maths.rng);
}
alias ds_list_shuffle = dsListShuffle;
unittest{
	auto list = dsListCreate();
	dsListAdd(list, 0,1,2,3,4);
	dsListShuffle(list);
	assert(list._data[0..list._length][0] != DSVal(0));
}

void dsListSort(DSList* id, bool ascending) nothrow @nogc pure @safe{
	if(ascending){
		id._data[0..id._length].sort!((a, b) => match!(
			(long a, long b) => a < b,
			(double a, double b) => a.cmp(b) < 0,
			(string a, string b) => a.sicmp(b) < 0,
			(double a, string b) => true,
			(string a, double b) => false,
			(a, b) => false, //TODO: work out how `undefined` is sorted
		)(a, b))();
	}else{
		id._data[0..id._length].sort!((a, b) => match!(
			(long a, long b) => a > b,
			(double a, double b) => a.cmp(b) > 0,
			(string a, string b) => a.sicmp(b) > 0,
			(double a, string b) => false,
			(string a, double b) => true,
			(a, b) => false,
		)(a, b))();
	}
}
alias ds_list_sort = dsListSort;
unittest{
	auto list = dsListCreate();
	dsListAdd(list, "!5", "5 (number)", 4, 2.5, double.infinity, "cba", "abc");
	dsListSort(list, true);
	assert(list._data[0..list._length] == [DSVal(2.5), DSVal(4), DSVal(double.infinity), DSVal("!5"), DSVal("5 (number)"), DSVal("abc"), DSVal("cba")]);
	dsListSort(list, false);
	assert(list._data[0..list._length] == [DSVal("cba"), DSVal("abc"), DSVal("5 (number)"), DSVal("!5"), DSVal(double.infinity), DSVal(4), DSVal(2.5)]);
}


