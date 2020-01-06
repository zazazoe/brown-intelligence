class CurvePoint {

  PVector origin;
  PVector current;
  float speed;
  
  CurvePoint(PVector loc){
    origin = new PVector(loc.x, loc.y);
    current = new PVector(loc.x, loc.y);
    speed = 0.05;
  }
  
  //void update(){
  //  PVector mouse = new PVector(mouseX, mouseY);

  //  //float distX = location.x - mouse.x;
  //  //float distY = location.y - mouse.y;
    
  //  //if(distY <=0 && abs(distX)<50) {
  //  //  target.y = location.y + map(abs(distX), 0, 50, -200, 0);
  //  //} else if(distY >0 && abs(distX)<50) {
  //  //  target.y = location.y + map(abs(distX), 0, 50, 200, 0);
  //  //}
    
  //  //current.y = current.y+((target.y-current.y)*0.05);
  //}
  void update(){
    PVector mouse = new PVector(mouseX, mouseY);
   
    PVector toOrigin = PVector.sub(origin,current);
    float distOrigin = PVector.dist(origin,current);
    if(distOrigin<10)
    {
    }
    else
    {
      toOrigin.normalize();
      toOrigin.mult(map(distOrigin,0,250,0,10));
      current.add(toOrigin);
    }
    PVector awayMouse = PVector.sub(mouse, current);
    float distMouse = PVector.dist(mouse,current);
    
    awayMouse.normalize();
    awayMouse.mult(-constrain(map(distMouse,0,250,50,0),0,50));
    current.add(awayMouse);
  }
  
  PVector pos(){
    return current;
  }
}
