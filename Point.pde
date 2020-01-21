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

  ArrayList<Float[]> bursttPosses;
  ArrayList<PVector> burstPositions;
  
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
    tPosses = new Float[trail][2]; //0 is tPos, 1 is tStep
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
    burstSize = 1.5*_maxSize;
    
    bursttPosses = new ArrayList<Float[]>();
    burstPositions = new ArrayList<PVector>();
    
    success = (int)random(0,4);
  }
  
  void update(AUBezier curve) {
    //calculate position
    
    //update idle particles
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
      
      pos = setBezierPos(curve, t);

      size = maxSize;
      
      positions[i] = new PVector(pos.x,pos.y);
    }
    
    //update burst particles
    if(burstPositions.size() > 0){
      for(int i=0; i<burstPositions.size(); i++){
        bursttPosses.get(i)[0] += bursttPosses.get(i)[1];
        
        if (bursttPosses.get(i)[0] > PI-(0.02*PI) && side == LEFT_SIDE || bursttPosses.get(i)[0] < 0.02*PI && side == RIGHT_SIDE){
          //lineOpacities[idNr] = 1.0; /*line opacities should be replaced with more generic function*/
        }
  
        float tmp = cos(bursttPosses.get(i)[0]);
        t = map(tmp, 1.0, -1.0, 0.0, 1.0);

        burstPositions.set(i, setBezierPos(curve, t));
      }
      
      for(int i=burstPositions.size()-1; i>=0; i--){
        if (bursttPosses.get(i)[0] > PI || bursttPosses.get(i)[0] < 0){
           bursttPosses.remove(i);
           burstPositions.remove(i);
           break;
        }
      }
    }
  }
  
  void update(AUCurve curve) {
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
      
      pos = setCurvePos(curve, t);

      size = maxSize;
      
      positions[i] = new PVector(pos.x,pos.y);
    }

    if(burstPositions.size() > 0){
      for(int i=0; i<burstPositions.size(); i++){
        bursttPosses.get(i)[0] += bursttPosses.get(i)[1];
        
        if (bursttPosses.get(i)[0] > PI-(0.02*PI) && side == LEFT_SIDE || bursttPosses.get(i)[0] < 0.02*PI && side == RIGHT_SIDE){
          //lineOpacities[idNr] = 1.0; /*line opacities should be replaced with more generic function*/
        }
  
        float tmp = cos(bursttPosses.get(i)[0]);
        t = map(tmp, 1.0, -1.0, 0.0, 1.0);
        
        burstPositions.set(i, setCurvePos(curves.get(idNr), t));
      }
      
      for(int i=burstPositions.size()-1; i>=0; i--){
        if (bursttPosses.get(i)[0] > PI || bursttPosses.get(i)[0] < 0){
           bursttPosses.remove(i);
           burstPositions.remove(i);
           break;
        }
      }
    }
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
    
    if(burstPositions.size() > 0){
      fill(c);

      for(int i=0; i<burstPositions.size(); i++){
        ellipse(burstPositions.get(i).x, burstPositions.get(i).y, burstSize, burstSize);
      }
    }
  }
  
  void display(color c, int _size, int _burstSize, color _burstColor) {
    noStroke();
    
    for(int i=0; i<positions.length; i++){
      fill(c);
      ellipse(positions[i].x,positions[i].y,_size,_size);
      //brightness += stepSize;
    }
    
    if(burstPositions.size() > 0){
      fill(_burstColor);

      for(int i=0; i<burstPositions.size(); i++){
        ellipse(burstPositions.get(i).x, burstPositions.get(i).y, _burstSize, _burstSize);
      }
    }
  }
  
  void reset(float _t){
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
    
    int i = bursttPosses.size();
    
      if(_side == LEFT_SIDE){ //left is 0, right is 1
        bursttPosses.add(new Float[2]);
        bursttPosses.get(i)[0] = 0.0; //+(i*0.02) //+(i*random(0.01,0.02))
        bursttPosses.get(i)[1] = tStep*random(3.5,4.5);
      }
      if(_side == RIGHT_SIDE){
        bursttPosses.add(new Float[2]);
        bursttPosses.get(i)[0] = PI; //(i*0.02) //-(i*random(0.01,0.02))
        bursttPosses.get(i)[1] = tStep*-random(3.5,4.5);
      }
      
      burstPositions.add(new PVector(0,0));
      side = _side;
  }
}
