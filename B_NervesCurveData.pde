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

int inactive  = 0;
int leg       = 1;
int arm       = 2;
//etc.

int   gameParticleSize = 2;
int   gameParticleBurstSize = 3;
color gameParticleBurstColor;


void initNerveCurves(){
  curveIndex = new int[curveSets];
  colorIndex = new color[curveSets];
  nervousSystem = loadImage("NervousSystem.png");
  nervousSystem.resize(width, height);
  
  /*INACTIVE NERVES.*/
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

void TransitionParticlesToNerveCurves(){
  int perCategory = particlesToMove/curveSets;
  
  for(int i=0; i<perCategory; i++){
    particles.get(i).transition(inactiveCurves[i]);
    particles.get(i).display(color(red(colorIndex[inactive]), green(colorIndex[inactive]), blue(colorIndex[inactive])),
                                   gameParticleSize,
                                   gameParticleBurstSize,
                                   gameParticleBurstColor);
  }
  
  for(int i=perCategory; i<perCategory*2; i++){
    particles.get(i).transition(legCurves[i-perCategory]);
    particles.get(i).display(color(red(colorIndex[leg]), green(colorIndex[leg]), blue(colorIndex[leg])),
                                   gameParticleSize,
                                   gameParticleBurstSize,
                                   gameParticleBurstColor);
  }
  
  for(int i=perCategory*2; i<perCategory*3; i++){
    if(i<particlesToMove){
      particles.get(i).transition(armCurves[i-perCategory*2]);
      particles.get(i).display(color(red(colorIndex[arm]), green(colorIndex[arm]), blue(colorIndex[arm])),
                                     gameParticleSize,
                                     gameParticleBurstSize,
                                     gameParticleBurstColor);
    }
  }
}

void renderParticles(int _curveIndex, AUBezier[] curveSet){
  int i=0;
  
  for(int j=0; j<_curveIndex; j++){
    i+=curveIndex[j];
  }
  
  for(int j=i; j<i+curveIndex[_curveIndex]; j++){ //<>//
    if(j < particles.size()){
      particles.get(j).update(curveSet[j-i]);
      particles.get(j).display(color(red(colorIndex[_curveIndex]), green(colorIndex[_curveIndex]), blue(colorIndex[_curveIndex])),
                                             gameParticleSize,
                                             gameParticleBurstSize,
                                             gameParticleBurstColor);
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
