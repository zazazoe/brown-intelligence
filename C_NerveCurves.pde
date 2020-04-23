 //<>// //<>// //<>// //<>//
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


void initNerveCurves(){
  curveIndex = new int[curveSets];
  colorIndex = new color[curveSets];

  /*LEG.*/ 
  //initCurveSet("nerveData/1440900/leg.csv", "nerveData/1440900/legRef.csv");
  initCurveSet("nerveData/19201080/leg.csv", "nerveData/19201080/legRef.csv");
  
  legKnots = new float[nrOfCurves][][];
  legCurves = new AUBezier[nrOfCurves];
  fillKnots(legKnots);
  fillCurves(legCurves,legKnots);
  
  curveIndex[leg] = legCurves.length;
  
  /*ARM.*/ 
  //initCurveSet("nerveData/1440900/arm.csv", "nerveData/1440900/armRef.csv");
  initCurveSet("nerveData/19201080/arm.csv", "nerveData/19201080/armRef.csv");
  
  armKnots = new float[nrOfCurves][][];
  armCurves = new AUBezier[nrOfCurves];
  fillKnots(armKnots);
  fillCurves(armCurves,armKnots);
  
  curveIndex[arm] = armCurves.length;
  
  /*HEART.*/ 
  //initCurveSet("nerveData/1440900/heart.csv", "nerveData/1440900/heartRef.csv");
  initCurveSet("nerveData/19201080/heart.csv", "nerveData/19201080/heartRef.csv");
  
  heartKnots = new float[nrOfCurves][][];
  heartCurves = new AUBezier[nrOfCurves];
  fillKnots(heartKnots);
  fillCurves(heartCurves,heartKnots);
  
  curveIndex[heart] = heartCurves.length;
  
  /*BLADDER.*/ 
  //initCurveSet("nerveData/1440900/bladder.csv", "nerveData/1440900/bladderRef.csv");
  initCurveSet("nerveData/19201080/bladder.csv", "nerveData/19201080/bladderRef.csv");
  
  bladderKnots = new float[nrOfCurves][][];
  bladderCurves = new AUBezier[nrOfCurves];
  fillKnots(bladderKnots);
  fillCurves(bladderCurves,bladderKnots);
  
  curveIndex[bladder] = bladderCurves.length;
 
  /*INACTIVE NERVES.*/
  //initCurveSet("nerveData/1440900/inactive.csv", "nerveData/1440900/inactiveRef.csv");
  initCurveSet("nerveData/19201080/inactive.csv", "nerveData/19201080/inactiveRef.csv");
  
  inactiveKnots = new float[nrOfCurves][][];
  inactiveCurves = new AUBezier[nrOfCurves];
  fillKnots(inactiveKnots);
  fillCurves(inactiveCurves,inactiveKnots);
  
  curveIndex[inactive] = inactiveCurves.length;
  
  //gameParticleBurstColor = color(225,225,225);
  
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

void drawNerveCurves(float _tStep){
  drawParticles(leg, legCurves, _tStep);
  drawParticles(arm, armCurves, _tStep);
  drawParticles(heart, heartCurves, _tStep);
  drawParticles(bladder, bladderCurves, _tStep);
  drawParticles(inactive, inactiveCurves, _tStep);
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
  for(int j=i; j<i+curveIndex[_curveIndex]; j++){ //<>// //<>// //<>// //<>//
    if(j < particles.size()){
      particles.get(j).updateGame(curveSet[j-i]);
      particles.get(j).setGameColor(gameColor);
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
  for(int j=i; j<i+curveIndex[_curveIndex]; j++){
    if(j < particles.size()){
      particles.get(j).updateGame(curveSet[j-i]);
      particles.get(j).setGameColor(gameColor);
      particles.get(j).setGameSize(gameParticleSize);
    } 
  }
}

void drawParticles(int _curveIndex, AUBezier[] curveSet, float _tStep){
  int i=0;
  for(int j=0; j<_curveIndex; j++){
    i+=curveIndex[j];
  }
  for(int j=i; j<i+curveIndex[_curveIndex]; j++){
    if(j < particles.size()){
      particles.get(j).updateGameDraw(curveSet[j-i], _tStep);
      particles.get(j).setGameColor(gameColor);
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
      particles.get(j).transition(particleTransitionSpeed);
      particles.get(j).setGameColor(gameColor);
      particles.get(j).setGameSize(gameParticleSize);
      particles.get(j).displayTransition(gameParticleBurstSize, gameParticleBurstColor);
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
      particles.get(j).setTransition(true, curveSet[j-i], 0.0);
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
      particles.get(j).particleBurst(_side, random(3.5,4.5)); //NOTE TO SELF: update with proper variable
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
    knots[i] = new float[curveLength][3];
    
    for(int j=0; j<curveLength; j++){
      knots[i][j][0] = curveData.getFloat(j+curveIndex,0);
      knots[i][j][1] = curveData.getFloat(j+curveIndex,1);
      knots[i][j][2] = 0;
    } 
    curveIndex += curveLength;
  }
}

void fillCurves(AUBezier[] curves, float knots[][][]){
  for(int i=0; i<curveRef.getRowCount(); i++){
    curves[i] = new AUBezier(knots[i], 3, false);
  }
}

void drawCurves(float knots[][][]){
  for(int i=0; i<knots.length; i++){
    int curveLength = knots[i].length;
    
    beginShape(); 
    vertex(knots[i][0][0], knots[i][0][1], knots[i][0][2]);
    
    for(int j=1; j<curveLength; j+=3){
      
      bezierVertex(knots[i][j][0],   knots[i][j][1],   knots[i][j][2],
                   knots[i][j+1][0], knots[i][j+1][1], knots[i][j+1][2],
                   knots[i][j+2][0], knots[i][j+2][1], knots[i][j+2][2]);
    }
    endShape();
  }
}
