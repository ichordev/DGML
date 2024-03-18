module gml.draw;

public import
	gml.draw.colour,
	gml.draw.forms,
	gml.draw.gpu,
	gml.draw.texture;

import gml.display, gml.game, gml.room, gml.window;

import core.time, core.thread;
import std.exception, std.format, std.math, std.string;
import ic.vec;
static import shelper;
import bindbc.sdl, bindbc.bgfx;

void init(){
	SDL_SysWMinfo wmi;
	SDL_GetVersion(&wmi.version_);
	enforce(SDL_GetWindowWMInfo(window, &wmi), "SDL failed to get window WM info: %s".format(SDL_GetError().fromStringz()));
	
	auto bgfxInit = bgfx.Init(0);
	
	bgfxInit.resolution.width = room.width;
	bgfxInit.resolution.height = room.height;
	bgfxInit.resolution.reset = bgfxResetFlags;
	
	switch(wmi.subsystem){
		version(linux){
			case SDL_SYSWM_X11:
				bgfxInit.platformData.nwh = cast(void*)wmi.info.x11.window;
				bgfxInit.platformData.ndt = wmi.info.x11.display;
				bgfxInit.type = RendererType.vulkan;
				break;
			case SDL_SYSWM_WAYLAND:
				bgfxInit.platformData.nwh = SDL_GetWindowData(window, "wl_egl_window");
				bgfxInit.platformData.ndt = wmi.info.wl.display;
				bgfxInit.type = RendererType.vulkan;
				break;
		}
		version(OSX){
			case SDL_SYSWM_COCOA:
				SDL_MetalView view = SDL_Metal_CreateView(window);
				bgfxInit.platformData.nwh = SDL_Metal_GetLayer(view);
				bgfxInit.type = RendererType.metal;
				break;
		}
		version(iOS){
			case SDL_SYSWM_UIKIT:
				bgfxInit.platformData.nwh = wmi.info.uikit.window;
				bgfxInit.type = RendererType.metal;
				break;
		}
		version(Android){
			case SDL_SYSWM_ANDROID:
				bgfxInit.platformData.nwh = wmi.info.android.window;
				bgfxInit.type = RendererType.vulkan;
				break;
		}
		version(Windows){
			case SDL_SYSWM_WINDOWS:
				bgfxInit.platformData.nwh = wmi.info.win.window;
				bgfxInit.type = RendererType.direct3D11;
				break;
		}
		default:
			enforce(0, "Your windowing sub-system is not supported on this platform.");
	}
	enforce(bgfx.init(bgfxInit), "bgfx failed to initialise");
	
	u_colour = bgfx.createUniform("u_colour", UniformType.vec4, 1);
	shPassPos       = shelper.load("passPos",       "uniformCol");
	shPassPosCol    = shelper.load("passPosCol",    "passCol");
	
	prevFrameTime = MonoTime.zero();
	gpuState = GPUState.init;
	gpuState.program = shPassPos;
	
	VertPos.init();
	VertPosCol.init();
	VertPosColTex.init();
	
	gml.draw.colour.init();
	gml.draw.forms.init();
	gml.draw.gpu.init();
	gml.draw.texture.init();
}

void quit(){
	gml.draw.texture.quit();
	gml.draw.gpu.quit();
	gml.draw.forms.quit();
	gml.draw.colour.quit();
	
	shelper.unloadAllShaderPrograms();
	bgfx.destroy(u_colour);
	
	bgfx.shutdown();
}

bgfx.ProgramHandle shPassPos, shPassPosCol;
bgfx.UniformHandle u_colour;

MonoTime prevFrameTime;

void startFrame(){
	if(prevFrameTime == MonoTime.zero()){
		prevFrameTime = MonoTime.currTime;
	}
	gpuState.view = 0;
	gpuState.setUpView();
}

void endFrame(){
	bgfx.frame();
	
	auto now = MonoTime.currTime;
	Duration waitFor = (prevFrameTime + frameDelay) - now;
	
	while(waitFor > msecs(3)){
		Thread.sleep(waitFor - msecs(3));
		
		now = MonoTime.currTime;
		waitFor = (prevFrameTime + frameDelay) - now;
	}
	const addNewPrevFrameTime = prevFrameTime + frameDelay;
	const nowNewPrevFrameTime = MonoTime.currTime;
	prevFrameTime = addNewPrevFrameTime.ticks > nowNewPrevFrameTime.ticks ? addNewPrevFrameTime : nowNewPrevFrameTime;
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
	
	void nextView() nothrow @nogc{
		view++;
		setUpView();
	}
	
	void setUpView() nothrow @nogc{
		if(room.views){
			//TODO: this
		}else{
			bgfx.setViewRect(view, 0, 0, cast(ushort)room.width, cast(ushort)room.height);
		}
		
		const projMat = Mat4.projOrtho(Vec2!float(0f, 0f), Vec2!float(room.width, room.height), -16000f,16000f, bgfx.getCaps().homogeneousDepth);
		bgfx.setViewTransform(view, null, &projMat);
		
		bgfx.touch(view);
	}
	
	bgfx.ProgramHandle program;
}
GPUState gpuState;

struct VertPos{
	float x,y;
	
	static bgfx.VertexLayout layout;
	static void init(){
		layout.begin()
			.add(Attrib.position,  2, AttribType.float_)
		.end();
	}
}
struct VertPosCol{
	float x,y;
	uint col;
	
	static bgfx.VertexLayout layout;
	static void init(){
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
	static void init(){
		layout.begin()
			.add(Attrib.position,  2, AttribType.float_)
			.add(Attrib.colour0,   4, AttribType.uint8, true)
			.add(Attrib.texCoord0, 2, AttribType.float_)
		.end();
	}
}
