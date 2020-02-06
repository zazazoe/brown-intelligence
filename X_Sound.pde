
int BUTTONCLICK = 0;
int WOOSHGAMETRANS  = 1;
//int WOOSHIDLETRANS  = 2;
int WOOSHDRAW   = 3;
int NERVETRIGGER = 4;

SoundFile  buttonClick;
SoundFile  transitionToGameWoosh;
//SoundFile  transitionToIdleWoosh;
SoundFile  drawWoosh;
SoundFile  nerveTrigger;


void initSound(){
  buttonClick = new SoundFile(this, "buttonClick2.wav");
  //transitionToIdleWoosh = new SoundFile(this, "drawWoosh2.mp3");
  transitionToGameWoosh = new SoundFile(this, "drawWoosh.mp3");
  drawWoosh = new SoundFile(this, "drawWoosh7.mp3");
  nerveTrigger = new SoundFile(this, "drawShort.mp3");
}

void playSound(int sound){
  switch(sound){
    case 0: //BUTTONCLICK
      buttonClick.play();
      break;
    case 1: //WOOSHGAMETRANS
      transitionToGameWoosh.play();
      break;
    case 2: //WOOSHIDLETRANS
      //transitionToIdleWoosh.play();
      break;
    case 3: //WOOSHDRAW
      drawWoosh.play();
      break;
    case 4: //NERVETRIGGER
      nerveTrigger.play();
      break;
  }
}
