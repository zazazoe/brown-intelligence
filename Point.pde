class Point{

  float t;
  float tPos;
  float tStep;
  EquiCurve curve;
  float minSize;
  float maxSize;
  float size;
  int trail;
  
  PVector pos;
  ArrayList<PVector> history;

  //speed defined by stepsize so smaller nr is faster, bigger nr is slower
  Point(float sp, EquiCurve c, float minS, float maxS, int tr){   
    t=0.0;
    tPos = t;
    curve = c;
    minSize = minS;
    maxSize = maxS;
    tStep = sp;
    trail = tr;
    
    pos = new PVector(0,0);
    history = new ArrayList<PVector>();
  }
  
  void update() {
    //calculate position
    tPos += tStep;
    if (tPos > PI || tPos < 0){
      tStep = tStep*-1;
      tPos += tStep;
    }
    
    float tmp = cos(tPos);
    t = map(tmp, 1.0, -1.0, 0.0, 1.0);
    
    //pos = curve.pointAtFraction(t);
    pos.x = myCurve.getX(t);
    pos.y = myCurve.getY(t);
    
    //calculate size
    size = map(abs(tmp), 1.0, 0.0, minSize, maxSize);  
    
    //add trail
    history.add(new PVector(pos.x,pos.y));
    
    if(history.size() > trail) {
      history.remove(0);
    }
  }
  
  void display() {
    fill(255,0,255);
    noStroke();
    
    float stepSize = 255/trail;
    float brightness = stepSize;
    
    //DRAW points  
    for(int i=0; i<history.size(); i++){
      fill(255,0,255,brightness);
      ellipse(history.get(i).x,history.get(i).y,size,size);
      brightness += stepSize;
    }
    //ellipse(pos.x, pos.y, size, size);
  }
}
