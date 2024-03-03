module gml.draw;

public import
	gml.draw.colour,
	gml.draw.form,
	gml.draw.gpu;

import ic.vec;
static if(hasBgfx){
	import bindbc.bgfx;
}

enum hasBgfx = is(typeof({ import bindbc.bgfx; }));

struct GPUState{
	float[4] col = [1f, 1f, 1f, 1f];
	
	Mat4 getTransform() nothrow @nogc pure @safe =>
		transform.translate(Vec3!float(0f, 0f, depth));
	
	Mat4 transform;
	float depth = 0f;
	
	bool zTest = false;
	bool alphaTest = false;
	
	static if(hasBgfx){
		ulong getBgfxState() nothrow @nogc pure @safe =>
			write | blending | culling
			| (zTest ? zFunc : 0)
			| (alphaTest ? alphaRef : 0);
		
		ulong write = StateWrite.rgb | StateWrite.a | StateWrite.z;
		
		ulong blending = StateBlendFunc.alpha;
		
		ulong culling = 0;
		
		ulong zFunc = StateDepthTest.lEqual;
		ulong alphaRef = (() @trusted => toStateAlphaRef(0))();
		
		bgfx.ViewID view = 0;
	}
}
GPUState gpuState;
