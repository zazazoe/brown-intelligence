Table curveData;
Table curveRef;
int   nrOfCurves;

float[][][] inactiveKnots;
AUBezier[]  inactiveCurves;
float[][][] legKnots;
AUBezier[]  legCurves;
float[][][] armKnots;
AUBezier[]  armCurves;

PImage nervousSystem;

int[]   curveIndex;
color[] colorIndex;
int     curveSets = 3; //update based on nr of curveSets
int     nrOfNerveCurves=0;

int leg       = 0;
int arm       = 1;
int inactive  = 2;
//etc.

int   gameParticleSize = 2;
int   gameParticleBurstSize = 3;
color gameParticleBurstColor;

float transitionSpeed = 0.99;


void initNerveCurves(){
  curveIndex = new int[curveSets];
  colorIndex = new color[curveSets];
  nervousSystem = loadImage("NervousSystem.png");
  nervousSystem.resize(width, height);
  
  ///*INACTIVE NERVES.*/
  initCurveSet("inactiveV3.csv", "inactiveRefV3.csv");
  
  inactiveKnots = new float[nrOfCurves][][];
  inactiveCurves = new AUBezier[nrOfCurves];
  
  fillKnots(inactiveKnots);
  fillCurves(inactiveCurves,inactiveKnots);
  
  curveIndex[inactive] = inactiveCurves.length;
  
  /*LEG.*/ 
  initCurveSet("legSensorV3.csv", "legSensorRefV3.csv");
  
  legKnots = new float[nrOfCurves][][];
  legCurves = new AUBezier[nrOfCurves];
  
  fillKnots(legKnots);
  fillCurves(legCurves,legKnots);
  
  curveIndex[leg] = legCurves.length;
  
  /*ARM.*/ 
  initCurveSet("armSensorV3.csv", "armSensorRefV3.csv");
  
  armKnots = new float[nrOfCurves][][];
  armCurves = new AUBezier[nrOfCurves];
  
  fillKnots(armKnots);
  fillCurves(armCurves,armKnots);
  
  curveIndex[arm] = armCurves.length;
 
  /*DEFINE COLORS FOR EACH SET.*/
  colorIndex[inactive] = color(153,51,255,lineOpacityMin*255);
  colorIndex[leg]      = color(153,51,255,lineOpacityMin*255);
  colorIndex[arm]      = color(153,51,255,lineOpacityMin*255);
  
  gameParticleBurstColor = color(225,225,225);
  
  for(int i=0; i<curveIndex.length; i++){
    nrOfNerveCurves += curveIndex[i];
  }
}


void renderNerveCurves(){
  noFill();
  strokeWeight(1.5);
  
  image(nervousSystem,0,0);
  
  //stroke(colorIndex[inactive]);  
  //drawCurves(inactiveKnots);
  
  //stroke(colorIndex[leg]); 
  //drawCurves(legKnots);

  //stroke(colorIndex[arm]); 
  //drawCurves(armKnots);
}

void renderParticlesOnNerveCurves(){
  renderParticles(inactive, inactiveCurves);
  renderParticles(leg, legCurves);
  renderParticles(arm, armCurves);
}

void transitionParticlesToNerveCurves(){
  transitionParticles(inactive, inactiveCurves);
  transitionParticles(leg, legCurves);
  transitionParticles(arm, armCurves);
}

void initTransitionParticlesToNerveCurves(){
  initTransitionParticles(inactive, inactiveCurves);
  initTransitionParticles(leg, legCurves);
  initTransitionParticles(arm, armCurves);
}

void renderParticles(int _curveIndex, AUBezier[] curveSet){
  int i=0;
  for(int j=0; j<_curveIndex; j++){
    i+=curveIndex[j];
  }
  for(int j=i; j<i+curveIndex[_curveIndex]; j++){ //<>//
    if(j < particles.size()){
      particles.get(j).updateGame(curveSet[j-i]);
      particles.get(j).setGameColor(color(red(colorIndex[_curveIndex]), green(colorIndex[_curveIndex]), blue(colorIndex[_curveIndex]), alpha(colorIndex[_curveIndex])));
      particles.get(i).setGameSize(gameParticleSize);
      particles.get(j).displayGame(gameParticleBurstSize, gameParticleBurstColor);
    } 
  }
}

void transitionParticles(int _curveIndex, AUBezier[] curveSet){
  int i=0;
  for(int j=0; j<_curveIndex; j++){
    i+=curveIndex[j];
  }
  for(int j=i; j<i+curveIndex[_curveIndex]; j++){
    if(j < particles.size()){
      particles.get(j).transition(curveSet[j-i], transitionSpeed);
      particles.get(j).setGameColor(color(red(colorIndex[_curveIndex]), green(colorIndex[_curveIndex]), blue(colorIndex[_curveIndex]), alpha(colorIndex[_curveIndex])));
      particles.get(i).setGameSize(gameParticleSize);
      particles.get(j).displayGame(gameParticleBurstSize, gameParticleBurstColor);
    } 
  }
}

void initTransitionParticles(int _curveIndex, AUBezier[] curveSet){
  int i=0;
  for(int j=0; j<_curveIndex; j++){
    i+=curveIndex[j];
  }
  for(int j=i; j<i+curveIndex[_curveIndex]; j++){
    if(j < particles.size()){
      particles.get(j).setTransition(true, curveSet[j-i]);
    } 
  }
}

void sendNerveBurst(int _curveIndex, int _side){
  int i=0;
  
  for(int j=0; j<_curveIndex; j++){
    i+=curveIndex[j];
  }
  
  for(int j=i; j<i+curveIndex[_curveIndex]; j++){
    if(j < particles.size()){
      particles.get(j).particleBurst(_side);
    } 
  }
}

void initCurveSet(String CurveData, String CurveRef){
  curveData = loadTable(CurveData);
  curveRef = loadTable(CurveRef);  
  nrOfCurves = curveRef.getRowCount();
}

void fillKnots(float knots[][][]){
  int curveIndex=0;
  
  for(int i=0; i<curveRef.getRowCount(); i++){
    int curveLength = curveRef.getInt(i,0);
    knots[i] = new float[curveLength][2];
    
    for(int j=0; j<curveLength; j++){
      knots[i][j][0] = curveData.getFloat(j+curveIndex,0);
      knots[i][j][1] = curveData.getFloat(j+curveIndex,1);
    } 
    curveIndex += curveLength;
  }
}

void fillCurves(AUBezier[] curves, float knots[][][]){
  for(int i=0; i<curveRef.getRowCount(); i++){
    curves[i] = new AUBezier(knots[i], 2, false);
  }
}

void drawCurves(float knots[][][]){
  for(int i=0; i<knots.length; i++){
    int curveLength = knots[i].length;
    
    beginShape(); 
    vertex(knots[i][0][0], knots[i][0][1]);
    
    for(int j=1; j<curveLength; j+=3){
      
      bezierVertex(knots[i][j][0], knots[i][j][1],
                   knots[i][j+1][0], knots[i][j+1][1],
                   knots[i][j+2][0], knots[i][j+2][1]);
    }
    endShape();
  }
}
