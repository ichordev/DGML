module gml.display;

import gml.options;

import bindbc.bgfx;

void init(){
	timingMode = TM.countVSyncs;
	vsync = options.useVSync;
	msaaLevel = 0;
}

void quit(){
	
}

enum TM{
	sleep,         ///The sleep margin value is the main timing method
	countVSyncs,   ///Vsync timing is the main timing method (default for all supported platforms)
	countvsyncs = countVSyncs,
	systemTiming,  ///System timing is the main timing method
	systemtiming = systemTiming,
}
alias tm = TM;

TM timingMode;
bool vsync;
uint msaaLevel;

@property bgfxResetFlags() nothrow @nogc @safe => bgfxResetMSAA | (vsync ? Reset.vsync : 0);

@property bgfxResetMSAA() nothrow @nogc @safe{
	switch(msaaLevel){
		case  0: return cast(ResetMSAA)0;
		case  2: return ResetMSAA.x2;
		case  4: return ResetMSAA.x4;
		case  8: return ResetMSAA.x8;
		case 16: return ResetMSAA.x16;
		default: assert(0);
	}
}
@property ulong bgfxRenderTargetFlag() nothrow @nogc @safe{
	switch(msaaLevel){
		case  0: return bgfx.Texture.rt;
		case  2: return TextureRTMSAA.x2;
		case  4: return TextureRTMSAA.x4;
		case  8: return TextureRTMSAA.x8;
		case 16: return TextureRTMSAA.x16;
		default: assert(0);
	}
}

enum displayAA = 2 | 4 | 8;
alias display_aa = displayAA;

//TODO: display_reset
//TODO: display_get_width
//TODO: display_get_height
//TODO: display_get_orientation
//TODO: display_get_dpi_x
//TODO: display_get_dpi_y
//TODO: display_get_gui_width
//TODO: display_get_gui_height
//TODO: display_get_timing_method
//TODO: display_get_sleep_margin
//TODO: display_get_frequency
//TODO: display_mouse_get_x
//TODO: display_mouse_get_y
//TODO: display_mouse_set
//TODO: display_set_gui_size
//TODO: display_set_gui_maximise
//TODO: display_set_ui_visibility
//TODO: display_set_timing_method
//TODO: display_set_sleep_margin

//TODO: screen_save
//TODO: screen_save_part
//TODO: gif_open
//TODO: gif_add_surface
//TODO: gif_save
//TODO: gif_save_buffer
