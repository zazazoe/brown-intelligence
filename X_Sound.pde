
int BUTTONCLICK = 0;
int WOOSHGAMETRANS  = 1;
int WOOSHDRAW   = 2;
int NERVETRIGGER = 3;

SoundFile  buttonClick;
SoundFile  transitionToGameWoosh;
SoundFile  drawWoosh;
SoundFile  nerveTrigger;


void initSound(){
  buttonClick = new SoundFile(this, "buttonClick2.wav");
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
    case 2: //WOOSHDRAW
      drawWoosh.play();
      break;
    case 3: //NERVETRIGGER
      nerveTrigger.play();
      break;
  }
}
