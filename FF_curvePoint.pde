class CurvePoint {

  PVector origin;
  PVector current;
  boolean move;
  
  
  CurvePoint(PVector loc, boolean m){
    origin = new PVector(loc.x, loc.y, loc.z);
    current = new PVector(loc.x, loc.y, loc.z);
    move = m;
  }
  
  void update(){
    
    if(move || !fixEndPoints){
      PVector toOrigin = PVector.sub(origin,current);
      float distOrigin = PVector.dist(origin,current);
      if(distOrigin<2) //close enough, to avoid jitter
      {
      }
      else
      {
        toOrigin.normalize();
        toOrigin.mult(map(distOrigin,0,200,0,attractionToOrigin));
        current.add(toOrigin);
      }
      PVector transformedBlob = NearestPointOnLine(blobBack, blobDir, current);
      //pushMatrix();
      //  fill(255,0,0);
      //  noStroke();
      //  translate(transformedBlob.x, transformedBlob.y, transformedBlob.z);
      //  sphere(5);
      //popMatrix();
      PVector awayBlob = PVector.sub(transformedBlob, current);
      float distBlob = PVector.dist(transformedBlob, current);
      
      awayBlob.normalize();
      awayBlob.mult(-constrain(map(distBlob,0,mouseAffectRadius,repulseFromMouse,0),0,repulseFromMouse));
      current.add(awayBlob);
    }
  }
    
    PVector pos(){
      return current;
    }
    
    PVector NearestPointOnLine(PVector linePnt, PVector lineDir, PVector pnt)
    {
      lineDir.normalize();//this needs to be a unit vector
      PVector v = PVector.sub(pnt, linePnt);
      float d = PVector.dot(v,lineDir);
      return PVector.add(linePnt, PVector.mult(lineDir,d));
    }

}
