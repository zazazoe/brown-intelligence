

void transitionCurves(){
  if(curveCounter < newTreeLength){
    if(curveCounter < oldTreeLength){
      replaceExistingCurve();
      curveCounter++;
    } else {
      createNewCurve();
      curveCounter++;
    }
  } else if(curveCounter < oldTreeLength){
    if(knots.size()>newTreeLength){
      removeExcessCurve();
    } else {
      nextTree();
    }
  } else {
    nextTree();
  }
}

void replaceExistingCurve(){
  knots.set(curveCounter, new float[linesToSave.get(curveCounter).size()+2][2]);
  curvePoints.set(curveCounter, new CurvePoint[linesToSave.get(curveCounter).size()+2]);
  
  createKnots(curveCounter);
  createCurvePoints(curveCounter);
  
  curves.set(curveCounter, new AUCurve(knots.get(curveCounter),2,false));
}

void createNewCurve(){
  knots.add(new float[linesToSave.get(curveCounter).size()+2][2]);
  curvePoints.add(new CurvePoint[linesToSave.get(curveCounter).size()+2]);
  
  createKnots(curveCounter);
  createCurvePoints(curveCounter);
  
  curves.add(new AUCurve(knots.get(curveCounter),2,false));
  particles.add(new Point(particleSpeed, curveCounter, particleSize, particleSize, particleTrailSize));
}

void removeExcessCurve(){
  int lastItem = knots.size()-1;
      
  knots.remove(lastItem);
  curvePoints.remove(lastItem);
  curves.remove(lastItem);
  particles.remove(lastItem);
}

void nextTree(){
  reGenerateTree(segmentMaxLength, treeRot, treeStartPoint, numGenerations);  
  newTreeLength = linesToSave.size();
  oldTreeLength = curves.size();
  curveCounter=0;
}
