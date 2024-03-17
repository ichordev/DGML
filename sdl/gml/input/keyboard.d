module gml.input.keyboard;

import bindbc.sdl;

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

enum keycodeSpecialMask = cast(SDL_Keycode)(1U << 29U);

SDL_Keycode getSDLKeycode(VirtualKeyConstant code) nothrow @nogc pure @safe{
	switch(code){
		case VK.noKey:        return SDLK_UNKNOWN;
		case VK.anyKey:       return cast(SDL_Keycode)(keycodeSpecialMask | 0);
		case VK.left:         return SDLK_LEFT;
		case VK.right:        return SDLK_RIGHT;
		case VK.up:           return SDLK_UP;
		case VK.down:         return SDLK_DOWN;
		case VK.enter:        return SDLK_RETURN;
		case VK.escape:       return SDLK_ESCAPE;
		case VK.space:        return SDLK_SPACE;
		case VK.shift:        return cast(SDL_Keycode)(keycodeSpecialMask | 1);
		case VK.control:      return cast(SDL_Keycode)(keycodeSpecialMask | 2);
		case VK.alt:          return cast(SDL_Keycode)(keycodeSpecialMask | 3);
		case VK.backspace:    return SDLK_BACKSPACE;
		case VK.tab:          return SDLK_TAB;
		case VK.home:         return SDLK_HOME;
		case VK.end:          return SDLK_END;
		case VK.delete_:      return SDLK_DELETE;
		case VK.insert:       return SDLK_INSERT;
		case VK.pageup:       return SDLK_PAGEUP;
		case VK.pagedown:     return SDLK_PAGEDOWN;
		case VK.pause:        return SDLK_PAUSE;
		case VK.printScreen:  return SDLK_PRINTSCREEN;
		case VK.f1:           return SDLK_F1;
		case VK.f2:           return SDLK_F2;
		case VK.f3:           return SDLK_F3;
		case VK.f4:           return SDLK_F4;
		case VK.f5:           return SDLK_F5;
		case VK.f6:           return SDLK_F6;
		case VK.f7:           return SDLK_F7;
		case VK.f8:           return SDLK_F8;
		case VK.f9:           return SDLK_F9;
		case VK.f10:          return SDLK_F10;
		case VK.f11:          return SDLK_F11;
		case VK.f12:          return SDLK_F12;
		case VK.numpad0:      return SDLK_KP_0;
		case VK.numpad1:      return SDLK_KP_1;
		case VK.numpad2:      return SDLK_KP_2;
		case VK.numpad3:      return SDLK_KP_3;
		case VK.numpad4:      return SDLK_KP_4;
		case VK.numpad5:      return SDLK_KP_5;
		case VK.numpad6:      return SDLK_KP_6;
		case VK.numpad7:      return SDLK_KP_7;
		case VK.numpad8:      return SDLK_KP_8;
		case VK.numpad9:      return SDLK_KP_9;
		case VK.multiply:     return SDLK_KP_MEMMULTIPLY;
		case VK.divide:       return SDLK_KP_MEMDIVIDE;
		case VK.add:          return SDLK_KP_MEMADD;
		case VK.subtract:     return SDLK_KP_MEMSUBTRACT;
		case VK.decimal:      return SDLK_KP_DECIMAL;
		case VK.lShift:       return SDLK_LSHIFT;
		case VK.lControl:     return SDLK_LCTRL;
		case VK.lAlt:         return SDLK_LALT;
		case VK.rShift:       return SDLK_RSHIFT;
		case VK.rControl:     return SDLK_RCTRL;
		case VK.rAlt:         return SDLK_RALT;
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
		default: return SDLK_UNKNOWN;
	}
}
