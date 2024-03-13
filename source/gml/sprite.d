module gml.sprite;

import gml.draw.texture;

import ic.vec;

class SpriteAsset{
	bool valid;
	Texture tex;
	float[4] uv;
	
	this(int val){
		valid = val != -1;
	}
	
	void opAssign(int val) nothrow @nogc pure @safe{
		valid = val != -1;
	}
}
