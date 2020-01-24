Table curveData;
Table curveRef;
int   nrOfCurves;

float[][][] legKnots;
AUBezier[]  legCurves;
float[][][] armKnots;
AUBezier[]  armCurves;
float[][][] heartKnots;
AUBezier[]  heartCurves;
float[][][] bladderKnots;
AUBezier[]  bladderCurves;
float[][][] inactiveKnots;
AUBezier[]  inactiveCurves;

int[]   curveIndex;
color[] colorIndex;
int     curveSets = 5; //update based on nr of curveSets
int     nrOfNerveCurves=0;

int leg      = 0;
int arm      = 1;
int heart    = 2;
int bladder  = 3;
int inactive = 4;
//etc.

int   gameParticleSize = 4;
int   gameParticleBurstSize = 3;
color gameParticleBurstColor;

float transitionSpeed = 0.96;


void initNerveCurves(){
  curveIndex = new int[curveSets];
  colorIndex = new color[curveSets];

  /*LEG.*/ 
  initCurveSet("nerveData/legV4.csv", "nerveData/legRefV4.csv");
  
  legKnots = new float[nrOfCurves][][];
  legCurves = new AUBezier[nrOfCurves];
  
  fillKnots(legKnots);
  fillCurves(legCurves,legKnots);
  
  curveIndex[leg] = legCurves.length;
  
  /*ARM.*/ 
  initCurveSet("nerveData/armV4.csv", "nerveData/armRefV4.csv");
  
  armKnots = new float[nrOfCurves][][];
  armCurves = new AUBezier[nrOfCurves];
  
  fillKnots(armKnots);
  fillCurves(armCurves,armKnots);
  
  curveIndex[arm] = armCurves.length;
  
  /*HEART.*/ 
  initCurveSet("nerveData/heartV4.csv", "nerveData/heartRefV4.csv");
  
  heartKnots = new float[nrOfCurves][][];
  heartCurves = new AUBezier[nrOfCurves];
  
  fillKnots(heartKnots);
  fillCurves(heartCurves,heartKnots);
  
  curveIndex[heart] = heartCurves.length;
  
  /*BLADDER.*/ 
  initCurveSet("nerveData/bladderV4.csv", "nerveData/bladderRefV4.csv");
  
  bladderKnots = new float[nrOfCurves][][];
  bladderCurves = new AUBezier[nrOfCurves];
  
  fillKnots(bladderKnots);
  fillCurves(bladderCurves,bladderKnots);
  
  curveIndex[bladder] = bladderCurves.length;
 
  /*INACTIVE NERVES.*/
  initCurveSet("nerveData/inactiveV7.csv", "nerveData/inactiveRefV7.csv");
  
  inactiveKnots = new float[nrOfCurves][][];
  inactiveCurves = new AUBezier[nrOfCurves];
  
  fillKnots(inactiveKnots);
  fillCurves(inactiveCurves,inactiveKnots);
  
  curveIndex[inactive] = inactiveCurves.length;
  
  /*DEFINE COLORS FOR EACH SET.*/
  colorIndex[leg]      = color(153,51,255,255);
  colorIndex[arm]      = color(153,51,255,255);
  colorIndex[heart]      = color(153,51,255,255);
  colorIndex[bladder]      = color(153,51,255,255);
  colorIndex[inactive] = color(153,51,255,255); //lineOpacityMin*255
  
  gameParticleBurstColor = color(225,225,225);
  
  for(int i=0; i<curveIndex.length; i++){
    nrOfNerveCurves += curveIndex[i];
  }
}

void renderParticlesOnNerveCurves(){
  renderParticles(leg, legCurves);
  renderParticles(arm, armCurves);
  renderParticles(heart, heartCurves);
  renderParticles(bladder, bladderCurves);
  renderParticles(inactive, inactiveCurves);
}

void updateParticlesOnNerveCurves(){
  updateParticles(leg, legCurves);
  updateParticles(arm, armCurves);
  updateParticles(heart, heartCurves);
  updateParticles(bladder, bladderCurves);
  updateParticles(inactive, inactiveCurves);
}

void transitionParticlesToNerveCurves(){
  transitionParticles(leg, legCurves);
  transitionParticles(arm, armCurves);
  transitionParticles(heart, heartCurves);
  transitionParticles(bladder, bladderCurves);
  transitionParticles(inactive, inactiveCurves);
}

void initTransitionParticlesToNerveCurves(){
  println("initialising nerve curves");
  
  initTransitionParticles(leg, legCurves);
  initTransitionParticles(arm, armCurves);
  initTransitionParticles(heart, heartCurves);
  initTransitionParticles(bladder, bladderCurves);
  initTransitionParticles(inactive, inactiveCurves);
}


void renderParticles(int _curveIndex, AUBezier[] curveSet){
  int i=0;
  for(int j=0; j<_curveIndex; j++){
    i+=curveIndex[j];
  }
  for(int j=i; j<i+curveIndex[_curveIndex]; j++){ //<>// //<>//
    if(j < particles.size()){
      particles.get(j).updateGame(curveSet[j-i]);
      particles.get(j).setGameColor(color(red(colorIndex[_curveIndex]), green(colorIndex[_curveIndex]), blue(colorIndex[_curveIndex]), alpha(colorIndex[_curveIndex])));
      particles.get(j).setGameSize(gameParticleSize);
      particles.get(j).displayGame(gameParticleBurstSize, gameParticleBurstColor);
    } 
  }
}

void updateParticles(int _curveIndex, AUBezier[] curveSet){
  int i=0;
  for(int j=0; j<_curveIndex; j++){
    i+=curveIndex[j];
  }
  for(int j=i; j<i+curveIndex[_curveIndex]; j++){ //<>//
    if(j < particles.size()){
      particles.get(j).updateGame(curveSet[j-i]);
      particles.get(j).setGameColor(color(red(colorIndex[_curveIndex]), green(colorIndex[_curveIndex]), blue(colorIndex[_curveIndex]), alpha(colorIndex[_curveIndex])));
      particles.get(j).setGameSize(gameParticleSize);
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
      particles.get(j).transition(transitionSpeed);
      particles.get(j).setGameColor(color(red(colorIndex[_curveIndex]), green(colorIndex[_curveIndex]), blue(colorIndex[_curveIndex]), alpha(colorIndex[_curveIndex])));
      particles.get(j).setGameSize(gameParticleSize);
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
