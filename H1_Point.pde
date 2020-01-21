class Point{

  float t;
  float tPos;
  float tStep;
  float minSize;
  float maxSize;
  float size;
  int   trail;
  int   idNr;
  
  PVector   pos;
  Float[][] tPosStep; 
  PVector[] positions;

  ArrayList<Float[]> burstPosStep;
  ArrayList<PVector> burstPositions;
  
  boolean burst;
  float   bursttPos;
  float   bursttStep;
  PVector burstPos;
  float   burstSize;
  
  int success;
  int side;
  
  boolean transition;
  
  PVector lastPoint;
  PVector newStartPoint;

  //speed defined by stepsize so smaller nr is faster, bigger nr is slower
  Point(float _tStep, int _idNr, float _minSize, float _maxSize, int _trail){   
    t=0.0;
    tPos = 0.0;
    
    idNr = _idNr;
    minSize = _minSize;
    maxSize = _maxSize;
    size = maxSize;
    tStep = _tStep;
    trail = _trail;
    
    pos = new PVector(0,0);
    tPosStep = new Float[trail][2]; //0 is tPos, 1 is tStep
    positions = new PVector[trail];
    
    for(int i=0; i<trail; i++){
      tPosStep[i][0] = random(0.0, PI);
      tPosStep[i][1] = _tStep * ((int)random(0,2)* 2 -1);
      positions[i] = new PVector(0,0);
    }
    
    burst = false;
    bursttPos = 0.0;
    bursttStep = _tStep*15;  //NOTE TO SELF: make this proper variable
    burstPos = new PVector(0,0);
    burstSize = 1.5*_maxSize;  //NOTE TO SELF: make this proper variable
    
    burstPosStep = new ArrayList<Float[]>();
    burstPositions = new ArrayList<PVector>();
    
    success = (int)random(0,4);  //NOTE TO SELF: make this proper variable, + implement below
    transition = false;
  }
  
  void update(AUBezier curve) {
    for(int i=0; i<tPosStep.length; i++){
      updateIdleParticles(i);
      pos = setBezierPos(curve, t);
      positions[i] = new PVector(pos.x,pos.y);
    }
    
    //update burst particles
    if(burstPositions.size() > 0){
      for(int i=0; i<burstPositions.size(); i++){
        updateBurstParticles(i);
        burstPositions.set(i, setBezierPos(curve, t));
      }
      removeFinishedBurstParticles();
    }
  }
  
  void update(AUCurve curve) {
    for(int i=0; i<tPosStep.length; i++){
      updateIdleParticles(i);
      pos = setCurvePos(curve, t);
      positions[i] = new PVector(pos.x,pos.y);
    }

    if(burstPositions.size() > 0){
      for(int i=0; i<burstPositions.size(); i++){
        updateBurstParticles(i);
        burstPositions.set(i, setCurvePos(curve, t));
      }
      removeFinishedBurstParticles();
    }
  }
  
  void transition(AUBezier curve){  
    if(transition){
      newStartPoint = setBezierPos(curve, 0.0);
      
      for(int i=0; i<positions.length; i++){
        positions[i].x = 0.95*positions[i].x + 0.05*newStartPoint.x;
        positions[i].y = 0.95*positions[i].y + 0.05*newStartPoint.y;
        
        float d = positions[i].dist(newStartPoint);
        if(d<2){
          transition = false;
          println("reached");
        } else {
          println("not reached");
        }
      }
    }
  }
  
  void updateIdleParticles(int i){
    tPosStep[i][0] += tPosStep[i][1]; //add tstep to tpos
    if (tPosStep[i][0] > PI){
      if(success == 1){
        //lineOpacities[idNr] = 1.0;  //NOTE TO SELF: line opacities should be replaced with more generic function
      }
      success = (int)random(0,4);
      tPosStep[i][0] = 0.0;
      tPosStep[i][0] += tPosStep[i][1];
    }
    if (tPosStep[i][0] < 0){
      tPosStep[i][0] = 1.0;
      tPosStep[i][0] += tPosStep[i][1];
      success = (int)random(0,4);
    }
    float tmp = cos(tPosStep[i][0]);
    t = map(tmp, 1.0, -1.0, 0.0, 1.0);
  }
  
  void updateBurstParticles(int i){
    burstPosStep.get(i)[0] += burstPosStep.get(i)[1];    
    if (burstPosStep.get(i)[0] > PI-(0.02*PI) && side == LEFT_SIDE || burstPosStep.get(i)[0] < 0.02*PI && side == RIGHT_SIDE){
      //lineOpacities[idNr] = 1.0; /*line opacities should be replaced with more generic function*/
    }
    float tmp = cos(burstPosStep.get(i)[0]);
    t = map(tmp, 1.0, -1.0, 0.0, 1.0);
  }
  
  void removeFinishedBurstParticles(){
    for(int i=burstPositions.size()-1; i>=0; i--){
      if (burstPosStep.get(i)[0] > PI || burstPosStep.get(i)[0] < 0){
         burstPosStep.remove(i);
         burstPositions.remove(i);
         break;
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
    for(int i=0; i<tPosStep.length; i++){
      tPosStep[i][0] = _t;
    }
  }
  
  void disperse(){
    tStep = tStep * ((int)random(0,2)* 2 -1);
    tPos = random(0,PI);
    
    for(int i=0; i<tPosStep.length; i++){
      tPosStep[i][0] = random(0,PI); //set tPos
      tPosStep[i][1] = tStep * ((int)random(0,2)* 2 -1); //set tStep
    }
  }
  
  void particleBurst(int _side){  
    
    int i = burstPosStep.size();
    
      if(_side == LEFT_SIDE){ //left is 0, right is 1
        burstPosStep.add(new Float[2]);
        burstPosStep.get(i)[0] = 0.0; //+(i*0.02) //+(i*random(0.01,0.02))
        burstPosStep.get(i)[1] = tStep*random(3.5,4.5);
      }
      if(_side == RIGHT_SIDE){
        burstPosStep.add(new Float[2]);
        burstPosStep.get(i)[0] = PI; //(i*0.02) //-(i*random(0.01,0.02))
        burstPosStep.get(i)[1] = tStep*-random(3.5,4.5);
      }
      
      burstPositions.add(new PVector(0,0));
      side = _side;
  }
  
  void setTransition(boolean _transition){
    transition = _transition;
  }
  
  boolean getTransition(){
    return transition;
  }

}
