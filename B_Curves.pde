
float   curveSetRot = 0;
PVector curveSetStartPoint;
int     numGenerations = 4;
int     minBranches = 1;
int     maxBranches = 3;
float   segmentMinLength = 75;
float   segmentMaxLength = 200;
int     segmentMinRot = -50;
int     segmentMaxRot = 50;

int     generationLimit;
ArrayList<Segment>[] points;
ArrayList<ArrayList<PVector>> curvesToSave;
int     counter;

ArrayList<float[][]> knots;
ArrayList<AUCurve> curves;
ArrayList<Particle> particles;
ArrayList<CurvePoint[]> curvePoints;
ArrayList<float[]> curveOpacity;

int     curveRandX = 10;
int     curveRandY = 20;
int     curveWeight = 3;
Float[] curveOpacities;
float   curveOpacityMin = 0.8; //DOESN'T BEHAVE AS SHOULD, CHECK OUT
float   curveFadeOutSpeed;

float   attractionToOrigin = 15; 
float   repulseFromMouse   = 25;
float   mouseAffectRadius  = 200;
float   mouseAffectRadiusStore = 400;
boolean fixEndPoints = true;

int     curveTransitionIndex = 0;
int     newTreeLength;
int     oldTreeLength;


void initCurves(){
  curveFadeOutSpeed = curveOpacityMin/(curveTimer/60.0);
  
  curveSetStartPoint = new PVector(0, random(0,height)); //NOTE TO SELF: make more generic variables, also expand capability to start drawing from other edges.
  segmentMinRot = (int)map(curveSetStartPoint.y, height, 0, -80.0, 20.0); //NOTE TO SELF: make more generic variables
  segmentMaxRot = (int)map(curveSetStartPoint.y, height, 0, -20.0, 80.0); //NOTE TO SELF: make more generic variables
  curveSetRot = (int)map(curveSetStartPoint.y, height, 0, -50, 50);
  
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
  
  segment(_startLength, _startRotation, _startPoint, 0);
  findLastSegment(points[0].get(0).p2, 1, 0);
  reversePointArray();
  addPointRandomization();
  
  knots = new ArrayList<float[][]>();
  curves = new ArrayList<AUCurve>();
  particles = new ArrayList<Particle>();
  curvePoints = new ArrayList<CurvePoint[]>();
  curveOpacity = new ArrayList<float[]>();
  
  for(int i=0; i<curvesToSave.size(); i++){
    knots.add(new float[curvesToSave.get(i).size()+2][2]);
    curvePoints.add(new CurvePoint[curvesToSave.get(i).size()+2]);
    
    createKnots(i);
    createCurvePoints(i);
    
    curves.add(new AUCurve(knots.get(i),2,false));
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
  
  segment(_startLength, _startRotation, _startPoint, 0);
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
    
    float r = f1*red(cpL1.getColorValue()) + f2*red(cpL2.getColorValue());
    float g = f1*green(cpL1.getColorValue()) + f2*green(cpL2.getColorValue());
    float b = f1*blue(cpL1.getColorValue()) + f2*blue(cpL2.getColorValue());    
    if(curveOpacity.get(i)[1] == 1){ //phase out
        curveOpacity.get(i)[0] -= curveFadeOutSpeed;
    } else if(curveOpacity.get(i)[1] == 0) { //normal
      if(curveOpacity.get(i)[0]>curveOpacityMin){
        curveOpacity.get(i)[0] -= curveFadeOutSpeed;
      } else {
        curveOpacity.get(i)[0] += curveFadeOutSpeed;
      }
    }
    float a = 255*curveOpacity.get(i)[0];
    
    stroke(r,g,b,a);
    strokeWeight(curveWeight);
    noFill();
    
    pushMatrix();
    translate(0,0,z1);
      beginShape();
      for (int j=0; j<knots.get(i).length; j++) {
        int x = j % knots.get(i).length;
        float x1 = knots.get(i)[x][0];
        float y1 = knots.get(i)[x][1];

          curveVertex(x1, y1);
         
      }
      endShape();
    popMatrix();
   } 
}


  
//////////////////////////////////////
/* UPDATE CURVES, KNOTS, CURVEPOINTS*/
//////////////////////////////////////
  
  void updateCurves(){
    for(int i=0; i<curvePoints.size(); i++){
      updateKnots(i);
      curves.set(i, new AUCurve(knots.get(i),2,false));
    }
  }
  
  void updateKnots(int nr){  
    for(int i = 1; i<curvePoints.get(nr).length; i++){
      knots.get(nr)[i][0] = curvePoints.get(nr)[i].pos().x;
      knots.get(nr)[i][1] = curvePoints.get(nr)[i].pos().y;
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
  knots.set(curveTransitionIndex, new float[curvesToSave.get(curveTransitionIndex).size()+2][2]);
  curvePoints.set(curveTransitionIndex, new CurvePoint[curvesToSave.get(curveTransitionIndex).size()+2]);
  
  createKnots(curveTransitionIndex);
  createCurvePoints(curveTransitionIndex);
  
  curves.set(curveTransitionIndex, new AUCurve(knots.get(curveTransitionIndex),2,false));
  
  curveOpacity.get(curveTransitionIndex)[1] = 0;
  if(curveTransitionIndex+1 < curveOpacity.size()) curveOpacity.get(curveTransitionIndex+1)[1] = 1;
}

void createNewCurve(){
  knots.add(new float[curvesToSave.get(curveTransitionIndex).size()+2][2]);
  curvePoints.add(new CurvePoint[curvesToSave.get(curveTransitionIndex).size()+2]);
  
  createKnots(curveTransitionIndex);
  createCurvePoints(curveTransitionIndex);
  
  curves.add(new AUCurve(knots.get(curveTransitionIndex),2,false));
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
  curveSetStartPoint = new PVector(0, random(0,height)); //NOTE TO SELF: make more generic variables, also expand capability to start drawing from other edges.
  segmentMinRot = (int)map(curveSetStartPoint.y, height, 0, -80.0, 20.0); //NOTE TO SELF: make more generic variables
  segmentMaxRot = (int)map(curveSetStartPoint.y, height, 0, -20.0, 80.0); //NOTE TO SELF: make more generic variables
  curveSetRot = (int)map(curveSetStartPoint.y, height, 0, -50, 50);
  
  regenerateCurveSet(segmentMaxLength, curveSetRot, curveSetStartPoint, numGenerations);  
  newTreeLength = curvesToSave.size();
  oldTreeLength = curves.size();
  curveTransitionIndex=0;
}

  
///////////////////////////////////////////////
/* GENERATE TREE AND CONVERT TO SET OF POINTS*/
///////////////////////////////////////////////
  
  void segment(float _segmentLength, float _segmentRotation, PVector _prevPoint, int _generation) {
    PVector point = new PVector();
    
    point.x = cos(radians(_segmentRotation));
    point.y = sin(radians(_segmentRotation));
    point.mult(_segmentLength);
    point.add(_prevPoint);
    
    points[_generation].add(new Segment(_prevPoint, point)); 
    _generation += 1;
    
    if(_generation<generationLimit) {
      int tmp = floor(random(minBranches, maxBranches));
      for(int i=0; i<tmp; i++){
         segment(map(_generation, 0, generationLimit, segmentMaxLength, segmentMinLength), random(segmentMinRot, segmentMaxRot), point, _generation);
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
                                              curvesToSave.get(i).get(j).y + random(0,curveRandY)));
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

    //transfer all curve points
    for(int i = 1; i<curvesToSave.get(nr).size()+1; i++){
      knots.get(nr)[i][0] = curvesToSave.get(nr).get(i-1).x;
      knots.get(nr)[i][1] = curvesToSave.get(nr).get(i-1).y;
    }
    
    //duplicate last point
    knots.get(nr)[curvesToSave.get(nr).size()+1][0] = curvesToSave.get(nr).get(curvesToSave.get(nr).size()-1).x;
    knots.get(nr)[curvesToSave.get(nr).size()+1][1] = curvesToSave.get(nr).get(curvesToSave.get(nr).size()-1).y;
  }
  
  void createCurvePoints(int nr){ 
    //duplicate first point
    curvePoints.get(nr)[0] = new CurvePoint(new PVector(curvesToSave.get(nr).get(0).x,curvesToSave.get(nr).get(0).y), false);
    
    //transfer all curve points
    for(int i = 1; i<curvesToSave.get(nr).size()+1; i++){
      if(i==1){
        curvePoints.get(nr)[i] = new CurvePoint(new PVector(curvesToSave.get(nr).get(i-1).x,curvesToSave.get(nr).get(i-1).y), false);
      } else {
        curvePoints.get(nr)[i] = new CurvePoint(new PVector(curvesToSave.get(nr).get(i-1).x,curvesToSave.get(nr).get(i-1).y), true);
      }
    }
    
    //duplicate last point
    curvePoints.get(nr)[curvesToSave.get(nr).size()+1] = new CurvePoint(new PVector(curvesToSave.get(nr).get(curvesToSave.get(nr).size()-1).x,curvesToSave.get(nr).get(curvesToSave.get(nr).size()-1).y), true);
  }
