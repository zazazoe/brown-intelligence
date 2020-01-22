

void transitionCurves(){
  if(curveTransitionIndex < newTreeLength){
    if(curveTransitionIndex < oldTreeLength){
      replaceExistingCurve();
      curveTransitionIndex++;
    } else {
      createNewCurve();
      curveTransitionIndex++;
    }
  } else if(curveTransitionIndex < oldTreeLength){
    if(knots.size()>newTreeLength){
      removeExcessCurve();
    } else {
      prepNextTree();
    }
  } else {
    prepNextTree();
  }
}

void transitionToGameMode(){
  if(particles.size() <= nrOfNerveCurves){
    println("all current particles move: " + particles.size());
    particlesToMove = particles.size();
  } else {
    println("subset of current particles move: " + particles.size());
    particlesToMove = nrOfNerveCurves;
  }

  for(int i=0; i<particlesToMove; i++){
    particles.get(i).setTransition(true);
  }
  
  updateParticleAmount(nrOfNerveCurves);

  for(int i=0; i<particles.size(); i++){
    if(!particles.get(i).getTransition()){
      particles.get(i).setPoint();
      particles.get(i).setIdleColor(color(0));
    }
    particles.get(i).clearBurst();
  }

  println("enter transition to game mode");  
  initTransitionParticlesToNerveCurves();
  mode = TRANSITION_GAMEMODE;
}

////////////////////
/*CURVE TRANSITION*/
////////////////////

void replaceExistingCurve(){
  knots.set(curveTransitionIndex, new float[linesToSave.get(curveTransitionIndex).size()+2][2]);
  curvePoints.set(curveTransitionIndex, new CurvePoint[linesToSave.get(curveTransitionIndex).size()+2]);
  
  createKnots(curveTransitionIndex);
  createCurvePoints(curveTransitionIndex);
  
  curves.set(curveTransitionIndex, new AUCurve(knots.get(curveTransitionIndex),2,false));
}

void createNewCurve(){
  knots.add(new float[linesToSave.get(curveTransitionIndex).size()+2][2]);
  curvePoints.add(new CurvePoint[linesToSave.get(curveTransitionIndex).size()+2]);
  
  createKnots(curveTransitionIndex);
  createCurvePoints(curveTransitionIndex);
  
  curves.add(new AUCurve(knots.get(curveTransitionIndex),2,false));
  particles.add(new Point(particleSpeed, curveTransitionIndex, particleSize, particleTrailSize));
}

void removeExcessCurve(){
  int lastItem = knots.size()-1;
      
  knots.remove(lastItem);
  curvePoints.remove(lastItem);
  curves.remove(lastItem);
  particles.remove(lastItem);
}

void prepNextTree(){
  treeStartPoint = new PVector(0, random(0,height)); //NOTE TO SELF: make more generic variables, also expand capability to start drawing from other edges.
  segmentMinRot = (int)map(treeStartPoint.y, height, 0, -80.0, 20.0); //NOTE TO SELF: make more generic variables
  segmentMaxRot = (int)map(treeStartPoint.y, height, 0, -20.0, 80.0); //NOTE TO SELF: make more generic variables
  treeRot = (int)map(treeStartPoint.y, height, 0, -50, 50);
  
  reGenerateTree(segmentMaxLength, treeRot, treeStartPoint, numGenerations);  
  newTreeLength = linesToSave.size();
  oldTreeLength = curves.size();
  curveTransitionIndex=0;
}
