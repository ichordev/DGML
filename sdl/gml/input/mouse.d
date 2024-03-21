module gml.input.mouse;

import gml.room, gml.window;

import ic.vec;
import bindbc.sdl;

void init() @safe{
	resetMouseStates();
}

void quit(){
	
}

alias MouseButtonConstant = uint;

MouseButtonConstant mousePressed;
MouseButtonConstant mouseReleased;
float scrolling;
Vec2!int absMousePos;
Vec2!int relMousePos;

enum MB: MouseButtonConstant{
	left    = SDL_BUTTON(SDL_BUTTON_LEFT),    ///The left mouse button
	middle  = SDL_BUTTON(SDL_BUTTON_MIDDLE),  ///The middle mouse button
	right   = SDL_BUTTON(SDL_BUTTON_RIGHT),   ///The right mouse button
	side1   = SDL_BUTTON(SDL_BUTTON_X1),      ///Mouse side button 1
	side2   = SDL_BUTTON(SDL_BUTTON_X2),      ///Mouse side button 2
	any     = left|middle|right|side1|side2,  ///Any of the mouse buttons
	none    = 0,                              ///No mouse button
}
alias mb = MB;

void setPressed(byte val) nothrow @nogc @safe{
	mousePressed |= SDL_BUTTON(val);
}

void setReleased(byte val) nothrow @nogc @safe{
	mouseReleased |= SDL_BUTTON(val);
}

void resetMouseStates() nothrow @nogc @safe{
	mousePressed = MB.none;
	mouseReleased = MB.none;
	scrolling = 0f;
	relMousePos.x = 0;
	relMousePos.y = 0;
	mouseViewPosDirty = true;
	mouseViewsPosDirty[] = true;
	mouseButton = MB.none;
	mouseLastButton = MB.none;
}

//Standard Mouse Button Controls

MouseButtonConstant mouseButton;
alias mouse_button = mouseButton;

bool mouseCheckButton(MouseButtonConstant numb) nothrow @nogc =>
	(SDL_GetMouseState(null, null) & numb) != 0;
alias mouse_check_button = mouseCheckButton;

bool mouseCheckButtonPressed(MouseButtonConstant numb) nothrow @nogc =>
	(mousePressed & numb) != 0;
alias mouse_check_button_pressed = mouseCheckButtonPressed;

bool mouseCheckButtonReleased(MouseButtonConstant numb) nothrow @nogc =>
	(mouseReleased & numb) != 0;
alias mouse_check_button_released = mouseCheckButtonReleased;

//TODO: mouse_clear

MouseButtonConstant mouseLastButton;

//TODO: mouse_wheel_up

//TODO: mouse_wheel_down

bool mouseViewPosDirty;
Vec2!int mouseViewPos;
bool[Room.viewCount] mouseViewsPosDirty;
Vec2!int[Room.viewCount] mouseViewsPos;

//Window Functions

int windowMouseGetX() nothrow @nogc @safe =>
	absMousePos.x;
alias window_mouse_get_x = windowMouseGetX;

int windowMouseGetY() nothrow @nogc @safe =>
	absMousePos.y;
alias window_mouse_get_y = windowMouseGetY;

int windowMouseGetDeltaX() nothrow @nogc @safe =>
	relMousePos.x;
alias window_mouse_get_delta_x = windowMouseGetDeltaX;

int windowMouseGetDeltaY() nothrow @nogc @safe =>
	relMousePos.y;
alias window_mouse_get_delta_y = windowMouseGetDeltaY;

void windowMouseSet(int x, int y) nothrow @nogc{
	SDL_WarpMouseInWindow(window, x, y);
}
alias window_mouse_set = windowMouseSet;
