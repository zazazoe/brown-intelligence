import AULib.*;
import processing.video.*;
import ch.bildspur.realsense.*;
import controlP5.*;
import processing.sound.*;
import gab.opencv.*;
import java.awt.Rectangle;


boolean DEBUG = true;

int     mode;
int     IDLE_MODE = 0;
int     FADE_IDLEMODE = 1;
int     TRANSITION_GAMEMODE = 2;
int     DRAW_GAMEMODE = 3;
int     FADE_GAMEMODE = 4;
int     GAME_MODE = 5;
int     TRANSITION_IDLEMODE = 6;

boolean switchToIdle = false;
boolean transitionToGame = false;
boolean transitionToIdle = false;

int     timerStart    = 0;
int     curveTimer    = 5000;
int     drawTimer     = 12000;
int     fadeTimer     = 1500;
int     idleFadeTimer = 1500; 
int     gameTimer     = 60000;

int     z0 = -1;
int     z1 = 0;
int     z2 = 1;
int     z3 = 2;
int     z4 = 3;
int     z5 = 4;
int     zx = 10;

float   idleTranslateX =575;  //big display:691      //laptop:410      //projector:575
float   idleTranslateY =540;  //big display:612      //laptop:450      //projector:540
float   idleTranslateZ =64;   //big display:-48      //laptop:-110     //projector:64
float   idleRotateX    =0;    //big display:0        //laptop:0        //projector:0
float   idleRotateY    =-0.25;//big display:-0.35    //laptop:-0.35    //projector:-0.25
float   idleRotateZ    =0;    //big display:0        //laptop:0        //projector:0

float   gameTranslateX=0;
float   gameTranslateY=0;
float   gameTranslateZ=0;
float   gameRotateX=0;
float   gameRotateY=0;
float   gameRotateZ=0;

float   translateX;
float   translateY;
float   translateZ;
float   rotateX;
float   rotateY;
float   rotateZ;

float   zStep = 0.01;
float   transitSpeed = 0.95;

PShader fogLines; 
PShader fogColor; 

PVector cameraPos;

boolean firstCycle = true;

void setup(){
  //fullScreen(P3D, 1);
  fullScreen(P3D);
  //size(1920,1080,P3D);
  frameRate(60);  
  smooth(10);
  noCursor();
  
  mode       = IDLE_MODE;
  timerStart = millis();
  blobDir    = new PVector(0,0,0);
  blobBack   = new PVector(0,0,0);
  blobFront  = new PVector(0,0,0);
  blobBackModel  = new PVector(0,0,0);
  blobFrontModel =  new PVector(0,0,0);
  blobDirModel   = new PVector(0,0,0);
  
  translateX = idleTranslateX;
  translateY = idleTranslateY;
  translateZ = idleTranslateZ;
  rotateX    = idleRotateX;
  rotateY    = idleRotateY;
  rotateZ    = idleRotateZ;

  loadImages();
  loadUIImages();
  initNerveCurves();
  initCP5();
  initCurves();
  initSound();
  if(sensorConnected) initCV(); 
  
  fogLines = loadShader("fogLines.glsl");
  fogLines.set("fogNear", 0.0);           //laptop:0.0      //projector:0.0
  fogLines.set("fogFar", 650.0);          //laptop:800.0    //projector:650.0
  
  fogColor = loadShader("fogColor.glsl");
  fogColor.set("fogNear", 0.0);           //laptop:0.0      //projector:0.0
  fogColor.set("fogFar", 750.0);         //laptop:1000.0   //projector:750.0
  
  hint(DISABLE_DEPTH_MASK);
  //hint(DISABLE_OPENGL_ERRORS);
  hint(ENABLE_STROKE_PERSPECTIVE);
  //strokeCap(ROUND);
  //hint(DISABLE_DEPTH_TEST);
}


void draw() {
  if(firstCycle) cacheImages();
  background(0);
  
  //SMALL CURSOR FOR DEBUG/////
  if(DEBUG){
    pushMatrix();
    noStroke();
    fill(255,0,0);
    ellipse(mouseX, mouseY, 6, 6);
    popMatrix();
  }
  /////////////////////////////
  
  switch(mode){
  case 0: /*IDLE MODE*/ 
    updateCurves();
    updateCurvePoints();

    pushMatrix();
    rotateX(rotateX);
    rotateY(rotateY);
    rotateZ(rotateZ);
    translate(translateX,translateY,translateZ);
    shader(fogLines, LINES);
    renderCurves(); 
    shader(fogColor);
    updateParticlesIdle();
    renderParticlesIdle(); 
    popMatrix();
    
    resetShader();
    
    if(millis()-timerStart>curveTimer){
      transitionToNextTree();
      timerStart = millis();
    }

    if(transitionToGame)
      transition(FADE_IDLEMODE); 
    break;
 
  case 1: /*FADE OUT IDLE MODE*/ 
    updateParticlesIdleFade();
    
    pushMatrix();
    rotateX(rotateX);
    rotateY(rotateY);
    rotateZ(rotateZ);
    translate(translateX,translateY,translateZ);
    shader(fogLines, LINES);
    renderCurves();
    shader(fogColor);
    renderParticlesIdleFade();
    popMatrix();
    
    resetShader();
    
    if(millis()-timerStart>idleFadeTimer)
      transition(TRANSITION_GAMEMODE);
    break;
    
  case 2: /*TRANSITION TO GAME MODE*/ 
    pushMatrix();
    rotateX(rotateX);
    rotateY(rotateY);
    rotateZ(rotateZ);
    translate(translateX,translateY,translateZ);
      transitionParticlesToNerveCurves();
      renderCurves(); 
    popMatrix();
    
    translateIdleToGame();
    
    if(transitionDone())
      transition(DRAW_GAMEMODE);
    break;
    
  case 3: /*DRAW GAME MODE*/ 
    drawNerveCurves(particleDrawingSpeed);
    drawParticlesOnCanvas(nerveSkeleton, 0, particles.size()-inactiveCurves.length);
    drawParticlesOnCanvas(nerveSkeletonFG, particles.size()-inactiveCurves.length, particles.size());

    pushMatrix();  
    tint(255, 200);
    image(nerveSkeleton, 0,0);
    tint(255, 255);
    image(blackOverlay, 0,0);
    tint(255, 200);
    image(nerveSkeletonFG, 0,0);
    popMatrix();

    if(transitionDone())
      transition(FADE_GAMEMODE);
    break;
    
  case 4: /*FADE GAME MODE*/
    tint(255, imageAlpha);
    pushMatrix();
    translate(0,0,z1);
      image(organUnderlay,0,0);
    popMatrix();
    
    tint(255, 255);
    pushMatrix();
    translate(0,0,z2);
    tint(255, 200);
      image(nerveSkeletonPR, 0,0);
    popMatrix();
    pushMatrix();
    translate(0,0,z3);
      image(blackOverlay, 0,0);
    popMatrix();
    pushMatrix();
    translate(0,0,z4);
    tint(255, 200);
      image(nerveSkeletonFGPR, 0,0);
    popMatrix();
    
    tint(255, imageAlpha);
    pushMatrix();
    translate(0,0,zx);
      image(deviceOverlay,0,0);
      image(UI, 0,0);
    popMatrix();
    
    if(imageAlpha<255)
      imageAlpha += imageAlphaStep;
    if(millis()-timerStart>fadeTimer)
      transition(GAME_MODE);
    break;   
    
  case 5:  /*GAME MODE*/  
    pushMatrix();
    translate(0,0,z0);
      image(organUnderlay,0,0);
    popMatrix();
    pushMatrix();
    translate(0,0,z1);
    tint(255, 200);
      image(nerveSkeletonPR,0,0);
    popMatrix();
    pushMatrix();
    translate(0,0,z2);
      image(blackOverlay, 0,0);
    popMatrix();
    pushMatrix();
    translate(0,0,z3);
    tint(255, 200);
      image(nerveSkeletonFGPR, 0,0);
    popMatrix();
    pushMatrix();
      translate(0,0,z4);
      if(renderParticles){
        renderParticlesOnNerveCurves();
      }
    popMatrix();
    pushMatrix();
    translate(0,0,zx);
      image(deviceOverlay,0,0);
      updateUI(mouseX, mouseY);
      renderUI();
    popMatrix();

    if(switchToIdle || millis()-timerStart>gameTimer)
      transition(TRANSITION_IDLEMODE);
    break;  
    
  case 6: /*TRANSITION TO IDLE MODE*/ 
    pushMatrix();
    rotateX(rotateX);
    rotateY(rotateY);
    rotateZ(rotateZ);
    translate(translateX,translateY,translateZ);
      renderCurves();
      transitionParticlesToIdleCurves();  
    popMatrix();
    
    translateIdleToIdle();
    
    if(transitionDone())
      transition(IDLE_MODE);
    break;
  }
  
  blobx = -width; //MOVED --> CHECK IF WORKS
  bloby = -height;
  blobDir   = new PVector(0,0,0);
  blobBack  = new PVector(0,0,0);
  blobFront = new PVector(0,0,0);
  
  if(mode == IDLE_MODE)
    updateCV(); 
  
  updateCurveColors();
  
  //DISPLAY FRAMERATE//
  //if(DEBUG){
  //  pushMatrix();
  //  translate(0,0,zx);
  //  fill(255);
  //  text(frameRate, 20, height-20);
  //  popMatrix();
  //}
  ////////////////////
}


void transition(int _toMode){
  switch(_toMode){
    case 0: //TO IDLE MODE
      timerStart = millis() + curveTimer;
      setParticlesForIdle();
      mode = IDLE_MODE;
      println("change back to idle mode");
      break;
      
    case 1: //TO IDLE FADE MODE
      for(int i=0; i<curveOpacity.size(); i++){
        curveOpacity.get(i)[1] = 1.0;
        curveOpacity.get(i)[0] = map(i, 0,curveOpacity.size(), curveOpacityMax,0.5);
      }
      timerStart = millis();
      curveFadeOutSpeed = curveOpacityMin/(idleFadeTimer/60.0);
      mode = FADE_IDLEMODE;
      println("fade out idle mode");  
      break;
      
    case 2: //TO TRANSITION GAME MODE
      curveFadeOutSpeed = curveOpacityMin/(curveTimer/60.0);
      transitionParticlesToGameMode();
      clearDrawingCanvas(nerveSkeleton);
      clearDrawingCanvas(nerveSkeletonFG);
      gameParticleSize = 5;
      timerStart = millis();
      mode = TRANSITION_GAMEMODE; 
      transitionToGame = false;
      playSound(WOOSHGAMETRANS);
      
      println("ready to move particles");
      break;
      
    case 3: //TO DRAW GAME MODE
      gameParticleSize = 1.5;
      for(int i=0; i<particles.size(); i++){
        particles.get(i).setTransition(true);
        particles.get(i).setSize(gameParticleSize);
      }
      timerStart = millis();
      mode = DRAW_GAMEMODE; 
      playSound(WOOSHDRAW);
      
      println("change game draw mode");
      break;
      
    case 4: //TO FADE IN GAME MODE
      timerStart = millis();
      imageAlphaStep = 255.0/(fadeTimer/60.0); //NOTE TO SELF: based on 60fps
      mode = FADE_GAMEMODE;
      //nerveSkeleton.save("nerveSkeleton.png");
      //nerveSkeletonFG.save("nerveSkeletonFG.png");
      println("change to game mode");
      break;
      
    case 5: //TO GAME MODE
      timerStart = millis();
      gameParticleSize = 3;
      setParticlesForGame();
      tint(255,255);
      mode = GAME_MODE;
      println("change to game mode");
      break;
      
    case 6: //TO TRANSITION TO IDLE MODE
      transitionParticlesToIdleMode();
      curveFadeOutSpeed = curveOpacityMin/(curveTimer/60.0); //NOTE TO SELF: update proper 
      activatedButton=0;
      switchToIdle = false;
      mode = TRANSITION_IDLEMODE;
      for(int i=0; i<curveOpacity.size(); i++){
        curveOpacity.get(i)[1] = 0.0;
        curveOpacity.get(i)[0] = map(i, 0,curveOpacity.size(), -1.5,-0.5);
      }
      playSound(WOOSHGAMETRANS);
      
      println("enter idle mode");
      break;
  }
}

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
    case 'a':
      if(mode == IDLE_MODE){
        for(int i=0; i<particles.size(); i++){
          particles.get(i).particleBurst(SENSOR_SIDE, random(3.5,4.5));
        }
      }
      break;
    case 's':
      if(mode == IDLE_MODE){
        for(int i=0; i<particles.size(); i++){
          particles.get(i).particleBurst(MOTOR_SIDE, random(3.5,4.5));
        }
      }
      break;
    case 'g':
      if(isBackgroundSave){
        background.save("BGcapture.jpg");
      }
      break;
    case 'b':
      if(mode == IDLE_MODE){
        if(camera.isCameraAvailable()){
          opencv = new OpenCV(this, 480, 270);
          opencv.loadImage(camera.getDepthImage());
          background = opencv.getSnapshot();
          isBackgroundSave = true;
          println("background set");
        }
      }
      break;
    case '1':
      cp5.saveProperties(("parameters"));
      break;
    case '2':
      cp5.loadProperties(("parameters.ser"));
      break;  
  }
}

void mousePressed(){ //NOTE TO SELF: UPDATE ALL OF THIS WITH SENSOR
  if(mode == IDLE_MODE && millis()-timeOutStart>timeOut){
    if(mouseX > 200){
      transitionToGame = true;
    }
  } 
  else if (mode == GAME_MODE){
    PVector mouse = new PVector(mouseX, mouseY);
      
    if(mouse.dist(UIlegpos)<=bigButton){
      legButton = checkButton(legButton);
      updateActivatedButton(legButton, 1);
      brainButton=false;
      
      playSound(BUTTONCLICK);
      playSound(NERVETRIGGER);
    }
    if(mouse.dist(UIarmpos)<=bigButton){
      armButton = checkButton(armButton);
      updateActivatedButton(armButton, 2);
      brainButton=false;
      
      playSound(BUTTONCLICK);
      playSound(NERVETRIGGER);
    }
    if(mouse.dist(UIheartpos)<=bigButton){
      heartButton = checkButton(heartButton);
      updateActivatedButton(heartButton, 3);
      brainButton=false;
    
      playSound(BUTTONCLICK);
      playSound(NERVETRIGGER);
    }
    if(mouse.dist(UIbladderpos)<=bigButton){
      bladderButton = checkButton(bladderButton);
      updateActivatedButton(bladderButton, 4);
      brainButton=false;
      
      playSound(BUTTONCLICK);
      playSound(NERVETRIGGER);
    }
    if(mouse.dist(UIbrainarmpos)<=smallButton && brainButton){
      brainArmButton = checkButton(brainArmButton);
      updateActivatedButton(brainArmButton, 7);
    
      playSound(BUTTONCLICK);
      playSound(NERVETRIGGER);
    }
    if(mouse.dist(UIbrainlegpos)<=smallButton && brainButton){
      brainLegButton = checkButton(brainLegButton);
      updateActivatedButton(brainLegButton, 8);
    
      playSound(BUTTONCLICK);
      playSound(NERVETRIGGER);
    }
    if(mouse.dist(UIbrainbladderpos)<=smallButton && brainButton){
      brainBladderButton = checkButton(brainBladderButton);
      updateActivatedButton(brainBladderButton, 9);
    
      playSound(BUTTONCLICK);
      playSound(NERVETRIGGER);
    }
    
    if(mouse.dist(UIbrainpos)<=bigButton){
      if(!brainButton){
        brainButton = true;
        //deviceButton = false;
        //deviceDevice = false;
        //deviceRings = false;
        activatedButton = 0;
      } else {
        brainButton = false;
        updateActivatedButton(brainBladderButton, 0);
      }
      
      playSound(BUTTONCLICK);
    }
    if(mouse.dist(UIdevicepos)<=bigButton){
      if(!deviceButton){
        deviceButton = true;
        //brainButton = false;
      } else {
        deviceButton = false;
        deviceDevice = false;
        deviceRings = false;
      }
      
      playSound(BUTTONCLICK);
    }
    
    if(mouse.dist(UIdeviceringspos)<=smallButton && deviceButton){
      if(!deviceRings){
        deviceRings = true;
        deviceDevice = false;
      } else {
        deviceRings = false;
      }
      
      playSound(BUTTONCLICK);
    }
    if(mouse.dist(UIdevicedevicepos)<=smallButton && deviceButton){
      if(!deviceDevice){
        deviceDevice = true;
        deviceRings = false;
      } else {
        deviceDevice = false;
      }
      
      playSound(BUTTONCLICK);
    }
    
    if(mouse.dist(UIexitpos)<=bigButton){
      deviceRings  = false;
      deviceDevice = false;
      deviceButton = false;
      brainButton  = false; 
      timerStart   = millis();
      
      switchToIdle = true;
      
      playSound(BUTTONCLICK);
    }
  }
}

////////////////
/*LITTLE TASKS*/
////////////////

boolean transitionDone(){
  boolean transitionDone = true;
  for(int i=0; i<particles.size(); i++){
    if(particles.get(i).getTransition() == true){
      transitionDone = false;
    }
  }
  return transitionDone;
}


void translateIdleToGame(){
  translateX = transitSpeed*translateX + (1-transitSpeed)*gameTranslateX;
  translateY = transitSpeed*translateY + (1-transitSpeed)*gameTranslateY;
  translateZ = transitSpeed*translateZ + (1-transitSpeed)*gameTranslateZ;
  rotateX    = transitSpeed*rotateX + (1-transitSpeed)*gameRotateX;
  rotateY    = transitSpeed*rotateY + (1-transitSpeed)*gameRotateY;
  rotateZ    = transitSpeed*rotateZ + (1-transitSpeed)*gameRotateZ;
}

void translateIdleToIdle(){
  translateX = transitSpeed*translateX + (1-transitSpeed)*idleTranslateX;
  translateY = transitSpeed*translateY + (1-transitSpeed)*idleTranslateY;
  translateZ = transitSpeed*translateZ + (1-transitSpeed)*idleTranslateZ;
  rotateX    = transitSpeed*rotateX + (1-transitSpeed)*idleRotateX;
  rotateY    = transitSpeed*rotateY + (1-transitSpeed)*idleRotateY;
  rotateZ    = transitSpeed*rotateZ + (1-transitSpeed)*idleRotateZ;
}
