module gml.draw;

public import
	gml.draw.colour,
	gml.draw.forms,
	gml.draw.gpu,
	gml.draw.texture;

import std.math;
import ic.vec;
version(Have_bindbc_bgfx){
	import bindbc.bgfx;
}

struct GPUState{
	float[4] col = [1f, 1f, 1f, 1f];
	@property uint intCol() nothrow @nogc pure @safe =>
		cast(uint)round(col[0] * 255f) <<  0 |
		cast(uint)round(col[1] * 255f) <<  8 |
		cast(uint)round(col[2] * 255f) << 16 |
		cast(uint)round(col[3] * 255f) << 24;
	
	Mat4 getTransform() nothrow @nogc pure @safe =>
		transform.translate(Vec3!float(0f, 0f, depth));
	
	Mat4 transform;
	float depth = 0f;
	
	bool zTest = false;
	bool alphaTest = false;
	
	version(Have_bindbc_bgfx){
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

version(Have_bindbc_bgfx){
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
