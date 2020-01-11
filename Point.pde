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
  //ArrayList<PVector> history;
  Float[][] tPosses;
  PVector[] positions;

  boolean burst;
  float bursttPos;
  float bursttStep;
  PVector burstPos;
  float burstSize;
  
  int success;
  int side;

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
    //history = new ArrayList<PVector>();
    tPosses = new Float[trail][2];
    positions = new PVector[trail];
    
    for(int i=0; i<trail; i++){
      tPosses[i][0] = random(0.0, PI);
      tPosses[i][1] = _tStep * ((int)random(0,2)* 2 -1);
      positions[i] = new PVector(0,0);
    }
    
    burst = false;
    bursttPos = 0.0;
    bursttStep = _tStep*15;
    burstPos = new PVector(0,0);
    burstSize = 1.2*_maxSize;
    
    success = (int)random(0,4);
  }
  
  void update(String curveType) {
    //calculate position
    
    for(int i=0; i<tPosses.length; i++){
      tPosses[i][0] += tPosses[i][1]; //add tstep to tpos
      if (tPosses[i][0] > PI){
        if(success == 1){
          tPosses[i][1] = tPosses[i][1]*-1;
          //lineOpacities[idNr] = 1.0;  /*line opacities should be replaced with more generic function*/
        } else {
          tPosses[i][0] = 0.0;
          success = (int)random(0,4);
        }
        tPosses[i][0] += tPosses[i][1];
      }
      if (tPosses[i][0] < 0){
        tPosses[i][1] = tPosses[i][1]*-1;
        success = (int)random(0,4);
      }
      
      tPosses[i][0] += tPosses[i][1];
      
      float tmp = cos(tPosses[i][0]);
      t = map(tmp, 1.0, -1.0, 0.0, 1.0);
      
      if(curveType == "curve"){
        pos = setCurvePos(curves.get(idNr), t);
      } else if(curveType == "bezier"){
        pos = setBezierPos(motorCurves[idNr], t);
      }

      size = maxSize;
      
      positions[i] = new PVector(pos.x,pos.y);
    }
    
    if(burst){
      bursttPos += bursttStep;
      if (bursttPos > PI || bursttPos < 0){
         burst = false;
      }
      
      if (bursttPos > PI-(0.02*PI) && side == LEFT_SIDE || bursttPos < 0.02*PI && side == RIGHT_SIDE){
        //lineOpacities[idNr] = 1.0; /*line opacities should be replaced with more generic function*/
      }

      float tmp = cos(bursttPos);
      t = map(tmp, 1.0, -1.0, 0.0, 1.0);
      
      if(curveType == "curve"){
        burstPos = setCurvePos(curves.get(idNr), t);
      } else if(curveType == "bezier"){
        burstPos = setBezierPos(motorCurves[idNr], t);
      }
    }

    //history.add(new PVector(pos.x,pos.y));
    
    //if(history.size() > trail) {
    //  history.remove(0);
    //}
  }
  
  PVector setCurvePos(AUCurve curve, float t){
    PVector p = new PVector();   
    p.x = curve.getX(t);
    p.y = curve.getY(t);
    
    return(p);
  }
  
  PVector setBezierPos(AUBezier bezier, float t){
    PVector p = new PVector();    
    p.x = bezier.getX(t);
    p.y = bezier.getY(t);
    
    return(p);
  }
  
  void display(color c) {
    noStroke();
    
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
  
  void particleBurst(int _side){
    burst = true;
    
    /*left-side and right-side will become obsolete with dedicated sensor and motor particles...*/
    
    if(_side == LEFT_SIDE){ //left is 0, right is 1
      bursttPos = 0.0;
      bursttStep = tStep*3;
    }
    if(_side == RIGHT_SIDE){
      bursttPos = PI;
      bursttStep = tStep*-3;
    }
    
    side = _side;
  }
}
