module gml.draw.texture;

import gml.draw;

static if(hasBgfx){
	import bindbc.bgfx;
}

class Texture{
	static if(hasBgfx){
		bgfx.TextureHandle handle;
	}
	void[] data;
}
