module gml.bgfx;

public import
	gml.draw,
	gml.sprite;

/**
Before calling this function:
- You must've run `gml.sdl.init`.
*/
void init(){
	gml.draw.init();
	gml.sprite.init();
}

void quit(){
	gml.sprite.quit();
	gml.draw.quit();
}
