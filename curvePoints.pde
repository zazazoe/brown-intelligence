class CurvePoint {

  PVector location;
  PVector target;
  PVector current;
  
  CurvePoint(PVector loc){
    location = new PVector(loc.x, loc.y);
    target = new PVector(loc.x, loc.y);
    current = new PVector(loc.x, loc.y);
  }
  
  void update(){
    PVector mouse = new PVector(mouseX, mouseY);

    float distX = location.x - mouse.x;
    float distY = location.y - mouse.y;
    
    if(distY <=0 && abs(distX)<50) {
      target.y = location.y + map(abs(distX), 0, 50, -200, 0);
    } else if(distY >0 && abs(distX)<50) {
      target.y = location.y + map(abs(distX), 0, 50, 200, 0);
    }
    
    current.y = current.y+((target.y-current.y)*0.05);
  }
  
  PVector pos(){
    return current;
  }
}
