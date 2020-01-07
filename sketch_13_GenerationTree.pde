import AULib.*;

int LEFT_SIDE = 0;
int RIGHT_SIDE = 1;

float treeRot;
PVector treeStartPoint;
int numGenerations;

int minBranches;
int maxBranches;
float segmentMinLength;
float segmentMaxLength;
int segmentMinRot;
int segmentMaxRot;

float particleSpeed;
float particleSize;
int particleTrailSize;
boolean renderParticles;
boolean syncParticles;
boolean disperseParticles;

int lineRandX;
int lineRandY;
int lineWeight;
int lineOpacity;
Float[] lineOpacities;

float attractionToOrigin; 
float repulseFromMouse;
float mouseAffectRadius;
boolean fixEndPoints;

void setup(){
  //size(500,500); 
  fullScreen();
  frameRate(60);
  smooth(8);
  
  //init values
  treeRot = -1;
  treeStartPoint = new PVector(0, height/2);
  numGenerations = 5;
  
  minBranches = 1;
  maxBranches = 5;
  segmentMaxLength = 500;
  segmentMinLength = 50;
  segmentMinRot = -60;
  segmentMaxRot = 60;
  
  particleSpeed = 0.005;
  particleSize = 8.0;
  particleTrailSize = 1;
  renderParticles = true;
  syncParticles = false;
  disperseParticles = true;
  
  lineRandX = 10;
  lineRandY = 10;
  lineWeight = 3;
  lineOpacity = 100;
  
  attractionToOrigin = 15;
  repulseFromMouse = 25;
  mouseAffectRadius = 200;
  fixEndPoints = true;
  
  //generate a tree
  generateTree(segmentMaxLength, treeRot, treeStartPoint, numGenerations, particleSpeed, particleSize, particleTrailSize); //segement length, rotation, starting point, gen limit, particleSpeed, particleSize, particleTrailSize
  
  setupCP5();
}

void draw() {
  background(0);
  
  renderCrvPt();
  updateCurves();
  
  //update points + render
  for(int i=0; i<particles.size(); i++){
    //color c = color((100/(i+1))*linesToSave.size(),0,(200/linesToSave.size())*i);
    //color c = cpP.getColorValue();
    float f1 = map(i, 0, particles.size(), 0,1);
    float f2 = map(i, 0, particles.size(), 1,0);
    
    float r = f1*red(cpL1.getColorValue()) + f2*red(cpL2.getColorValue());
    float g = f1*green(cpL1.getColorValue()) + f2*green(cpL2.getColorValue());
    float b = f1*blue(cpL1.getColorValue()) + f2*blue(cpL2.getColorValue());
    float a = f1*alpha(cpL1.getColorValue()) + f2*alpha(cpL2.getColorValue());
    
    color c = color(r,g,b,255);
    
    particles.get(i).update();
    
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
  
  println(syncParticles);
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
      cp5.saveProperties(("test"));
      break;
    case '2':
      cp5.loadProperties(("test.ser"));
      break;  
  }
}
