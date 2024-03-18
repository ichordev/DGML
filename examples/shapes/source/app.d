module app;

import std.file, std.math, std.path;
import ic.calc;
import shelper;
import gml;

void main(){
	shelper.shaderPath = buildNormalizedPath(thisExePath()~"/../../shaders/")~"/";
	
	gml.room.orderedRooms ~= Room(width: 800, height: 600);
	gml.initAll();
	
	
	float s = 0f;
	while(processEvents()){
		startFrame();
		
		s += 0.001f;
		s %= pi*2f;
		float x = sin(s)*0.5f + 0.5f;
		float y = abs(cos(s));
		
		drawClear(C.grey);
		drawSetColour(0xFF_FF_FF);
		drawRectangle(10, 100, lerp(100, 350, x), lerp(200, 400, x), false);
		drawSetColour(0xFF);
		drawRectangle(lerp(200, 400, x), lerp(150, 300, x), 700, 750, false);
		drawSetColour(C.maroon);
		drawCircle(200, 450, lerp(20, 80, y), true);
		drawCircle(550, 160, lerp(10, 90, 1f-y), false);
		
		endFrame();
	}
	
	quitAll();
}
