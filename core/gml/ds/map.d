module gml.ds.map;

import gml.ds.list;

import core.memory;
import std.algorithm.searching, std.variant;

void init(){
	
}

void quit(){
	
}

struct DSMap{
	Variant[Variant] data;
	alias data this;
	
	size_t nextKey;
	
	Variant opIndex(T)(T key) =>
		data.get(Variant(key), Variant(null));
	
	Variant opIndexAssign(V, K)(V val, K key){
		return data[Variant(key)] = Variant(val);
	}
}

bool dsMapExists(K)(const DSMap id, K key) nothrow{
	try return (Variant(key) in id.data) !is null;
	catch(Exception ex) return false;
}
alias ds_map_exists = dsMapExists;

DSMap dsMapCreate() nothrow @nogc pure @safe =>
	DSMap();
alias ds_map_create = dsMapCreate;

bool dsMapAdd(K, V)(ref DSMap id, K key, V val){
	bool ret = false;
	id.data.require(
		Variant(key), {
			ret = true;
			return Variant(val);
		}(),
	);
	return ret;
}
alias ds_map_add = dsMapAdd;
unittest{
	auto map = dsMapCreate();
	assert(dsMapAdd(map, "onePointFive", 1.5) == true);
	assert(dsMapAdd(map, "onePointFive", 1.5) == false);
	assert(dsMapExists(map, "onePointFive"));
	assert(map["onePointFive"] == 1.5);
}

void dsMapClear(ref DSMap id) nothrow pure{
	id.clear();
}
alias ds_map_clear = dsMapClear;

void dsMapCopy(ref DSMap id, DSMap source){
	id.data = source.data.dup;
}
alias ds_map_copy = dsMapCopy;

bool dsMapReplace(K, V)(ref DSMap id, K key, V val){
	const varKey = Variant(key);
	bool ret = (varKey in id.data) !is null;
	id.data[varKey] = Variant(val);
	return ret;
}
alias ds_map_replace = dsMapReplace;
unittest{
	auto map = dsMapCreate();
	dsMapAdd(map, "onePointFive", 1.5);
	assert(dsMapReplace(map, "onePointFive", 1.05) == true);
	assert(dsMapReplace(map, "twoPointTwo", 2.2) == false);
}

void dsMapDelete(K)(ref DSMap id, K key){
	id.data.remove(Variant(key));
}
alias ds_map_delete = dsMapDelete;
unittest{
	auto map = dsMapCreate();
	dsMapAdd(map, "onePointFive", 1.5);
	dsMapDelete(map, "onePointFive");
	assert(!dsMapExists(map, "onePointFive"));
}

bool dsMapEmpty(const DSMap id) nothrow @nogc pure @safe =>
	id.data.length == 0;
alias ds_map_empty = dsMapEmpty;

size_t dsMapSize(const DSMap id) nothrow @nogc pure @safe =>
	id.data.length;
alias ds_map_size = dsMapSize;

Variant dsMapFindFirst(const DSMap id) =>
	id.data.length ? id.data.keys[0] : Variant(null);
alias ds_map_find_first = dsMapFindFirst;

Variant dsMapFindLast(const DSMap id) =>
	id.data.length ? id.data.keys[$-1] : Variant(null);
alias ds_map_find_last = dsMapFindLast;

/**
Warning:
	This function is stupidly slow!
	To iterate forwards over the keys of a DSMap, you should do this instead:
	```
	foreach(key; dsMap.byKey()){
		//use the key here
	}
	```
*/
Variant dsMapFindNext(K)(const DSMap id, K key){
	const keys = id.data.keys;
	const ind = keys.countUntil(Variant(key));
	if(ind == -1 || ind+1 >= keys.length) return Variant(null);
	return keys[ind+1];
}
alias ds_map_find_next = dsMapFindNext;
unittest{
	auto map = dsMapCreate();
	dsMapAdd(map, "a", 1);
	dsMapAdd(map, "b", 2);
	dsMapAdd(map, "c", 3);
	auto key = dsMapFindFirst(map);
	size_t keyCount = 0;
	while(key != Variant(null)){
		keyCount++;
		if(     key == Variant("a")) assert(map[key] == 1);
		else if(key == Variant("b")) assert(map[key] == 2);
		else if(key == Variant("c")) assert(map[key] == 3);
		else assert(0);
		
		key = dsMapFindNext(map, key);
	}
	assert(keyCount == 3);
}

/**
Warning:
	This function is stupidly slow!
	To iterate backwards over the keys of a DSMap, you should do this instead:
	```
	foreach_reverse(key; dsMap.byKey()){
		//use the key here
	}
	```
*/
Variant dsMapFindPrevious(K)(const DSMap id, K key){
	const keys = id.data.keys;
	const ind = keys.countUntil(Variant(key));
	if(ind == -1 || ind == 0) return Variant(null);
	return keys[ind-1];
}
alias ds_map_find_previous = dsMapFindPrevious;
unittest{
	auto map = dsMapCreate();
	dsMapAdd(map, "a", 1);
	dsMapAdd(map, "b", 2);
	dsMapAdd(map, "c", 3);
	auto key = dsMapFindLast(map);
	size_t keyCount = 0;
	while(key != Variant(null)){
		keyCount++;
		if(     key == Variant("a")) assert(map[key] == 1);
		else if(key == Variant("b")) assert(map[key] == 2);
		else if(key == Variant("c")) assert(map[key] == 3);
		else assert(0);
		
		key = dsMapFindPrevious(map, key);
	}
	assert(keyCount == 3);
}

Variant dsMapFindValue(K)(const DSMap id, K key) =>
	id[key];
alias ds_map_find_value = dsMapFindValue;

Variant[] dsMapKeysToArray(const DSMap id) =>
	id.data.keys;
Variant[] dsMapKeysToArray(const DSMap id, ref Variant[] array) =>
	array ~= id.data.keys;
alias ds_map_keys_to_array = dsMapKeysToArray;

Variant[] dsMapValuesToArray(DSMap id) =>
	id.data.values;
Variant[] dsMapValuesToArray(const DSMap id, ref Variant[] array) =>
	array ~= id.data.values;
alias ds_map_values_to_array = dsMapValuesToArray;

void dsMapSet(K, V)(ref DSMap id, K key, V value){
	id[key] = value;
}
alias ds_map_set = dsMapSet;
unittest{
	auto map = dsMapCreate();
	dsMapSet(map, "a", 1);
	assert(map["a"] == Variant(1));
}

//TODO: ds_map_read

//TODO: ds_map_write

void dsMapDestroy(ref DSMap id) nothrow @nogc pure{
	GC.free(cast(void*)id.data);
	id.data = null;
}
alias ds_map_destroy = dsMapDestroy;
unittest{
	auto map = dsMapCreate();
	dsMapSet(map, "a", 1);
	assert(map.data !is null);
	dsMapDestroy(map);
	assert(map.data is null);
}

//TODO: ds_map_secure_save

//TODO: ds_map_secure_save_buffer

//TODO: ds_map_secure_load

//TODO: ds_map_secure_load_buffer

///Adds a list in the same way as any other function, because `DSList`s added to a DSMap are marked automatically.
void dsMapAddList(K)(ref DSMap id, K key, DSList value){
	id[key] = value;
}
alias ds_map_add_list = dsMapAddList;

///Adds a list in the same way as any other function, because `DSMap`s added to a DSMap are marked automatically.
void dsMapAddMap(K)(ref DSMap id, K key, DSMap value){
	id[key] = value;
}
alias ds_map_add_map = dsMapAddMap;

///Adds a list in the same way as any other function, because `DSList`s added to a DSMap are marked automatically.
void dsMapReplaceList(K)(ref DSMap id, K key, DSList value){
	id[key] = value;
}
alias ds_map_replace_list = dsMapReplaceList;

///Adds a list in the same way as any other function, because `DSMap`s added to a DSMap are marked automatically.
void dsMapReplaceMap(K)(ref DSMap id, K key, DSMap value){
	id[key] = value;
}
alias ds_map_replace_map = dsMapReplaceMap;

bool dsMapIsList(K)(ref DSMap id, K key){
	if(auto var = Variant(key) in id.data){
		return var.peek!DSList !is null;
	}
	return false;
}
alias ds_map_is_list = dsMapIsList;
unittest{
	auto map = dsMapCreate();
	dsMapSet(map, "a", 120);
	dsMapSet(map, "b", dsListCreate());
	assert(!dsMapIsList(map, "a"));
	assert( dsMapIsList(map, "b"));
}

bool dsMapIsMap(K)(ref DSMap id, K key){
	if(auto var = Variant(key) in id.data){
		return var.peek!DSMap !is null;
	}
	return false;
}
alias ds_map_is_map = dsMapIsMap;
unittest{
	auto map = dsMapCreate();
	dsMapSet(map, "a", 120);
	dsMapSet(map, "b", dsMapCreate());
	assert(!dsMapIsMap(map, "a"));
	assert( dsMapIsMap(map, "b"));
}
