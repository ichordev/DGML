module gml.object;

import gml.layer, gml.maths, gml.sprite;

import core.memory;
import std.math;

class GMObject{
	bool visible = true;
	bool solid;
	const bool persistent;
	float depth = float.nan; //sets gpuState.depth
	LayerID layer;
	int[12] alarm;
	
	final @property float direction() nothrow @nogc pure @safe => datan2(vSpeed, hSpeed);
	final @property direction(float val) nothrow @nogc pure @safe{
		const rad = val.degToRad();
		const s = speed;
		hSpeed = cos(rad) * s;
		vSpeed = sin(rad) * s;
	}
	float friction = 0f;
	float gravity = 0f;
	float gravityDirection = 0f;
	alias gravity_direction = gravityDirection;
	float hSpeed;
	alias hspeed = hSpeed;
	float vSpeed;
	alias vspeed = vSpeed;
	final @property float speed() nothrow @nogc pure @safe => sqrt(hSpeed*hSpeed + vSpeed*vSpeed);
	final @property speed(float val) nothrow @nogc pure @safe{
		const rad = atan2(vSpeed, hSpeed);
		hSpeed = cos(rad) * val;
		vSpeed = sin(rad) * val;
	}
	float xStart = 0f;
	alias xstart = xStart;
	float yStart = 0f;
	alias ystart = yStart;
	float x = 0f;
	float y = 0f;
	float xPrevious;
	alias xprevious = xPrevious;
	float yPrevious;
	alias yprevious = yPrevious;
	
	SpriteAsset spriteIndex = new SpriteAsset(-1);
	alias sprite_index = spriteIndex;
	final @property double spriteWidth() nothrow @nogc pure @safe => double.nan * imageXScale; //TODO: get width
	alias sprite_width = spriteWidth;
	final @property double spriteHeight() nothrow @nogc pure @safe => double.nan * imageYScale;
	alias sprite_height = spriteHeight;
	final @property double spriteXOffset() nothrow @nogc pure @safe => double.nan * imageXScale; //TODO: get width
	alias sprite_xoffset = spriteXOffset;
	final @property double spriteYOffset() nothrow @nogc pure @safe => double.nan * imageYScale;
	alias sprite_yoffset = spriteYOffset;
	float imageAlpha = 1f;
	alias image_alpha = imageAlpha;
	double imageAngle = 0.0;
	alias image_angle = imageAngle;
	long imageBlend = -1;
	alias image_blend = imageBlend;
	int imageIndex = 0;
	alias image_index = imageIndex;
	final @property uint imageNumber() => 0; //TODO: get frame count
	alias image_number = imageNumber;
	float imageSpeed = 1f;
	alias image_speed = imageSpeed;
	float imageXScale = 1f;
	alias image_xscale = imageXScale;
	float imageYScale = 1f;
	alias image_yscale = imageYScale;
	SpriteAsset maskIndex = new SpriteAsset(-1);
	alias mask_index = maskIndex;
	final @property int bboxBottom() nothrow @nogc pure @safe => y; //TODO: get bbox
	alias bbox_bottom = bboxBottom;
	final @property int bboxLeft() nothrow @nogc pure @safe => x;
	alias bbox_left = bboxLeft;
	final @property int bboxRight() nothrow @nogc pure @safe => x;
	alias bbox_right = bboxRight;
	final @property int bboxTop() nothrow @nogc pure @safe => y;
	alias bbox_top = bboxTop;
	
	this(bool persistent){
		this.persistent = persistent;
	}
	
	final void instanceDestroy(){
		instanceDestroy(this);
	}
	alias instance_destroy = instanceDestroy;
	
	final void builtInStep(){
		//TODO: this
	}
	
	final void drawSelf(){
		//TODO: this
	}
	alias draw_self = drawSelf;
	
	void onPreStep(){}
	void onStep(){}
	void onPostStep(){}
	
	void onDraw(){
		drawSelf();
	}
	
	void onAlarm0(){}
	void onAlarm1(){}
	void onAlarm2(){}
	void onAlarm3(){}
	void onAlarm4(){}
	void onAlarm5(){}
	void onAlarm6(){}
	void onAlarm7(){}
	void onAlarm8(){}
	void onAlarm9(){}
	void onAlarm10(){}
	void onAlarm11(){}
	void onAlarm12(){}
	
	void onGameStart(){}
	void onGameEnd(){}
	
	void onRoomStart(){}
	void onRoomEnd(){}
	
	void onDestroy(){}
}

Obj instanceCreateLayer(Obj)(float x, float y, LayerID layerID) nothrow pure @safe{
	auto obj = new Obj();
	obj.x = x;
	obj.y = y;
	obj.layer = layerID;
}
Obj instanceCreateLayer(Obj)(float x, float y, string layerID){
	auto obj = new Obj();
	obj.x = x;
	obj.y = y;
	//obj.layer = layerID;
}
alias instance_create_layer = instanceCreateLayer;

Obj instanceCreateDepth(Obj)(float x, float y, float depth){
	auto obj = new Obj();
	obj.x = x;
	obj.y = y;
	obj.depth = depth;
}
alias instance_create_depth = instanceCreateDepth;

void instanceDestroy(Obj)(Obj id, executeEventFlag=true){
	if(executeEventFlag){
		id.onDestroy();
	}
	//Add to instance free queue
}
alias instance_destroy = instanceDestroy;
