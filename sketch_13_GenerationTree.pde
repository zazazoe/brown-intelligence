import AULib.*;

//variables
int     LEFT_SIDE = 0;
int     RIGHT_SIDE = 1;

int     IDLE_MODE = 0;
int     FADE_IDLEMODE = 1;
int     TRANSITION_GAMEMODE = 2;
int     DRAW_GAMEMODE = 3;
int     FADE_GAMEMODE = 4;
int     GAME_MODE = 5;

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
int     particleTrailSize = 1;
boolean renderParticles = true;
boolean syncParticles = false;
boolean disperseParticles = true;
float   particleDrawingSpeed = 0.005;
float   particleTransitionSpeed = 0.90;
float   particleFadeSlowDown = 6;

int     lineRandX = 10;
int     lineRandY = 20;
int     lineWeight = 3;
int     lineOpacity = 100;
Float[] lineOpacities;
float   lineOpacityMin = 0.8;
float   lineFadeOutSpeed = 1.0;

float   attractionToOrigin = 15; 
float   repulseFromMouse = 25;
float   mouseAffectRadius = 200;
float   mouseAffectRadiusStore = 400;
boolean fixEndPoints = true;

int     mode;

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

int     startTimer = 0;
int     treeTimer  = 5000;
int     drawTimer  = 12000;
int     fadeTimer  = 1000;
int     idleFadeTimer = 1000; 

boolean sensorConnected = false;
  
PGraphics nerveSkeleton;
PGraphics nerveSkeletonBG;
PImage    blackOverlay;
PImage    deviceOverlay;
PImage    organUnderlay;

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


void setup(){
  fullScreen();
  frameRate(60);
  
  //init parameters
  lineFadeOutSpeed     = lineOpacityMin/(treeTimer/60.0);
  treeStartPoint       = new PVector(0, height/2);
  mode                 = IDLE_MODE;
  startTimer           = millis();
  
  loadImages();
  initNerveCurves();
  initCP5();

  if(sensorConnected){
    initCV();
    println("sensor started");
  }

  //generate a tree
  generateTree(segmentMaxLength, treeRot, treeStartPoint, numGenerations, particleSpeed, particleSize, particleTrailSize); //segement length, rotation, starting point, gen limit, particleSpeed, particleSize, particleTrailSize
  reGenerateTree(segmentMaxLength, treeRot, treeStartPoint, numGenerations);
  newTreeLength = linesToSave.size();
  oldTreeLength = curves.size();
  println("generated old tree: " + oldTreeLength);
  println("generated new tree: " + newTreeLength);
}


void draw() {
  background(0);
  
  switch(mode){
  case 0: /*IDLE MODE*/ 
    updateCurves();
    updateCurvePoints();
    renderCurves();
    
    //NOTE TO SELF: move all this particle stuff to a tab and make them update functions, similar to above for curves
    for(int i=0; i<particles.size(); i++){
      particles.get(i).updateIdle(curves.get(i));
    }
    if(renderParticles){
      for(int i=0; i<particles.size(); i++){
        particles.get(i).setIdleColor(particleColor(i)); //actually changing
        particles.get(i).setIdleSize(particleSize); //stupid to do every time (could be as move to mode and in setup?)
        particles.get(i).displayIdle();
      }
    }
    
    if(millis()-startTimer>treeTimer){
      transitionToNextTree();
      startTimer = millis();
    }
    
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
    for(int i=0; i<particles.size(); i++){
      particles.get(i).updateIdleFade(curves.get(i), particleFadeSlowDown); //slow down factor
    }
    if(renderParticles){
      for(int i=0; i<particles.size(); i++){
        particles.get(i).setIdleColor(particleColor(i)); //actually changing
        particles.get(i).setIdleSize(particleSize); //stupid to do every time (could be as move to mode and in setup?)
        particles.get(i).displayIdle();
      }
    }
    
    if(millis()-startTimer>idleFadeTimer){
      lineFadeOutSpeed = lineOpacityMin/(treeTimer/60.0);
      
      transitionToGameMode();
      clearDrawingCanvas();
      gameParticleSize = 1;
      println("total nr of particles:" + particles.size());
      println("total nr of nerve curves:" + nrOfNerveCurves);
      transitionToGame = false;
      startTimer = millis();
      mode = TRANSITION_GAMEMODE; 
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
    if(renderParticles){
      drawNerveCurves(particleDrawingSpeed);
      
      nerveSkeleton.beginDraw();
      for(int i=0; i<(particles.size()-inactiveCurves.length); i++){
        particles.get(i).displayDraw(); //draw on PGraphics nerveSkeleton
      }
      nerveSkeleton.endDraw();
      
      nerveSkeletonBG.beginDraw();
      for(int i=(particles.size()-inactiveCurves.length); i<particles.size(); i++){
        particles.get(i).displayDrawBG(); //draw on PGraphics nerveSkeleton
      }
      nerveSkeletonBG.endDraw();
      
      image(nerveSkeleton, 0,0);
      image(blackOverlay, 0,0);
      image(nerveSkeletonBG, 0,0);
    }
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
    image(nerveSkeletonBG, 0,0);
    tint(255, imageAlpha);
    image(deviceOverlay,0,0);
    image(UI, 0,0);
    
    //NOTE TO SELF: also make particles fade in more subtle
    
    if(millis()-startTimer>fadeTimer){
      gameParticleSize = 3;
      for(int i=0; i<particles.size(); i++){
        particles.get(i).setSize(gameParticleSize);
        particles.get(i).disperse();
      }
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
    image(nerveSkeletonBG, 0,0);
    if(renderParticles){
      renderParticlesOnNerveCurves(); //NOTE TO SELF: can particles be layered, so all bursts on top and all idle on bottom? Split in two functions...
    }
    image(deviceOverlay,0,0);
    
    PVector mouse = new PVector(mouseX, mouseY);
    checkButtons(mouse);
    
    image(UI, 0,0);
    if(brainButton) image(UIbrain, 0,0);
    if(deviceButton) image(UIdevice, 0,0);
    //NOTE TO ADD: if device rings, show rings explanation
    //NOTE TO ADD: if device device, show device explanation

    if(switchToIdle){
      updateParticleAmount(curves.size());   
      //gameParticleSize = 4;
      for(int i=0; i<particles.size(); i++){
        particles.get(i).setSize(gameParticleSize);
        particles.get(i).disperse();
      }
      for(int i=0; i<curveOpacity.size(); i++){
        curveOpacity.get(i)[1] = 0.0;
      }
      mode = IDLE_MODE;
      switchToIdle = false;
      println("enter idle mode");
    }
    break;  
  }
  
  blobx = 0; //CHECK THIS OUT AND CLEAN UP
  bloby = 0;
  
  if(sensorConnected){
    updateCV(); 
  }

  fill(255);
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
        for(int i=0; i<particles.size(); i++){
          particles.get(i).particleBurst(LEFT_SIDE);
        }
      }
      break;
    case 's':
      if(mode == IDLE_MODE){
        for(int i=0; i<particles.size(); i++){
          particles.get(i).particleBurst(RIGHT_SIDE);
        }
      }
      break;
    case 'f':
      if(mode == GAME_MODE)
        sendNerveBurst(leg, RIGHT_SIDE);
        image(UIbrainLeg,0,0);
      break;
    case 'g':
      if(mode == GAME_MODE)
        sendNerveBurst(arm, RIGHT_SIDE);
        image(UIbrainArm,0,0);
      break;
    case 'h':
      if(mode == GAME_MODE)
        sendNerveBurst(bladder, RIGHT_SIDE);
        image(UIbrainBladder,0,0);
      break;
    case 'j':
      if(mode == GAME_MODE)
        sendNerveBurst(arm, LEFT_SIDE);
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
  if(mode == IDLE_MODE){
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
  nerveSkeleton   = createGraphics(width, height);
  nerveSkeletonBG = createGraphics(width, height);
  blackOverlay    = loadImage("imageAssets/blackOverlay.png");
  deviceOverlay   = loadImage("imageAssets/deviceOverlay.png");
  organUnderlay   = loadImage("imageAssets/organUnderlay.png");
  
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

void clearDrawingCanvas(){
  nerveSkeleton.beginDraw(); 
  nerveSkeleton.clear();
  nerveSkeleton.endDraw();
  nerveSkeletonBG.beginDraw(); 
  nerveSkeletonBG.clear();
  nerveSkeletonBG.endDraw();
}
