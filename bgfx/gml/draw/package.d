module gml.draw;

public import
	gml.draw.colour,
	gml.draw.forms,
	gml.draw.gpu,
	gml.draw.texture;

import gml.camera, gml.display, gml.game, gml.options, gml.room, gml.window;

import core.time, core.thread;
import std.algorithm.comparison, std.exception, std.format, std.math, std.string;
import ic.vec;
static import shelper;
import bindbc.sdl, bindbc.bgfx;

void init(){
	masterViewportPos1 = Vec2!ushort(0, 0);
	masterViewportPos2 = Vec2!ushort(windowSize.x, windowSize.y);
	masterViewportScale = Vec2!double(1.0, 1.0);
	
	SDL_SysWMinfo wmi;
	SDL_GetVersion(&wmi.version_);
	enforce(SDL_GetWindowWMInfo(window, &wmi), "SDL failed to get window WM info: %s".format(SDL_GetError().fromStringz()));
	
	auto bgfxInit = bgfx.Init(0);
	
	bgfxInit.resolution.width  = windowSize.x;
	bgfxInit.resolution.height = windowSize.y;
	bgfxInit.resolution.reset  = bgfxResetFlags;
	
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

Vec2!ushort masterViewportPos1;
Vec2!ushort masterViewportPos2;
Vec2!double masterViewportScale;

void scaleToMasterViewport(ref Vec2!ushort pos, ref Vec2!ushort size) nothrow @nogc @safe{
	pos = masterViewportPos1 + Vec2!ushort(
		cast(ushort)round(pos.x * masterViewportScale.x),
		cast(ushort)round(pos.y * masterViewportScale.y),
	);
	size = Vec2!ushort(
		cast(ushort)round(size.x * masterViewportScale.x),
		cast(ushort)round(size.y * masterViewportScale.y),
	);
}

void startFrame(){
	if(prevFrameTime == MonoTime.zero()){
		prevFrameTime = MonoTime.currTime;
	}
	
	if(windowSize != prevWindowSize){
		bgfx.reset(windowSize.x, windowSize.y, bgfxResetFlags);
		
		const roomWindowSize = room.windowSize;
		if(options.keepAspectRatio){
			const ratio = roomWindowSize.x / cast(double)roomWindowSize.y;
			const masterViewportSize = {
				if(cast(uint)(windowSize.x / ratio) > windowSize.y){
					return Vec2!ushort(
						cast(ushort)ceil(windowSize.y * ratio),
						cast(ushort)windowSize.y,
					);
				}else{
					return Vec2!ushort(
						cast(ushort)windowSize.x,
						cast(ushort)ceil(windowSize.x / ratio),
					);
				}
			}();
			masterViewportPos1 = Vec2!ushort(
				cast(ushort)(windowSize.x / 2),
				cast(ushort)(windowSize.y / 2),
			) - (masterViewportSize / 2);
			masterViewportPos2 = masterViewportPos1 + masterViewportSize;
			masterViewportScale = Vec2!double(masterViewportSize.x / cast(double)roomWindowSize.x);
		}else{
			masterViewportPos1 = Vec2!ushort(0, 0);
			masterViewportPos2 = Vec2!ushort(windowSize.x, windowSize.y);
			masterViewportScale = cast(Vec2!double)(masterViewportPos2 - masterViewportPos1) / Vec2!double(
				roomWindowSize.x, roomWindowSize.y,
			);
		}
	}
	
	if(room.useViews){
		foreach(viewport; room.viewports){
			if(viewport.visible){
				if(viewport.camera){
					viewport.camera.update();
				}
			}
		}
	}
	
	viewCurrent = 0;
	viewNext = 0;
	gpuState.bgfxView = 0;
	gpuState.bgfxViewNext = 2;
	
	bgfx.setViewClear(gpuState.bgfxView, Clear.colour | Clear.depth, windowColour);
	bgfx.setViewRect(gpuState.bgfxView, 0, 0, cast(ushort)windowSize.x, cast(ushort)windowSize.y);
	bgfx.touch(gpuState.bgfxView);
}

bool nextView(){
	viewCurrent = viewNext;
	
	if(room.useViews){
		if(viewCurrent > 0){
			if(viewportCam){
				viewportCam.end();
			}
		}
		
		//find first visible viewport
		Viewport port;
		while(viewCurrent < 8){
			port = room.viewports[viewCurrent];
			if(port.visible){
				break;
			}
			viewCurrent++;
		}
		if(viewCurrent >= 8) return false;
		
		port.apply();
		
		viewNext = viewCurrent+1;
	}else{
		if(viewCurrent >= 1) return false;
		
		const roomWindowSize = room.windowSize;
		viewportPos = Vec2!ushort(0, 0);
		viewportSize = Vec2!ushort(roomWindowSize.x, roomWindowSize.y);
		
		viewportCam = null;
		
		viewNext = 1;
	}
	
	scaleToMasterViewport(viewportPos, viewportSize);
	
	gpuState.nextBgfxView();
	return true;
}

void endFrame(){
	bgfx.frame();
	viewportCam = null;
	
	auto now = MonoTime.currTime;
	Duration waitFor = (prevFrameTime + frameDelay) - now;
	
	while(waitFor > usecs(50)){
		Thread.sleep(waitFor - usecs(50));
		
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
	
	bgfx.ViewID bgfxViewNext = 0;
	bgfx.ViewID bgfxView = 0;
	
	void nextBgfxView() nothrow @nogc{
		bgfxView = bgfxViewNext;
		bgfxViewNext++;
		setUpBgfxView();
	}
	
	void setUpBgfxView() nothrow @nogc{
		if(viewportCam is null){
			bgfx.setViewRect(
				bgfxView,
				viewportPos.x,
				viewportPos.y,
				viewportSize.x,
				viewportSize.y,
			);
			
			const projMat = Mat4.projOrtho(Vec2!float(0f, 0f), Vec2!float(room.size.x, room.size.y), -16000f, 16000f, bgfx.getCaps().homogeneousDepth);
			bgfx.setViewTransform(bgfxView, null, &projMat);
		}else{
			bgfx.setViewRect(bgfxView, viewportPos.x, viewportPos.y, viewportSize.x, viewportSize.y);
			bgfx.setViewTransform(bgfxView, &viewportCam.view, &viewportCam.proj);
		}
		
		bgfx.touch(bgfxView);
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

void cameraApply(Camera cameraID) nothrow @nogc{
	viewportCam = cameraID;
	gpuState.nextBgfxView();
}
alias camera_apply = cameraApply;
