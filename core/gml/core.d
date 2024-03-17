module gml.core;

public import
	gml.collision,
	gml.ds,
	gml.game,
	gml.maths,
	gml.room;

import std.exception;

/**
Before calling this function:
- You must have declared at least one room. (for `gml.window`)
*/
void init(){
	gml.collision.init();
	gml.ds.init();
	gml.game.init();
	gml.maths.init();
	gml.room.init();
}
