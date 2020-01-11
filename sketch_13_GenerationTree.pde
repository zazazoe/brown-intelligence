import AULib.*;

int LEFT_SIDE = 0;
int RIGHT_SIDE = 1;

int IDLE_MODE = 0;
int GAME_MODE = 1;

float treeRot = -1;
PVector treeStartPoint;
int numGenerations = 5;

int minBranches = 1;
int maxBranches = 5;
float segmentMinLength = 50;
float segmentMaxLength = 500;
int segmentMinRot = -60;
int segmentMaxRot = 60;

float particleSpeed = 0.005;
float particleSize = 8;
int particleTrailSize = 1;
boolean renderParticles = true;
boolean syncParticles = false;
boolean disperseParticles = true;

int lineRandX = 10;
int lineRandY = 10;
int lineWeight = 3;
int lineOpacity = 100;
Float[] lineOpacities;

float attractionToOrigin = 15; 
float repulseFromMouse = 25;
float mouseAffectRadius =200;
boolean fixEndPoints = true;

float lineOpacityMin = 0.4;
float lineFadeOutSpeed = 0.005;

int mode = IDLE_MODE;

void setup(){
  fullScreen();
  frameRate(60);
  
  //init values
  treeStartPoint = new PVector(0, height/2);;
  
  //generate a tree
  generateTree(segmentMaxLength, treeRot, treeStartPoint, numGenerations, particleSpeed, particleSize, particleTrailSize); //segement length, rotation, starting point, gen limit, particleSpeed, particleSize, particleTrailSize
  
  //pre-load data for nerves system curves
  initNerveCurves();
  
  initCP5();
}

void draw() {
  background(0);
  
  switch(mode){
    /*IDLE MODE*/
    case 0: 
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
        
        particles.get(i).update("curve");
        
        if(syncParticles){
          particles.get(i).reset(0.0);
        } 
        
        if(disperseParticles){
          particles.get(i).disperse();
        }
        
        if(renderParticles){
          particles.get(i).display(c);
        }
      }
      break;
      
    /*GAME MODE*/  
    case 1:
      renderNerveCurves();
      
      for(int i=0; i<particles.size(); i++){
        color c = color(255,0,255,255);
       
        particles.get(i).update("bezier");
        particles.get(i).display(c);
      }
      break;  
  }
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
      generateTree(segmentMaxLength, treeRot, treeStartPoint, numGenerations, particleSpeed, particleSize, particleTrailSize);
      break;
    case 'p':
      println("nr knots: " + knots.get(0).length);
      println("nr curvePoints: " + curvePoints.get(0).length);
      break;
    case 'a':
      for(int i=0; i<particles.size(); i++){
        particles.get(i).particleBurst(LEFT_SIDE);
      }
      break;
    case 's':
      for(int i=0; i<particles.size(); i++){
        particles.get(i).particleBurst(RIGHT_SIDE);
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

void mousePressed(){
  if(mode == IDLE_MODE){
    mode = GAME_MODE;
    println("enter game mode");
    
    int nr = motorCurves.length;
    updateParticleAmount(nr);    
  } else if(mode == GAME_MODE){
    mode = IDLE_MODE;
    println("enter idle mode");
    
    int nr = curves.size();
    updateParticleAmount(nr);
  }
}
