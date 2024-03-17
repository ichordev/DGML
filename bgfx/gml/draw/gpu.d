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
		case 0:             return Cull.noCulling;
		case StateCull.cw:  return Cull.clockwise;
		case StateCull.acw: return Cull.counterClockwise;
		default: assert(0);
	}
}
alias gpu_get_cullmode = gpuGetCullMode;

//TODO: gpu_get_blendmode. What happens if using an extended blend mode?
//TODO: gpu_get_blendmode_ext
//TODO: gpu_get_blendmode_ext_sepalpha
//TODO: gpu_get_blendmode_src
//TODO: gpu_get_blendmode_dest
//TODO: gpu_get_blendmode_srcalpha
//TODO: gpu_get_blendmode_destalpha

bool[4] gpuGetColourWriteEnable() nothrow @nogc @safe => [
	(gpuState.write & StateWrite.r) != 0,
	(gpuState.write & StateWrite.g) != 0,
	(gpuState.write & StateWrite.b) != 0,
	(gpuState.write & StateWrite.a) != 0,
];
alias gpu_get_colourwriteenable = gpuGetColourWriteEnable;

//TODO: gpu_get_texfilter
//TODO: gpu_get_texfilter_ext
//TODO: gpu_get_texrepeat
//TODO: gpu_get_texrepeat_ext

bool gpuGetAlphaTestEnable() nothrow @nogc @safe =>
	gpuState.alphaTest;
alias gpu_get_alphatestenable = gpuGetAlphaTestEnable;

//Setters

//TODO: gpu_set_blendenable
//TODO: gpu_set_ztestenable
//TODO: gpu_set_zfunc
//TODO: gpu_set_zwriteenable
//TODO: gpu_set_depth
//TODO: gpu_set_fog
//TODO: gpu_set_cullmode
//TODO: gpu_set_blendmode
//TODO: gpu_set_blendmode_ext
//TODO: gpu_set_blendmode_ext_sepalpha
//TODO: gpu_set_colourwriteenable
//TODO: gpu_set_alphatestenable
//TODO: gpu_set_alphatestref
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
