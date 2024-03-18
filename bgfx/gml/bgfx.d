module gml.bgfx;

public import
	gml.display,
	gml.draw,
	gml.sprite;

/**
Before calling this function:
- You must've run `gml.sdl.init`.
*/
void init(){
	gml.display.init();
	gml.draw.init();
	gml.sprite.init();
}

void quit(){
	gml.sprite.quit();
	gml.draw.quit();
	gml.display.init();
}
