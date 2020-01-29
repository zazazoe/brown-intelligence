
PGraphics nerveSkeleton;
PGraphics nerveSkeletonFG;

PImage    blackOverlay;
PImage    deviceOverlay;
PImage    organUnderlay;
PImage    deviceDeviceOverlay;
PImage    deviceRingsOverlay;

float     imageAlpha = 0.0;
float     imageAlphaStep = 0.0; //will be set based on fade timer


void loadImages(){
  nerveSkeleton       = createGraphics(width, height);
  nerveSkeletonFG     = createGraphics(width, height);
  blackOverlay        = loadImage("imageAssets/blackOverlay.png");
  deviceOverlay       = loadImage("imageAssets/deviceOverlay.png");
  organUnderlay       = loadImage("imageAssets/organUnderlay.png");
  deviceDeviceOverlay = loadImage("imageAssets/deviceDevice.png");
  deviceRingsOverlay  = loadImage("imageAssets/deviceRings.png");
}

void clearDrawingCanvas(PGraphics canvas){
  canvas.beginDraw();
  canvas.clear();
  canvas.endDraw();
}
