Table curveData;
Table curveRef;
int nrOfCurves;

float[][][] motorKnots;
AUBezier[] motorCurves;

float[][][] sensorKnots;
AUBezier[] sensorCurves;

float t = 0;

void initNerveCurves(){
  /*MOTOR.*/
  initCurveSet("motor.csv", "motor-ref.csv");
  
  motorKnots = new float[nrOfCurves][][];
  motorCurves = new AUBezier[nrOfCurves];
  
  fillKnots(motorKnots);
  fillCurves(motorCurves,motorKnots);
  
  /*SENSOR.*/ 
  initCurveSet("sensor.csv", "sensor-ref.csv");
  
  sensorKnots = new float[nrOfCurves][][];
  sensorCurves = new AUBezier[nrOfCurves];
  
  fillKnots(sensorKnots);
  fillCurves(sensorCurves,sensorKnots);
}


void renderNerveCurves(){
  background(0);
  
  noFill();
  stroke(255,100);  
  drawCurves(motorKnots);
  drawCurves(sensorKnots);
  
  ////draw ellipses
  //noStroke();
  //fill(255,0,0);  
  //drawParticles(motorCurves);
  //drawParticles(sensorCurves);
  
  t+=0.005;
  if(t>1.0) t=0.0;
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

void drawParticles(AUBezier[] curves){
  for(int i=0; i<curves.length; i++){
    ellipse(curves[i].getX(t), curves[i].getY(t), 10,10);
  }
}
