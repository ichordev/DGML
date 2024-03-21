module gml.camera;

import gml.room;

import std.math;
import ic.vec;

void init(){
	
}

void quit(){
	
}

Vec2!ushort viewportPos;
Vec2!ushort viewportSize;
Camera viewportCam;

Vec2!ushort masterViewportPos1;
Vec2!ushort masterViewportPos2;
Vec2!double masterViewportScale;

void scaleToMasterViewport(ref Vec2!ushort pos, ref Vec2!ushort size) nothrow @nogc @safe{
	pos = masterViewportPos1 + Vec2!ushort(
		cast(ushort)round(pos.x * masterViewportScale.x),
		cast(ushort)round(pos.y * masterViewportScale.y),
	);
	size = Vec2!ushort(
		cast(ushort)round(size.x * masterViewportScale.x),
		cast(ushort)round(size.y * masterViewportScale.y),
	);
}

Mat4 viewMat;
Mat4 projMat;
Mat4 worldMat;

class Camera{
	Mat4 view;
	Mat4 proj;
	
	static Mat4 getDefaultView() nothrow @nogc pure @safe =>
		Mat4.init;
	static Mat4 getDefaultProj(bool homoNDC) nothrow @nogc @safe =>
		Mat4.projOrtho(Vec2!float(0f, 0f), Vec2!float(roomData.size.x, roomData.size.y), -16000f, 16000f, homoNDC);
	
	void delegate() updateFn;
	void delegate() beginFn;
	void delegate() endFn;
	
	void update(){
		if(updateFn){
			updateFn();
		}
	}
	void begin(){
		if(beginFn){
			beginFn();
		}
	}
	void end(){
		if(endFn){
			endFn();
		}
	}
	
	void apply(){
		begin();
		viewportCam = this;
	}
}

struct Viewport{
	bool visible = false;
	Vec2!ushort pos;
	Vec2!ushort size;
	Camera camera;
	
	void apply(){
		viewportPos = pos;
		viewportSize = size;
		
		if(camera){
			camera.apply();
		}else{
			viewportCam = null;
		}
	}
}

//Create & Destroy

Camera cameraCreate() nothrow pure @safe =>
	new Camera;
alias camera_create = cameraCreate;

///Does nothing—we'll let the GC destroy it.
void cameraDestroy(Camera cameraID) nothrow @nogc pure{
	//do nothing
}
alias camera_destroy = cameraDestroy;

void cameraCopyTransforms(Camera destCamera, Camera srcCamera) nothrow @nogc pure @safe{
	destCamera.view = srcCamera.view;
	destCamera.proj = srcCamera.proj;
}
alias camera_copy_transforms = cameraCopyTransforms;

//Camera Information

void cameraSetViewMat(Camera cameraID, Mat4 matrix) nothrow @nogc pure @safe{
	cameraID.view = matrix;
}
alias camera_set_view_mat = cameraSetViewMat;

void cameraSetProjMat(Camera cameraID, Mat4 matrix) nothrow @nogc pure @safe{
	cameraID.proj = matrix;
}
alias camera_set_proj_mat = cameraSetProjMat;

void cameraSetUpdateScript(Camera cameraID, void delegate() script) nothrow @nogc pure @safe{
	cameraID.updateFn = script;
}
alias camera_set_update_script = cameraSetUpdateScript;

void cameraSetBeginScript(Camera cameraID, void delegate() script) nothrow @nogc pure @safe{
	cameraID.beginFn = script;
}
alias camera_set_begin_script = cameraSetBeginScript;

void cameraSetEndScript(Camera cameraID, void delegate() script) nothrow @nogc pure @safe{
	cameraID.endFn = script;
}
alias camera_set_end_script = cameraSetEndScript;

//TODO: camera_set_view_size
//TODO: camera_set_view_speed
//TODO: camera_set_view_border
//TODO: camera_set_view_angle
//TODO: camera_set_view_target
//TODO: camera_set_default


Mat4 cameraGetViewMat(Camera cameraID) nothrow @nogc pure @safe =>
	cameraID.view;
alias camera_get_view_mat = cameraGetViewMat;

Mat4 cameraGetProjMat(Camera cameraID) nothrow @nogc pure @safe =>
	cameraID.proj;
alias camera_get_proj_mat = cameraGetProjMat;

void delegate() cameraGetUpdateScript(Camera cameraID) nothrow @nogc pure @safe =>
	cameraID.updateFn;
alias camera_get_update_script = cameraGetUpdateScript;

void delegate() cameraGetBeginScript(Camera cameraID) nothrow @nogc pure @safe =>
	cameraID.beginFn;
alias camera_get_begin_script = cameraGetBeginScript;

void delegate() cameraGetEndScript(Camera cameraID) nothrow @nogc pure @safe =>
	cameraID.endFn;
alias camera_get_end_script = cameraGetEndScript;

//TODO: camera_get_view_x
//TODO: camera_get_view_y
//TODO: camera_get_view_width
//TODO: camera_get_view_height
//TODO: camera_get_view_speed_x
//TODO: camera_get_view_speed_y
//TODO: camera_get_view_border_x
//TODO: camera_get_view_border_y
//TODO: camera_get_view_angle
//TODO: camera_get_view_target
//TODO: camera_get_default

Camera cameraGetActive() nothrow @nogc @safe =>
	viewportCam;
alias camera_get_active = cameraGetActive;

uint viewCurrent;
alias view_current = viewCurrent;
uint viewNext;


