class Point{

  float t;
  float tPos;
  float tStep;
  float minSize;
  float maxSize;
  float size;
  int trail;
  int idNr;
  
  PVector pos;
  ArrayList<PVector> history;
  Float[][] tPosses;
  PVector[] positions;

  //speed defined by stepsize so smaller nr is faster, bigger nr is slower
  Point(float _tStep, int _idNr, float _minSize, float _maxSize, int _trail){   
    t=0.0;
    tPos = random(0.0, PI);
    
    idNr = _idNr;
    minSize = _minSize;
    maxSize = _maxSize;
    tStep = _tStep * ((int)random(0,2)* 2 -1);
    trail = _trail;
    
    pos = new PVector(0,0);
    history = new ArrayList<PVector>();
    tPosses = new Float[trail][2];
    positions = new PVector[trail];
    
    for(int i=0; i<trail; i++){
      tPosses[i][0] = random(0.0, PI);
      tPosses[i][1] = _tStep * ((int)random(0,2)* 2 -1);
      positions[i] = new PVector(0,0);
    }
  }
  
  void update() {
    //calculate position
    
    for(int i=0; i<tPosses.length; i++){
      tPosses[i][0] += tPosses[i][1]; //add tstep to tpos
      if (tPosses[i][0] > PI || tPosses[i][0] < 0){
        tPosses[i][1] = tPosses[i][1]*-1;
        tPosses[i][0] += tPosses[i][1];
      }
      
      float tmp = cos(tPosses[i][0]);
      t = map(tmp, 1.0, -1.0, 0.0, 1.0);
      
      pos.x = curves.get(idNr).getX(t);
      pos.y = curves.get(idNr).getY(t);
      
      //size = map(t, 0.0, 1.0, 3.0, maxSize);
      size = maxSize;
      
      positions[i] = new PVector(pos.x,pos.y);
    }
    //tPos += tStep;
    //if (tPos > PI || tPos < 0){
    //  tStep = tStep*-1;
    //  tPos += tStep;
    //}
    
    //float tmp = cos(tPos);
    //t = map(tmp, 1.0, -1.0, 0.0, 1.0);
    
    //pos.x = curves.get(idNr).getX(t);
    //pos.y = curves.get(idNr).getY(t);
    
    ////calculate size
    ////size = map(abs(tmp), 1.0, 0.0, minSize, maxSize);  
    //size = map(t, 0.0, 1.0, 3.0, particleSize);
    
    ////add trail
    //history.add(new PVector(pos.x,pos.y));
    
    //if(history.size() > trail) {
    //  history.remove(0);
    //}
  }
  
  void display(color c) {
    noStroke();
    
    //float stepSize = 255/trail;
    //float brightness = stepSize;
    
    //DRAW points  
    //for(int i=0; i<history.size(); i++){
    //  fill(c,brightness);
    //  ellipse(history.get(i).x,history.get(i).y,size,size);
    //  brightness += stepSize;
    //}
    
    for(int i=0; i<positions.length; i++){
      fill(c);
      ellipse(positions[i].x,positions[i].y,size,size);
      //brightness += stepSize;
    }
  }
  
  void reset(float _t){
    //t = _t;
    //tPos = _t; 
    
    for(int i=0; i<tPosses.length; i++){
      tPosses[i][0] = _t;
    }
  }
  
  void disperse(){
    tStep = tStep * ((int)random(0,2)* 2 -1);
    tPos = random(0,PI);
    
    for(int i=0; i<tPosses.length; i++){
      tPosses[i][0] = random(0,PI);
      tPosses[i][1] = tStep * ((int)random(0,2)* 2 -1);
    }
  }
}
