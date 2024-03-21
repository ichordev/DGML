module gml.draw.gpu;

import gml.draw;

import bindbc.bgfx;

void init(){
	
}

void quit(){
	
}

enum CmpFunc{
	never, ///Never
	less, ///Less
	equal, ///Equal
	lessEqual, ///Less or Equal
	lessequal = lessEqual,
	greater, ///Greater
	notEqual, ///Not Equal
	notequal = notEqual,
	greaterEqual, ///Greater or Equal
	greaterequal = greaterEqual,
	always, ///Always
}
alias cmpfunc = CmpFunc;

enum Cull{
	noCulling, ///No culling will be done.
	noculling = noCulling,
	clockwise, ///All clockwise triangles will be culled.
	counterClockwise, ///All counter-clockwise triangles will be culled.
	antiClockwise    = counterClockwise,
	counterclockwise = counterClockwise,
}
alias cull = Cull;

enum BM: bgfx.StateBlend_{
	zero            = StateBlend.zero,          ///(0, 0, 0, 0)
	one             = StateBlend.one,           ///(1, 1, 1, 1)
	srcColour       = StateBlend.srcColour,     ///(Rs, Gs, Bs, As)
	src_colour      = srcColour,
	invSrcColour    = StateBlend.invSrcColour,  ///(1-Rs, 1-Gs, 1-Bs, 1-As)
	inv_src_colour  = invSrcColour,
	srcAlpha        = StateBlend.srcAlpha,      ///(As, As, As, As)
	src_alpha       = srcAlpha,
	invSrcAlpha     = StateBlend.invSrcAlpha,   ///(1-As, 1-As, 1-As, 1-As)
	inv_src_alpha   = invSrcAlpha,
	destAlpha       = StateBlend.dstAlpha,      ///(Ad, Ad, Ad, Ad)
	dest_alpha      = destAlpha,
	invDestAlpha    = StateBlend.invDstAlpha,   ///(1-Ad, 1-Ad, 1-Ad, 1-Ad)
	inv_dest_alpha  = invDestAlpha,
	destColour      = StateBlend.dstColour,     ///(Rd, Gd, Bd, Ad)
	dest_colour     = destColour,
	invDestColour   = StateBlend.invDstColor,   ///(1-Rd, 1-Gd, 1-Bd, 1-Ad)
	inv_dest_colour = invDestColour,
	srcAlphaSat     = StateBlend.srcAlphaSat,   ///(f, f, f, 1) where f = min(As, 1-Ad)
	src_alpha_sat   = srcAlphaSat,
	
	normal    = blendFunc(StateBlend.srcAlpha, StateBlend.invSrcAlpha),   ///Normal blending (the default blend mode).
	add       = blendFunc(StateBlend.srcAlpha, StateBlend.one),           ///Additive blending. Luminosity values of light areas are added.
	subtract  = blendFunc(StateBlend.zero,     StateBlend.invSrcColour),  ///Subtractive blending. Luminosity values of light areas are subtracted.
	max       = blendFunc(StateBlend.srcAlpha, StateBlend.invSrcColour),  ///Max blending. Similar to additive blending.
}
alias bm = BM;

//Getters

//TODO: gpu_get_blendenable

bool gpuGetZTestEnable() nothrow @nogc @safe =>
	gpuState.zTest;
alias gpu_get_ztestenable = gpuGetZTestEnable;

CmpFunc gpuGetZFunc() nothrow @nogc @safe{
	with(StateDepthTest) switch(gpuState.zFunc){
		case less:     return CmpFunc.less;
		case lEqual:   return CmpFunc.lessEqual;
		case equal:    return CmpFunc.equal;
		case gEqual:   return CmpFunc.greaterEqual;
		case greater:  return CmpFunc.greater;
		case notEqual: return CmpFunc.notEqual;
		case never:    return CmpFunc.never;
		case always:   return CmpFunc.always;
		default: assert(0);
	}
}
alias gpu_get_zfunc = gpuGetZFunc;

bool gpuGetZWriteEnable() nothrow @nogc @safe =>
	(gpuState.write & StateWrite.z) != 0;
alias gpu_get_zwriteenable = gpuGetZWriteEnable;

float gpuGetDepth() nothrow @nogc @safe =>
	gpuState.depth;
alias gpu_get_depth = gpuGetDepth;

//TODO: gpu_get_fog?

Cull gpuGetCullMode() nothrow @nogc @safe{
	with(StateCull) switch(gpuState.culling){
		case 0:   return Cull.noCulling;
		case cw:  return Cull.clockwise;
		case acw: return Cull.counterClockwise;
		default: assert(0);
	}
}
alias gpu_get_cullmode = gpuGetCullMode;

BM gpuGetBlendMode() nothrow @nogc @safe =>
	cast(BM)gpuState.blendMode;
alias gpu_get_blendmode = gpuGetBlendMode;

BM[2] gpuGetBlendModeExt() nothrow @nogc @safe =>
	[gpuGetBlendModeSrc(), gpuGetBlendModeDest()];
alias gpu_get_blendmode_ext = gpuGetBlendModeExt;

BM[4] gpuGetBlendModeExtSepAlpha() nothrow @nogc @safe =>
	[gpuGetBlendModeSrc(), gpuGetBlendModeDest(), gpuGetBlendModeSrcAlpha(), gpuGetBlendModeDestAlpha()];
alias gpu_get_blendmode_ext_sepalpha = gpuGetBlendModeExtSepAlpha;

BM gpuGetBlendModeSrc() nothrow @nogc @safe =>
	cast(BM)(gpuState.blendMode & StateBlend.mask);
alias gpu_get_blendmode_src = gpuGetBlendModeSrc;

BM gpuGetBlendModeDest() nothrow @nogc @safe =>
	cast(BM)((gpuState.blendMode >> 4) & StateBlend.mask);
alias gpu_get_blendmode_dest = gpuGetBlendModeDest;

BM gpuGetBlendModeSrcAlpha() nothrow @nogc @safe =>
	cast(BM)((gpuState.blendMode >> 8) & StateBlend.mask);
alias gpu_get_blendmode_srcalpha = gpuGetBlendModeSrcAlpha;

BM gpuGetBlendModeDestAlpha() nothrow @nogc @safe =>
	cast(BM)((gpuState.blendMode >> 12) & StateBlend.mask);
alias gpu_get_blendmode_destalpha = gpuGetBlendModeDestAlpha;

bool[4] gpuGetColourWriteEnable() nothrow @nogc @safe => [
	(gpuState.write & StateWrite.r) != 0,
	(gpuState.write & StateWrite.g) != 0,
	(gpuState.write & StateWrite.b) != 0,
	(gpuState.write & StateWrite.a) != 0,
];
alias gpu_get_colourwriteenable = gpuGetColourWriteEnable;

bool gpuGetAlphaTestEnable() nothrow @nogc @safe =>
	gpuState.alphaTest;
alias gpu_get_alphatestenable = gpuGetAlphaTestEnable;

ubyte gpuGetAlphaTestRef() nothrow @nogc @safe =>
	cast(ubyte)(gpuState.alphaRef >> StateAlphaRef.shift);
alias gpu_get_alphatestref = gpuGetAlphaTestRef;

//TODO: gpu_get_texfilter
//TODO: gpu_get_texfilter_ext
//TODO: gpu_get_texrepeat
//TODO: gpu_get_texrepeat_ext

//Setters

//TODO: gpu_set_blendenable

void gpuSetZTestEnable(bool enable) nothrow @nogc @safe{
	gpuState.zTest = enable;
}
alias gpu_set_ztestenable = gpuSetZTestEnable;

void gpuSetZFunc(CmpFunc cmpFunc) nothrow @nogc @safe{
	gpuState.zFunc = {
		with(CmpFunc) final switch(cmpFunc){
			case CmpFunc.less:          return StateDepthTest.less;
			case CmpFunc.lessEqual:     return StateDepthTest.lEqual;
			case CmpFunc.equal:         return StateDepthTest.equal;
			case CmpFunc.greaterEqual:  return StateDepthTest.gEqual;
			case CmpFunc.greater:       return StateDepthTest.greater;
			case CmpFunc.notEqual:      return StateDepthTest.notEqual;
			case CmpFunc.never:         return StateDepthTest.never;
			case CmpFunc.always:        return StateDepthTest.always;
		}
	}();
}
alias gpu_set_zfunc = gpuSetZFunc;

void gpuSetZWriteEnable(bool enable) nothrow @nogc @safe{
	if(enable){
		gpuState.write |= StateWrite.z;
	}else{
		gpuState.write &= ~StateWrite.z;
	}
}
alias gpu_set_zwriteenable = gpuSetZWriteEnable;

void gpuSetDepth(float depth) nothrow @nogc @safe{
	gpuState.depth = depth;
} 
alias gpu_set_depth = gpuSetDepth;

//TODO: gpu_set_fog

void gpuSetCullMode(Cull cullMode) nothrow @nogc @safe{
	gpuState.culling = {
		with(Cull) final switch(cullMode){
			case noCulling:         return cast(StateCull)0;
			case clockwise:         return StateCull.cw;
			case counterClockwise:  return StateCull.acw;
		}
	}();
}
alias gpu_set_cullmode = gpuSetCullMode;

void gpuSetBlendMode(BM mode) nothrow @nogc @safe{
	gpuState.blendMode = mode;
}
alias gpu_set_blendmode = gpuSetBlendMode;

void gpuSetBlendModeExt(BM src, BM dest) nothrow @nogc @safe{
	gpuState.blendMode = blendFunc(src, dest);
}
alias gpu_set_blendmode_ext = gpuSetBlendModeExt;

void gpuSetBlendModeExtSepAlpha(BM src, BM dest, BM alphaSrc, BM alphaDest) nothrow @nogc @safe{
	gpuState.blendMode = blendFuncSeparate(src, dest, alphaSrc, alphaDest);
}
alias gpu_set_blendmode_ext_sepalpha = gpuSetBlendModeExtSepAlpha;

void gpuSetColourWriteEnable(bool red, bool green, bool blue, bool alpha) nothrow @nogc @safe{
	gpuState.write &= ~(StateWrite.rgb | StateWrite.a);
	gpuState.write |= (
		(red   ? StateWrite.r : 0) |
		(green ? StateWrite.g : 0) |
		(blue  ? StateWrite.b : 0) |
		(alpha ? StateWrite.a : 0)
	);
}
void gpuSetColourWriteEnable(bool[4] array) nothrow @nogc @safe{
	gpuSetColourWriteEnable(array[0], array[1], array[2], array[3]);
}
alias gpu_set_colourwriteenable = gpuSetColourWriteEnable;

void gpuSetAlphaTestEnable(bool enable) nothrow @nogc @safe{
	gpuState.alphaTest = enable;
}
alias gpu_set_alphatestenable = gpuSetAlphaTestEnable;

void gpuSetAlphaTestRef(ubyte val) nothrow @nogc @safe{
	gpuState.alphaRef = (() @trusted => toStateAlphaRef(val))();
}
alias gpu_set_alphatestref = gpuSetAlphaTestRef;

//TODO: gpu_set_texfilter
//TODO: gpu_set_texfilter_ext
//TODO: gpu_set_texrepeat
//TODO: gpu_set_texrepeat_ext

//GPU Stack

GPUState[] gpuStateStack = null;

void gpuPushState() nothrow @safe{
	gpuStateStack ~= gpuState;
}
alias gpu_push_state = gpuPushState;

void gpuPopState() nothrow @safe{
	if(gpuStateStack.length){
		gpuState = gpuStateStack[$-1];
		gpuStateStack.length -= 1;
	}
}
alias gpu_pop_state = gpuPopState;

//TODO: what does the DSMap contain?
//DSMap gpuGetState() nothrow @nogc @safe => ???
//alias gpu_get_state = gpuGetState;

//TODO: gpu_set_state
