module gml.ds.list;

import gml.ds.map, gml.maths;

import core.exception, core.memory;
import std.algorithm.sorting, std.conv, std.math, std.random, std.typecons, std.variant, std.uni;

void init(){
	
}

void quit(){
	
}

struct DSList{
	Variant[] data;
	alias data this;
	
	size_t[2] opSlice() nothrow @nogc pure @safe =>
		[0, data.length];
	size_t[2] opSlice(size_t i, size_t j) nothrow @nogc pure @safe =>
		[i, j];
	
	Variant opIndexAssign(T)(T val) nothrow @nogc pure @safe{
		const varVal = Variant(val);
		data[] = varVal;
		return varVal;
	}
	Variant opIndexAssign(T)(T val, size_t i) @safe{
		if(i >= data.length){
			const start = data.length;
			data.length = i+1;
			() @trusted{
				data[start..$-1] = Variant(null);
			}();
		}
		return (() @trusted => data[i] = Variant(val))();
	}
	Variant opIndexAssign(T)(T val, size_t[2] r) nothrow @safe{
		if(r[1] >= data.length){
			const start = data.length;
			data.length = r[1]+1;
			() @trusted{
				data[start..r[0]] = Variant(null);
			}();
		}
		const varVal = Variant(val);
		data[r[0]..r[1]] = varVal;
		return varVal;
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

void dsListAdd(A...)(ref DSList id, A vals) @safe{
	id.data.length += vals.length;
	() @trusted{
		static foreach(i, val; vals){
			id.data[$-vals.length + i] = Variant(val);
		}
	}();
}
alias ds_list_add = dsListAdd;

void dsListSet(T)(ref DSList id, size_t pos, T val) nothrow @nogc pure @safe{
	id[pos] = val;
}
alias ds_list_set = dsListSet;

void dsListDelete(ref DSList id, size_t pos) nothrow{
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
	assert(list.data == [Variant(10), Variant(20), Variant(30), Variant(50)]);
}

ptrdiff_t dsListFindIndex(T)(const DSList id, T val){
	static if(!__traits(isFloating, T)){
		const dsVal = Variant(val);
	}
	foreach(ind, item; id){
		try{
			static if(__traits(isFloating, T)){
				double itemDouble = item.coerce!double();
				if(val.eqEps(itemDouble, dsPrecision)){
					return ind;
				}
			}else{
				if(dsVal == item){
					return ind;
				}
			}
		}catch(Exception ex){
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

Variant dsListFindValue(const DSList id, size_t pos) nothrow =>
	id[pos];
alias ds_list_find_value = dsListFindValue;

void dsListInsert(T)(ref DSList id, size_t pos, T val) @safe{
	if(pos < id.data.length){
		id.data.length++;
		() @trusted{
			foreach_reverse(i; pos..id.data.length-1){
				id.data[i+1] = id.data[i];
			}
			id.data[pos] = Variant(val);
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
	assert(list.data == [Variant(8), Variant(7), Variant(6), Variant(5), Variant(4), Variant(3), Variant(2)]);
	dsListInsert(list, 8, 0);
	assert(list.data == [Variant(8), Variant(7), Variant(6), Variant(5), Variant(4), Variant(3), Variant(2), Variant(null), Variant(0)]);
}

void dsListReplace(T)(ref DSList id, size_t pos, T val) @safe{
	if(pos >= id.data.length) throw new ArrayIndexError(pos, id.data.length);
	() @trusted{
		id.data[pos] = Variant(val);
	}();
}
alias ds_list_replace = dsListReplace;
unittest{
	auto list = dsListCreate();
	dsListAdd(list, 0.0, 0.4, 0.8, 1.2, 1.6, 2.0);
	dsListReplace(list, 4, 1.92);
	assert(list.data == [Variant(0.0), Variant(0.4), Variant(0.8), Variant(1.2), Variant(1.92), Variant(2.0)]);
}

void dsListShuffle(ref DSList id) nothrow @nogc @safe{
	id.data.randomShuffle(gml.maths.rng);
}
alias ds_list_shuffle = dsListShuffle;
unittest{
	auto list = dsListCreate();
	dsListAdd(list, 0,1,2,3,4);
	dsListShuffle(list);
	assert(list.data[0] != Variant(0));
}

void dsListSort(ref DSList id, bool ascending){
	if(ascending){
		id.data.sort!((a, b){
			if(a.convertsTo!long && b.convertsTo!long){
				return a.coerce!long() < b.coerce!long();
			}
			if(a.convertsTo!double && b.convertsTo!double){
				return a.coerce!double().cmp(b.coerce!double()) < 0;
			}
			if(a.convertsTo!string && b.convertsTo!string){
				return a.coerce!string().sicmp(b.coerce!string()) < 0;
			}
			if(a.convertsTo!double && b.convertsTo!string){
				return true;
			}/*else if(a.convertsTo!string && b.convertsTo!double){
				return false;
			}*/
			return false; //TODO: work out how `undefined` is sorted
		})();
	}else{
		id.data.sort!((a, b){
			if(a.convertsTo!long && b.convertsTo!long){
				return a.coerce!long() > b.coerce!long();
			}
			if(a.convertsTo!double && b.convertsTo!double){
				return a.coerce!double().cmp(b.coerce!double()) > 0;
			}
			if(a.convertsTo!string && b.convertsTo!string){
				return a.coerce!string().sicmp(b.coerce!string()) > 0;
			}
			/*if(a.convertsTo!double && b.convertsTo!string){
				return false;
			}else */if(a.convertsTo!string && b.convertsTo!double){
				return true;
			}
			return false; //TODO: work out how `undefined` is sorted
		})();
	}
}
alias ds_list_sort = dsListSort;
unittest{
	auto list = dsListCreate();
	dsListAdd(list, "!5", "5 (number)", 4, 2.5, double.infinity, "cba", "abc");
	dsListSort(list, true);
	assert(list.data == [Variant(2.5), Variant(4), Variant(double.infinity), Variant("!5"), Variant("5 (number)"), Variant("abc"), Variant("cba")]);
	dsListSort(list, false);
	assert(list.data == [Variant("cba"), Variant("abc"), Variant("5 (number)"), Variant("!5"), Variant(double.infinity), Variant(4), Variant(2.5)]);
}

void dsListCopy(ref DSList id, const DSList source) nothrow{
	id.data = new Variant[](source.data.length);
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

bool dsListIsList(const DSList id, size_t pos){
	if(pos >= id.data.length) return false;
	return id.data[pos].peek!DSList() !is null;
}
alias ds_list_is_list = dsListIsList;

bool dsListIsMap(const DSList id, size_t pos){
	if(pos >= id.data.length) return false;
	return id.data[pos].peek!DSMap() !is null;
}
alias ds_list_is_map = dsListIsMap;
