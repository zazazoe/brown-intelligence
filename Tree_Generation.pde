
int generationLimit;
ArrayList<Segment>[] points;
ArrayList<ArrayList<PVector>> linesToSave;
int counter;

Point point;

ArrayList<float[][]> knots;
ArrayList<AUCurve> curves;
ArrayList<Point> particles;

ArrayList<CurvePoint[]> curvePoints;

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
  
  knots = new ArrayList<float[][]>();
  curves = new ArrayList<AUCurve>();
  particles = new ArrayList<Point>();
  curvePoints = new ArrayList<CurvePoint[]>();
  
  for(int i=0; i<linesToSave.size(); i++){
    knots.add(new float[linesToSave.get(i).size()+2][2]);
    curvePoints.add(new CurvePoint[linesToSave.get(i).size()+2]);
    
    fillKnots(i);
    fillCurvePoints(i);
    
    curves.add(new AUCurve(knots.get(i),2,false));
    particles.add(new Point(_particleSpeed, i, _particleSize, _particleSize, _particleTrailSize)); //float _tStep, int _idNr, float _minSize, float _maxSize, int _trail //<>//
  }

}

void segment(float _segmentLength, float _segmentRotation, PVector _prevPoint, int _generation) {
    PVector point = new PVector();
    
    point.x = cos(radians(_segmentRotation));
    point.y = sin(radians(_segmentRotation));
    
    point.mult(_segmentLength);
    point.add(_prevPoint);
    
    //line(_prevPoint.x, _prevPoint.y, point.x, point.y);
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
    //println("//" + i + "//");
    
    PVector pointsReversed[] = linesToSave.get(i).toArray(new PVector[linesToSave.get(i).size()]);
    pointsReversed = (PVector[])reverse(pointsReversed);
    
    for(int j=0;j<pointsReversed.length;j++){
      linesToSave.get(i).set(j, pointsReversed[j]);
      //print(linesToSave.get(i).get(j) + ",");
    }
    //println(); 
  }
}

void render(){
    for(int i=0; i<linesToSave.size(); i++) {
      //stroke((100/(i+1))*linesToSave.size(),0,(200/linesToSave.size())*i);
      stroke(80);
      strokeWeight(2);
      noFill();

      for(int j=0; j<linesToSave.get(i).size()-1; j++){
        PVector pt1 = linesToSave.get(i).get(j);
        PVector pt2 = linesToSave.get(i).get(j+1);
        PVector ctrlPt1;
        PVector ctrlPt2;

        if(j-1<0){
          ctrlPt1 = linesToSave.get(i).get(j);
        } else {
          ctrlPt1 = linesToSave.get(i).get(j-1);
        }
          
        if(j+2>linesToSave.get(i).size()-1){
          ctrlPt2 = linesToSave.get(i).get(j+1);
        } else {
          ctrlPt2 = linesToSave.get(i).get(j+2);
        }

        pt1 = adjustPoint(pt1);
        pt2 = adjustPoint(pt2);
        ctrlPt1 = adjustPoint(ctrlPt1);
        ctrlPt2 = adjustPoint(ctrlPt2);
        
        noFill();
        curve(ctrlPt1.x, ctrlPt1.y, pt1.x, pt1.y, pt2.x, pt2.y, ctrlPt2.x, ctrlPt2.y);
      }
    }
  }
  
  void renderCrvPt(){ 
    for(int i=0; i<curvePoints.size(); i++) {
      for(int j=0; j<curvePoints.get(i).length; j++){
        curvePoints.get(i)[j].update();
      }
    }
    
    for(int i=0; i<curvePoints.size(); i++) {
      //stroke((100/(i+1))*linesToSave.size(),0,(200/linesToSave.size())*i);
      stroke(80);
      strokeWeight(2);
      noFill();

      for(int j=1; j<curvePoints.get(i).length-2; j++){
        PVector ctrlPt1 = curvePoints.get(i)[j-1].pos();
        PVector pt1 = curvePoints.get(i)[j].pos();
        PVector pt2 = curvePoints.get(i)[j+1].pos();
        PVector ctrlPt2 = curvePoints.get(i)[j+2].pos();

        curve(ctrlPt1.x, ctrlPt1.y, pt1.x, pt1.y, pt2.x, pt2.y, ctrlPt2.x, ctrlPt2.y);
      }
    }
  }
  
  PVector adjustPoint(PVector point){
    //float dist = point.dist(new PVector(mouseX, mouseY));
    PVector tmp = new PVector(point.x,point.y);
    
    float distX = point.x - mouseFollowerX;
    float distY = point.y - height/2;
    
    if(distY <=0 && abs(distX)<50) {
      tmp.y = point.y + map(abs(distX), 0, 50, -50, 0);
    } else if(distY >0 && abs(distX)<50) {
      tmp.y = point.y + map(abs(distX), 0, 50, 50, 0);
    }
    
    //if(dist>0){
    //  tmp.y = point.y + map(dist, 0, 50, 50, 0);
    //} else if(dist<=0) {
    //  tmp.y = point.y + map(dist, 0, -50, -50, 0);
    //}
     
    return tmp;
  }
  
  void fillKnots(int nr){  
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
  
  void fillCurvePoints(int nr){ 
    //duplicate first point
    curvePoints.get(nr)[0] = new CurvePoint(new PVector(linesToSave.get(nr).get(0).x,linesToSave.get(nr).get(0).y));
    
    //transfer all curve points
    for(int i = 1; i<linesToSave.get(nr).size()+1; i++){
      curvePoints.get(nr)[i] = new CurvePoint(new PVector(linesToSave.get(nr).get(i-1).x,linesToSave.get(nr).get(i-1).y));
    }
    
    //duplicate last point
    curvePoints.get(nr)[linesToSave.get(nr).size()+1] = new CurvePoint(new PVector(linesToSave.get(nr).get(linesToSave.get(nr).size()-1).x,linesToSave.get(nr).get(linesToSave.get(nr).size()-1).y));
  }
