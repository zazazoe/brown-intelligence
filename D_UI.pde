
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
boolean deviceButton = false;
boolean deviceRings  = false;
boolean deviceDevice = false;

int timeOutStart=0;
int timeOut=500;

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


void renderUI(){
  image(UI, 0,0);
  if(brainButton)  image(UIbrain, 0,0);
  if(deviceButton) image(UIdevice, 0,0);
  if(deviceRings)  image(UIdeviceRings, 0,0);
  if(deviceDevice) image(UIdeviceDevice, 0,0);
  if(deviceRings)  image(deviceRingsOverlay, 0,0);
  if(deviceDevice) image(deviceDeviceOverlay, 0,0);
}

void checkButtons(float mX, float mY){
  int button = whichButton(new PVector(mX, mY));

  if(button>0){
    switch(button){
      case 1:
        if(mousePressed && frameCount%4 == 0) sendNerveBurst(leg, SENSOR_SIDE);
        image(UIleg,0,0);
        println("leg nerves");
        break;
      case 2:
        if(mousePressed && frameCount%4 == 0) sendNerveBurst(arm, SENSOR_SIDE);
        image(UIarm,0,0);
        println("arm nerves");
        break;
      case 3:
        if(mousePressed && frameCount%4 == 0) sendNerveBurst(heart, SENSOR_SIDE);
        image(UIheart,0,0);
        println("heart nerves");
        break;
      case 4:
        if(mousePressed && frameCount%4 == 0) sendNerveBurst(bladder, SENSOR_SIDE);
        image(UIbladder,0,0);
        println("bladder nerves");
        break;
      case 5:
        image(UIbrain,0,0);
        println("brain button opens");
        break;
      case 6:
        image(UIdevice,0,0);
        println("device button opens");
        break;
      case 7:
        if(mousePressed && frameCount%4 == 0) sendNerveBurst(arm, MOTOR_SIDE);
        image(UIbrainArm,0,0);
        println("arm motor");
        break;
      case 8:
        if(mousePressed && frameCount%4 == 0) sendNerveBurst(leg, MOTOR_SIDE);
        image(UIbrainLeg,0,0);
        println("leg motor");
        break;
      case 9:
        if(mousePressed && frameCount%4 == 0) sendNerveBurst(bladder, MOTOR_SIDE);
        image(UIbrainBladder,0,0);
        println("bladder motor");
        break;
      case 10:
        image(UIdeviceRings,0,0);
        println("device ring explanation");
        break;
      case 11:
        image(UIdeviceDevice,0,0);
        println("device explanation");
        break;
      case 100: //exit
        if(mousePressed) switchToIdle=true;    
        break;
    }
  }
}

int whichButton(PVector mouse){
  int button=0;

  if(mouse.dist(UIlegpos)<=bigButton){
    //leg sensor
    button = 1;
    timerStart = millis();
  }
  if(mouse.dist(UIarmpos)<=bigButton){
    //arm sensor
    button = 2;
    timerStart = millis();
  }
  if(mouse.dist(UIheartpos)<=bigButton){
    //heart sensor
    button = 3;
    timerStart = millis();
  }
  if(mouse.dist(UIbladderpos)<=bigButton){
    //bladder sensor
    button = 4;
    timerStart = millis();
  }
  if(mouse.dist(UIbrainpos)<=bigButton){
    //brain --> unfold menu
    if(mousePressed && millis()-timeOutStart>timeOut){
      timeOutStart = millis(); 
      if(!brainButton){
        brainButton = true;
        deviceButton = false;
        deviceDevice = false;
        deviceRings = false;
      } else {
        brainButton = false;
      }
    }
    button = 5;
    timerStart = millis();
  }
  if(mouse.dist(UIdevicepos)<=bigButton){
    //device --> unfold menu
    if(mousePressed && millis()-timeOutStart>timeOut){
      timeOutStart = millis();
      if(!deviceButton){
        deviceButton = true;
        brainButton = false;
      } else {
        deviceButton = false;
        deviceDevice = false;
        deviceRings = false;
      }
    }
    button = 6;
    timerStart = millis();
  }
  
  if(mouse.dist(UIbrainarmpos)<=smallButton && brainButton){
    //arm motor
    button = 7;
    timerStart = millis();
  }
  if(mouse.dist(UIbrainlegpos)<=smallButton && brainButton){
    //leg motor
    button = 8;
    timerStart = millis();
  }
  if(mouse.dist(UIbrainbladderpos)<=smallButton && brainButton){
    //bladder motor
    button = 9;
    timerStart = millis();
  }
  
  if(mouse.dist(UIdeviceringspos)<=smallButton && deviceButton){
    //show device rings explanation
    if(mousePressed && millis()-timeOutStart>timeOut){
      timeOutStart = millis();
      if(!deviceRings){
        deviceRings = true;
        deviceDevice = false;
      } else {
        deviceRings = false;
      }
    }
    button = 10;
    timerStart = millis();
  }
  if(mouse.dist(UIdevicedevicepos)<=smallButton && deviceButton){
    //show device explanation
    if(mousePressed && millis()-timeOutStart>timeOut){
      timeOutStart = millis();
      if(!deviceDevice){
        deviceDevice = true;
        deviceRings = false;
      } else {
        deviceDevice = false;
      }
    }
    button = 11;
    timerStart = millis();
  }
  
  if(mouse.dist(UIexitpos)<=bigButton){
    //exit
    if(mousePressed && millis()-timeOutStart>timeOut){
      timeOutStart = millis();
      deviceRings  = false;
      deviceDevice = false;
      deviceButton = false;
      brainButton  = false;
      button = 100;
      timerStart = millis();
    }
    println("exit button pressed");
  }
  return button;
}
