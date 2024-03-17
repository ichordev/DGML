module gml.input.mouse;

import gml.room, gml.window;

import bindbc.sdl;

void init() @safe{
	resetMouseStates();
}

alias MouseButtonConstant = uint;

MouseButtonConstant mousePressed;
MouseButtonConstant mouseReleased;
float scrolling;

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

@property double mouseX() nothrow @nogc @trusted{
	int x;
	SDL_GetMouseState(&x, null);
	return (x - room.viewports[0].pos.x) / room.viewports[0].size.x;
}
alias mouse_x = mouseX;

@property double mouseY() nothrow @nogc @trusted{
	int y;
	SDL_GetMouseState(null, &y);
	return (y - room.viewports[0].pos.y) / room.viewports[0].size.y;
}
alias mouse_y = mouseY;

int windowMouseGetX() nothrow @nogc @trusted{
	int x;
	SDL_GetMouseState(&x, null);
	return x;
}
alias window_mouse_get_x = windowMouseGetX;

int windowMouseGetY() nothrow @nogc @trusted{
	int y;
	SDL_GetMouseState(null, &y);
	return y;
}
alias window_mouse_get_y = windowMouseGetY;

void windowMouseSet(int x, int y) nothrow @nogc{
	SDL_WarpMouseInWindow(window, x, y);
}
alias window_mouse_set = windowMouseSet;
