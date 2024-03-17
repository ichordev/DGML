module gml.input;

public import
	gml.input.keyboard,
	gml.input.mouse;

void init(){
	gml.input.keyboard.init();
	gml.input.mouse.init();
}
