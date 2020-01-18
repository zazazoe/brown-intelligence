Table curveData;
Table curveRef;
int   nrOfCurves;

float[][][] inactiveKnots;
AUBezier[]  inactiveCurves;
float[][][] legMotorKnots;
AUBezier[]  legMotorCurves;
float[][][] legSensorKnots;
AUBezier[]  legSensorCurves;
float[][][] armMotorKnots;
AUBezier[]  armMotorCurves;
float[][][] armSensorKnots;
AUBezier[]  armSensorCurves;

int[]   curveIndex;
color[] colorIndex;
int     curveSets = 5; //update based on nr of curveSets
int     nrOfNerveCurves=0;

int inactive  = 0;
int legMotor  = 1;
int legSensor = 2;
int armMotor  = 3;
int armSensor = 4;
//etc.

int gameParticleSize = 2;
int gameParticleBurstSize = 3;


void initNerveCurves(){
  curveIndex = new int[curveSets];
  colorIndex = new color[curveSets];
  
  /*INACTIVE NERVES.*/
  initCurveSet("inactiveV3.csv", "inactiveRefV3.csv");
  
  inactiveKnots = new float[nrOfCurves][][];
  inactiveCurves = new AUBezier[nrOfCurves];
  
  fillKnots(inactiveKnots);
  fillCurves(inactiveCurves,inactiveKnots);
  
  curveIndex[inactive] = inactiveCurves.length;
  
  
  /*LEG MOTOR.*/
  initCurveSet("legMotorV3.csv", "legMotorRefV3.csv");
  
  legMotorKnots = new float[nrOfCurves][][];
  legMotorCurves = new AUBezier[nrOfCurves];
  
  fillKnots(legMotorKnots);
  fillCurves(legMotorCurves,legMotorKnots);
  
  curveIndex[legMotor] = legMotorCurves.length;
  
  /*LEG SENSOR.*/ 
  initCurveSet("legSensorV3.csv", "legSensorRefV3.csv");
  
  legSensorKnots = new float[nrOfCurves][][];
  legSensorCurves = new AUBezier[nrOfCurves];
  
  fillKnots(legSensorKnots);
  fillCurves(legSensorCurves,legSensorKnots);
  
  curveIndex[legSensor] = legSensorCurves.length;
  
  /*ARM MOTOR.*/
  initCurveSet("armMotorV3.csv", "armMotorRefV3.csv");
  
  armMotorKnots = new float[nrOfCurves][][];
  armMotorCurves = new AUBezier[nrOfCurves];
  
  fillKnots(armMotorKnots);
  fillCurves(armMotorCurves,armMotorKnots);
  
  curveIndex[armMotor] = armMotorCurves.length;
  
  /*ARM SENSOR.*/ 
  initCurveSet("armSensorV3.csv", "armSensorRefV3.csv");
  
  armSensorKnots = new float[nrOfCurves][][];
  armSensorCurves = new AUBezier[nrOfCurves];
  
  fillKnots(armSensorKnots);
  fillCurves(armSensorCurves,armSensorKnots);
  
  curveIndex[armSensor] = armSensorCurves.length;
 
  /*DEFINE COLORS FOR EACH SET.*/
  colorIndex[inactive]  = color(151,238,191,lineOpacityMin*255);
  colorIndex[legMotor]  = color(151,238,191,lineOpacityMin*255);
  colorIndex[legSensor] = color(153,51,255,lineOpacityMin*255);
  colorIndex[armMotor]  = color(151,238,191,lineOpacityMin*255);
  colorIndex[armSensor] = color(153,51,191,lineOpacityMin*255);
  
  for(int i=0; i<curveIndex.length; i++){
    nrOfNerveCurves += curveIndex[i];
  }
} //<>//


void renderNerveCurves(){
  background(0);
  
  noFill();
  strokeWeight(1.5);
  
  stroke(colorIndex[inactive]);  
  drawCurves(inactiveKnots);
  
  stroke(colorIndex[legMotor]);  
  drawCurves(legMotorKnots);
  
  stroke(colorIndex[legSensor]); 
  drawCurves(legSensorKnots);
  
  stroke(colorIndex[armMotor]); 
  drawCurves(armMotorKnots);
  
  stroke(colorIndex[armSensor]); 
  drawCurves(armSensorKnots);
}

void renderParticlesOnCurves(){
  renderParticles(inactive, inactiveCurves);
  renderParticles(legMotor, legMotorCurves);  
  renderParticles(legSensor, legSensorCurves);
  renderParticles(armMotor, armMotorCurves);
  renderParticles(armSensor, armSensorCurves);
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
                               gameParticleBurstSize);
    } 
  }
}

void sendNerveBurst(int _curveIndex){
  int i=0;
  
  for(int j=0; j<_curveIndex; j++){
    i+=curveIndex[j];
  }
  
  for(int j=i; j<i+curveIndex[_curveIndex]; j++){
    if(j < particles.size()){
      particles.get(j).particleBurst(LEFT_SIDE);
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
