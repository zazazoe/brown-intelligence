
int SENSOR_SIDE = 0;
int MOTOR_SIDE  = 1;

int bigButton   =42;   //projector:42   //laptop:32
int smallButton =22;  //projector:22    //laptop:16
    
//int nrOfButtons = 4;
//int buttonSize = 40;

//int buttonX = 50;
//int buttonHeight1 = 200;
//int buttonHeight2 = 150;
//int buttonHeight3 = 100;
//int buttonHeight4 = 50;

//int exitX = 50;
//int exitY = 50;

boolean brainButton  = false;
boolean brainArmButton     = false;
boolean brainBladderButton = false;
boolean brainLegButton     = false;
boolean deviceButton = false;
boolean deviceRings  = false;
boolean deviceDevice = false;
boolean armButton    = false;
boolean bladderButton = false;
boolean legButton    = false;
boolean heartButton  = false;

int timeOutStart=0;
int timeOut=50;
int particleFrequency = 30;

PImage  UI;
PVector UIexitpos = new PVector(1820, 995);        //projector:1820, 995  //laptop:1364, 836
PImage  UIleg;    
PVector UIlegpos = new PVector(79, 980);           //projector:79, 980    //laptop:59, 825
PImage  UIbladder;
PVector UIbladderpos = new PVector(79, 874);       //projector:79, 874    //laptop:59, 745
PImage  UIarm;
PVector UIarmpos = new PVector(79, 767);           //projector:79, 767    //laptop:59, 665
PImage  UIheart;
PVector UIheartpos = new PVector(79, 661);         //projector:79, 661    //laptop:59, 585
PImage  UIbrain;
PVector UIbrainpos = new PVector(79, 555);         //projector:79, 555    //laptop:59, 505
PImage  UIbrainBladder;
PVector UIbrainbladderpos = new PVector(178, 550); //projector:178, 550   //laptop:134, 505
PImage  UIbrainArm;
PVector UIbrainarmpos = new PVector(155, 498);     //projector:155, 498   //laptop:116, 463
PImage  UIbrainLeg;
PVector UIbrainlegpos = new PVector(155, 603);     //projector:155, 603   //laptop:116, 542
PImage  UIdevice;
PVector UIdevicepos = new PVector(79, 420);        //projector:79, 420    //laptop:59, 405
PImage  UIdeviceRings;
PVector UIdeviceringspos = new PVector(161, 390);  //projector:161, 390   //laptop:121, 382
PImage  UIdeviceDevice;
PVector UIdevicedevicepos = new PVector(161, 446); //projector:161, 446   //laptop:121, 424


int activatedButton=0;

void renderUI(){
  image(UI, 0,0);
  if(brainButton)  image(UIbrain, 0,0);
  if(deviceButton) image(UIdevice, 0,0);
  if(deviceRings)  image(UIdeviceRings, 0,0);
  if(deviceDevice) image(UIdeviceDevice, 0,0);
  if(deviceRings)  image(deviceRingsOverlay, 0,0);
  if(deviceDevice) image(deviceDeviceOverlay, 0,0);
  
  //if(legButton)  image(UIleg, 0,0);
  //if(armButton)  image(UIarm, 0,0);
}

void updateUI(float mX, float mY){
  //if(mousePressed) checkButtons(new PVector(mX, mY));
  
  if(activatedButton>0){
    switch(activatedButton){
      case 1:
        if(frameCount%particleFrequency == 0) sendNerveBurst(leg, SENSOR_SIDE);
        image(UIleg,0,0);
        println("leg nerves");
        break;
      case 2:
        if(frameCount%particleFrequency == 0) sendNerveBurst(arm, SENSOR_SIDE);
        image(UIarm,0,0);
        println("arm nerves");
        break;
      case 3:
        if(frameCount%particleFrequency == 0) sendNerveBurst(heart, SENSOR_SIDE);
        image(UIheart,0,0);
        println("heart nerves");
        break;
      case 4:
        if(frameCount%particleFrequency == 0) sendNerveBurst(bladder, SENSOR_SIDE);
        image(UIbladder,0,0);
        println("bladder nerves");
        break;
      //case 5:
      //  image(UIbrain,0,0);
      //  println("brain button opens");
      //  break;
      //case 6:
      //  image(UIdevice,0,0);
      //  println("device button opens");
      //  break;
      case 7:
        if(frameCount%particleFrequency == 0) sendNerveBurst(arm, MOTOR_SIDE);
        image(UIbrainArm,0,0);
        println("arm motor");
        break;
      case 8:
        if(frameCount%particleFrequency == 0) sendNerveBurst(leg, MOTOR_SIDE);
        image(UIbrainLeg,0,0);
        println("leg motor");
        break;
      case 9:
        if(frameCount%particleFrequency == 0) sendNerveBurst(bladder, MOTOR_SIDE);
        image(UIbrainBladder,0,0);
        println("bladder motor");
        break;
      //case 10:
      //  image(UIdeviceRings,0,0);
      //  println("device ring explanation");
      //  break;
      //case 11:
      //  image(UIdeviceDevice,0,0);
      //  println("device explanation");
      //  break;
      //case 100: //exit
      //  if(mousePressed) switchToIdle=true;    
      //  break;
    }
  }
}

void checkButtons(PVector mouse){
  //if(mouse.dist(UIlegpos)<=bigButton){
  //  //leg sensor
  //  legButton = checkButton(legButton);
  //  updateActivatedButton(legButton, 1);
  //  brainButton=false;
  //}
  //if(mouse.dist(UIarmpos)<=bigButton){
  //  //arm sensor
  //  armButton = checkButton(armButton);
  //  updateActivatedButton(armButton, 2);
  //  brainButton=false;
  //}
  //if(mouse.dist(UIheartpos)<=bigButton){
  //  //heart sensor
  //  heartButton = checkButton(heartButton);
  //  updateActivatedButton(heartButton, 3);
  //  brainButton=false;
  //}
  //if(mouse.dist(UIbladderpos)<=bigButton){
  //  //bladder sensor
  //  bladderButton = checkButton(bladderButton);
  //  updateActivatedButton(bladderButton, 4);
  //  brainButton=false;
  //}
  //if(mouse.dist(UIbrainarmpos)<=smallButton && brainButton){
  //  //arm motor (brain)
  //  brainArmButton = checkButton(brainArmButton);
  //  updateActivatedButton(brainArmButton, 7);
  //}
  //if(mouse.dist(UIbrainlegpos)<=smallButton && brainButton){
  //  //leg motor (brain)
  //  brainLegButton = checkButton(brainLegButton);
  //  updateActivatedButton(brainLegButton, 8);
  //}
  //if(mouse.dist(UIbrainbladderpos)<=smallButton && brainButton){
  //  //bladder motor (brain)
  //  brainBladderButton = checkButton(brainBladderButton);
  //  updateActivatedButton(brainBladderButton, 9);
  //}
  
  //if(mouse.dist(UIbrainpos)<=bigButton){
  //  //brain --> unfold menu
  //  if(millis()-timeOutStart>timeOut){
  //    timeOutStart = millis(); 
  //    if(!brainButton){
  //      brainButton = true;
  //      deviceButton = false;
  //      deviceDevice = false;
  //      deviceRings = false;
  //    } else {
  //      brainButton = false;
  //    }
  //  }
  //  timerStart = millis();
  //}
  //if(mouse.dist(UIdevicepos)<=bigButton){
  //  //device --> unfold menu
  //  if(millis()-timeOutStart>timeOut){
  //    timeOutStart = millis();
  //    if(!deviceButton){
  //      deviceButton = true;
  //      brainButton = false;
  //    } else {
  //      deviceButton = false;
  //      deviceDevice = false;
  //      deviceRings = false;
  //    }
  //  }
  //  timerStart = millis();
  //}
  //if(mouse.dist(UIdeviceringspos)<=smallButton && deviceButton){
  //  //show device rings explanation
  //  if(millis()-timeOutStart>timeOut){
  //    timeOutStart = millis();
  //    if(!deviceRings){
  //      deviceRings = true;
  //      deviceDevice = false;
  //    } else {
  //      deviceRings = false;
  //    }
  //  }
  //  timerStart = millis();
  //}
  //if(mouse.dist(UIdevicedevicepos)<=smallButton && deviceButton){
  //  //show device explanation
  //  if(millis()-timeOutStart>timeOut){
  //    timeOutStart = millis();
  //    if(!deviceDevice){
  //      deviceDevice = true;
  //      deviceRings = false;
  //    } else {
  //      deviceDevice = false;
  //    }
  //  }
  //  timerStart = millis();
  //}
  
  //if(mouse.dist(UIexitpos)<=bigButton){
  //  //exit
  //  if(millis()-timeOutStart>timeOut){
  //    timeOutStart = millis();
  //    deviceRings  = false;
  //    deviceDevice = false;
  //    deviceButton = false;
  //    brainButton  = false; 
  //    timerStart   = millis();
      
  //    switchToIdle = true;
  //  }
  //  println("exit button pressed");
  //}
}

boolean checkButton(boolean buttonActive){
  if(millis()-timeOutStart>timeOut){
      timeOutStart = millis(); 
      if(buttonActive == false){
        buttonActive = true;
      } else {
        buttonActive = false;
      }
    }
  return buttonActive;
}

void updateActivatedButton(boolean buttonActive, int i){
  if(buttonActive){
    activatedButton = i;
  } else {
    activatedButton = 0;
  }
  timerStart = millis();
}
