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

  boolean burst;
  float bursttPos;
  float bursttStep;
  PVector burstPos;
  float burstSize;
  
  int success;

  //speed defined by stepsize so smaller nr is faster, bigger nr is slower
  Point(float _tStep, int _idNr, float _minSize, float _maxSize, int _trail){   
    t=0.0;
    tPos = 0.0;
    
    idNr = _idNr;
    minSize = _minSize;
    maxSize = _maxSize;
    tStep = _tStep;
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
    
    burst = false;
    bursttPos = 0.0;
    bursttStep = _tStep*5;
    burstPos = new PVector(0,0);
    burstSize = 1.5*_maxSize;
    
    success = (int)random(0,2);
  }
  
  void update() {
    //calculate position
    
    for(int i=0; i<tPosses.length; i++){
      tPosses[i][0] += tPosses[i][1]; //add tstep to tpos
      if (tPosses[i][0] > PI){
        if(success == 1){
          tPosses[i][1] = tPosses[i][1]*-1;
          if(lineOpacities[idNr] < 1.0){
            lineOpacities[idNr] += 0.1;
          }
        } else {
          tPosses[i][0] = 0.0;
          success = (int)random(0,2);
          if(lineOpacities[idNr] >0.0){
            lineOpacities[idNr] -= 0.1;
          }
        }
        tPosses[i][0] += tPosses[i][1];
      }
      if (tPosses[i][0] < 0){
        tPosses[i][1] = tPosses[i][1]*-1;
        success = (int)random(0,2);
        if(idNr == 0) println("success" + success);
      }
      
      tPosses[i][0] += tPosses[i][1];
      
      float tmp = cos(tPosses[i][0]);
      t = map(tmp, 1.0, -1.0, 0.0, 1.0);
      
      pos.x = curves.get(idNr).getX(t);
      pos.y = curves.get(idNr).getY(t);
      
      //size = map(t, 0.0, 1.0, 3.0, maxSize);
      size = maxSize;
      
      positions[i] = new PVector(pos.x,pos.y);
    }
    
    if(burst){
      bursttPos += bursttStep;
      if (bursttPos > PI || bursttPos < 0){
         burst = false;
      }
      
      float tmp = cos(bursttPos);
      t = map(tmp, 1.0, -1.0, 0.0, 1.0);
      
      burstPos.x = curves.get(idNr).getX(t);
      burstPos.y = curves.get(idNr).getY(t);
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
    
    if(burst){
      fill(c);
      ellipse(burstPos.x, burstPos.y, burstSize, burstSize);
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
      tPosses[i][0] = random(0,PI); //set tPos
      tPosses[i][1] = tStep * ((int)random(0,2)* 2 -1); //set tStep
    }
  }
  
  void particleBurst(int side){
    burst = true;
    
    if(side == LEFT_SIDE){ //left is 0, right is 1
      bursttPos = 0.0;
      bursttStep = tStep*3;
    }
    if(side == RIGHT_SIDE){
      bursttPos = PI;
      bursttStep = tStep*-3;
    }
  }
}
