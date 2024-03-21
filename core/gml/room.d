module gml.room;

import gml.camera;

import std.algorithm.comparison;
import ic.vec;

void init(){
	roomInd = 0;
	roomStart();
}

void quit(){
	
}

Room[] orderedRooms;
Room roomData;
size_t roomInd;

struct Room{
	Vec2!uint size = Vec2!uint(1366, 768);
	bool persistent = false;
	bool useViews = false;
	enum viewCount = 8;
	Viewport[viewCount] viewports;
	
	bool ordered = false;
	
	@property Vec2!uint windowSize(){
		if(useViews){
			//technically there should be a 'windowPos' variable, used to account for a `minPos` of >0, but GameMaker doesn't account for this at all!
			auto minPos = Vec2!uint(uint.max, uint.max);
			Vec2!uint maxPos;
			foreach(viewport; viewports){
				if(viewport.visible){
					const portMaxPos = viewport.pos + viewport.size;
					minPos.x = min(minPos.x, viewport.pos.x);
					minPos.y = min(minPos.y, viewport.pos.y);
					maxPos.x = max(maxPos.x, portMaxPos.x);
					maxPos.y = max(maxPos.y, portMaxPos.y);
				}
			}
			if(minPos == vec2(uint.max, uint.max)){
				return size;
			}else{
				return maxPos - minPos;
			}
		}else{
			return size;
		}
	}
}

alias RoomAsset = Room*;

void roomStart(){
	//room = &orderedRooms[roomInd];
	roomData = orderedRooms[roomInd];
	roomData.ordered = false;
}

//Global

@property RoomAsset roomFirst() nothrow @nogc @safe =>
	&orderedRooms[0];
alias room_first = roomFirst;

alias roomHeight = roomData.size.y;
alias room_height = roomHeight;

//Information

Room* roomAdd() nothrow pure @safe =>
	new Room();
alias room_add = roomAdd;

Room* roomAddOrdered() nothrow @safe{
	orderedRooms ~= Room();
	return &orderedRooms[$-1];
}


