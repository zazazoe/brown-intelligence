import AULib.*;

//variables
int     SENSOR_SIDE = 0;
int     MOTOR_SIDE  = 1;

int     mode;
int     IDLE_MODE = 0;
int     FADE_IDLEMODE = 1;
int     TRANSITION_GAMEMODE = 2;
int     DRAW_GAMEMODE = 3;
int     FADE_GAMEMODE = 4;
int     GAME_MODE = 5;
int     TRANSITION_IDLEMODE = 6;

float   treeRot = 0;
PVector treeStartPoint;
int     numGenerations = 4;
int     minBranches = 1;
int     maxBranches = 3;
float   segmentMinLength = 75;
float   segmentMaxLength = 200;
int     segmentMinRot = -50;
int     segmentMaxRot = 50;

float   particleSpeed = 0.005;
float   particleSize = 8;
float   particleBurstSize = 8;
int     particleTrailSize = 1;
boolean renderParticles = true;
boolean syncParticles = false;
boolean disperseParticles = true;
float   particleDrawingSpeed = 0.005;
float   particleTransitionSpeed = 0.93;
float   particleTransitionSpeedIdle = 0.96;
float   particleFadeSlowDown = 8;
color   burstColor;

int     lineRandX = 10;
int     lineRandY = 20;
int     lineWeight = 3;
Float[] lineOpacities;
float   lineOpacityMin = 0.8; //DOESN'T BEHAVE AS SHOULD, CHECK OUT
float   lineFadeOutSpeed;

float   attractionToOrigin = 15; 
float   repulseFromMouse   = 25;
float   mouseAffectRadius  = 200;
float   mouseAffectRadiusStore = 400;
boolean fixEndPoints = true;

float   blobx;
float   bloby;
float   blobxPrev;
float   blobyPrev;
int     blobCount = 0;
int     blobCountPrev = 0;

int     curveTransitionIndex = 0;
int     newTreeLength;
int     oldTreeLength;
int     particlesToMove = 0;

boolean switchToIdle = false;
boolean transitionToGame = false;
boolean transitionToIdle = false;

int     startTimer = 0;
int     treeTimer  = 5000;
int     drawTimer  = 12000;
int     fadeTimer  = 1000;
int     idleFadeTimer = 1000; 

boolean sensorConnected = false;
  
PGraphics nerveSkeleton;
PGraphics nerveSkeletonFG;
PImage    blackOverlay;
PImage    deviceOverlay;
PImage    organUnderlay;
PImage    deviceDeviceOverlay;
PImage    deviceRingsOverlay;


PImage    UI;
PVector   UIexitpos = new PVector(1364, 836);
PImage    UIleg;
PVector   UIlegpos = new PVector(59, 852);
PImage    UIbladder;
PVector   UIbladderpos = new PVector(59, 745);
PImage    UIarm;
PVector   UIarmpos = new PVector(59, 665);
PImage    UIheart;
PVector   UIheartpos = new PVector(59, 585);
PImage    UIbrain;
PVector   UIbrainpos = new PVector(59, 505);
PImage    UIbrainBladder;
PVector   UIbrainbladderpos = new PVector(134, 505);
PImage    UIbrainArm;
PVector   UIbrainarmpos = new PVector(116, 463);
PImage    UIbrainLeg;
PVector   UIbrainlegpos = new PVector(116, 542);
PImage    UIdevice;
PVector   UIdevicepos = new PVector(59, 405);
PImage    UIdeviceRings;
PVector   UIdeviceringspos = new PVector(121, 382);
PImage    UIdeviceDevice;
PVector   UIdevicedevicepos = new PVector(121, 424);

float     imageAlpha = 0.0;
float     imageAlphaStep = 0.0; //set based on fade timer

PVector   mouse;

int       timePassed=0;


void setup(){
  fullScreen(OPENGL);
  frameRate(60);
  
  //init parameters
  lineFadeOutSpeed     = lineOpacityMin/(treeTimer/60.0);
  treeStartPoint       = new PVector(0, height/2);
  mode                 = IDLE_MODE;
  startTimer           = millis();
  mouse                = new PVector(0, 0);
  burstColor           = color(255);

  loadImages();
  initNerveCurves();
  initCP5();

  if(sensorConnected){
    initCV();
    println("sensor started");
  }

  //generate a tree
  treeStartPoint = new PVector(0, random(0,height)); //NOTE TO SELF: make more generic variables, also expand capability to start drawing from other edges.
  segmentMinRot = (int)map(treeStartPoint.y, height, 0, -80.0, 20.0); //NOTE TO SELF: make more generic variables
  segmentMaxRot = (int)map(treeStartPoint.y, height, 0, -20.0, 80.0); //NOTE TO SELF: make more generic variables
  treeRot = (int)map(treeStartPoint.y, height, 0, -50, 50);
  
  generateTree(segmentMaxLength, treeRot, treeStartPoint, numGenerations, particleSpeed, particleSize, particleTrailSize); //segement length, rotation, starting point, gen limit, particleSpeed, particleSize, particleTrailSize
  reGenerateTree(segmentMaxLength, treeRot, treeStartPoint, numGenerations);
  newTreeLength = linesToSave.size();
  oldTreeLength = curves.size();
  println("generated old tree: " + oldTreeLength);
  println("generated new tree: " + newTreeLength);
}


void draw() {
  background(0);
  timePassed=millis();
  
  switch(mode){
  case 0: /*IDLE MODE*/ 
    if(millis()-startTimer>treeTimer){
      transitionToNextTree();
      startTimer = millis();
    }
    
    updateCurves();
    updateCurvePoints();
    updateParticlesIdle();
    
    
    renderCurves(); 
    renderParticlesIdle();
    
    if(transitionToGame){
      for(int i=0; i<curveOpacity.size(); i++){
        curveOpacity.get(i)[1] = 1.0;
      }
      startTimer = millis();
      lineFadeOutSpeed = lineOpacityMin/(idleFadeTimer/60.0);
      mode = FADE_IDLEMODE;
      println("fade out idle mode");  
    }
    break;
 
  case 1: /*FADE OUT IDLE MODE*/ 
    renderCurves();
    updateParticlesIdleFade();
    renderParticlesIdle();
    
    if(millis()-startTimer>idleFadeTimer){
      lineFadeOutSpeed = lineOpacityMin/(treeTimer/60.0);
      transitionParticlesToGameMode();
      clearDrawingCanvas(nerveSkeleton);
      clearDrawingCanvas(nerveSkeletonFG);
      gameParticleSize = 1;
      startTimer = millis();
      mode = TRANSITION_GAMEMODE; 
      transitionToGame = false;
      println("ready to move particles");
    }
    break;
  
  case 2: /*TRANSITION TO GAME MODE*/ 
    transitionParticlesToNerveCurves();
    renderCurves();
    
    if(transitionDone()){
      println("ready to start drawing");
      startTimer = millis();
      mode = DRAW_GAMEMODE; 
      println("change game draw mode");
    }
    break;

  case 3: /*DRAW GAME MODE*/ 
    drawNerveCurves(particleDrawingSpeed);
    drawParticlesOnCanvas(nerveSkeleton, 0, particles.size()-inactiveCurves.length);
    drawParticlesOnCanvas(nerveSkeletonFG, particles.size()-inactiveCurves.length, particles.size());

    image(nerveSkeleton, 0,0);
    image(blackOverlay, 0,0);
    image(nerveSkeletonFG, 0,0);
    
    if(millis()-startTimer>drawTimer){ 
      startTimer = millis();
      imageAlphaStep = 255.0/(fadeTimer/60.0); //NOTE TO SELF: based on 60fps
      mode = FADE_GAMEMODE;
      println("change to game mode");
    }
    break;
  
  case 4: /*FADE GAME MODE*/
    tint(255, imageAlpha);
    image(organUnderlay,0,0);
    tint(255, 255);
    image(nerveSkeleton, 0,0);
    image(blackOverlay, 0,0);
    image(nerveSkeletonFG, 0,0);
    tint(255, imageAlpha);
    image(deviceOverlay,0,0);
    image(UI, 0,0);
    
    //NOTE TO SELF: also make particles fade in more subtle
    
    if(millis()-startTimer>fadeTimer){
      gameParticleSize = 3;
      setParticlesForGame();
      tint(255,255);
      mode = GAME_MODE;
      println("change to game mode");
    }
    if(imageAlpha<255) imageAlpha += imageAlphaStep;
    println(imageAlpha);
    break;
    
  case 5:  /*GAME MODE*/  
    image(organUnderlay,0,0);
    image(nerveSkeleton,0,0);
    image(blackOverlay, 0,0);
    image(nerveSkeletonFG, 0,0);
    if(renderParticles){
      renderParticlesOnNerveCurves(); //NOTE TO SELF: can particles be layered, so all bursts on top and all idle on bottom? Split in two functions...
    }
    image(deviceOverlay,0,0);
    
    mouse.x = mouseX;
    mouse.y = mouseY;
    checkButtons(mouse);
    
    image(UI, 0,0);
    if(brainButton) image(UIbrain, 0,0);
    if(deviceButton) image(UIdevice, 0,0);
    if(deviceRings) image(UIdeviceRings, 0,0);
    if(deviceDevice) image(UIdeviceDevice, 0,0);
    if(deviceRings) image(deviceRingsOverlay, 0,0); //NOTE TO ADD: if device rings, show rings explanation
    if(deviceDevice) image(deviceDeviceOverlay, 0,0); //NOTE TO ADD: if device device, show device explanation

    if(switchToIdle){
      //updateParticleAmount(curves.size());   
      transitionParticlesToIdleMode();
      
      lineFadeOutSpeed = lineOpacityMin/(treeTimer/120.0);
      for(int i=0; i<curveOpacity.size(); i++){
        curveOpacity.get(i)[1] = 0.0;
      }

      switchToIdle = false;
      //transitionToIdle = true;
      mode = TRANSITION_IDLEMODE;
      println("enter idle mode");
    }
    break; 
    
  case 6: /*TRANSITION TO IDLE MODE*/ 
    renderCurves();
    transitionParticlesToIdleCurves();
    
    if(transitionDone()){
      startTimer = millis() + treeTimer;
      mode = IDLE_MODE;
      println("change back to idle mode");
    }
    break;
  }
  
  blobx = 0; //CHECK THIS OUT AND CLEAN UP
  bloby = 0;
  
  if(sensorConnected){
    updateCV(); 
  }

  //fill(255);
  //text(frameRate, 20, height-20);
} //<>//




//////////////////////////////////////////////////
/*DEBUG CONTROLS AND TEMPORARY INPUT REPLACEMENT*/
//////////////////////////////////////////////////

void keyPressed(){
  switch(key){
    case 'o': //open cp5 control panel
      cp5.show();
      break;
    case 'c': //close cp5 control panel
      cp5.hide();
      break;
    case 'r': //regenerate a tree
      //generateTree(segmentMaxLength, treeRot, treeStartPoint, numGenerations, particleSpeed, particleSize, particleTrailSize);
      reGenerateTree(segmentMaxLength, treeRot, treeStartPoint, numGenerations);
      break;
    case 'a':
      if(mode == IDLE_MODE){
        opencv = new OpenCV(this, 480, 270);
        opencv.loadImage(camera.getDepthImage());
        background = opencv.getSnapshot();
        println("background set");
      }
      break;
    case 's':
      if(mode == IDLE_MODE){
        for(int i=0; i<particles.size(); i++){
          particles.get(i).particleBurst(MOTOR_SIDE);
        }
      }
      break;
    case 'f':
      if(mode == GAME_MODE)
        sendNerveBurst(leg, MOTOR_SIDE);
        image(UIbrainLeg,0,0);
      break;
    case 'g':
      if(mode == GAME_MODE)
        sendNerveBurst(arm, MOTOR_SIDE);
        image(UIbrainArm,0,0);
      break;
    case 'h':
      if(mode == GAME_MODE)
        sendNerveBurst(bladder, MOTOR_SIDE);
        image(UIbrainBladder,0,0);
      break;
    case 'j':
      if(mode == GAME_MODE)
        sendNerveBurst(arm, SENSOR_SIDE);
      break;
    case '1':
      cp5.saveProperties(("parameters"));
      break;
    case '2':
      cp5.loadProperties(("parameters.ser"));
      break;  
  }
}

void mousePressed(){
  if(mode == IDLE_MODE && millis()-timeOutStart>timeOut){
    transitionToGame = true;
  }
}


////////////////
/*LITTLE TASKS*/
////////////////

color particleColor(int i){
  float f1 = map(i, 0, particles.size(), 0,1);
  float f2 = map(i, 0, particles.size(), 1,0);
  
  float r = f1*red(cpL1.getColorValue()) + f2*red(cpL2.getColorValue());
  float g = f1*green(cpL1.getColorValue()) + f2*green(cpL2.getColorValue());
  float b = f1*blue(cpL1.getColorValue()) + f2*blue(cpL2.getColorValue());
  float a = f1*alpha(cpL1.getColorValue()) + f2*alpha(cpL2.getColorValue());
  
  color c = color(r,g,b,255);
  
  return c;
}


boolean transitionDone(){
  boolean transitionDone = true;
  for(int i=0; i<particles.size(); i++){
    if(particles.get(i).getTransition() == true){
      transitionDone = false;
    }
  }
  return transitionDone;
}

void loadImages(){
  //game nerve skeleton drawing
  nerveSkeleton       = createGraphics(width, height);
  nerveSkeletonFG     = createGraphics(width, height);
  blackOverlay        = loadImage("imageAssets/blackOverlay.png");
  deviceOverlay       = loadImage("imageAssets/deviceOverlay.png");
  organUnderlay       = loadImage("imageAssets/organUnderlay.png");
  deviceDeviceOverlay = loadImage("imageAssets/deviceDevice.png");
  deviceRingsOverlay  = loadImage("imageAssets/deviceRings.png");

  //game UI
  UI              = loadImage("imageAssets/UI/UI.png");
  UIleg           = loadImage("imageAssets/UI/leg.png");
  UIarm           = loadImage("imageAssets/UI/arm.png");
  UIheart         = loadImage("imageAssets/UI/heart.png");
  UIbladder       = loadImage("imageAssets/UI/bladder.png");
  UIbrain         = loadImage("imageAssets/UI/brain.png");
  UIbrainBladder  = loadImage("imageAssets/UI/brain_bladder.png");
  UIbrainArm      = loadImage("imageAssets/UI/brain_arm.png");
  UIbrainLeg      = loadImage("imageAssets/UI/brain_leg.png");
  UIdevice        = loadImage("imageAssets/UI/device.png");
  UIdeviceRings   = loadImage("imageAssets/UI/device_ring.png");
  UIdeviceDevice  = loadImage("imageAssets/UI/device_device.png");
}

void clearDrawingCanvas(PGraphics canvas){
  canvas.beginDraw();
  canvas.clear();
  canvas.endDraw();
}
