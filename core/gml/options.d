module gml.options;

struct Options{
	double fps = 60.0;
	float[4] defaultDrawColour = [1f, 1f, 1f, 1f];
	
	string displayName = "Created with De-GML";
	
	bool allowMenuAndDockInFullscreen = false;
	bool displayCursor = true;
	bool startFullscreen = false;
	bool allowFullscreenSwitching = false;
	bool interpolateColours = true;
	bool useVSync = false;
	bool allowWindowResize = false;
	bool borderlessWindow = false;
	bool enableHighDPI = false;
	
	bool keepAspectRatio = true;
	
	uint texturePageSize = 2048;
}
Options options;
