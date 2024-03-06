module gml.ds.map;

import gml.ds;

struct DSMap(Key, Val){
	alias KeyT = Key;
	alias ValT = Val;
	
	ValT[KeyT] data;
	alias data this;
	
	ValT opIndex(KeyT key) nothrow @nogc pure @safe =>
		data[key];
	
	ValT opIndexAssign(ValT val, KeyT key) nothrow pure @safe{
		return data[key] = val;
	}
}

enum isDSMap(T) = is(T TT: DSMap!(K, V), K, V);

bool dsMapExists(Map)(const Map id, Map.KeyT key) nothrow @nogc pure @safe
if(isDSMap!Map) =>
	key in id.data;

DSMap!(K, V) dsMapCreate(K, V)() nothrow @nogc pure @safe =>
	DSMap!(K, V)();
alias ds_map_create = dsMapCreate;

bool dsMapAdd(Map)(ref Map id, Map.KeyT key, Map.ValT val) nothrow @nogc pure @safe
if(isDSMap!Map){
	bool ret = false;
	id.data.require(key, {
		ret = true;
		return val;
	}());
	return ret;
}
alias ds_map_add = dsMapAdd;
unittest{
	auto map = dsMapCreate!(string, double)();
	dsMapAdd(map, "a", 1.5);
}

//TODO: the rest of the DSMap functions
