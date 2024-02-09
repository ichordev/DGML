module gml.maths;

import std.math, std.random;

//Number Functions

Mt19937 rng;

T choose(T)(T[] vals...) nothrow @nogc @safe =>
	choice(vals, rng);

double random(double n) @safe =>
	uniform!"[]"(0.0, n, rng);

double randomRange(double n1, double n2) @safe =>
	uniform!"[]"(n1, n2, rng);
alias random_range = randomRange;

long iRandom(long n) @safe =>
	uniform!"[]"(0L, n, rng);
alias irandom = iRandom;

long iRandomRange(long n1, long n2) @safe =>
	uniform!"[]"(n1, n2, rng);
alias irandom_range = iRandomRange;

void randomSetSeed(uint val) nothrow @nogc @safe{
	rng.seed(val);
}
alias random_set_seed = randomSetSeed;

//uint randomGetSeed() nothrow @nogc @safe =>
//	rng.???
//alias random_get_seed = randomGetSeed;

//TOOD: randomise

//Angles And Distance 

F dcos(F)(F val) nothrow @nogc pure @safe
if(__traits(isFloating, F)) =>
	cos(val.degToRad());

F dsin(F)(F val) nothrow @nogc pure @safe
if(__traits(isFloating, F)) =>
	sin(val.degToRad());

F dtan(F)(F val) nothrow @nogc pure @safe
if(__traits(isFloating, F)) =>
	tan(val.degToRad());

F dacos(F)(F val) nothrow @nogc pure @safe
if(__traits(isFloating, F)) =>
	acos(val.degToRad());

F dasin(F)(F val) nothrow @nogc pure @safe
if(__traits(isFloating, F)) =>
	asin(val.degToRad());

F datan(F)(F val) nothrow @nogc pure @safe
if(__traits(isFloating, F)) =>
	atan(val).degToRad();
alias darctan = datan;

F datan2(F)(F y, F x) nothrow @nogc pure @safe
if(__traits(isFloating, F)) =>
	atan2(y, x).degToRad();
alias darctan2 = datan2;

F degToRad(F)(F val) nothrow @nogc pure @safe
if(__traits(isFloating, F)) =>
	val * cast(F)PI / cast(F)180;
alias degtorad = degToRad;

F radToDeg(F)(F val) nothrow @nogc pure @safe
if(__traits(isFloating, F)) =>
	val * cast(F)180 / cast(F)PI;
alias radtodeg = radToDeg;

double pointDirection(double x1, double y1, double x2, double y2) nothrow @nogc pure @safe =>
	datan2(y1 - y2, x1 - x2);
alias point_direction = pointDirection;

double pointDistance(double x1, double y1, double x2, double y2) nothrow @nogc pure @safe{
	x1 -= x2;
	y1 -= y2;
	return sqrt(x1*x1 + y1*y1);
}
alias point_distance = pointDistance;

double pointDistance3D(double x1, double y1, double z1, double x2, double y2, double z2) nothrow @nogc pure @safe{
	x1 -= x2;
	y1 -= y2;
	z1 -= z2;
	return sqrt(x1*x1 + y1*y1 + z1*z1);
}
alias point_distance_3d = pointDistance3D;

//TODO: distance_to_object

//TODO: distance_to_point

double dotProduct(double x1, double y1, double x2, double y2) nothrow @nogc pure @safe =>
	(x1 * x2) + (y1 * y2);
alias dot_product = dotProduct;

double dotProduct3D(double x1, double y1, double z1, double x2, double y2, double z2) nothrow @nogc pure @safe =>
	(x1 * x2) + (y1 * y2) + (z1 * z2);
alias dot_product_3d = dotProduct3D;

double dotProductNormalised(double x1, double y1, double x2, double y2) nothrow @nogc pure @safe{
	const len1 = sqrt(x1*x1 + y1*y1);
	if(len1 > 0.0){
		x1 /= len1; y1 /= len1;
	}else{
		x1 = 0.0; y1 = 0.0;
	}
	const len2 = sqrt(x2*x2 + y2*y2);
	if(len2 > 0.0){
		x1 /= len1; y1 /= len1;
	}else{
		x1 = 0.0; y1 = 0.0;
	}
	return (x1 * x2) + (y1 * y2);
}
alias dot_product_normalised = dotProductNormalised;
