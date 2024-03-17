module gml;

public import
	gml.audio,
	gml.collision,
	gml.draw,
	gml.ds,
	gml.game,
	gml.input,
	gml.layer,
	gml.maths,
	gml.object,
	gml.room,
	gml.sprite,
	gml.window;

import std.exception;

/**
Before calling this function:
You must have declared at least one room. (for `gml.window`)

*/
void init(){
	gml.window.init();
	gml.audio.init();
	gml.draw.init();
	
	gml.collision.init();
	gml.ds.init();
	gml.game.init();
	gml.input.init();
	gml.layer.init();
	gml.maths.init();
	gml.object.init();
	gml.room.init();
	gml.sprite.init();
}
