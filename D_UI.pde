
int SENSOR_SIDE = 0;
int MOTOR_SIDE  = 1;

int bigButton   = 42;   //projector:42   //laptop:32
int smallButton = 22;  //projector:22    //laptop:16
    
boolean brainButton        = false;
boolean brainArmButton     = false;
boolean brainBladderButton = false;
boolean brainLegButton     = false;
boolean deviceButton       = false;
boolean deviceRings        = false;
boolean deviceDevice       = false;
boolean armButton          = false;
boolean bladderButton      = false;
boolean legButton          = false;
boolean heartButton        = false;

long timeOutStart=0;
int timeOut=100;
int particleFrequency = 30;

int xOffset = 25;

PImage  UI;
PVector UIexitpos = new PVector(1820+xOffset, 995);        //projector:1820, 995  //laptop:1364, 836
PImage  UIleg;    
PVector UIlegpos = new PVector(79+xOffset, 980);           //projector:79, 980    //laptop:59, 825
PImage  UIbladder;
PVector UIbladderpos = new PVector(79+xOffset, 874);       //projector:79, 874    //laptop:59, 745
PImage  UIarm;
PVector UIarmpos = new PVector(79+xOffset, 767);           //projector:79, 767    //laptop:59, 665
PImage  UIheart;
PVector UIheartpos = new PVector(79+xOffset, 661);         //projector:79, 661    //laptop:59, 585
PImage  UIbrain;
PVector UIbrainpos = new PVector(79+xOffset, 555);         //projector:79, 555    //laptop:59, 505
PImage  UIbrainBladder;
PVector UIbrainbladderpos = new PVector(178+xOffset, 550); //projector:178, 550   //laptop:134, 505
PImage  UIbrainArm;
PVector UIbrainarmpos = new PVector(155+xOffset, 498);     //projector:155, 498   //laptop:116, 463
PImage  UIbrainLeg;
PVector UIbrainlegpos = new PVector(155+xOffset, 603);     //projector:155, 603   //laptop:116, 542
PImage  UIdevice;
PVector UIdevicepos = new PVector(79+xOffset, 420);        //projector:79, 420    //laptop:59, 405
PImage  UIdeviceRings;
PVector UIdeviceringspos = new PVector(161+xOffset, 390);  //projector:161, 390   //laptop:121, 382
PImage  UIdeviceDevice;
PVector UIdevicedevicepos = new PVector(161+xOffset, 446); //projector:161, 446   //laptop:121, 424
PImage  UIhint;

int activatedButton=0;

void renderUI(){
  image(UI, 0+xOffset,0);
  if(brainButton)  image(UIbrain, 0+xOffset,0);
  if(deviceButton) image(UIdevice, 0+xOffset,0);
  if(deviceRings)  image(UIdeviceRings, 0+xOffset,0);
  if(deviceDevice) image(UIdeviceDevice, 0+xOffset,0);
  if(deviceRings)  image(deviceRingsOverlay, 0+xOffset,0);
  if(deviceDevice) image(deviceDeviceOverlay, 0+xOffset,0);
}

void updateUI(float mX, float mY){
  if(activatedButton>0){
    switch(activatedButton){
      case 1:
        if(frameCount%particleFrequency == 0) sendNerveBurst(leg, SENSOR_SIDE);
        image(UIleg,0+xOffset,0);
        println("leg nerves");
        break;
      case 2:
        if(frameCount%particleFrequency == 0) sendNerveBurst(arm, SENSOR_SIDE);
        image(UIarm,0+xOffset,0);
        println("arm nerves");
        break;
      case 3:
        if(frameCount%particleFrequency == 0) sendNerveBurst(heart, SENSOR_SIDE);
        image(UIheart,0+xOffset,0);
        println("heart nerves");
        break;
      case 4:
        if(frameCount%particleFrequency == 0) sendNerveBurst(bladder, SENSOR_SIDE);
        image(UIbladder,0+xOffset,0);
        println("bladder nerves");
        break;
      case 7:
        if(frameCount%particleFrequency == 0) sendNerveBurst(arm, MOTOR_SIDE);
        image(UIbrainArm,0+xOffset,0);
        println("arm motor");
        break;
      case 8:
        if(frameCount%particleFrequency == 0) sendNerveBurst(leg, MOTOR_SIDE);
        image(UIbrainLeg,0+xOffset,0);
        println("leg motor");
        break;
      case 9:
        if(frameCount%particleFrequency == 0) sendNerveBurst(bladder, MOTOR_SIDE);
        image(UIbrainBladder,0+xOffset,0);
        println("bladder motor");
        break;
    }
  }
}


boolean checkButton(boolean buttonActive){
  if(millis()-timeOutStart>timeOut){
      timeOutStart = millis(); 
      playSound(BUTTONCLICK);
      if(buttonActive == false){
        playSound(NERVETRIGGER);
        buttonActive = true;
      } else {
        buttonActive = false;
      }
    }
    return buttonActive;
}

void updateActivatedButton(boolean buttonActive, int i){
  resetValue(activatedButton);
  
  if(buttonActive){
    activatedButton = i;
  } else {
    activatedButton = 0;
  }
  timerStart = millis();
}

void resetValue(int prevActiveButton){
  switch(prevActiveButton){
    case 1: //leg
      legButton          = false;
      break;
    case 2: //arm
      armButton          = false;
      break;
    case 3: //heart
      heartButton        = false;
      break;
    case 4: //bladder
      bladderButton      = false;
      break;
    case 7: //Brain-Arm
      brainArmButton     = false;
      break;
    case 8: //Brain-Leg
      brainLegButton     = false;
      break;
    case 9: //Brain-Bladded
      brainBladderButton = false;
      break;
  }
}
