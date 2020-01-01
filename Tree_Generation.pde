
int generationLimit;
ArrayList<Segment>[] points;
ArrayList<ArrayList<PVector>> linesToSave;
int counter;

Point point;

ArrayList<float[][]> knots;
ArrayList<AUCurve> curves;
ArrayList<Point> particles;

void generateTree(float _startLength, float _startRotation, PVector _startPoint, int _generationLimit){
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
  render();
  
  knots = new ArrayList<float[][]>();
  curves = new ArrayList<AUCurve>();
  particles = new ArrayList<Point>();
  
  for(int i=0; i<linesToSave.size(); i++){
    knots.add(new float[linesToSave.get(i).size()+2][2]);
    fillKnots(i);
    curves.add(new AUCurve(knots.get(i),2,false));
    particles.add(new Point(0.015, i, 4.0, 8.0, 10)); //<>//
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
      
      int tmp = floor(random(1,4));

      for(int i=0; i<tmp; i++){
         segment(map(_generation, 0, generationLimit, 100, 25), random(-150,-30), point, _generation);
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
      stroke(255,0,0);
      ellipse(points[generation].get(i).p2.x, points[generation].get(i).p2.y, 5, 5);
      //println("found " + points[generation].get(i).p2);
      linesToSave.add( new ArrayList<PVector>());
      //int prevGeneration = generation-1;
      createList(points[generation].get(i).p2,generation);
      count++;
      counter++;
    }
  }
  
  if(count==0){
    //FOUND LAST SEGMENT --> PREV POINT
      linesToSave.add( new ArrayList<PVector>());
      stroke(255,0,0);
      ellipse(prevP2.x, prevP2.y, 5, 5);
      //println("found " + prevP2);
      //int prevGeneration = generation-1;
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
    println("//" + i + "//");
    
    PVector pointsReversed[] = linesToSave.get(i).toArray(new PVector[linesToSave.get(i).size()]);
    pointsReversed = (PVector[])reverse(pointsReversed);
    
    for(int j=0;j<pointsReversed.length;j++){
      linesToSave.get(i).set(j, pointsReversed[j]);
      print(linesToSave.get(i).get(j) + ",");
    }
    println(); 
  }
}

void render(){
    for(int i=0; i<linesToSave.size(); i++) {
      stroke((100/(i+1))*linesToSave.size(),0,(200/linesToSave.size())*i);
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
          
        curve(ctrlPt1.x, ctrlPt1.y, pt1.x, pt1.y, pt2.x, pt2.y, ctrlPt2.x, ctrlPt2.y);
      }
    }
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
