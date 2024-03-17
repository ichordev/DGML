module gml.sdl;

public import
	gml.audio,
	gml.input,
	gml.window;

import gml.room;

/**
Before calling this function:
- You must've run `gml.core.init`.
- You must've declared at least one room.
*/
void init(){
	gml.room.init();
	gml.window.init();
	gml.audio.init();
	gml.input.init();
}
