class Point{

  float t;
  float tStep;
  int   nrOfPoints;
  int   idNr;
  float size;
  float sizeIdle;
  float sizeGame;
  color c;
  color cIdle;
  color cGame;
  
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
  int     side;
  
  int     success;
  boolean transition;
  PVector newStartPoint;

  //speed defined by stepsize so smaller nr is faster, bigger nr is slower
  Point(float _tStep, int _idNr, float _size, int _nrOfPoints){   
    t=0.0;
    idNr = _idNr;
    size = _size;
    tStep = _tStep;
    nrOfPoints = _nrOfPoints;
    pos = new PVector(0,0);
    tPosStep = new Float[nrOfPoints][2]; //0 is tPos, 1 is tStep
    positions = new PVector[nrOfPoints];
    
    for(int i=0; i<nrOfPoints; i++){
      tPosStep[i][0] = random(0.0, PI);
      tPosStep[i][1] = _tStep * ((int)random(0,2)* 2 -1);
      positions[i] = new PVector(0,0);
    }
    
    burst = false;
    bursttPos = 0.0;
    bursttStep = _tStep*15;  //NOTE TO SELF: make this proper variable
    burstPos = new PVector(0,0);
    burstSize = 1.5*_size;  //NOTE TO SELF: make this proper variable
    
    burstPosStep = new ArrayList<Float[]>();
    burstPositions = new ArrayList<PVector>();
    
    success = (int)random(0,4);  //NOTE TO SELF: make this proper variable, + implement below
    transition = false;
  }

///////////////////////////////////
/*UPDATE BASED ON CURVE OR BEZIER*/
///////////////////////////////////

  void updateIdle(AUCurve curve) {
    for(int i=0; i<positions.length; i++){
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

  void updateGame(AUBezier curve) {
    for(int i=0; i<positions.length; i++){
      updateIdleParticles(i);
      pos = setBezierPos(curve, t);
      positions[i] = new PVector(pos.x,pos.y);
    }
    
    if(burstPositions.size() > 0){
      for(int i=0; i<burstPositions.size(); i++){
        updateBurstParticles(i);
        burstPositions.set(i, setBezierPos(curve, t));
      }
      removeFinishedBurstParticles();
    }
  }
  
  void updateIdleParticles(int i){
    tPosStep[i][0] += tPosStep[i][1]; //add tstep to tpos
    if(tPosStep[i][0] > PI || tPosStep[i][0] < 0){
      if(success == 1)        ;//lineOpacities[idNr] = 1.0;  //NOTE TO SELF: line opacities should be replaced with more generic function
      if(tPosStep[i][0] > PI) tPosStep[i][0] = 0.0;
      if(tPosStep[i][0] < 0)  tPosStep[i][0] = 1.0;  
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
  
////////////////////////////////////////////
/*TRANSITION POINTS FROM IDLE TO GAME MODE*/
////////////////////////////////////////////
  
  void transition(AUBezier curve, float _speed){  
    if(transition){
      for(int i=0; i<positions.length; i++){
        positions[i].x = _speed*positions[i].x + (1-_speed)*newStartPoint.x;
        positions[i].y = _speed*positions[i].y + (1-_speed)*newStartPoint.y;
        
        float d = positions[i].dist(newStartPoint);
        if(d<2){
          setTransition(false);
        }
      }
    }
  }
  
/////////////////////////
/*DISPLAY IDLE AND GAME*/
/////////////////////////

  void displayIdle() {
    noStroke();
    
    for(int i=0; i<positions.length; i++){
      fill(cIdle);
      ellipse(positions[i].x,positions[i].y,size,size);
    }
    
    if(burstPositions.size() > 0){
      fill(cIdle);
      for(int i=0; i<burstPositions.size(); i++){
        ellipse(burstPositions.get(i).x, burstPositions.get(i).y, burstSize, burstSize);
      }
    }
  }
  
  void displayGame(int _burstSize, color _burstColor) {
    noStroke();
    transitionColor(c, cGame, 0.99);
    transitionSize(size, gameParticleSize, 0.99);
      
    for(int i=0; i<positions.length; i++){
      fill(c);
      ellipse(positions[i].x,positions[i].y,size,size);
      //brightness += stepSize;
    }
    
    if(burstPositions.size() > 0){
      fill(_burstColor);

      for(int i=0; i<burstPositions.size(); i++){
        ellipse(burstPositions.get(i).x, burstPositions.get(i).y, _burstSize, _burstSize);
      }
    }
  }

//////////////////////////////////////
/*ADD, REMOVE & REPOSITION PARTICLES*/
//////////////////////////////////////

  void disperse(){
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
  
  void reset(float _t){
    for(int i=0; i<tPosStep.length; i++){
      tPosStep[i][0] = _t;
    }
  }
  
  void clearBurst(){
    burstPosStep.clear();
    burstPositions.clear();
  }


///////////////////////
/*TINY TASK FUNCTIONS*/
///////////////////////
  
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
  
  void transitionColor(color _c1, color _c2, float _speed){
    float r = red(_c1)*_speed+red(_c2)*(1-_speed);
    float g = green(_c1)*_speed+green(_c2)*(1-_speed);
    float b = blue(_c1)*_speed+blue(_c2)*(1-_speed);
    float a = alpha(_c1)*_speed+alpha(_c2)*(1-_speed);
    
    c = color(r, g, b, a);
  }
  
  void transitionSize(float _s1, float _s2, float _speed){
    size = _speed*_s1 + (1-_speed)*_s2;
  }
  
  void setTransition(boolean _transition){
    transition = _transition;
  }
  
  void setTransition(boolean _transition, AUBezier curve){
    transition = _transition;
    float newPos = 0.0;//random(0.0, PI);
    newStartPoint = setBezierPos(curve, newPos);
    reset(newPos);
  }
  
  boolean getTransition(){
    return transition;
  }
  
  void setPoint(){
    for(int i=0; i<positions.length;  i++){
      positions[i] = new PVector(random(0,width), random(0,height));
    }
  }
  
  void setIdleColor(color _c){
    cIdle = _c;
    c = cIdle;
  }
  
  void setGameColor(color _c){
    cGame = _c;
  }
  
  void setIdleSize(float _s){
    sizeIdle = _s;
    size = sizeIdle;
  }
  
  void setGameSize(float _s){
    sizeGame = _s;
  }
  
  void setSize(float _s){
    size = _s;
  }
}
