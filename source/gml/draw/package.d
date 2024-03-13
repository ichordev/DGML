module gml.draw;

public import
	gml.draw.colour,
	gml.draw.forms,
	gml.draw.gpu,
	gml.draw.texture;

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
		
		bgfx.ProgramHandle program;
	}
}
GPUState gpuState;

static if(hasBgfx){
	struct VertPos{
		float x,y;
		
		static bgfx.VertexLayout layout;
		static void ini(){
			layout.begin()
				.add(Attrib.position,  2, AttribType.float_)
			.end();
		}
	}
	struct VertPosCol{
		float x,y;
		uint col;
		
		static bgfx.VertexLayout layout;
		static void ini(){
			layout.begin()
				.add(Attrib.position,  2, AttribType.float_)
				.add(Attrib.colour0,   4, AttribType.uint8, true)
			.end();
		}
	}
	struct VertPosColTex{
		float x,y;
		uint col;
		float u,v;
		
		static bgfx.VertexLayout layout;
		static void ini(){
			layout.begin()
				.add(Attrib.position,  2, AttribType.float_)
				.add(Attrib.colour0,   4, AttribType.uint8, true)
				.add(Attrib.texCoord0, 2, AttribType.float_)
			.end();
		}
	}
	
	void initVertFormats(){
		VertPos.ini();
		VertPosCol.ini();
		VertPosColTex.ini();
	}
}
