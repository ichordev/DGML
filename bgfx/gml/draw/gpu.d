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
		case 0:   return Cull.noCulling;
		case cw:  return Cull.clockwise;
		case acw: return Cull.counterClockwise;
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
