import AULib.*;

//variables
int     LEFT_SIDE = 0;
int     RIGHT_SIDE = 1;

int     IDLE_MODE = 0;
int     TRANSITION_GAMEMODE = 1;
int     DRAW_GAMEMODE = 2;
int     FADE_GAMEMODE = 3;
int     GAME_MODE = 4;

float   treeRot = 0;
PVector treeStartPoint;
int     numGenerations = 5;
int     minBranches = 1;
int     maxBranches = 5;
float   segmentMinLength = 50;
float   segmentMaxLength = 500;
int     segmentMinRot = -60;
int     segmentMaxRot = 60;

float   particleSpeed = 0.005;
float   particleSize = 8;
int     particleTrailSize = 1;
boolean renderParticles = true;
boolean syncParticles = false;
boolean disperseParticles = true;

int     lineRandX = 10;
int     lineRandY = 10;
int     lineWeight = 3;
int     lineOpacity = 100;
Float[] lineOpacities;
float   lineOpacityMin = 0.8;
float   lineFadeOutSpeed = 5;

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

int     curveTransitionIndex;
int     newTreeLength;
int     oldTreeLength;

int     particlesToMove = 0;
boolean switchToIdle = false;
boolean transitionToGame = false;

int     startTimer = 0;
int     treeTimer  = 1500;
int     drawTimer  = 12000;
int     fadeTimer  = 250;

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


void setup(){
  fullScreen();
  frameRate(60);
  
  //init parameters
  treeStartPoint = new PVector(0, height/2);
  mode = IDLE_MODE;
  curveTransitionIndex = 0;
  initCP5();
  println("initiated controls");
  loadImages();
  startTimer = millis();
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
  
  //pre-load data for nerves system curves
  initNerveCurves();
  println("loaded nerve data");
}


void draw() {
  background(0);
  
  switch(mode){
  case 0: /*IDLE MODE*/ 
    updateCurves();
    updateCurvePoints();
    renderCurves();
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
      transitionToGameMode();
      nerveSkeleton.beginDraw(); 
      nerveSkeleton.clear();
      nerveSkeleton.endDraw();
      for(int i=0; i<curveOpacity.size(); i++){
        curveOpacity.get(i)[1] = 1.0;
      }
      gameParticleSize = 1;
      mode = TRANSITION_GAMEMODE;
      //initTransitionParticlesToNerveCurves();
      transitionToGame = false;
      println("total nr of particles:" + particles.size());
      println("total nr of nerve curves:" + nrOfNerveCurves);
      println("enter transition to game mode");  
    }
    break;
 
  case 1: /*TRANSITION TO GAME MODE*/ 
    transitionParticlesToNerveCurves();
    renderCurves();
    if(transitionDone()){
      println("ready to start drawing");
      startTimer = millis();
      mode = DRAW_GAMEMODE; 
      println("change game draw mode");
    }
    break;

  case 2: /*DRAW GAME MODE*/ 
    if(renderParticles){
      updateParticlesOnNerveCurves();
      
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
      mode = FADE_GAMEMODE;
      println("change to game mode");
    }
    break;
  
  case 3: /*FADE GAME MODE*/
    image(nerveSkeleton, 0,0);
    image(blackOverlay, 0,0);
    image(nerveSkeletonBG, 0,0);
    
    if(millis()-startTimer>fadeTimer){
      gameParticleSize = 3;
      for(int i=0; i<particles.size(); i++){
        particles.get(i).setSize(gameParticleSize);
        particles.get(i).disperse();
      }
      
      mode = GAME_MODE;
      println("change to game mode");
    }
    break;
    
  case 4:  /*GAME MODE*/  
    image(organUnderlay,0,0);
    image(nerveSkeleton,0,0);
    image(blackOverlay, 0,0);
    image(nerveSkeletonBG, 0,0);
    
    if(renderParticles){
      renderParticlesOnNerveCurves();
    }
    image(deviceOverlay,0,0);
    
    //drawButtons();
    image(UI, 0,0);
    //if(mousePressed && frameCount%4 == 0){
      PVector mouse = new PVector(mouseX, mouseY);
      checkButtons(mouse);
    //}
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
      break;
    case 'g':
      if(mode == GAME_MODE)
        sendNerveBurst(leg, LEFT_SIDE);
      break;
    case 'h':
      if(mode == GAME_MODE)
        sendNerveBurst(arm, RIGHT_SIDE);
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
