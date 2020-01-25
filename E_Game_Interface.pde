
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


void drawButtons(){
  rectMode(CENTER);
  fill(200);
  rect(buttonX, height-buttonHeight1, buttonSize,buttonSize);
  rect(buttonX, height-buttonHeight2, buttonSize,buttonSize);
  rect(buttonX, height-buttonHeight3, buttonSize,buttonSize);
  rect(buttonX, height-buttonHeight4, buttonSize,buttonSize);
  
  ellipse(width-exitX, exitY, buttonSize, buttonSize);
}

void checkButtons(PVector mouse){
  int button = whichButton(mouse);

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
    button = 100;
    println("exit button pressed");
  }
  
  return button;
}
