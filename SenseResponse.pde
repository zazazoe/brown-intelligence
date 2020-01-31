import AULib.*;
import processing.video.*;
import ch.bildspur.realsense.*;
import controlP5.*;
import peasy.*;

PeasyCam cam;

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

int     timerStart = 0;
int     curveTimer = 1000;
int     drawTimer  = 12000;
int     fadeTimer  = 1000;
int     idleFadeTimer = 1500; 

int     z0 = -1;
int     z1 = 0;
int     z2 = 1;
int     z3 = 2;
int     z4 = 3;
int     z5 = 4;
int     zx = 10;

void setup(){
  fullScreen(OPENGL, 2); //NOTE TO SELF: change display back to 1
  frameRate(60);  
  cam = new PeasyCam(this, 100);
  
  mode             = IDLE_MODE;
  timerStart       = millis();

  loadImages();
  loadUIImages();
  initNerveCurves();
  initCP5();
  initCurves();
  if(sensorConnected) initCV(); 
}


void draw() {
  background(0);

  switch(mode){
  case 0: /*IDLE MODE*/ 
    //updateCurves();
    //updateCurvePoints();
    //updateParticlesIdle();
    
    pushMatrix();
    translate(0,0,z1);
    renderCurves(); 
    popMatrix();
    
    pushMatrix();
    translate(0,0,z2);
    //renderParticlesIdle(); 
    popMatrix();
    
    //if(millis()-timerStart>curveTimer){
    //  transitionToNextTree();
    //  timerStart = millis();
    //}
    if(transitionToGame)
      transition(FADE_IDLEMODE);
    break;
 
  case 1: /*FADE OUT IDLE MODE*/ 
    updateParticlesIdleFade();
    
    pushMatrix();
    translate(0,0,z1);
      renderCurves();
    popMatrix();
    pushMatrix();
    translate(0,0,z2);
      renderParticlesIdle();
    popMatrix();
    
    if(millis()-timerStart>idleFadeTimer)
      transition(TRANSITION_GAMEMODE);
    break;
    
  case 2: /*TRANSITION TO GAME MODE*/ 
    pushMatrix();
    translate(0,0,z1);
      transitionParticlesToNerveCurves();
    popMatrix();
    pushMatrix();
    translate(0,0,z2);
      renderCurves();
    popMatrix();
    if(transitionDone())
      transition(DRAW_GAMEMODE);
    break;
    
  case 3: /*DRAW GAME MODE*/ 
    drawNerveCurves(particleDrawingSpeed);
    drawParticlesOnCanvas(nerveSkeleton, 0, particles.size()-inactiveCurves.length);
    drawParticlesOnCanvas(nerveSkeletonFG, particles.size()-inactiveCurves.length, particles.size());
    
    pushMatrix();
    translate(0,0,z1);
      image(nerveSkeleton, 0,0);
    popMatrix();
    pushMatrix();
    translate(0,0,z1);
      image(blackOverlay, 0,0);
    popMatrix();
    pushMatrix();
    translate(0,0,z3);
      image(nerveSkeletonFG, 0,0);
    popMatrix();
    
    if(transitionDone())//millis()-timerStart>drawTimer)
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
      image(nerveSkeleton, 0,0);
    popMatrix();
    pushMatrix();
    translate(0,0,z3);
      image(blackOverlay, 0,0);
    popMatrix();
    pushMatrix();
    translate(0,0,z4);
      image(nerveSkeletonFG, 0,0);
    popMatrix();
    
    tint(255, imageAlpha);
    pushMatrix();
    translate(0,0,zx);
      image(deviceOverlay,0,0);
      image(UI, 0,0);
    popMatrix();
    //NOTE TO SELF: also make particles fade in more subtle
    
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
      image(nerveSkeleton,0,0);
    popMatrix();
    pushMatrix();
    translate(0,0,z2);
      image(blackOverlay, 0,0);
    popMatrix();
    pushMatrix();
    translate(0,0,z3);
      image(nerveSkeletonFG, 0,0);
    popMatrix();
    pushMatrix();
      translate(0,0,z4);
      if(renderParticles){
        renderParticlesOnNerveCurves(); //NOTE TO SELF: can particles be layered, so all bursts on top and all idle on bottom? Split in two functions...
      }
    popMatrix();
    pushMatrix();
    translate(0,0,zx);
      image(deviceOverlay,0,0);
      checkButtons(mouseX, mouseY);
      renderUI();
    popMatrix();
   
    if(switchToIdle)
      transition(TRANSITION_IDLEMODE);
    break;  
    
  case 6: /*TRANSITION TO IDLE MODE*/ 
    pushMatrix();
    translate(0,0,z1);
      renderCurves();
    popMatrix();
    pushMatrix();
    translate(0,0,z2);
      transitionParticlesToIdleCurves();  
    popMatrix();
   
    if(transitionDone())
      transition(IDLE_MODE);
    break;
  }
  
  blobx = 0; //CHECK THIS OUT AND CLEAN UP
  bloby = 0;
  
  if(sensorConnected)
    updateCV(); 
  
  updateCurveColors(); //NOTE TO SELF: adjust speed of color change here
  
  pushMatrix();
  translate(0,0,zx);
  fill(255);
  text(frameRate, 20, height-20);
  popMatrix();
}


void transition(int _toMode){
  switch(_toMode){
    case 0: //TO IDLE MODE
      timerStart = millis() + curveTimer;
      mode = IDLE_MODE;
      println("change back to idle mode");
      break;
    case 1:
      for(int i=0; i<curveOpacity.size(); i++){
        curveOpacity.get(i)[1] = 1.0;
        curveOpacity.get(i)[0] = map(i, 0,curveOpacity.size(), 1.5,0.5);
      }
      timerStart = millis();
      curveFadeOutSpeed = curveOpacityMin/(idleFadeTimer/60.0);
      mode = FADE_IDLEMODE;
      println("fade out idle mode");  
      break;
    case 2:
      curveFadeOutSpeed = curveOpacityMin/(curveTimer/60.0);
      transitionParticlesToGameMode();
      clearDrawingCanvas(nerveSkeleton);
      clearDrawingCanvas(nerveSkeletonFG);
      gameParticleSize = 1;
      timerStart = millis();
      mode = TRANSITION_GAMEMODE; 
      transitionToGame = false;
      println("ready to move particles");
      break;
    case 3:
      for(int i=0; i<particles.size(); i++){
        particles.get(i).setTransition(true);
      }
      timerStart = millis();
      mode = DRAW_GAMEMODE; 
      println("change game draw mode");
      break;
    case 4:
      timerStart = millis();
      imageAlphaStep = 255.0/(fadeTimer/60.0); //NOTE TO SELF: based on 60fps
      mode = FADE_GAMEMODE;
      println("change to game mode");
      break;
    case 5:
      gameParticleSize = 3;
      setParticlesForGame();
      tint(255,255);
      mode = GAME_MODE;
      println("change to game mode");
      break;
    case 6:
      transitionParticlesToIdleMode();
      curveFadeOutSpeed = curveOpacityMin/(curveTimer/60.0); //NOTE TO SELF: update proper 
      switchToIdle = false;
      mode = TRANSITION_IDLEMODE;
      for(int i=0; i<curveOpacity.size(); i++){
        curveOpacity.get(i)[1] = 0.0;
        curveOpacity.get(i)[0] = map(i, 0,curveOpacity.size(), -1.5,-0.5);
      }
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
    case 'r': //regenerate a tree
      regenerateCurveSet(segmentMaxLength, curveSetRot, curveSetStartPoint, numGenerations);
      break;
    case 'a':
      if(mode == IDLE_MODE){
        if(camera.isCameraAvailable()){
          opencv = new OpenCV(this, 480, 270);
          opencv.loadImage(camera.getDepthImage());
          background = opencv.getSnapshot();
          println("background set");
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
  //if(mode == IDLE_MODE && millis()-timeOutStart>timeOut){
  //  transitionToGame = true;
  //}
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
