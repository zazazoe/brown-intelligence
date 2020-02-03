
float   particleSpeed = 0.005;
float   particleSize = 1;
int     particleTrailSize = 1; //NOTE TO SELF: may want to remove... now have burst
boolean renderParticles = true;
boolean syncParticles = false;
boolean disperseParticles = true;
float   particleDrawingSpeed = 0.01;
float   particleTransitionSpeed = 0.93;
float   particleTransitionSpeedIdle = 0.96;
float   particleFadeSlowDown = 8;
int     particlesToMove = 0;
int     successRate = 3;

color   burstColor = color(255);
float   burstSpeed = 0.075;
float   particleBurstSize = 3;

color   gameColor = color(70,53,159);

void updateParticlesIdle(){
  for(int i=0; i<particles.size(); i++){
    particles.get(i).updateIdle(curves.get(i));
  }
}

void updateParticlesIdleFade(){
  for(int i=0; i<particles.size(); i++){
    particles.get(i).updateIdleFade(curves.get(i), particleFadeSlowDown); //slow down factor
    particles.get(i).clearBurst();
  }
}

void renderParticlesIdle(){
  if(renderParticles){
    for(int i=0; i<particles.size(); i++){
      particles.get(i).setIdleColor(particleColor(i)); //actually changing
      particles.get(i).setBurstColor(burstColor); //stupid to do every time (could be as move to mode and in setup?)
      particles.get(i).setIdleSize(particleSize); //stupid to do every time (could be as move to mode and in setup?)
      particles.get(i).setBurstSize(particleBurstSize); //stupid to do every time (could be as move to mode and in setup?)
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
  updateParticleAmount(curves.size());

  for(int i=0; i<particles.size(); i++){
    particles.get(i).setTransition(true, curves.get(i), random(0.0, PI));
    //particles.get(i).disperse();
    particles.get(i).clearBurst();
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

void updateParticleAmount(int amount) {
    if(particles.size() > amount){
      for(int i=particles.size()-1; i>amount-1; i--){
        particles.remove(i);
      }
    } else if(particles.size() < amount){
      for(int i=particles.size(); i<amount; i++){
        particles.add(new Particle(particleSpeed, i, particleSize, particleTrailSize));
      }
    }
  }

////////////////
/*LITTLE TASKS*/
////////////////

color particleColor(int i){
  float f1 = map(i, 0, particles.size(), 0,1);
  float f2 = map(i, 0, particles.size(), 1,0);
  
  //float r = f1*red(cpL1.getColorValue()) + f2*red(cpL2.getColorValue());
  //float g = f1*green(cpL1.getColorValue()) + f2*green(cpL2.getColorValue());
  //float b = f1*blue(cpL1.getColorValue()) + f2*blue(cpL2.getColorValue());
  //float a = f1*alpha(cpL1.getColorValue()) + f2*alpha(cpL2.getColorValue());
  
  float r = f1*red(curveClr1) + f2*red(curveClr2);
  float g = f1*green(curveClr1) + f2*green(curveClr2);
  float b = f1*blue(curveClr1) + f2*blue(curveClr2);    

  color c = color(r,g,b,255);

  return c;
}
