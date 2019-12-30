
int generationLimit = 3;
ArrayList<Segment>[] points;
ArrayList<ArrayList<PVector>> linesToSave;
int counter = 0;

void setup(){
  size(500,500);
  background(0);
  stroke(255);
  
  points = new ArrayList[generationLimit];
  linesToSave = new ArrayList<ArrayList<PVector>>();
  
  for(int i=0; i<generationLimit; i++){
    points[i] = new ArrayList<Segment>();
  }
  
  segment(100, -90, new PVector(width/2, height), 0);
}


void draw() {
  
}


void segment(float _segmentLength, float _segmentRotation, PVector _prevPoint, int _generation) {
    PVector point = new PVector();
    
    point.x = cos(radians(_segmentRotation));
    point.y = sin(radians(_segmentRotation));
    
    point.mult(_segmentLength);
    point.add(_prevPoint);
    
    line(_prevPoint.x, _prevPoint.y, point.x, point.y);
    points[_generation].add(new Segment(_prevPoint, point));
    
    _generation += 1;
    

    if(_generation<generationLimit) {
      //segment(map(_generation, 0, generationLimit, 100, 25), random(-120,-60), point, _generation);
      
      int tmp = floor(random(1,4));
      //int tmp = 2;
      
      for(int i=0; i<tmp; i++){
         segment(map(_generation, 0, generationLimit, 100, 25), random(-110,-70), point, _generation);
      }
    }   
}

void mousePressed(){
  
  findLastSegment(points[0].get(0).p2, 1, 0);
  //isLastGeneration(points[0].get(0).p2,1);
  printPointArray(); //<>//
}

void printPointArray(){
  //for(int i=0; i<generationLimit; i++){
  //    println("Generation " + i);
  //    for(int j=0; j<points[i].size(); j++){
  //      print("[" + points[i].get(j).p1.x + "," + points[i].get(j).p1.y + "]");
  //      print("[" + points[i].get(j).p2.x + "," + points[i].get(j).p2.y + "], ");
  //    }
  //    println();
  //}
  

  for(int i=0; i<linesToSave.size(); i++){
    println("//" + i + "//");
    reverse(linesToSave.get(i));
    
    for(int j=0;j<linesToSave.get(i).size();j++){
     print(linesToSave.get(i).get(j) + ",");
    }
    println(); 
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


//boolean isLastGeneration(PVector p2, int nextGeneration){
//  if(nextGeneration >= generationLimit-1)
//  {
//    return true;
//  }
//  for(int i =0; i<points[nextGeneration].size();i++)
//  {
//    if(p2 == points[nextGeneration].get(i).p1){
//      if(isLastGeneration(points[nextGeneration].get(i).p2,nextGeneration+1)){
//        linesToSave.add( new ArrayList<Segment>());
//        ellipse(points[nextGeneration].get(i).p2.x,points[nextGeneration].get(i).p2.y,5,5);
//        int prevGeneration = nextGeneration-1;
//        createList(points[nextGeneration].get(i),prevGeneration);
//        counter++;
//      }
//    }
//  }
//  return true;
//}

void createList(PVector p2,int generation){
  //println("prevGen: "+prevGeneration+" count: "+counter);
  if(generation == -1)
  {   
    //println("prevGen must be grater than "+prevGeneration);
    linesToSave.get(counter).add(points[0].get(0).p1);
    return;
  }
  //else if(prevGeneration == 0) {
  //  //linesToSave.get(counter).add(points[0].get(0).p1);
  //  return;
  //}
  linesToSave.get(counter).add(p2);
  
  for(int i=0;i<points[generation].size();i++)
  {
    if(p2 == points[generation].get(i).p2)
    {
      createList(points[generation].get(i).p1,generation-1);
    }
  }
}
