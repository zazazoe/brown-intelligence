
int SENSOR_SIDE = 0;
int MOTOR_SIDE  = 1;

int nrOfButtons = 4;
int buttonSize = 40;

int buttonX = 50;
int buttonHeight1 = 200;
int buttonHeight2 = 150;
int buttonHeight3 = 100;
int buttonHeight4 = 50;

int exitX = 50;
int exitY = 50;

boolean brainButton  = false;
boolean deviceButton = false;
boolean deviceRings  = false;
boolean deviceDevice = false;

int timeOutStart=0;
int timeOut=500;

PImage  UI;
PVector UIexitpos = new PVector(1364, 836);
PImage  UIleg;
PVector UIlegpos = new PVector(59, 825);
PImage  UIbladder;
PVector UIbladderpos = new PVector(59, 745);
PImage  UIarm;
PVector UIarmpos = new PVector(59, 665);
PImage  UIheart;
PVector UIheartpos = new PVector(59, 585);
PImage  UIbrain;
PVector UIbrainpos = new PVector(59, 505);
PImage  UIbrainBladder;
PVector UIbrainbladderpos = new PVector(134, 505);
PImage  UIbrainArm;
PVector UIbrainarmpos = new PVector(116, 463);
PImage  UIbrainLeg;
PVector UIbrainlegpos = new PVector(116, 542);
PImage  UIdevice;
PVector UIdevicepos = new PVector(59, 405);
PImage  UIdeviceRings;
PVector UIdeviceringspos = new PVector(121, 382);
PImage  UIdeviceDevice;
PVector UIdevicedevicepos = new PVector(121, 424);


//void drawButtons(){
//  rectMode(CENTER);
//  fill(200);
//  rect(buttonX, height-buttonHeight1, buttonSize,buttonSize);
//  rect(buttonX, height-buttonHeight2, buttonSize,buttonSize);
//  rect(buttonX, height-buttonHeight3, buttonSize,buttonSize);
//  rect(buttonX, height-buttonHeight4, buttonSize,buttonSize);
  
//  ellipse(width-exitX, exitY, buttonSize, buttonSize);
//}

void renderUI(){
  image(UI, 0,0);
  if(brainButton)  image(UIbrain, 0,0);
  if(deviceButton) image(UIdevice, 0,0);
  if(deviceRings)  image(UIdeviceRings, 0,0);
  if(deviceDevice) image(UIdeviceDevice, 0,0);
  if(deviceRings)  image(deviceRingsOverlay, 0,0); //NOTE TO SELF: FADE IN SUBTLE
  if(deviceDevice) image(deviceDeviceOverlay, 0,0); //NOTE TO SELF: FADE IN SUBTLE
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
  int bigButton=32;
  int smallButton=16;
  
  if(mouse.dist(UIlegpos)<=bigButton){
    //leg sensor
    button = 1;
  }
  if(mouse.dist(UIarmpos)<=bigButton){
    //arm sensor
    button = 2;
  }
  if(mouse.dist(UIheartpos)<=bigButton){
    //heart sensor
    button = 3;
  }
  if(mouse.dist(UIbladderpos)<=bigButton){
    //bladder sensor
    button = 4;
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
  }
  
  if(mouse.dist(UIbrainarmpos)<=smallButton && brainButton){
    //arm motor
    button = 7;
  }
  if(mouse.dist(UIbrainlegpos)<=smallButton && brainButton){
    //leg motor
    button = 8;
  }
  if(mouse.dist(UIbrainbladderpos)<=smallButton && brainButton){
    //bladder motor
    button = 9;
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
  }
  
  if(mouse.dist(UIexitpos)<=bigButton){
    //exit
    if(mousePressed && millis()-timeOutStart>timeOut){
      timeOutStart = millis();
      button = 100;
    }
    println("exit button pressed");
  }
  
  return button;
}

void loadUIImages(){
  UI              = loadImage("imageAssets/UI/UI.png");
  UIleg           = loadImage("imageAssets/UI/leg.png");
  UIarm           = loadImage("imageAssets/UI/arm.png");
  UIheart         = loadImage("imageAssets/UI/heart.png");
  UIbladder       = loadImage("imageAssets/UI/bladder.png");
  UIbrain         = loadImage("imageAssets/UI/brain.png");
  UIbrainBladder  = loadImage("imageAssets/UI/brain_bladder.png");
  UIbrainArm      = loadImage("imageAssets/UI/brain_arm.png");
  UIbrainLeg      = loadImage("imageAssets/UI/brain_leg.png");
  UIdevice        = loadImage("imageAssets/UI/device.png");
  UIdeviceRings   = loadImage("imageAssets/UI/device_ring.png");
  UIdeviceDevice  = loadImage("imageAssets/UI/device_device.png");
}
