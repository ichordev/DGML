module gml.room;

import ic.vec;

Room[] orderedRooms;
Room room;

//when room starts: copy orderedRoom into room

struct Viewport{
	bool visible = false;
	Vec2!float pos;
	Vec2!float size;
}

struct Room{
	double width = 800.0;
	double height = 600.0;
	bool persistent = false;
	bool views = false;
	Viewport[8] viewports;
}
