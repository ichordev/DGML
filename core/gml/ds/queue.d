module gml.ds.queue;

import core.memory;
import std.variant;

void init(){
	
}

void quit(){
	
}

struct DSQueue{
	Variant[] data;
	alias data this;
}

DSQueue dsQueueCreate() nothrow @nogc pure @safe =>
	DSQueue();
alias ds_queue_create = dsQueueCreate;

void dsQueueDestroy(ref DSQueue id) nothrow @nogc pure{
	GC.free(id.data.ptr);
	id.data = null;
}
alias ds_queue_destroy = dsQueueDestroy;

void dsQueueClear(ref DSQueue id) nothrow @nogc pure{
	dsQueueDestroy(id);
}
alias ds_queue_clear = dsQueueClear;

bool dsQueueEmpty(const DSQueue id) nothrow @nogc pure @safe =>
	id.data.length > 0;
alias ds_queue_empty = dsQueueEmpty;

size_t dsQueueSize(const DSQueue id) nothrow @nogc pure @safe =>
	id.data.length;
alias ds_queue_size = dsQueueSize;

Variant dsQueueDequeue(ref DSQueue id){
	if(id.data.length){
		auto var = id.data[0];
		id.data = id.data[1..$];
		return var;
	}
	return Variant(null);
}
alias ds_queue_dequeue = dsQueueDequeue;

Variant dsQueueEnqueue(A...)(ref DSQueue id, A vals) @trusted{
	static foreach_reverse(i, val; vals){
		id.data = Variant(val) ~ id.data;
	}
}
alias ds_queue_enqueue = dsQueueEnqueue;

Variant dsQueueHead(DSQueue id) =>
	id.data.length ? id.data[0] : Variant(null);
alias ds_queue_head = dsQueueHead;

Variant dsQueueTail(DSQueue id) =>
	id.data.length ? id.data[$-1] : Variant(null);
alias ds_queue_tail = dsQueueTail;

void dsQueueCopy(ref DSQueue id, const DSQueue source){
	id.data = source.data.dup;
}
alias ds_queue_copy = dsQueueCopy;

//TODO: ds_queue_read

//TODO: ds_queue_write
