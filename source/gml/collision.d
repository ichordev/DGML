module gml.collision;

import std.algorithm.comparison, std.math;

void init(){
}

F pointLineDistance(F)(F px, F py, F x1, F y1, F x2, F y2) nothrow @nogc pure @safe
if(__traits(isFloating, F)){
	F a = px - x1;
	F b = py - y1;
	F c = x2 - x1;
	F d = y2 - y1;
	F dot = a * c + b * d;
	F lenSq = c * c + d * d;
	F param = (lenSq != F(0)) ? dot/lenSq : F(-1); //in case of 0-length line
	
	F xx, yy;
	if(param < F(0)){
		xx = x1;
		yy = y1;
	}else if(param > F(1)){
		xx = x2;
		yy = y2;
	}else{
		xx = x1 + param * c;
		yy = y1 + param * d;
	}
	
	F dx = px - xx;
	F dy = py - yy;
	return sqrt(dx * dx + dy * dy);
}

bool pointInRectangle(F)(
	F px, F py,
	F x1, F y1, F x2, F y2,
) nothrow @nogc pure @safe
if(__traits(isFloating, F)){
	if(x1 > x2){
		F x = x2;
		x2 = x1;
		x1 = x;
	}
	assert(x1 <= x2);
	if(y1 > y2){
		F y = y2;
		y2 = y1;
		y1 = y;
	}
	assert(y1 <= y2);
	return px >= x1 && px <= x2 && py >= y1 && py <= y2;
}
alias point_in_rectangle = pointInRectangle;

bool pointInTriangle(F)(
	F px, F py,
	F x1, F y1, F x2, F y2, F x3, F y3,
) nothrow @nogc pure @safe
if(__traits(isFloating, F)){
	
	F sign(F x1, F y1, F x2, F y2, F x3, F y3) =>
		(x1 - x3) * (y2 - y3) - (x2 - x3) * (y1 - y3);
	F d1 = sign(px,py, x1,y1, x2,y2);
	F d2 = sign(px,py, x2,y2, x3,y3);
	F d3 = sign(px,py, x3,y3, x1,y1);
	
	return !(
		((d1 < F(0)) || (d2 < F(0)) || (d3 < F(0))) && //has negative
		((d1 > F(0)) || (d2 > F(0)) || (d3 > F(0)))    //has positive
	);
}
alias point_in_triangle = pointInTriangle;

bool pointInQuadrangle(F)(
	F px, F py,
	F x1, F y1, F x2, F y2, F x3, F y3, F x4, F y4,
) nothrow @nogc pure @safe
if(__traits(isFloating, F)) =>
	pointInTriangle!F(px,py, x1,y1,x2,y2,x3,y3) ||
	pointInTriangle!F(px,py, x1,y1,x4,y4,x3,y3);

bool pointInCircle(F)(
	F px, F py,
	F cx, F cy, F rad,
) nothrow @nogc pure @safe
if(__traits(isFloating, F)){
	px -= cx;
	py -= cy;
	return (px*px + py*py) <= rad * rad;
}
alias point_in_circle = pointInCircle;

bool rectangleInRectangle(F)(
	F sx1, F sy1, F sx2, F sy2,
	F dx1, F dy1, F dx2, F dy2,
) nothrow @nogc pure @safe
if(__traits(isFloating, F)){
	if(sx1 > sx2){
		F sx = sx2;
		sx2 = sx1;
		sx1 = sx;
	}
	assert(sx1 <= sx2);
	if(sy1 > sy2){
		F sy = sy2;
		sy2 = sy1;
		sy1 = sy;
	}
	assert(sy1 <= sy2);
	if(dx1 > dx2){
		F dx = dx2;
		dx2 = dx1;
		dx1 = dx;
	}
	assert(dx1 <= dx2);
	if(dy1 > dy2){
		F dy = dy2;
		dy2 = dy1;
		dy1 = dy;
	}
	assert(dy1 <= dy2);
	return sx2 >= dx1 && sx1 <= dx2 && sy2 >= dy1 && sy1 <= dy2;
}
alias rectangle_in_rectangle = rectangleInRectangle;

//TODO: rectangle_in_triangle

//TODO: rectangle_in_circle

bool circleInCircle(F)(
	F x1, F y1, F rad1,
	F x2, F y2, F rad2,
) nothrow @nogc pure @safe
if(__traits(isFloating, F)){
	F distX = x1 - x2;
	F distY = y1 - y2;
	return distX*distX + distY*distY <= rad1*rad1 + rad2*rad2;
}
