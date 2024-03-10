module gml.ds.priority;

import std.algorithm.searching, std.container.binaryheap, std.typecons, std.variant;

alias DSPriority = BinaryHeap!(Tuple!(Variant, double)[], "a[1] < b[1]");
private alias DSPriorityReverse = BinaryHeap!(Tuple!(Variant, double)[], "a[1] > b[1]");

DSPriority dsPriorityCreate() nothrow @nogc pure =>
	DSPriority([]);
alias ds_priority_create = dsPriorityCreate;

void dsPriorityDestroy(ref DSPriority id) nothrow @nogc pure{
	id.clear();
}
alias ds_priority_destroy = dsPriorityDestroy;

void dsPriorityClear(ref DSPriority id) nothrow @nogc pure{
	id.release();
}
alias ds_priority_clear = dsPriorityClear;

bool dsPriorityEmpty(DSPriority id) nothrow @nogc pure =>
	id.empty;
alias ds_priority_empty = dsPriorityEmpty;

size_t dsPrioritySize(DSPriority id) nothrow @nogc pure =>
	id.length;
alias ds_priority_size = dsPrioritySize;

void dsPriorityAdd(V)(ref DSPriority id, V val, double priority){
	id.insert(tuple(Variant(val), priority));
}
alias ds_priority_add = dsPriorityAdd;
unittest{
	auto prio = dsPriorityCreate();
	dsPriorityAdd(prio, 325.39,  2.7);
	dsPriorityAdd(prio, "test", -5);
	dsPriorityAdd(prio, 59,      1);
	assert(dsPriorityDeleteMax(prio) == Variant(325.39));
	assert(dsPriorityDeleteMax(prio) == Variant(59));
	assert(dsPriorityDeleteMax(prio) == Variant("test"));
}

void dsPriorityChangePriority(V)(ref DSPriority id, V val, double priority){
	if(id.length){
		auto store = id.release();
		const varVal = Variant(val);
		foreach(ref item; store){
			try{
				if(item[0] == varVal){
					item[1] = priority;
				}
			}catch(Exception ex){
			}
		}
		id = DSPriority(store);
	}
}
alias ds_priority_change_priority = dsPriorityChangePriority;
unittest{
	auto prio = dsPriorityCreate();
	dsPriorityAdd(prio, 100,    2.7);
	dsPriorityAdd(prio, 20.0,  -5);
	dsPriorityAdd(prio, "300",  1);
	dsPriorityChangePriority(prio, 20.0, 5);
	assert(dsPriorityDeleteMax(prio) == Variant(20.0));
}

Variant dsPriorityDeleteMax(ref DSPriority id) =>
	id.length ? id.removeAny()[0] : Variant(0);
alias ds_priority_delete_max = dsPriorityDeleteMax;

Variant dsPriorityDeleteMin(ref DSPriority id){
	if(!id.length) return Variant(0);
	auto idRev = DSPriorityReverse(id.release());
	auto ret = idRev.removeAny()[0];
	id = DSPriority(idRev.release());
	return ret;
}
alias ds_priority_delete_min = dsPriorityDeleteMin;
unittest{
	auto prio = dsPriorityCreate();
	dsPriorityAdd(prio, 325.39,  2.7);
	dsPriorityAdd(prio, "test", -5);
	dsPriorityAdd(prio, 59,      1);
	assert(dsPriorityDeleteMin(prio) == Variant("test"));
	assert(dsPriorityDeleteMin(prio) == Variant(59));
	assert(dsPriorityDeleteMin(prio) == Variant(325.39));
}

void dsPriorityDeleteValue(V)(ref DSPriority id, V val){
	if(id.length){
		auto store = id.release();
		const varVal = Variant(val);
		foreach(ind, item; store){
			try{
				if(item[0] == varVal){
					store = store[0..ind] ~ store[ind+1..$];
					break;
				}
			}catch(Exception ex){
			}
		}
		id = DSPriority(store);
	}
}
alias ds_priority_delete_value = dsPriorityDeleteValue;
unittest{
	auto prio = dsPriorityCreate();
	dsPriorityAdd(prio, 100,    2.7);
	dsPriorityAdd(prio, 20.0,  -5);
	dsPriorityAdd(prio, "300",  1);
	assert(dsPrioritySize(prio) == 3);
	dsPriorityDeleteValue(prio, 100);
	assert(dsPriorityFindMax(prio) == Variant("300"));
	assert(dsPrioritySize(prio) == 2);
	dsPriorityDeleteValue(prio, 20.0);
	assert(dsPrioritySize(prio) == 1);
	dsPriorityDeleteValue(prio, "300");
	assert(dsPrioritySize(prio) == 0);
}

Variant dsPriorityFindMax(DSPriority id) =>
	id.length ? id.front[0] : Variant(null);
alias ds_priority_find_max = dsPriorityFindMax;

Variant dsPriorityFindMin(DSPriority id){
	if(!id.length) return Variant(null);
	auto idRev = DSPriorityReverse(id.release());
	auto ret = idRev.front[0];
	id = DSPriority(idRev.release());
	return ret;
}
alias ds_priority_find_min = dsPriorityFindMin;

double dsPriorityFindPriority(V)(DSPriority id, V val){
	double ret;
	if(id.length){
		auto store = id.release();
		const varVal = Variant(val);
		foreach(item; store){
			try{
				if(item[0] == varVal){
					ret = item[1];
				}
			}catch(Exception ex){
			}
		}
		id = DSPriority(store);
	}
	return ret;
}
alias ds_priority_find_priority = dsPriorityFindPriority;
unittest{
	auto prio = dsPriorityCreate();
	dsPriorityAdd(prio, 100,    2.7);
	dsPriorityAdd(prio, 20.0,  -5);
	dsPriorityAdd(prio, "300",  1);
	assert(dsPriorityFindPriority(prio, 100)   ==  2.7);
	assert(dsPriorityFindPriority(prio, 20.0)  == -5);
	assert(dsPriorityFindPriority(prio, "300") ==  1);
}

//TODO: ds_priority_read

//TODO: ds_priority_write
