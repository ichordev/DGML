module gml.input.keyboard;

version(Have_bindbc_sdl){
	import bindbc.sdl;
}

void init(){
	
}

alias VirtualKeyConstant = uint;

enum VK: VirtualKeyConstant{
	noKey       = 0,   ///keycode representing that no key is pressed
	nokey       = noKey,
	anyKey      = 1,   ///keycode representing that any key is pressed
	anykey      = anyKey,
	left        = 37,  ///keycode for the left arrow key
	right       = 39,  ///keycode for the right arrow key
	up          = 38,  ///keycode for the up arrow key
	down        = 40,  ///keycode for the down arrow key
	enter       = 13,  ///enter key
	escape      = 27,  ///escape key
	space       = 32,  ///space key
	shift       = 16,  ///either of the shift keys
	control     = 17,  ///either of the control keys
	alt         = 18,  ///alt key
	backspace   = 8,   ///backspace key
	tab         = 9,   ///tab key
	home        = 36,  ///home key
	end         = 35,  ///end key
	delete_     = 46,  ///delete key
	insert      = 45,  ///insert key
	pageup      = 33,  ///pageup key
	pagedown    = 34,  ///pagedown key
	pause       = 19,  ///pause/break key
	printScreen = 44,  ///printscreen/sysrq key
	printscreen = printScreen,
	f1          = 112, ///keycode for the function key F1
	f2          = 113, ///keycode for the function key F2
	f3          = 114, ///keycode for the function key F3
	f4          = 115, ///keycode for the function key F4
	f5          = 116, ///keycode for the function key F5
	f6          = 117, ///keycode for the function key F6
	f7          = 118, ///keycode for the function key F7
	f8          = 119, ///keycode for the function key F8
	f9          = 120, ///keycode for the function key F9
	f10         = 121, ///keycode for the function key F10
	f11         = 122, ///keycode for the function key F11
	f12         = 123, ///keycode for the function key F12
	numpad0     = 96,  ///number key 0 on the numeric keypad
	numpad1     = 97,  ///number key 1 on the numeric keypad
	numpad2     = 98,  ///number key 2 on the numeric keypad
	numpad3     = 99,  ///number key 3 on the numeric keypad
	numpad4     = 100, ///number key 4 on the numeric keypad
	numpad5     = 101, ///number key 5 on the numeric keypad
	numpad6     = 102, ///number key 6 on the numeric keypad
	numpad7     = 103, ///number key 7 on the numeric keypad
	numpad8     = 104, ///number key 8 on the numeric keypad
	numpad9     = 105, ///number key 9 on the numeric keypad
	multiply    = 106, ///multiply key on the numeric keypad
	divide      = 111, ///divide key on the numeric keypad
	add         = 107, ///add key on the numeric keypad
	subtract    = 109, ///subtract key on the numeric keypad
	decimal     = 110, ///decimal dot keys on the numeric keypad
	lShift      = 160, ///left shift key
	lshift      = lShift,
	lControl    = 162, ///left control key
	lcontrol    = lControl,
	lAlt        = 164, ///left alt key
	lalt        = lAlt,
	rShift      = 161, ///right shift key
	rshift      = rShift,
	rControl    = 163, ///right control key
	rcontrol    = rControl,
	rAlt        = 165, ///right alt key
	ralt = rAlt,
}
alias vk = VK;

VirtualKeyConstant ord(string string_) nothrow @nogc pure @safe =>
	cast(VirtualKeyConstant)string_[0];

version(Have_bindbc_sdl):
enum keycodeSpecialMask = cast(SDL_Keycode)(1U << 29U);

SDL_Keycode getSDLKeycode(VirtualKeyConstant code) nothrow @nogc pure @safe{
	switch(code){
		case noKey:        return SDLK_UNKNOWN;
		case anyKey:       return cast(SDL_Keycode)(keycodeSpecialMask | 0);
		case left:         return SDLK_LEFT;
		case right:        return SDLK_RIGHT;
		case up:           return SDLK_UP;
		case down:         return SDLK_DOWN;
		case enter:        return SDLK_RETURN;
		case escape:       return SDLK_ESCAPE;
		case space:        return SDLK_SPACE;
		case shift:        return cast(SDL_Keycode)(keycodeSpecialMask | 1);
		case control:      return cast(SDL_Keycode)(keycodeSpecialMask | 2);
		case alt:          return cast(SDL_Keycode)(keycodeSpecialMask | 3);
		case backspace:    return SDLK_BACKSPACE;
		case tab:          return SDLK_TAB;
		case home:         return SDLK_HOME;
		case end:          return SDLK_END;
		case delete_:      return SDLK_DELETE;
		case insert:       return SDLK_INSERT;
		case pageup:       return SDLK_PAGEUP;
		case pagedown:     return SDLK_PAGEDOWN;
		case pause:        return SDLK_PAUSE;
		case printScreen:  return SDLK_PRINTSCREEN;
		case f1:           return SDLK_F1;
		case f2:           return SDLK_F2;
		case f3:           return SDLK_F3;
		case f4:           return SDLK_F4;
		case f5:           return SDLK_F5;
		case f6:           return SDLK_F6;
		case f7:           return SDLK_F7;
		case f8:           return SDLK_F8;
		case f9:           return SDLK_F9;
		case f10:          return SDLK_F10;
		case f11:          return SDLK_F11;
		case f12:          return SDLK_F12;
		case numpad0:      return SDLK_KP_0;
		case numpad1:      return SDLK_KP_1;
		case numpad2:      return SDLK_KP_2;
		case numpad3:      return SDLK_KP_3;
		case numpad4:      return SDLK_KP_4;
		case numpad5:      return SDLK_KP_5;
		case numpad6:      return SDLK_KP_6;
		case numpad7:      return SDLK_KP_7;
		case numpad8:      return SDLK_KP_8;
		case numpad9:      return SDLK_KP_9;
		case multiply:     return SDLK_KP_MEMMULTIPLY;
		case divide:       return SDLK_KP_MEMDIVIDE;
		case add:          return SDLK_KP_MEMADD;
		case subtract:     return SDLK_KP_MEMSUBTRACT;
		case decimal:      return SDLK_KP_DECIMAL;
		case lShift:       return SDLK_LSHIFT;
		case lControl:     return SDLK_LCTRL;
		case lAlt:         return SDLK_LALT;
		case rShift:       return SDLK_RSHIFT;
		case rControl:     return SDLK_RCTRL;
		case rAlt:         return SDLK_RALT;
		case 'A': return SDLK_a; case 'B': return SDLK_b; case 'C': return SDLK_c;
		case 'D': return SDLK_d; case 'E': return SDLK_e; case 'F': return SDLK_f;
		case 'G': return SDLK_g; case 'H': return SDLK_h; case 'I': return SDLK_i;
		case 'J': return SDLK_j; case 'K': return SDLK_k; case 'L': return SDLK_l;
		case 'M': return SDLK_m; case 'N': return SDLK_n; case 'O': return SDLK_o;
		case 'P': return SDLK_p; case 'Q': return SDLK_q; case 'R': return SDLK_r;
		case 'S': return SDLK_s; case 'T': return SDLK_t; case 'U': return SDLK_u;
		case 'V': return SDLK_v; case 'W': return SDLK_w; case 'X': return SDLK_x;
		case 'Y': return SDLK_y; case 'Z': return SDLK_z; case '0': return SDLK_0;
		case '1': return SDLK_1; case '2': return SDLK_2; case '3': return SDLK_3;
		case '4': return SDLK_4; case '5': return SDLK_5; case '6': return SDLK_6;
		case '7': return SDLK_7; case '8': return SDLK_8; case '9': return SDLK_9;
	}
}
