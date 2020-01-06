class CurvePoint {

  PVector origin;
  PVector current;
  float speed;
  boolean move;
  
  
  CurvePoint(PVector loc, boolean m){
    origin = new PVector(loc.x, loc.y);
    current = new PVector(loc.x, loc.y);
    speed = 0.05;
    move = m;
  }
  
  void update(){
    
    if(move){
      PVector mouse = new PVector(mouseX, mouseY);
     
      PVector toOrigin = PVector.sub(origin,current);
      float distOrigin = PVector.dist(origin,current);
      if(distOrigin<2)
      {
      }
      else
      {
        toOrigin.normalize();
        toOrigin.mult(map(distOrigin,0,200,0,10));
        current.add(toOrigin);
      }
      PVector awayMouse = PVector.sub(mouse, current);
      float distMouse = PVector.dist(mouse,current);
      
      awayMouse.normalize();
      awayMouse.mult(-constrain(map(distMouse,0,200,25,0),0,25));
      current.add(awayMouse);
    }
  }
    
    PVector pos(){
      return current;
    }

}
