module gml.sdl;

public import
	gml.audio,
	gml.input,
	gml.window;

/**
Before calling this function:
- You must've run `gml.core.init`.
*/
void init(){
	gml.window.init();
	gml.audio.init();
	gml.input.init();
}
