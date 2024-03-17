module gml.core;

public import
	gml.collision,
	gml.ds,
	gml.game,
	gml.maths,
	gml.room;

void init(){
	gml.collision.init();
	gml.ds.init();
	gml.game.init();
	gml.maths.init();
}
