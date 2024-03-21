module gml.window;

import gml.camera, gml.collision, gml.input, gml.options, gml.room;

import std.exception, std.string;
import ic.vec;
import bindbc.sdl;

void init(){
	enforce(SDL_InitSubSystem(SDL_INIT_VIDEO) == 0, "SDL failed to initialise video: %s".format(SDL_GetError().fromStringz()));
	
	windowSize = roomData.windowSize;
	prevWindowSize = windowSize;
	window = SDL_CreateWindow(
		options.displayName.toStringz(),
		SDL_WINDOWPOS_CENTRED,
		SDL_WINDOWPOS_CENTRED,
		windowSize.x,
		windowSize.y,
		(
			SDL_WINDOW_SHOWN
			| (options.startFullscreen ? SDL_WINDOW_FULLSCREEN : 0)
			| (options.allowWindowResize ? SDL_WINDOW_RESIZABLE : 0)
			| (options.borderlessWindow ? SDL_WINDOW_BORDERLESS : 0)
			| (options.enableHighDPI ? SDL_WINDOW_ALLOW_HIGHDPI : 0)
		),
	);
	enforce(window !is null, "SDL window creation error: %s".format(SDL_GetError().fromStringz()));
	windowFocused = true;
	windowColour = 0x00_00_00;
	borderlessFullscreen = false;
}

void quit(){
	SDL_QuitSubSystem(SDL_INIT_VIDEO);
}

Vec2!uint windowSize;
Vec2!uint prevWindowSize;
SDL_Window* window;
bool windowFocused;
uint windowColour;
bool borderlessFullscreen;

///Returns `false` if the program should exit.
bool processEvents(){
	resetKeyStates();
	keyboardLastKey = keyboardKey;
	resetMouseStates();
	
	prevWindowSize = windowSize;
	auto oldMB = mouseButton;
	
	SDL_Event event;
	while(SDL_PollEvent(&event)){
		switch(event.type){
			case SDL_WINDOWEVENT:
				switch(event.window.event){
					case SDL_WINDOWEVENT_FOCUS_GAINED:
						windowFocused = true;
						break;
					case SDL_WINDOWEVENT_FOCUS_LOST:
						windowFocused = false;
						break;
					case SDL_WINDOWEVENT_SIZE_CHANGED:
						windowSize = Vec2!uint(
							event.window.data1,
							event.window.data2,
						);
						break;
					default:
				}
				break;
			case SDL_KEYDOWN:
				if(event.key.repeat != 0) break;
				gml.input.keyboard.setPressed(event.key.keysym.sym);
				VirtualKeyConstant vkKey;
				if(getVKCode(event.key.keysym.sym, vkKey)){
					keyboardKey = vkKey;
				}
				break;
			case SDL_KEYUP:
				gml.input.keyboard.setReleased(event.key.keysym.sym);
				VirtualKeyConstant vkKey;
				if(getVKCode(event.key.keysym.sym, vkKey)){
					if(vkKey == keyboardKey){
						keyboardKey = -1;
					}
				}
				break;
			case SDL_MOUSEMOTION:
				absMousePos.x = event.motion.x;
				absMousePos.y = event.motion.y;
				relMousePos.x += event.motion.xrel;
				relMousePos.y += event.motion.yrel;
				break;
			case SDL_MOUSEBUTTONDOWN:
				gml.input.mouse.setPressed(event.button.button);
				mouseButton = SDL_BUTTON(event.button.button);
				break;
			case SDL_MOUSEBUTTONUP:
				gml.input.mouse.setReleased(event.button.button);
				if(mouseButton == SDL_BUTTON(event.button.button)){
					mouseButton = MB.none;
				}
				break;
			case SDL_QUIT:
				return false;
			default:
		}
	}
	
	if(oldMB != mouseButton){
		mouseLastButton = oldMB;
	}
	
	return true;
}

//Window Info

void* windowHandle() nothrow @nogc{
	SDL_SysWMinfo wmi;
	SDL_GetVersion(&wmi.version_);
	if(SDL_GetWindowWMInfo(window, &wmi)){
		switch(wmi.subsystem){
		version(linux){
			case SDL_SYSWM_X11:
				return cast(void*)wmi.info.x11.window;
			case SDL_SYSWM_WAYLAND:
				return SDL_GetWindowData(window, "wl_egl_window");
		}else version(OSX){
			case SDL_SYSWM_COCOA:
				SDL_MetalView view = SDL_Metal_CreateView(window);
				return SDL_Metal_GetLayer(view);
		}else version(iOS){
			case SDL_SYSWM_UIKIT:
				return wmi.info.uikit.window;
		}else version(Android){
			case SDL_SYSWM_ANDROID:
				return wmi.info.android.window;
		}else version(Windows){
			case SDL_SYSWM_WINDOWS:
				return wmi.info.win.window;
		}else static assert(0, "Getting a native window handle is unsupported on this platform!");
			default:
		}
	}
	return null;
}
alias window_handle = windowHandle;

bool windowHasFocus() nothrow @nogc @safe =>
	windowFocused;
alias window_has_focus = windowHasFocus;

//Mouse & Cursor

//TODO: window_set_cursor
//TODO: window_get_cursor

//Mouse Lock

void windowMouseSetLocked(bool enable) nothrow @nogc{
	SDL_SetRelativeMouseMode(enable);
}
alias window_mouse_set_locked = windowMouseSetLocked;

bool windowMouseGetLocked() nothrow @nogc =>
	SDL_GetRelativeMouseMode() == SDL_TRUE;
alias window_mouse_get_locked = windowMouseGetLocked;

//Drawing

void windowSetColour(uint colour) nothrow @nogc @safe{
	windowColour = ((colour & 0xFF) << 24) | ((colour & 0xFF_00) << 8) | ((colour & 0xFF_00_00) >> 8) | 0xFF;
}
alias window_set_colour = windowSetColour;

uint windowGetColour() nothrow @nogc @safe =>
	windowColour;
alias window_get_colour = windowGetColour;

//Border & Caption

void windowSetCaption(string caption) nothrow{
	SDL_SetWindowTitle(window, caption.toStringz());
}
alias window_set_caption = windowSetCaption;

const(char)[] windowGetCaption() nothrow @nogc =>
	SDL_GetWindowTitle(window).fromStringz();
alias window_get_caption = windowGetCaption;

void windowSetShowBorder(bool show) nothrow @nogc{
	SDL_SetWindowBordered(window, show);
}
alias window_set_showborder = windowSetShowBorder;

bool windowGetShowBorder() nothrow @nogc =>
	(SDL_GetWindowFlags(window) & SDL_WINDOW_BORDERLESS) != 0;
alias window_get_showborder = windowGetShowBorder;

void windowEnableBorderlessFullscreen(bool enable) nothrow @nogc @safe{
	borderlessFullscreen = enable;
}
alias window_enable_borderless_fullscreen = windowEnableBorderlessFullscreen;

bool windowGetBorderlessFullscreen() nothrow @nogc @safe =>
	borderlessFullscreen;
alias window_get_borderless_fullscreen = windowGetBorderlessFullscreen;

//Dimensions & Position

void windowCentre() nothrow @nogc{
	SDL_SetWindowPosition(window, SDL_WINDOWPOS_CENTRED, SDL_WINDOWPOS_CENTRED);
}
alias window_center = windowCentre;

bool windowGetFullscreen() nothrow @nogc =>
	(SDL_GetWindowFlags(window) & (SDL_WINDOW_FULLSCREEN | SDL_WINDOW_FULLSCREEN_DESKTOP)) != 0;
alias window_get_fullscreen = windowGetFullscreen;

int windowGetWidth() nothrow @nogc{
	int w;
	SDL_GetWindowSize(window, &w, null);
	return w;
}
alias window_get_width = windowGetWidth;

int windowGetHeight() nothrow @nogc{
	int h;
	SDL_GetWindowSize(window, null, &h);
	return h;
}
alias window_get_height = windowGetHeight;

int windowGetX() nothrow @nogc{
	int x;
	SDL_GetWindowPosition(window, &x, null);
	return x;
}
alias window_get_x = windowGetX;

int windowGetY() nothrow @nogc{
	int y;
	SDL_GetWindowPosition(window, null, &y);
	return y;
}
alias window_get_y = windowGetY;

//TODO: window_get_visible_rects

void windowSetFullscreen(bool full) nothrow @nogc{
	SDL_SetWindowFullscreen(window, full ? (borderlessFullscreen ? SDL_WINDOW_FULLSCREEN_DESKTOP : SDL_WINDOW_FULLSCREEN) : 0);
}
alias window_set_fullscreen = windowSetFullscreen;

void windowSetPosition(uint x, uint y) nothrow @nogc{
	SDL_SetWindowPosition(window, x, y);
}
alias window_set_position = windowSetPosition;

void windowSetSize(int w, int h) nothrow @nogc{
	SDL_SetWindowSize(window, w, h);
}
alias window_set_size = windowSetSize;

void windowSetRectangle(uint x, uint y, int w, int h) nothrow @nogc{
	windowSetPosition(x, y);
	windowSetSize(w, h);
}
alias window_set_rectangle = windowSetRectangle;

void windowSetMinWidth(int width) nothrow @nogc{
	int height;
	SDL_GetWindowMinimumSize(window, null, &height);
	SDL_SetWindowMinimumSize(window, width, height);
}
alias window_set_min_width = windowSetMinWidth;

void windowSetMaxWidth(int width) nothrow @nogc{
	int height;
	SDL_GetWindowMaximumSize(window, null, &height);
	SDL_SetWindowMaximumSize(window, width, height);
}
alias window_set_max_width = windowSetMaxWidth;

void windowSetMinHeight(int height) nothrow @nogc{
	int width;
	SDL_GetWindowMinimumSize(window, &width, null);
	SDL_SetWindowMinimumSize(window, width, height);
}
alias window_set_min_height = windowSetMinHeight;

void windowSetMaxHeight(int height) nothrow @nogc{
	int width;
	SDL_GetWindowMaximumSize(window, &width, null);
	SDL_SetWindowMaximumSize(window, width, height);
	
}
alias window_set_max_height = windowSetMaxHeight;
