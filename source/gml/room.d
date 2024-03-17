module gml.room;

import ic.vec;

void init(){
	
}

Room[] orderedRooms;
Room room;

//when room starts: copy orderedRoom into room

struct Viewport{
	bool visible = false;
	Vec2!float pos;
	Vec2!float size;
}

struct Room{
	uint width = 800;
	uint height = 600;
	bool persistent = false;
	bool views = false;
	Viewport[8] viewports;
}
