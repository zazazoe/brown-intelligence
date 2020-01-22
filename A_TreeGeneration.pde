
int generationLimit;
ArrayList<Segment>[] points;
ArrayList<ArrayList<PVector>> linesToSave;
int counter;

ArrayList<float[][]> knots;
ArrayList<AUCurve> curves;
ArrayList<Point> particles;
ArrayList<CurvePoint[]> curvePoints;
ArrayList<float[]> curveOpacity;


void generateTree(float _startLength, float _startRotation, PVector _startPoint, int _generationLimit, float _particleSpeed, float _particleSize, int _particleTrailSize){
  generationLimit = _generationLimit;
  points = new ArrayList[generationLimit];
  linesToSave = new ArrayList<ArrayList<PVector>>();
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
  particles = new ArrayList<Point>();
  curvePoints = new ArrayList<CurvePoint[]>();
  curveOpacity = new ArrayList<float[]>();
  
  for(int i=0; i<linesToSave.size(); i++){
    knots.add(new float[linesToSave.get(i).size()+2][2]);
    curvePoints.add(new CurvePoint[linesToSave.get(i).size()+2]);
    
    createKnots(i);
    createCurvePoints(i);
    
    curves.add(new AUCurve(knots.get(i),2,false));
    particles.add(new Point(_particleSpeed, i, _particleSize, _particleTrailSize)); //float _tStep, int _idNr, float _minSize, float _maxSize, int _trail
    curveOpacity.add(new float[2]);
    curveOpacity.get(i)[0] = lineOpacityMin;
    curveOpacity.get(i)[1] = 0;
  }
  
  //lineOpacities = new Float[linesToSave.size()];
  
  //for(int i=0; i<lineOpacities.length; i++){
  //  lineOpacities[i] = lineOpacityMin;
  //}
}

void reGenerateTree(float _startLength, float _startRotation, PVector _startPoint, int _generationLimit){
  generationLimit = _generationLimit;
  points = new ArrayList[generationLimit];
  linesToSave.clear();
  counter = 0;
  
  for(int i=0; i<generationLimit; i++){
    points[i] = new ArrayList<Segment>();
  }
  
  segment(_startLength, _startRotation, _startPoint, 0);
  findLastSegment(points[0].get(0).p2, 1, 0);
  reversePointArray();
  addPointRandomization();
}



void renderCurves(){ 
  for(int i=0; i<knots.size(); i++) {
    float f1 = map(i, 0, knots.size(), 0,1);
    float f2 = map(i, 0, knots.size(), 1,0);
    
    float r = f1*red(cpL1.getColorValue()) + f2*red(cpL2.getColorValue());
    float g = f1*green(cpL1.getColorValue()) + f2*green(cpL2.getColorValue());
    float b = f1*blue(cpL1.getColorValue()) + f2*blue(cpL2.getColorValue());
    //float a = f1*alpha(cpL1.getColorValue()) + f2*alpha(cpL2.getColorValue());
    //lineFadeOutSpeed
    if(curveOpacity.get(i)[1] == 1){ //phase out
        curveOpacity.get(i)[0] -= lineFadeOutSpeed;
    } else if(curveOpacity.get(i)[1] == 0) { //normal
      if(curveOpacity.get(i)[0]>lineOpacityMin){
        curveOpacity.get(i)[0] -= lineFadeOutSpeed;
      } else {
        curveOpacity.get(i)[0] += lineFadeOutSpeed;
      }
    }
    
    float a = 255*curveOpacity.get(i)[0]; //*lineOpacities[i]
    
    stroke(r,g,b,a);
    strokeWeight(lineWeight);
    noFill();

    beginShape();
      for (int j=0; j<knots.get(i).length; j++) {
        int x = j % knots.get(i).length;
        curveVertex(knots.get(i)[x][0], knots.get(i)[x][1]);
      }
    endShape();
   } 
}


  
/////////////////////////////////////////////////
/* UPDATE CURVES, KNOTS, CURVEPOINTS, PARTICLES*/
/////////////////////////////////////////////////
  
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
   
  void updateParticleAmount(int amount) {
    if(particles.size() > amount){
      for(int i=particles.size()-1; i>amount-1; i--){
        particles.remove(i);
      }
    } else if(particles.size() < amount){
      for(int i=particles.size(); i<amount; i++){
        particles.add(new Point(particleSpeed, i, particleSize, particleTrailSize));
      }
    }
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
        linesToSave.add( new ArrayList<PVector>());
        createList(points[generation].get(i).p2,generation);
        count++;
        counter++;
      }
    }
    
    if(count==0){
      //FOUND LAST SEGMENT --> PREV POINT
        linesToSave.add( new ArrayList<PVector>());
        createList(points[generation].get(prevArrayPos).p2,generation);
        counter++;
    }
  }
  
  void createList(PVector p2,int generation){
    if(generation == -1)
    {   
      linesToSave.get(counter).add(points[0].get(0).p1);
      return;
    }
    linesToSave.get(counter).add(p2);
    
    for(int i=0;i<points[generation].size();i++)
    {
      if(p2 == points[generation].get(i).p2)
      {
        createList(points[generation].get(i).p1,generation-1);
      }
    }
  }
  
  void reversePointArray(){
    for(int i=0; i<linesToSave.size(); i++){
      PVector pointsReversed[] = linesToSave.get(i).toArray(new PVector[linesToSave.get(i).size()]);
      pointsReversed = (PVector[])reverse(pointsReversed);
      
      for(int j=0;j<pointsReversed.length;j++){
        linesToSave.get(i).set(j, pointsReversed[j]);
      }
    }
  }
  
  void addPointRandomization(){
    for(int i=0; i<linesToSave.size(); i++){
      for(int j=0;j<linesToSave.get(i).size();j++){
        linesToSave.get(i).set(j, new PVector(linesToSave.get(i).get(j).x + random(0,lineRandX), 
                                              linesToSave.get(i).get(j).y + random(0,lineRandY)));
      }
    }
  }
  

  
/////////////////////////////////////////////////
/* CONVERT SET OF POINTS TO KNOTS, CURVEPOINTS*/
/////////////////////////////////////////////////
  
  void createKnots(int nr){  
    //duplicate first point
    knots.get(nr)[0][0] = linesToSave.get(nr).get(0).x;
    knots.get(nr)[0][1] = linesToSave.get(nr).get(0).y;

    //transfer all curve points
    for(int i = 1; i<linesToSave.get(nr).size()+1; i++){
      knots.get(nr)[i][0] = linesToSave.get(nr).get(i-1).x;
      knots.get(nr)[i][1] = linesToSave.get(nr).get(i-1).y;
    }
    
    //duplicate last point
    knots.get(nr)[linesToSave.get(nr).size()+1][0] = linesToSave.get(nr).get(linesToSave.get(nr).size()-1).x;
    knots.get(nr)[linesToSave.get(nr).size()+1][1] = linesToSave.get(nr).get(linesToSave.get(nr).size()-1).y;
  }
  
  void createCurvePoints(int nr){ 
    //duplicate first point
    curvePoints.get(nr)[0] = new CurvePoint(new PVector(linesToSave.get(nr).get(0).x,linesToSave.get(nr).get(0).y), false);
    
    //transfer all curve points
    for(int i = 1; i<linesToSave.get(nr).size()+1; i++){
      if(i==1){
        curvePoints.get(nr)[i] = new CurvePoint(new PVector(linesToSave.get(nr).get(i-1).x,linesToSave.get(nr).get(i-1).y), false);
      } else {
        curvePoints.get(nr)[i] = new CurvePoint(new PVector(linesToSave.get(nr).get(i-1).x,linesToSave.get(nr).get(i-1).y), true);
      }
    }
    
    //duplicate last point
    curvePoints.get(nr)[linesToSave.get(nr).size()+1] = new CurvePoint(new PVector(linesToSave.get(nr).get(linesToSave.get(nr).size()-1).x,linesToSave.get(nr).get(linesToSave.get(nr).size()-1).y), true);
  }
