module gml.draw.texture;

import gml.draw;

class Texture{
	static if(hasBgfx){
		bgfx.TextureHandle handle;
	}
	void[] data;
}
