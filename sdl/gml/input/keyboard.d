module gml.input.keyboard;

import bindbc.sdl;

void init() @safe{
	int keyCount;
	keysHeld = () @trusted{
		static assert(bool.sizeof == ubyte.sizeof); //so that we can implicitly convert `Uint8*` from `SDL_GetKeyboardState` into a bool array
		auto raw = SDL_GetKeyboardState(&keyCount);
		return (cast(const(bool)*)raw)[0..keyCount];
	}();
	keysPressed = null;
	keysPressed.length = keyCount;
	keysReleased = null;
	keysReleased.length = keyCount;
	
	keyboardKey = -1;
	keyboardLastKey = -1;
}

const(bool)[] keysHeld;
bool[] keysPressed;
bool[] keysReleased;

alias VirtualKeyConstant = int;

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
///Returns `false` if there's no equivalent VK code.
bool getVKCode(SDL_Keycode code, out VirtualKeyConstant key) nothrow @nogc pure @safe{
	switch(code){
		case SDLK_UNKNOWN:            key = VK.noKey; break;
		case keycodeSpecialMask | 0:  key = VK.anyKey; break;
		case SDLK_LEFT:               key = VK.left; break;
		case SDLK_RIGHT:              key = VK.right; break;
		case SDLK_UP:                 key = VK.up; break;
		case SDLK_DOWN:               key = VK.down; break;
		case SDLK_RETURN:             key = VK.enter; break;
		case SDLK_ESCAPE:             key = VK.escape; break;
		case SDLK_SPACE:              key = VK.space; break;
		case keycodeSpecialMask | 1:  key = VK.shift; break;
		case keycodeSpecialMask | 2:  key = VK.control; break;
		case keycodeSpecialMask | 3:  key = VK.alt; break;
		case SDLK_BACKSPACE:          key = VK.backspace; break;
		case SDLK_TAB:                key = VK.tab; break;
		case SDLK_HOME:               key = VK.home; break;
		case SDLK_END:                key = VK.end; break;
		case SDLK_DELETE:             key = VK.delete_; break;
		case SDLK_INSERT:             key = VK.insert; break;
		case SDLK_PAGEUP:             key = VK.pageup; break;
		case SDLK_PAGEDOWN:           key = VK.pagedown; break;
		case SDLK_PAUSE:              key = VK.pause; break;
		case SDLK_PRINTSCREEN:        key = VK.printScreen; break;
		case SDLK_F1:                 key = VK.f1; break;
		case SDLK_F2:                 key = VK.f2; break;
		case SDLK_F3:                 key = VK.f3; break;
		case SDLK_F4:                 key = VK.f4; break;
		case SDLK_F5:                 key = VK.f5; break;
		case SDLK_F6:                 key = VK.f6; break;
		case SDLK_F7:                 key = VK.f7; break;
		case SDLK_F8:                 key = VK.f8; break;
		case SDLK_F9:                 key = VK.f9; break;
		case SDLK_F10:                key = VK.f10; break;
		case SDLK_F11:                key = VK.f11; break;
		case SDLK_F12:                key = VK.f12; break;
		case SDLK_KP_0:               key = VK.numpad0; break;
		case SDLK_KP_1:               key = VK.numpad1; break;
		case SDLK_KP_2:               key = VK.numpad2; break;
		case SDLK_KP_3:               key = VK.numpad3; break;
		case SDLK_KP_4:               key = VK.numpad4; break;
		case SDLK_KP_5:               key = VK.numpad5; break;
		case SDLK_KP_6:               key = VK.numpad6; break;
		case SDLK_KP_7:               key = VK.numpad7; break;
		case SDLK_KP_8:               key = VK.numpad8; break;
		case SDLK_KP_9:               key = VK.numpad9; break;
		case SDLK_KP_MEMMULTIPLY:     key = VK.multiply; break;
		case SDLK_KP_MEMDIVIDE:       key = VK.divide; break;
		case SDLK_KP_MEMADD:          key = VK.add; break;
		case SDLK_KP_MEMSUBTRACT:     key = VK.subtract; break;
		case SDLK_KP_DECIMAL:         key = VK.decimal; break;
		case SDLK_LSHIFT:             key = VK.lShift; break;
		case SDLK_LCTRL:              key = VK.lControl; break;
		case SDLK_LALT:               key = VK.lAlt; break;
		case SDLK_RSHIFT:             key = VK.rShift; break;
		case SDLK_RCTRL:              key = VK.rControl; break;
		case SDLK_RALT:               key = VK.rAlt; break;
		case SDLK_a: key = 'A'; break; case SDLK_b: key = 'B'; break; case SDLK_c: key = 'C'; break;
		case SDLK_d: key = 'D'; break; case SDLK_e: key = 'E'; break; case SDLK_f: key = 'F'; break;
		case SDLK_g: key = 'G'; break; case SDLK_h: key = 'H'; break; case SDLK_i: key = 'I'; break;
		case SDLK_j: key = 'J'; break; case SDLK_k: key = 'K'; break; case SDLK_l: key = 'L'; break;
		case SDLK_m: key = 'M'; break; case SDLK_n: key = 'N'; break; case SDLK_o: key = 'O'; break;
		case SDLK_p: key = 'P'; break; case SDLK_q: key = 'Q'; break; case SDLK_r: key = 'R'; break;
		case SDLK_s: key = 'S'; break; case SDLK_t: key = 'T'; break; case SDLK_u: key = 'U'; break;
		case SDLK_v: key = 'V'; break; case SDLK_w: key = 'W'; break; case SDLK_x: key = 'X'; break;
		case SDLK_y: key = 'Y'; break; case SDLK_z: key = 'Z'; break; case SDLK_0: key = '0'; break;
		case SDLK_1: key = '1'; break; case SDLK_2: key = '2'; break; case SDLK_3: key = '3'; break;
		case SDLK_4: key = '4'; break; case SDLK_5: key = '5'; break; case SDLK_6: key = '6'; break;
		case SDLK_7: key = '7'; break; case SDLK_8: key = '8'; break; case SDLK_9: key = '9'; break;
		default: return false;
	}
	return true;
}

void setPressed(SDL_Keycode val) nothrow @nogc @safe{
	keysPressed[val] = true;
}
void setReleased(SDL_Keycode val) nothrow @nogc @safe{
	keysReleased[val] = true;
}
void resetKeyStates() nothrow @nogc @safe{
	keysPressed[] = false;
	keysReleased[] = false;
}

//General

void ioClear() nothrow @nogc{
	SDL_ResetKeyboard();
	resetKeyStates();
}
alias io_clear = ioClear;

bool keyboardCheck(VirtualKeyConstant key) nothrow @nogc @safe =>
	keysHeld[getSDLKeycode(key)];
alias keyboard_check = keyboardCheck;

bool keyboardCheckPressed(VirtualKeyConstant key) nothrow @nogc @safe =>
	keysPressed[getSDLKeycode(key)];
alias keyboard_check_pressed = keyboardCheckPressed;

bool keyboardCheckReleased(VirtualKeyConstant key) nothrow @nogc @safe =>
	keysReleased[getSDLKeycode(key)];
alias keyboard_check_released = keyboardCheckReleased;

//TODO: keyboard_clear

//TODO: keyboard_set_map

//TODO: keyboard_get_map

//TODO: keyboard_unset_map

void keyboardSetNumlock(bool value) nothrow @nogc{
	auto mods = SDL_GetModState();
	if(value){
		mods |= KMOD_NUM;
	}else{
		mods &= KMOD_NUM;
	}
	SDL_SetModState(mods);
}
alias keyboard_set_numlock = keyboardSetNumlock;

bool keyboardGetNumlock() nothrow @nogc =>
	(SDL_GetModState() & KMOD_NUM) != 0;
alias keyboard_get_numlock = keyboardGetNumlock;

//Simulating Keypresses

//TODO: keyboard_key_press

//TODO: keyboard_key_release

//Keyboard State & Input

VirtualKeyConstant keyboardKey;
alias keyboard_key = keyboardKey;

VirtualKeyConstant keyboardLastKey;
alias keyboard_lastkey = keyboardLastKey;

//TODO: keyboard_lastchar

//TODO: keyboard_string
