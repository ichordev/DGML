module gml.ds;

public import
	gml.ds.list;

import std.sumtype;

alias DSVal = SumType!(
	typeof(null),
	string,
	double,
	int,
	long,
	DSList*,
	//DSMap*,
);

double dsPrecision = 0.00_00_00_1;

void dsSetPrecision(double prec) nothrow @nogc @safe{
	dsPrecision = prec;
}
alias ds_set_precision = dsSetPrecision;
