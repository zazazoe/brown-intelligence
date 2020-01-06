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

float mouseFollowerX = 0;

void setup(){
  //size(500,500); 
  fullScreen();
  frameRate(60);
  smooth(8);
  
  //init values
  treeRot = -1;
  treeStartPoint = new PVector(0, height/2);
  numGenerations = 5;
  
  minBranches = 2;
  maxBranches = 3;
  segmentMaxLength = 400;
  segmentMinLength = 50;
  segmentMinRot = -30;
  segmentMaxRot = 30;
  
  particleSpeed = 0.015;
  particleSize = 5.0;
  particleTrailSize = 5;
  
  //generate a tree
  generateTree(segmentMaxLength, treeRot, treeStartPoint, numGenerations, particleSpeed, particleSize, particleTrailSize); //segement length, rotation, starting point, gen limit, particleSpeed, particleSize, particleTrailSize
}

void draw() {
  background(220);
  
  //mouseFollowerX = mouseFollowerX*0.98 + mouseX*0.02;
        
  //fill(0);
  //ellipse(mouseFollowerX, mouseY, 20,20);
  
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
