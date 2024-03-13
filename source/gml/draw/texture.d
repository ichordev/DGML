module gml.draw.texture;

import gml.draw;

version(Have_bindbc_bgfx){
	import bindbc.bgfx;
}

class Texture{
	version(Have_bindbc_bgfx){
		bgfx.TextureHandle handle;
	}
	void[] data;
}
