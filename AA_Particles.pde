

void updateParticlesIdle(){
  for(int i=0; i<particles.size(); i++){
    particles.get(i).updateIdle(curves.get(i));
  }
}

void updateParticlesIdleFade(){
  for(int i=0; i<particles.size(); i++){
    particles.get(i).updateIdleFade(curves.get(i), particleFadeSlowDown); //slow down factor
  }
}

void renderParticlesIdle(){
  if(renderParticles){
    for(int i=0; i<particles.size(); i++){
      particles.get(i).setIdleColor(particleColor(i)); //actually changing
      particles.get(i).setIdleSize(particleSize); //stupid to do every time (could be as move to mode and in setup?)
      particles.get(i).displayIdle();
    }
  }
}

void drawParticlesOnCanvas(PGraphics canvas, int start, int end){
  canvas.beginDraw();
  for(int i=start; i<end; i++){
    particles.get(i).displayDraw(canvas); //draw on PGraphics nerveSkeleton
  }
  canvas.endDraw();
}


void transitionParticlesToGameMode(){
  if(particles.size() <= nrOfNerveCurves){
    particlesToMove = particles.size();
  } else {
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
  initTransitionParticlesToNerveCurves();
  transitionToGame=true;
}

void transitionParticlesToIdleMode(){
  //if(particles.size() <= nrOfNerveCurves){
  //  particlesToMove = particles.size();
  //} else {
  //  particlesToMove = nrOfNerveCurves;
  //}
  //for(int i=0; i<particlesToMove; i++){
  //  particles.get(i).setTransition(true);
  //}
  updateParticleAmount(curves.size());
  //for(int i=0; i<particles.size(); i++){
  //  particles.get(i).setTransition(true);
  //}
  
  //for(int i=0; i<particles.size(); i++){
  //  if(!particles.get(i).getTransition()){
  //    particles.get(i).setPoint();
  //    particles.get(i).setIdleColor(color(0));
  //  }
  //  particles.get(i).clearBurst();
  //}
  
  for(int i=0; i<particles.size(); i++){
    particles.get(i).setTransition(true, curves.get(i), random(0.0, PI));
  }
  
  transitionToIdle=true;
}

void transitionParticlesToIdleCurves(){
  for(int i=0; i<particles.size(); i++){
    particles.get(i).transition(particleTransitionSpeedIdle);
    particles.get(i).setIdleColor(particleColor(i));
    particles.get(i).setIdleSize(particleSize);
    particles.get(i).displayIdle();
  }
}

void setParticlesForGame(){
  for(int i=0; i<particles.size(); i++){
    particles.get(i).setSize(gameParticleSize);
    particles.get(i).disperse();
  }
}
