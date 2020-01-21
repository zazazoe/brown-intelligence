     
void transitionCurves(){
  if(!done){
    if(curveCounter < newTreeLength){
      if(curveCounter < oldTreeLength){
        knots.set(curveCounter, new float[linesToSave.get(curveCounter).size()+2][2]);
        curvePoints.set(curveCounter, new CurvePoint[linesToSave.get(curveCounter).size()+2]);
        
        fillKnots(curveCounter);
        fillCurvePoints(curveCounter);
        
        curves.set(curveCounter, new AUCurve(knots.get(curveCounter),2,false));

        curveCounter++;
      } else {
        knots.add(new float[linesToSave.get(curveCounter).size()+2][2]);
        curvePoints.add(new CurvePoint[linesToSave.get(curveCounter).size()+2]);
        
        fillKnots(curveCounter);
        fillCurvePoints(curveCounter);
        
        curves.add(new AUCurve(knots.get(curveCounter),2,false));
        particles.add(new Point(particleSpeed, curveCounter, particleSize, particleSize, particleTrailSize));
        
        curveCounter++;
      }
    } else if(curveCounter < oldTreeLength){
      if(knots.size()>newTreeLength){
        int last = knots.size()-1;
        
        knots.remove(last);
        curvePoints.remove(last);
        curves.remove(last);
        particles.remove(last);
      } else {
        done = true; //generate a new tree and start over
      }
    } else {
      done = true; //generate a new tree and start over
    }
  } else {
    println("done");
    reGenerateTree(segmentMaxLength, treeRot, treeStartPoint, numGenerations);
    
    newTreeLength = linesToSave.size();
    oldTreeLength = curves.size();
    
    curveCounter=0;
    done=false;
  }
}
