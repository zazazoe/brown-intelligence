
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
  
  //OVERLAYS FOR 1440 x 900
  blackOverlay        = loadImage("imageAssets/overlays1440900/blackOverlay.png");
  deviceOverlay       = loadImage("imageAssets/overlays1440900/deviceOverlay.png");
  organUnderlay       = loadImage("imageAssets/overlays1440900/organUnderlay.png");
  deviceDeviceOverlay = loadImage("imageAssets/overlays1440900/deviceDevice.png");
  deviceRingsOverlay  = loadImage("imageAssets/overlays1440900/deviceRings.png");
  
  //OVERLAYS FOR 1920 x 1080
  //blackOverlay        = loadImage("imageAssets/overlays19201080/blackOverlay.png");
  //deviceOverlay       = loadImage("imageAssets/overlays19201080/deviceOverlay.png");
  //organUnderlay       = loadImage("imageAssets/overlays19201080/organsUnderlay.png");
  //deviceDeviceOverlay = loadImage("imageAssets/overlays19201080/deviceDevice.png");
  //deviceRingsOverlay  = loadImage("imageAssets/overlays19201080/deviceRing.png");
}

void loadUIImages(){  
  //UI FOR 1440 x 900
  UI              = loadImage("imageAssets/UI1440900/UI.png");
  UIleg           = loadImage("imageAssets/UI1440900/leg.png");
  UIarm           = loadImage("imageAssets/UI1440900/arm.png");
  UIheart         = loadImage("imageAssets/UI1440900/heart.png");
  UIbladder       = loadImage("imageAssets/UI1440900/bladder.png");
  UIbrain         = loadImage("imageAssets/UI1440900/brain.png");
  UIbrainBladder  = loadImage("imageAssets/UI1440900/brain_bladder.png");
  UIbrainArm      = loadImage("imageAssets/UI1440900/brain_arm.png");
  UIbrainLeg      = loadImage("imageAssets/UI1440900/brain_leg.png");
  UIdevice        = loadImage("imageAssets/UI1440900/device.png");
  UIdeviceRings   = loadImage("imageAssets/UI1440900/device_ring.png");
  UIdeviceDevice  = loadImage("imageAssets/UI1440900/device_device.png");
  
  //UI FOR 1920 x 1080
  //UI              = loadImage("imageAssets/UI19201080/UI.png");
  //UIleg           = loadImage("imageAssets/UI19201080/leg.png");
  //UIarm           = loadImage("imageAssets/UI19201080/arm.png");
  //UIheart         = loadImage("imageAssets/UI19201080/heart.png");
  //UIbladder       = loadImage("imageAssets/UI19201080/bladder.png");
  //UIbrain         = loadImage("imageAssets/UI19201080/brain.png");
  //UIbrainBladder  = loadImage("imageAssets/UI19201080/brain_bladder.png");
  //UIbrainArm      = loadImage("imageAssets/UI19201080/brain_arm.png");
  //UIbrainLeg      = loadImage("imageAssets/UI19201080/brain_leg.png");
  //UIdevice        = loadImage("imageAssets/UI19201080/device.png");
  //UIdeviceRings   = loadImage("imageAssets/UI19201080/device_ring.png");
  //UIdeviceDevice  = loadImage("imageAssets/UI19201080/device_device.png");
}

void clearDrawingCanvas(PGraphics canvas){
  canvas.beginDraw();
  canvas.clear();
  canvas.endDraw();
}
