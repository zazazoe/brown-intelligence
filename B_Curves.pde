
float   curveSetRot = 0;
PVector curveSetStartPoint;
int     numGenerations = 5;
int     minBranches = 3;
int     maxBranches = 3;
float   segmentMaxLength = 300;
int     segmentMaxRot = 10;
int     segmentMaxRotZ = 28;
int     segmentMaxRotY = 10;

int     generationLimit;
ArrayList<Segment>[] points;
ArrayList<ArrayList<PVector>> curvesToSave;
int     counter;

ArrayList<float[][]> knots;
ArrayList<AUCurve> curves;
ArrayList<Particle> particles;
ArrayList<CurvePoint[]> curvePoints;
ArrayList<float[]> curveOpacity;

int     curveRandX = 0; //15;
int     curveRandY = 5; //15;
int     curveRandZ = 5; //15;
int     curveWeight = 1;
Float[] curveOpacities;
float   curveOpacityMin = 0.4;
float   curveOpacityMax = 0.95;
float   curveFadeOutSpeed;

float   attractionToOrigin = 15; 
float   repulseFromMouse   = 25;
float   mouseAffectRadius  = 200;
float   mouseAffectRadiusStore = 400;
boolean fixEndPoints = true;

int     curveTransitionIndex = 0;
int     newTreeLength;
int     oldTreeLength;

//ORIGINAL VERSION
//color  clrA = color(212,  20,  90); //NOTE TO SELF: ARBITRARY, DO WITH LAILA
//color  clrB = color(252, 238,  33);
//color  clrC = color( 41, 171, 226);
//color  clrD = color( 75, 181,  74);

////OPTION 1
//color  clrA = color(0,  255,  255);
//color  clrB = color(49, 49,  146);
//color  clrC = color(140, 198, 63);
//color  clrD = color(158, 0,  93);

////OPTION 2
//color  clrA = color(255,  148,  0);
//color  clrB = color(211, 31,  71);
//color  clrC = color(41, 171, 226);
//color  clrD = color(75, 181,  74);

//OPTION 3
color  clrA = color(252,  238,  33);
color  clrB = color(0, 255,  255);
color  clrC = color(102, 45, 145);
color  clrD = color(140, 198,  63);

color  curveClr1;
color  curveClr2;


void initCurves(){
  curveFadeOutSpeed = curveOpacityMin/(curveTimer/60.0);

  curveClr1 = clrA;
  curveClr2 = clrB;
  
  curveSetStartPoint = new PVector(0, 0, 0); //random(0,height)); //NOTE TO SELF: make more generic variables, also expand capability to start drawing from other edges.
  curveSetRot = 0;

  generateCurveSet(segmentMaxLength, curveSetRot, curveSetStartPoint, numGenerations, particleSpeed, particleSize, particleTrailSize); //segement length, rotation, starting point, gen limit, particleSpeed, particleSize, particleTrailSize
  regenerateCurveSet(segmentMaxLength, curveSetRot, curveSetStartPoint, numGenerations);
  newTreeLength = curvesToSave.size();
  oldTreeLength = curves.size();
  println("generated old tree: " + oldTreeLength);
  println("generated new tree: " + newTreeLength);
}

void generateCurveSet(float _startLength, float _startRotation, PVector _startPoint, int _generationLimit, float _particleSpeed, float _particleSize, int _particleTrailSize){
  generationLimit = _generationLimit;
  points = new ArrayList[generationLimit];
  curvesToSave = new ArrayList<ArrayList<PVector>>();
  counter = 0;
  
  for(int i=0; i<generationLimit; i++){
    points[i] = new ArrayList<Segment>();
  }
  
  segment(_startLength, _startRotation, segmentMaxRotZ, _startPoint, 0);
  
  findLastSegment(points[0].get(0).p2, 1, 0);
  reversePointArray();
  addPointRandomization();
  
  knots = new ArrayList<float[][]>();
  curves = new ArrayList<AUCurve>();
  particles = new ArrayList<Particle>();
  curvePoints = new ArrayList<CurvePoint[]>();
  curveOpacity = new ArrayList<float[]>();
  
  for(int i=0; i<curvesToSave.size(); i++){
    knots.add(new float[curvesToSave.get(i).size()+2][3]);
    curvePoints.add(new CurvePoint[curvesToSave.get(i).size()+2]);
    
    createKnots(i);
    createCurvePoints(i);
    
    curves.add(new AUCurve(knots.get(i),3,false));
    particles.add(new Particle(_particleSpeed, i, _particleSize, _particleTrailSize)); //float _tStep, int _idNr, float _minSize, float _maxSize, int _trail
    curveOpacity.add(new float[2]);
    curveOpacity.get(i)[0] = curveOpacityMin;
    curveOpacity.get(i)[1] = 0;
  }
}

void regenerateCurveSet(float _startLength, float _startRotation, PVector _startPoint, int _generationLimit){
  generationLimit = _generationLimit;
  points = new ArrayList[generationLimit];
  curvesToSave.clear();
  counter = 0;
  
  for(int i=0; i<generationLimit; i++){
    points[i] = new ArrayList<Segment>();
  }
  
  segment(_startLength, _startRotation, segmentMaxRotZ, _startPoint, 0);
  findLastSegment(points[0].get(0).p2, 1, 0);
  reversePointArray();
  addPointRandomization();
  
  curveOpacity.get(0)[1] = 1.0;
}


/////////////////
/*DISPLAY CURVES*/
/////////////////

void renderCurves(){ 
  for(int i=0; i<knots.size(); i++) {
    float f1 = map(i, 0, knots.size(), 0,1);
    float f2 = map(i, 0, knots.size(), 1,0);
    
    //float r = f1*red(cpL1.getColorValue()) + f2*red(cpL2.getColorValue());
    //float g = f1*green(cpL1.getColorValue()) + f2*green(cpL2.getColorValue());
    //float b = f1*blue(cpL1.getColorValue()) + f2*blue(cpL2.getColorValue());    
    
    float r = f1*red(curveClr1) + f2*red(curveClr2);
    float g = f1*green(curveClr1) + f2*green(curveClr2);
    float b = f1*blue(curveClr1) + f2*blue(curveClr2);    
    
    if(curveOpacity.get(i)[1] == 1){ //phase out
        curveOpacity.get(i)[0] -= curveFadeOutSpeed;
    } else if(curveOpacity.get(i)[1] == 0) { //normal
      if(curveOpacity.get(i)[0]>curveOpacityMin){
        curveOpacity.get(i)[0] -= curveFadeOutSpeed;
      } else {
        curveOpacity.get(i)[0] += curveFadeOutSpeed;
      }
    }
    float a = constrain(255*curveOpacity.get(i)[0], 0, 255);
    
    stroke(r,g,b,a);
    strokeWeight(curveWeight);
    noFill();

      beginShape();
      for (int j=0; j<knots.get(i).length; j++) {
        int x = j % knots.get(i).length;
        float x1 = knots.get(i)[x][0];
        float y1 = knots.get(i)[x][1];
        float z1 = knots.get(i)[x][2];
 
        curveVertex(x1, y1, z1); 
      }
      endShape();
    
    pushMatrix();
    noStroke();
    fill(r,g,b,a);
    translate(knots.get(i)[knots.get(i).length-1][0],knots.get(i)[knots.get(i).length-1][1], knots.get(i)[knots.get(i).length-1][2]);
    ellipse(0,0,1,1);
    popMatrix();
   } 
}

void updateCurveColors(){
  float f1;
  float f2;
  float r;
  float g;
  float b;
  
  //map real world time to changing colors
  //currently mapping days of the month 1-15 color change one direction, 16-31 color changes other direction
  if(day()<16){
    f1 = map(day(), 1, 15, 0.0, 1.0);
    f2 = map(day(), 1, 15, 1.0, 0.0);
  } else {
    f1 = map(day(), 16, 31, 1.0, 0.0);
    f2 = map(day(), 16, 31, 0.0, 1.0);
  }
    
  r = f1*red(clrA) + f2*red(clrC);
  g = f1*green(clrA) + f2*green(clrC);
  b = f1*blue(clrA) + f2*blue(clrC);
  
  curveClr1 = color(r,g,b);
  
  r = f1*red(clrB) + f2*red(clrD);
  g = f1*green(clrB) + f2*green(clrD);
  b = f1*blue(clrB) + f2*blue(clrD);
  
  curveClr2 = color(r,g,b);
}
  
//////////////////////////////////////
/* UPDATE CURVES, KNOTS, CURVEPOINTS*/
//////////////////////////////////////
  
  void updateCurves(){
    for(int i=0; i<curvePoints.size(); i++){
      updateKnots(i);
      curves.set(i, new AUCurve(knots.get(i),3,false));
    }
  }
  
  void updateKnots(int nr){  
    for(int i = 1; i<curvePoints.get(nr).length; i++){
      knots.get(nr)[i][0] = curvePoints.get(nr)[i].pos().x;
      knots.get(nr)[i][1] = curvePoints.get(nr)[i].pos().y;
      knots.get(nr)[i][2] = curvePoints.get(nr)[i].pos().z;
    }
  }
  
  void updateCurvePoints(){
    for(int i=0; i<curvePoints.size(); i++) {
      for(int j=0; j<curvePoints.get(i).length; j++){
        curvePoints.get(i)[j].update();
      }
    }
  }

/////////////////////////////////////
/* TRANSITION ONE CURVE SET TO NEXT*/
/////////////////////////////////////

void transitionToNextTree(){
  if(curveTransitionIndex < newTreeLength){
    if(curveTransitionIndex < oldTreeLength){
      replaceExistingCurve();
      curveTransitionIndex++;
    } else {
      createNewCurve();
      curveTransitionIndex++;
    }
  } else if(curveTransitionIndex < oldTreeLength){
    if(knots.size()>newTreeLength){
      removeExcessCurve();
      curveTransitionIndex++;
    } else {
      prepNextTree();
    }
  } else {
    prepNextTree();
  }
}

void replaceExistingCurve(){
  knots.set(curveTransitionIndex, new float[curvesToSave.get(curveTransitionIndex).size()+2][3]);
  curvePoints.set(curveTransitionIndex, new CurvePoint[curvesToSave.get(curveTransitionIndex).size()+2]);
  
  createKnots(curveTransitionIndex);
  createCurvePoints(curveTransitionIndex);
  
  curves.set(curveTransitionIndex, new AUCurve(knots.get(curveTransitionIndex),3,false));
  
  curveOpacity.get(curveTransitionIndex)[1] = 0;
  if(curveTransitionIndex+1 < curveOpacity.size()) curveOpacity.get(curveTransitionIndex+1)[1] = 1;
}

void createNewCurve(){
  knots.add(new float[curvesToSave.get(curveTransitionIndex).size()+2][3]);
  curvePoints.add(new CurvePoint[curvesToSave.get(curveTransitionIndex).size()+2]);
  
  createKnots(curveTransitionIndex);
  createCurvePoints(curveTransitionIndex);
  
  curves.add(new AUCurve(knots.get(curveTransitionIndex),3,false));
  particles.add(new Particle(particleSpeed, curveTransitionIndex, particleSize, particleTrailSize));
  curveOpacity.add(new float[2]);
  curveOpacity.get(curveTransitionIndex)[0] = 0.0;
  curveOpacity.get(curveTransitionIndex)[1] = 0.0;
}

void removeExcessCurve(){
  int lastItem = knots.size()-1;
      
  knots.remove(lastItem);
  curvePoints.remove(lastItem);
  curves.remove(lastItem);
  particles.remove(lastItem);
  curveOpacity.remove(lastItem);
  if(lastItem-1 < curveOpacity.size()) curveOpacity.get(lastItem-1)[1] = 1;
}

void prepNextTree(){
  curveSetStartPoint = new PVector(0, 0, 0); //NOTE TO SELF: make more generic variables, also expand capability to start drawing from other edges.
  //segmentMinRot = -50;
  //segmentMaxRot = 50;
  curveSetRot = 0;
  
  //segmentMinRot = (int)map(curveSetStartPoint.y, height, 0, -80.0, 20.0); //NOTE TO SELF: make more generic variables
  //segmentMaxRot = (int)map(curveSetStartPoint.y, height, 0, -20.0, 80.0); //NOTE TO SELF: make more generic variables
  //curveSetRot = (int)map(curveSetStartPoint.y, height, 0, -50, 50);
  
  regenerateCurveSet(segmentMaxLength, curveSetRot, curveSetStartPoint, numGenerations);  
  newTreeLength = curvesToSave.size();
  oldTreeLength = curves.size();
  curveTransitionIndex=0;
}

  
///////////////////////////////////////////////
/* GENERATE TREE AND CONVERT TO SET OF POINTS*/
///////////////////////////////////////////////
  
  void segment(float _segmentLength, float _segmentRotation, float _rotZ, PVector _prevPoint, int _generation) {
    PVector point = new PVector();
    
    point.x = cos(radians(_segmentRotation))*cos(radians(_rotZ));
    point.y = sin(radians(_segmentRotation));
    point.z = cos(radians(_segmentRotation))*sin(radians(_rotZ));
    point.mult(_segmentLength);
    point.add(_prevPoint);
    points[_generation].add(new Segment(_prevPoint, point)); 
    
    _generation += 1;
    float tmp = random(-segmentMaxRot,segmentMaxRot);
    _segmentRotation+=tmp;
    
    if(_generation<generationLimit) {
      int branches = floor(random(minBranches, maxBranches));
      for(int i=0; i<branches; i++){

        if(_generation==generationLimit-1){
          _rotZ += random(-segmentMaxRotZ,segmentMaxRotZ);//segmentMaxRotZ/2,segmentMaxRotZ);
          segment(_segmentLength*random(0.3, 0.4), _segmentRotation, _rotZ, point, _generation);
        } else {
          if(i==0){
            _rotZ += random(-segmentMaxRotZ/4,segmentMaxRotZ); //segmentMaxRotZ/2,segmentMaxRotZ);
            segment(_segmentLength*random(0.7, 0.9), _segmentRotation, _rotZ, point, _generation);
          } else if(i==1){
            _rotZ += random(-segmentMaxRotZ,segmentMaxRotZ);
            segment(_segmentLength*random(0.5, 0.7), (_segmentRotation+random(segmentMaxRotY,segmentMaxRotY*2)), _rotZ, point, _generation);
          } else if(i==2){
            _rotZ += random(-segmentMaxRotZ,segmentMaxRotZ);
            segment(_segmentLength*random(0.5, 0.7), (_segmentRotation-random(segmentMaxRotY,segmentMaxRotY*2)), _rotZ, point, _generation);
          } else if(i>2){
            _rotZ += random(-segmentMaxRotZ,segmentMaxRotZ);
            segment(_segmentLength*random(0.5, 0.7), (_segmentRotation-random(-segmentMaxRotY,segmentMaxRotY*2)), _rotZ, point, _generation);
          }
        }
      }
    }   
  }
  
  void findLastSegment(PVector prevP2, int generation, int prevArrayPos){
    int count=0;
    
    if(generation>=generationLimit) return;
    
    for(int i=0; i<points[generation].size(); i++){
      if(points[generation].get(i).p1 == prevP2 && generation<generationLimit-1){
        //NOT LAST SEGMENT, CHECK NEXT GEN
        int tmp = generation+1;
        findLastSegment(points[generation].get(i).p2, tmp, i);
        count++;
      } else if(points[generation].get(i).p1 == prevP2 && generation == generationLimit-1) {
        //FOUND LAST SEGMENT --> LAST GENERATION
        curvesToSave.add( new ArrayList<PVector>());
        createList(points[generation].get(i).p2,generation);
        count++;
        counter++;
      }
    }
    
    if(count==0){
      //FOUND LAST SEGMENT --> PREV POINT
        curvesToSave.add( new ArrayList<PVector>());
        createList(points[generation].get(prevArrayPos).p2,generation);
        counter++;
    }
  }
  
  void createList(PVector p2,int generation){
    if(generation == -1)
    {   
      curvesToSave.get(counter).add(points[0].get(0).p1);
      return;
    }
    curvesToSave.get(counter).add(p2);
    
    for(int i=0;i<points[generation].size();i++)
    {
      if(p2 == points[generation].get(i).p2)
      {
        createList(points[generation].get(i).p1,generation-1);
      }
    }
  }
  
  void reversePointArray(){
    for(int i=0; i<curvesToSave.size(); i++){
      PVector pointsReversed[] = curvesToSave.get(i).toArray(new PVector[curvesToSave.get(i).size()]);
      pointsReversed = (PVector[])reverse(pointsReversed);
      
      for(int j=0;j<pointsReversed.length;j++){
        curvesToSave.get(i).set(j, pointsReversed[j]);
      }
    }
  }
  
  void addPointRandomization(){
    for(int i=0; i<curvesToSave.size(); i++){
      for(int j=0;j<curvesToSave.get(i).size();j++){
        curvesToSave.get(i).set(j, new PVector(curvesToSave.get(i).get(j).x + random(0,curveRandX), 
                                               curvesToSave.get(i).get(j).y + random(0,curveRandY),
                                               curvesToSave.get(i).get(j).z + random(0,curveRandZ)));
      }
    }
  }
  

  
/////////////////////////////////////////////////
/* CONVERT SET OF POINTS TO KNOTS, CURVEPOINTS*/
/////////////////////////////////////////////////
  
  void createKnots(int nr){  
    //duplicate first point
    knots.get(nr)[0][0] = curvesToSave.get(nr).get(0).x;
    knots.get(nr)[0][1] = curvesToSave.get(nr).get(0).y;
    knots.get(nr)[0][2] = curvesToSave.get(nr).get(0).z;

    //transfer all curve points
    for(int i = 1; i<curvesToSave.get(nr).size()+1; i++){
      knots.get(nr)[i][0] = curvesToSave.get(nr).get(i-1).x;
      knots.get(nr)[i][1] = curvesToSave.get(nr).get(i-1).y;
      knots.get(nr)[i][2] = curvesToSave.get(nr).get(i-1).z;
    }
    
    //duplicate last point
    knots.get(nr)[curvesToSave.get(nr).size()+1][0] = curvesToSave.get(nr).get(curvesToSave.get(nr).size()-1).x;
    knots.get(nr)[curvesToSave.get(nr).size()+1][1] = curvesToSave.get(nr).get(curvesToSave.get(nr).size()-1).y;
    knots.get(nr)[curvesToSave.get(nr).size()+1][2] = curvesToSave.get(nr).get(curvesToSave.get(nr).size()-1).z;
  }
  
  void createCurvePoints(int nr){ 
    //duplicate first point
    curvePoints.get(nr)[0] = new CurvePoint(new PVector(curvesToSave.get(nr).get(0).x,curvesToSave.get(nr).get(0).y, curvesToSave.get(nr).get(0).z), false);
    
    //transfer all curve points
    for(int i = 1; i<curvesToSave.get(nr).size()+1; i++){
      if(i==1){
        curvePoints.get(nr)[i] = new CurvePoint(new PVector(curvesToSave.get(nr).get(i-1).x,curvesToSave.get(nr).get(i-1).y, curvesToSave.get(nr).get(i-1).z), false);
      } else {
        curvePoints.get(nr)[i] = new CurvePoint(new PVector(curvesToSave.get(nr).get(i-1).x,curvesToSave.get(nr).get(i-1).y, curvesToSave.get(nr).get(i-1).z), true);
      }
    }
    
    //duplicate last point
    curvePoints.get(nr)[curvesToSave.get(nr).size()+1] = new CurvePoint(new PVector(curvesToSave.get(nr).get(curvesToSave.get(nr).size()-1).x,curvesToSave.get(nr).get(curvesToSave.get(nr).size()-1).y, curvesToSave.get(nr).get(curvesToSave.get(nr).size()-1).z), true);
  }
  
  
