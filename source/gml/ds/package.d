module gml.ds;

public import
	gml.ds.list;

import std.sumtype;

alias DSItem = SumType!(
	typeof(null),
	string,
	double,
	int,
	long,
	DSList*,
	//DSMap*,
);

/+
enum Type{
	undefined,
	str,
	number,
	int32,
	int64,
	ptr,
	dsList,
	dsMap,
}

struct DSItem{
	private union{
		string _str;
		double _number;
		int _int32;
		long _int64;
		bool _bool;
		DSItem[] array;
		void* _ptr;
		DSList* _dsList;
		DSMap* _dsMap;
	}
	Type type;
	
	this(T)(T data) nothrow @nogc pure @safe{
		cast(void)opAssign(data);
	}
	
	void opAssign(T)(T data) nothrow @nogc pure @trusted{
		static if(is(T: string)){
			_str = data;
			type = Type.str;
		}else static if(is(T: int)){
			_int32 = data;
			type = Type.int32;
		}
	}
	
	@property str() @trusted
	in(type == Type.str) =>
		_str;
	@property number() @trusted
	in(type == Type.number || type == Type.int32 || type == Type.int64){
		switch(type){
			case Type.number: return _number;
			case Type.int32:  return cast(double)_int32;
			case Type.int64:  return cast(double)_int64;
			default: assert(0);
		}
	}
	@property int32() @trusted
	in(type == Type.int32 || type == Type.number || type == Type.int64){
		switch(type){
			case Type.number: return cast(int)_number;
			case Type.int32:  return _int32;
			case Type.int64:  return cast(int)_int64;
			default: assert(0);
		}
	}
	@property int64() @trusted
	in(type == Type.int64 || type == Type.int32 || type == Type.number){
		switch(type){
			case Type.number: return cast(long)_number;
			case Type.int32:  return cast(long)_int32;
			case Type.int64:  return _int64;
			default: assert(0);
		}
	}
}
+/
