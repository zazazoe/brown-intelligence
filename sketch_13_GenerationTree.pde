import AULib.*;

//variables
int     LEFT_SIDE = 0;
int     RIGHT_SIDE = 1;

int     IDLE_MODE = 0;
int     GAME_MODE = 1;

float   treeRot = -1;
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
float   lineOpacityMin = 0.4;
float   lineFadeOutSpeed = 0.005;

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

int     curveCounter;
int     newTreeLength;
int     oldTreeLength;
boolean done = false;

void setup(){
  fullScreen();
  frameRate(60);
  
  //init values
  treeStartPoint = new PVector(0, height/2);;
  mode = IDLE_MODE;
  curveCounter = 0;
  
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
  
  initCP5();
  println("initiated controls");
  
  initCV();
  println("sensor started");
}


void draw() {
  background(0);

  switch(mode){
    case 0: /*IDLE MODE*/ 
      renderCrvPt();
      updateCurves();
      
      //update points + render
      for(int i=0; i<particles.size(); i++){
        float f1 = map(i, 0, particles.size(), 0,1);
        float f2 = map(i, 0, particles.size(), 1,0);
        
        float r = f1*red(cpL1.getColorValue()) + f2*red(cpL2.getColorValue());
        float g = f1*green(cpL1.getColorValue()) + f2*green(cpL2.getColorValue());
        float b = f1*blue(cpL1.getColorValue()) + f2*blue(cpL2.getColorValue());
        float a = f1*alpha(cpL1.getColorValue()) + f2*alpha(cpL2.getColorValue());
        
        color c = color(r,g,b,255);
        
        particles.get(i).update(curves.get(i));

        if(renderParticles){
          particles.get(i).display(c);
        }
      }
      
      if(frameCount%5==0){ //every 10 frames
        transitionCurves();
      }
      break;
      
    case 1:  /*GAME MODE*/  
      renderNerveCurves();
      
      if(renderParticles){
        renderParticlesOnNerveCurves();
                 }
      
      drawButtons();
      
      if(mousePressed && frameCount%4 == 0){
        checkButtons();
      }
      break;  
  }
  
  blobx = 0;
  bloby = 0;
  updateCV();  

  fill(255);
  //text(frameRate, 20, height-20);
} //<>//


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
    mode = GAME_MODE;
    updateParticleAmount(nrOfNerveCurves);      
    println("enter game mode");
    
  }
}
