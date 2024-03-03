module gml.ds.list;

import gml.ds;

import ic.mem;

struct DSList{
	private DSItem[] _data = null;
	private size_t _length = 0;
	
	@property length() nothrow @nogc pure @safe => _length;
	@property length(size_t val) nothrow @nogc @trusted{
		if(val == 0){
			freeData();
			return;
		}
		if(_data is null){
			_data = alloc!DSItem(val + 16);
		}else if(val > _data.length){
			_data = _data.resize(val + 16);
		}else if(val < cast(long)(_data.length) - 8L){
			_data = _data.resize(val + 8);
		}
		_length = val;
	}
	@property capacity() nothrow @nogc pure @safe => _data.length;
	
	DSItem opIndex(size_t i) nothrow @nogc pure @safe =>
		i < _length ? _data[i] : DSItem(null);
	
	DSItem opIndexAssign(T)(T val, size_t i) nothrow @nogc pure @safe{
		if(i >= _length){
			length = i+1;
		}
		return _data[i] = DSItem(val);
	}
	
	private void freeData() nothrow @nogc @trusted{
		if(_data !is null){
			free(_data);
			_data = null;
			_length = 0;
		}
	}
	
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
			id._data[start+i] = DSItem(val);
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
	import std; writeln(list._data[0..list._length]);
}
