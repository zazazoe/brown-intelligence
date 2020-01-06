import AULib.*;

float segmentStartLength;
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

int lineRandX;
int lineRandY;
int lineWeight;
int lineOpacity;

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
  
  particleSpeed = 0.01;
  particleSize = 8.0;
  particleTrailSize = 5;
  
  lineRandX = 20;
  lineRandY = 20;
  lineWeight = 3;
  lineOpacity = 100;
  
  //generate a tree
  generateTree(segmentMaxLength, treeRot, treeStartPoint, numGenerations, particleSpeed, particleSize, particleTrailSize); //segement length, rotation, starting point, gen limit, particleSpeed, particleSize, particleTrailSize
}

void draw() {
  background(255,220,220);

  //render(); //render tree lines
  renderCrvPt();
  
  //update points + render
  for(int i=0; i<particles.size(); i++){
    color c = color((100/(i+1))*linesToSave.size(),0,(200/linesToSave.size())*i);
    particles.get(i).update();
    particles.get(i).display(c);
  }
  
  
}

void mousePressed(){
  background(0);
  generateTree(segmentMaxLength, treeRot, treeStartPoint, numGenerations, particleSpeed, particleSize, particleTrailSize);
} //<>//
