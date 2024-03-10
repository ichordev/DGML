module gml.ds.list;

import gml.ds, gml.maths;

import core.exception, core.memory;
import std.algorithm.sorting, std.conv, std.math, std.random, std.sumtype, std.typecons, std.uni;
import ic.calc, ic.mem;

alias DSVal = SumType!(
	typeof(null),
	string,
	double,
	long,
	DSMap,
	DSList,
);

struct DSList{
	DSVal[] data;
	alias data this;
	
	size_t[2] opSlice() nothrow @nogc pure @safe =>
		[0, data.length];
	size_t[2] opSlice(size_t i, size_t j) nothrow @nogc pure @safe =>
		[i, j];
	
	DSVal opIndexAssign(T)(T val) nothrow @nogc pure @safe{
		const dsVal = DSVal(val);
		data[] = dsVal;
		return dsVal;
	}
	DSVal opIndexAssign(T)(T val, size_t i) nothrow @safe{
		if(i >= data.length){
			data.length = i+1;
		}
		return (() @trusted => data[i] = DSVal(val))();
	}
	DSVal opIndexAssign(T)(T val, size_t[2] r) nothrow @safe{
		if(r[1] >= data.length){
			length = r[1]+1;
		}
		const dsVal = DSVal(val);
		data[r[0]..r[1]] = dsVal;
		return dsVal;
	}
}

DSList dsListCreate() nothrow @nogc @safe =>
	DSList();
alias ds_list_create = dsListCreate;

void dsListDestroy(ref DSList id) nothrow @nogc pure{
	GC.free(id.data.ptr);
	id.data = null;
}
alias ds_list_destroy = dsListDestroy;

void dsListClear(ref DSList id) nothrow @nogc pure{
	dsListDestroy(id);
}
alias ds_list_clear = dsListClear;

bool dsListEmpty(const DSList id) nothrow @nogc pure @safe =>
	id.data.length == 0;
alias ds_list_empty = dsListEmpty;

size_t dsListSize(const DSList id) nothrow @nogc pure @safe =>
	id.data.length;
alias ds_list_size = dsListSize;

void dsListAdd(A...)(ref DSList id, A vals) nothrow pure @safe{
	id.data.length += vals.length;
	() @trusted{
		static foreach(i, val; vals){
			id.data[$-vals.length + i] = DSVal(val);
		}
	}();
}
alias ds_list_add = dsListAdd;

void dsListSet(T)(ref DSList id, size_t pos, T val) nothrow @nogc pure @safe{
	id[pos] = val;
}
alias ds_list_set = dsListSet;

void dsListDelete(ref DSList id, size_t pos) nothrow pure @safe{
	if(pos < id.data.length){
		id.data[pos..id.data.length-1] = id.data[pos+1..id.data.length];
		id.data.length--;
	}
}
alias ds_list_delete = dsListDelete;
unittest{
	auto list = dsListCreate();
	dsListAdd(list, 10, 20, 30, 40, 50);
	dsListDelete(list, 3);
	assert(list.data == [DSVal(10), DSVal(20), DSVal(30), DSVal(50)]);
}

ptrdiff_t dsListFindIndex(T)(const DSList id, T val) nothrow @nogc @safe{
	const dsVal = DSVal(val);
	foreach(ind, item; id){
		if(match!(
			(long a,   long b)   => a == b,
			(double a, double b) => a.eqEps(b, dsPrecision),
			(string a, string b) => a == b,
			(a,        b)        => false,
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

DSVal dsListFindValue(const DSList id, size_t pos) nothrow @nogc pure @safe =>
	id[pos];
alias ds_list_find_value = dsListFindValue;

void dsListInsert(T)(ref DSList id, size_t pos, T val) nothrow pure @safe{
	if(pos < id.data.length){
		id.data.length++;
		() @trusted{
			foreach_reverse(i; pos..id.data.length-1){
				id.data[i+1] = id.data[i];
			}
			id.data[pos] = DSVal(val);
		}();
	}else{
		id[pos] = val;
	}
}
alias ds_list_insert = dsListInsert;
unittest{
	auto list = dsListCreate();
	dsListAdd(list, 8, 7, 6, 5, 3, 2);
	dsListInsert(list, 4, 4);
	assert(list.data == [DSVal(8), DSVal(7), DSVal(6), DSVal(5), DSVal(4), DSVal(3), DSVal(2)]);
	dsListInsert(list, 8, 0);
	assert(list.data == [DSVal(8), DSVal(7), DSVal(6), DSVal(5), DSVal(4), DSVal(3), DSVal(2), DSVal(null), DSVal(0)]);
}

void dsListReplace(T)(ref DSList id, size_t pos, T val) pure @safe{
	if(pos >= id.data.length) throw new ArrayIndexError(pos, id.data.length);
	() @trusted{
		id.data[pos] = DSVal(val);
	}();
}
alias ds_list_replace = dsListReplace;
unittest{
	auto list = dsListCreate();
	dsListAdd(list, 0.0, 0.4, 0.8, 1.2, 1.6, 2.0);
	dsListReplace(list, 4, 1.92);
	assert(list.data == [DSVal(0.0), DSVal(0.4), DSVal(0.8), DSVal(1.2), DSVal(1.92), DSVal(2.0)]);
}

void dsListShuffle(ref DSList id) nothrow @nogc @safe{
	randomShuffle(id.data, gml.maths.rng);
}
alias ds_list_shuffle = dsListShuffle;
unittest{
	auto list = dsListCreate();
	dsListAdd(list, 0,1,2,3,4);
	dsListShuffle(list);
	assert(list.data[0] != DSVal(0));
}

void dsListSort(ref DSList id, bool ascending) nothrow @nogc pure @safe{
	if(ascending){
		id.data.sort!((a, b) => match!(
			(long a,   long b)   => a < b,
			(double a, double b) => a.cmp(b) < 0,
			(string a, string b) => a.sicmp(b) < 0,
			(double a, string b) => true,
			(string a, double b) => false,
			(a,        b)        => false, //TODO: work out how `undefined` is sorted
		)(a, b))();
	}else{
		id.data.sort!((a, b) => match!(
			(long a,   long b)   => a > b,
			(double a, double b) => a.cmp(b) > 0,
			(string a, string b) => a.sicmp(b) > 0,
			(double a, string b) => false,
			(string a, double b) => true,
			(a,        b)        => false,
		)(a, b))();
	}
}
alias ds_list_sort = dsListSort;
unittest{
	auto list = dsListCreate();
	dsListAdd(list, "!5", "5 (number)", 4, 2.5, double.infinity, "cba", "abc");
	dsListSort(list, true);
	assert(list.data == [DSVal(2.5), DSVal(4), DSVal(double.infinity), DSVal("!5"), DSVal("5 (number)"), DSVal("abc"), DSVal("cba")]);
	dsListSort(list, false);
	assert(list.data == [DSVal("cba"), DSVal("abc"), DSVal("5 (number)"), DSVal("!5"), DSVal(double.infinity), DSVal(4), DSVal(2.5)]);
}

void dsListCopy(ref DSList id, const DSList source) nothrow pure @safe{
	id.data = new DSVal[](source.data.length);
	id.data[] = source.data[];
}
alias ds_list_copy = dsListCopy;

//TODO: ds_list_read

//TODO: ds_list_write

///Does nothing, because `DSList`s added to a DSList are marked automatically.
DSList dsListMarkAsList(DSList id, size_t pos) nothrow @nogc pure @safe =>
	id;
alias ds_list_mark_as_list = dsListMarkAsList;

///Does nothing, because `DSMap`s added to a DSList are marked automatically.
DSList dsListMarkAsMap(DSList id, size_t pos) nothrow @nogc pure @safe =>
	id;
alias ds_list_mark_as_map = dsListMarkAsMap;

bool dsListIsList(DSList id, size_t pos) nothrow @nogc pure @safe{
	if(pos >= id.data.length) return false;
	return id.data[pos].match!(
		(DSList a) => true,
		(a)        => false,
	);
}
alias ds_list_is_list = dsListIsList;

bool dsListIsMap(DSList id, size_t pos) nothrow @nogc pure @safe{
	if(pos >= id.data.length) return false;
	return id.data[pos].match!(
		(DSMap a) => true,
		(a)       => false,
	);
}
alias ds_list_is_map = dsListIsMap;
