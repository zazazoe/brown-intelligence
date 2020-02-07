class Particle{

  float t;
  float tStep;
  int   nrOfPoints;
  int   idNr;
  float size;
  float sizeIdle;
  float sizeGame;
  color c;
  color cIdle;
  color cBurst;
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
  Particle(float _tStep, int _idNr, float _size, int _nrOfPoints){   
    t=0.0;
    idNr = _idNr;
    size = _size;
    tStep = _tStep;
    nrOfPoints = _nrOfPoints;
    pos = new PVector(0,0);
    tPosStep = new Float[nrOfPoints][2]; //0 is tPos, 1 is tStep //NOTE TO SELF: maybe simplify to single point... now have burst
    positions = new PVector[nrOfPoints]; //NOTE TO SELF: maybe simplify to single point... now have burst
    
    for(int i=0; i<nrOfPoints; i++){
      tPosStep[i][0] = random(0.0, 1.0);
      tPosStep[i][1] = _tStep * ((int)random(0,2)* 2 -1);
      positions[i] = new PVector(0,0,0);
    }
    
    burst = false;
    bursttPos = 0.0;
    bursttStep = burstSpeed;
    burstPos = new PVector(0,0,0);
    burstSize = particleBurstSize;
    
    burstPosStep = new ArrayList<Float[]>();
    burstPositions = new ArrayList<PVector>();
    
    success = (int)random(1,successRate);
    transition = false;
  }

///////////////////////////////////
/*UPDATE BASED ON CURVE OR BEZIER*/
///////////////////////////////////

  void updateIdle(AUCurve curve) {
    for(int i=0; i<positions.length; i++){
      updateIdleParticles(i);
      pos = setCurvePos(curve, t);
      positions[i] = new PVector(pos.x,pos.y,pos.z);
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
      positions[i] = new PVector(pos.x,pos.y, pos.z);
    }
    
    if(burstPositions.size() > 0){
      for(int i=0; i<burstPositions.size(); i++){
        updateBurstParticles(i);
        burstPositions.set(i, setBezierPos(curve, t));
      }
      removeFinishedBurstParticles();
    }
  }
  
  void updateGameDraw(AUBezier curve, float _tStep) {
    for(int i=0; i<positions.length; i++){
      updateIdleParticles(i, _tStep);
      pos = setBezierPos(curve, t);
      if(t>0.99){
        setTransition(false);
      }
      positions[i] = new PVector(pos.x,pos.y, pos.z);
    }
  }
  
  void updateIdleFade(AUCurve curve, float _tStep) {
    for(int i=0; i<positions.length; i++){
      _tStep = tPosStep[i][1]/_tStep;
      updateIdleParticles(i, _tStep);
      pos = setCurvePos(curve, t);
      positions[i] = new PVector(pos.x,pos.y,pos.z);
    }
  }
  
  void updateIdleParticles(int i){
    tPosStep[i][0] += tPosStep[i][1]; //add tstep to tpos
    if(tPosStep[i][0] >= 1.0 || tPosStep[i][0] <= 0){
      if(idNr<curveOpacity.size() && curveOpacity.get(idNr)[0]>curveOpacityMin){
        if(success == 1 && tPosStep[i][0] <= 0){
          curveOpacity.get(idNr)[0] = curveOpacityMax;
        } else if(tPosStep[i][0] >= 1.0)
        {
          curveOpacity.get(idNr)[0] = curveOpacityMax;
        }
      }
      if(tPosStep[i][0] > 1.0) tPosStep[i][0] = 0.0;
      if(tPosStep[i][0] < 0)  tPosStep[i][0] = 1.0;  
      success = (int)random(1,successRate);
    }
    //float tmp = cos(tPosStep[i][0]);
    t = tPosStep[i][0];//map(tmp, 1.0, -1.0, 0.0, 1.0);
  }
  
  void updateIdleParticles(int i, float _tStep){
    tPosStep[i][0] += _tStep; //add tstep to tpos
    if(tPosStep[i][0] >= 1.0 || tPosStep[i][0] <= 0){
      if(idNr<curveOpacity.size() && curveOpacity.get(idNr)[0]>curveOpacityMin){
        if(success == 1 && tPosStep[i][0] <= 0){
          curveOpacity.get(idNr)[0] = curveOpacityMax;
        } else if(tPosStep[i][0] >= 1.0)
        {
          curveOpacity.get(idNr)[0] = curveOpacityMax;
        }
      }
      if(tPosStep[i][0] > 1.0) tPosStep[i][0] = 0.0;
      if(tPosStep[i][0] < 0)  tPosStep[i][0] = 1.0;  
      success = (int)random(1,successRate);
    }
    //float tmp = cos(tPosStep[i][0]);
    t = tPosStep[i][0]; //map(tmp, 1.0, -1.0, 0.0, 1.0);
  }
  
  void updateBurstParticles(int i){
    burstPosStep.get(i)[0] += burstPosStep.get(i)[1]; 
    if(idNr<curveOpacity.size() && curveOpacity.get(idNr)[0]>curveOpacityMin){
      if (burstPosStep.get(i)[0] > 1.0-(0.02*1.0) && side == SENSOR_SIDE || burstPosStep.get(i)[0] < 0.02*1.0 && side == MOTOR_SIDE){
        curveOpacity.get(idNr)[0] = curveOpacityMax;
      }
    }
    //float tmp = cos(burstPosStep.get(i)[0]);
    t = burstPosStep.get(i)[0]; //map(tmp, 1.0, -1.0, 0.0, 1.0);
  }
  
  //void updateBurstParticles(AUCurve curve, int i){
  //  burstPosStep.get(i)[0] += burstPosStep.get(i)[1]; 
  //  if(idNr<curveOpacity.size() && curveOpacity.get(idNr)[0]>curveOpacityMin){
  //    if (burstPosStep.get(i)[0] > 1.0-(0.02*1.0) && side == SENSOR_SIDE || burstPosStep.get(i)[0] < 0.02*1.0 && side == MOTOR_SIDE){
  //      curveOpacity.get(idNr)[0] = 1.0;
  //      //pushMatrix();
  //      //fill(255);
  //      //translate(setCurvePos(curve, 0.0).x, setCurvePos(curve, 0.0).y, setCurvePos(curve, 0.0).z);
  //      //ellipse(0,0,burstSize,burstSize);
  //      //popMatrix();
  //    }
  //  }
  //  //float tmp = cos(burstPosStep.get(i)[0]);
  //  t = burstPosStep.get(i)[0]; //map(tmp, 1.0, -1.0, 0.0, 1.0);
  //}
  
  void removeFinishedBurstParticles(){
    for(int i=burstPositions.size()-1; i>=0; i--){
      if (burstPosStep.get(i)[0] > 1.0 || burstPosStep.get(i)[0] < 0){
         burstPosStep.remove(i);
         burstPositions.remove(i);
         break;
      }
    }
  }
  
////////////////////////////////////////////
/*TRANSITION POINTS FROM IDLE TO GAME MODE*/
////////////////////////////////////////////
  
  void transition(float _speed){  
    if(transition){
      for(int i=0; i<positions.length; i++){
        positions[i].x = _speed*positions[i].x + (1-_speed)*newStartPoint.x;
        positions[i].y = _speed*positions[i].y + (1-_speed)*newStartPoint.y;
        positions[i].z = _speed*positions[i].z + (1-_speed)*newStartPoint.z;
        
        float d = positions[i].dist(newStartPoint);
        if(d<1){
          setTransition(false);
        }
      }
    }
  }
  
/////////////////////////
/*DISPLAY IDLE AND GAME*/
/////////////////////////

  void displayIdle() {
    if(idNr < curveOpacity.size()){
      if(curveOpacity.get(idNr)[1] != 1.0){  //curve is about to fade out
        noStroke();
        transitionColor(c, cIdle, 0.99);
        transitionSize(size, sizeIdle, 0.99);
        
        
        for(int i=0; i<positions.length; i++){
          pushMatrix();
          translate(positions[i].x,positions[i].y, positions[i].z);
          fill(cIdle);
          ellipse(0,0,size,size);
          popMatrix();
        }
        
        if(burstPositions.size() > 0){
          fill(cBurst);
          for(int i=0; i<burstPositions.size(); i++){
            pushMatrix();
            translate(burstPositions.get(i).x, burstPositions.get(i).y, burstPositions.get(i).z);
            ellipse(0, 0, burstSize, burstSize);
            popMatrix();
          }
        }
        
        if(curveOpacity.get(idNr)[0] == curveOpacityMax){
          //sparkle
          fill(cBurst);
          pushMatrix();
          translate(setCurvePos(curves.get(idNr), 1.0).x, setCurvePos(curves.get(idNr), 1.0).y, setCurvePos(curves.get(idNr), 1.0).z);
          ellipse(0, 0, 1.5, 1.5);
          popMatrix();
        }
      }
    }
  }
  
  void displayIdleFade() {
    noStroke();
    transitionColor(c, cIdle, 0.99);
    transitionSize(size, sizeIdle, 0.99);
    
    
    for(int i=0; i<positions.length; i++){
      pushMatrix();
      translate(positions[i].x,positions[i].y, positions[i].z);
      fill(cIdle);
      ellipse(0,0,size,size);
      popMatrix();
    }
    
    if(burstPositions.size() > 0){
      fill(cBurst);
      for(int i=0; i<burstPositions.size(); i++){
        pushMatrix();
        translate(burstPositions.get(i).x, burstPositions.get(i).y, burstPositions.get(i).z);
        ellipse(0, 0, burstSize, burstSize);
        //sphere(burstSize);
        popMatrix();
      }
    }
  }
  
  void displayTransition(int _burstSize, color _burstColor) {
    noStroke();
    transitionColor(c, cGame, 0.97); //NOTE TO SELF REPLACE SPEED WITH PROPER VARIABLE
    transitionSize(size, gameParticleSize, 0.99); //NOTE TO SELF REPLACE SPEED WITH PROPER VARIABLE
    
    nerveSkeleton.noStroke();
    c = color(red(c),green(c),blue(c),255);
    
    for(int i=0; i<positions.length; i++){
      fill(c);
      pushMatrix();
      translate(positions[i].x,positions[i].y, positions[i].z);
      ellipse(0,0,size,size);
      popMatrix();
    }
    
    if(burstPositions.size() > 0){
      fill(_burstColor);
      for(int i=0; i<burstPositions.size(); i++){
        pushMatrix();
        translate(burstPositions.get(i).x, burstPositions.get(i).y, burstPositions.get(i).z);
        ellipse(0, 0, burstSize, burstSize);
        popMatrix();
      }
    }
  }
  
  void displayGame(int _burstSize, color _burstColor) {
    noStroke();
    transitionColor(c, cGame, 0.99);
    //transitionSize(size, gameParticleSize, 0.99);
    
    nerveSkeleton.noStroke();
    c = color(red(c),green(c),blue(c),255);
    
    for(int i=0; i<positions.length; i++){
      fill(c);
      pushMatrix();
      //translate(positions[i].x,positions[i].y, positions[i].z);
      //fill(cIdle);
      translate(0,0,positions[i].z);
      ellipse(positions[i].x,positions[i].y,size,size);
      //sphere(size);
      popMatrix();
    }
    
    if(burstPositions.size() > 0){
      fill(_burstColor);
      for(int i=0; i<burstPositions.size(); i++){
        pushMatrix();
        //translate(burstPositions.get(i).x, burstPositions.get(i).y, burstPositions.get(i).z);
        translate(0, 0, burstPositions.get(i).z);
        ellipse(burstPositions.get(i).x, burstPositions.get(i).y, _burstSize, _burstSize);
        //sphere(_burstSize);
        popMatrix();
      }
    }
  }
  
  void displayDraw(PGraphics canvas) {
    transitionColor(c, cGame, 0.99);
    transitionSize(size, gameParticleSize, 0.90);
    
    canvas.noStroke();
    c = color(red(gameColor),green(gameColor),blue(gameColor),255);

    for(int i=0; i<positions.length; i++){
      canvas.fill(c);
      canvas.ellipse(positions[i].x,positions[i].y,size,size);
    }
  }


//////////////////////////////////////
/*ADD, REMOVE & REPOSITION PARTICLES*/
//////////////////////////////////////

  void disperse(){
    for(int i=0; i<tPosStep.length; i++){
      tPosStep[i][0] = random(0.0,1.0); //set tPos
      tPosStep[i][1] = tStep * ((int)random(0,2)* 2 -1); //set tStep
    }
  }
  
  void particleBurst(int _side, float _speed){   
    int i = burstPosStep.size();
      if(_side == SENSOR_SIDE){ //left is 0, right is 1
        burstPosStep.add(new Float[2]);
        burstPosStep.get(i)[0] = 0.0; //+(i*0.02) //+(i*random(0.01,0.02))
        burstPosStep.get(i)[1] = tStep*_speed; //NOTE TO SELF, make proper variable, dif for idle and game >speed
      }
      if(_side == MOTOR_SIDE){
        burstPosStep.add(new Float[2]);
        burstPosStep.get(i)[0] = 1.0; //(i*0.02) //-(i*random(0.01,0.02))
        burstPosStep.get(i)[1] = tStep*-_speed; //NOTE TO SELF, make proper variable, dif for idle and game >speed
      }
      burstPositions.add(new PVector(0,0));
      side = _side;
  }
  
  void reset(float _t){
    for(int i=0; i<tPosStep.length; i++){
      tPosStep[i][0] = _t;
    }
  }
  
  void reset(float _t, int dir){
    for(int i=0; i<tPosStep.length; i++){
      tPosStep[i][0] = _t;
      tPosStep[i][1] = tStep * dir; //((int)random(0,2)* 2 -1); //set tStep
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
    p.z = curve.getZ(t);
    
    return(p);
  }
  
  PVector setBezierPos(AUBezier bezier, float t){
    PVector p = new PVector();    
    p.x = bezier.getX(t);
    p.y = bezier.getY(t);
    p.z = bezier.getZ(t);
    
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
  
  void setTransition(boolean _transition, AUBezier curve, float _t){
    transition = _transition;
    float newPos = _t; //random(0.0, PI);
    newStartPoint = setBezierPos(curve, newPos);
    reset(newPos);
  }
  
  void setTransition(boolean _transition, AUCurve curve, float _t){
    transition = _transition;
    float newPos = _t; //random(0.0, PI);
    newStartPoint = setCurvePos(curve, newPos);
    reset(newPos, (int)random(0,2)* 2 -1);
  }
  
  boolean getTransition(){
    return transition;
  }
  
  void setPoint(){
    if(positions.length<=0){
      println("no positions lenght");
    }
    for(int i=0; i<positions.length;  i++){
      positions[i] = new PVector(random(0,width), random(0,height), random(0,translateZ));
    }
  }
  
  void setIdleColor(color _c){
    cIdle = _c;
  }
  
  void setBurstColor(color _c){
    cBurst = _c;
  }
  
  void setGameColor(color _c){
    cGame = _c;
  }
  
  void setIdleSize(float _s){
    sizeIdle = _s;
  }
  
  void setBurstSize(float _s){
    burstSize = _s;
  }
  
  void setGameSize(float _s){
    sizeGame = _s;
  }
  
  void setSize(float _s){
    size = _s;
  }
}
