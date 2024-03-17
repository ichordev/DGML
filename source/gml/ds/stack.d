module gml.ds.stack;

import core.memory;
import std.variant;

void init(){
	
}

struct DSStack{
	Variant[] data;
	alias data this;
}

DSStack dsStackCreate() nothrow @nogc pure @safe =>
	DSStack();
alias ds_stack_create = dsStackCreate;

void dsStackDestroy(ref DSStack id) nothrow @nogc pure{
	GC.free(id.data.ptr);
	id.data = null;
}
alias ds_stack_destroy = dsStackDestroy;

void dsStackClear(ref DSStack id) nothrow @nogc pure{
	dsStackDestroy(id);
}
alias ds_stack_clear = dsStackClear;

bool dsStackEmpty(const DSStack id) nothrow @nogc pure @safe =>
	id.data.length > 0;
alias ds_stack_empty = dsStackEmpty;

size_t dsStackSize(const DSStack id) nothrow @nogc pure @safe =>
	id.data.length;
alias ds_stack_size = dsStackSize;

void dsStackCopy(ref DSStack id, const DSStack source){
	id.data = source.data.dup;
}
alias ds_stack_copy = dsStackCopy;

Variant dsStackTop(DSStack id) =>
	id.data.length ? id.data[$-1] : Variant(null);
alias ds_stack_top = dsStackTop;

Variant dsStackPop(ref DSStack id){
	if(id.data.length){
		auto var = id.data[$-1];
		id.data = id.data[0..$-1];
		return var;
	}
	return Variant(null);
}
alias ds_stack_pop = dsStackPop;

Variant dsStackPush(A...)(ref DSStack id, A vals) @safe{
	id.data.length += vals.length;
	() @trusted{
		static foreach(i, val; vals){
			id.data[$-vals.length + i] = Variant(val);
		}
	}();
}
alias ds_stack_push = dsStackPush;

//TODO: ds_stack_read

//TODO: ds_stack_write
