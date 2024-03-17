module gml;

public import
	gml.core,
	gml.sdl,
	gml.bgfx,
	
	gml.layer,
	gml.object;

/**
Before calling this function:
- You must have declared at least one room. (for `gml.window`)
*/
void initAll(){
	gml.core.init();
	gml.sdl.init();
	gml.bgfx.init();
	
	gml.layer.init();
	gml.object.init();
}
