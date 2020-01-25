
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
  //println(button);
  
  if(button>0){
    switch(button){
      case 1:
        //sendNerveBurst(arm, RIGHT_SIDE);
        //println("arm nerves");
        if(mousePressed && frameCount%4 == 0) sendNerveBurst(leg, LEFT_SIDE);
        image(UIleg,0,0);
        println("leg nerves");
        break;
      case 2:
        //sendNerveBurst(arm, LEFT_SIDE);
        //println("arm brain");
        if(mousePressed && frameCount%4 == 0) sendNerveBurst(arm, LEFT_SIDE);
        image(UIarm,0,0);
        println("arm nerves");
        break;
      case 3:
        //sendNerveBurst(leg, RIGHT_SIDE);
        //println("leg nerves");
        if(mousePressed && frameCount%4 == 0) sendNerveBurst(heart, LEFT_SIDE);
        image(UIheart,0,0);
        println("heart nerves");
        break;
      case 4:
        //sendNerveBurst(leg, LEFT_SIDE);
        //println("leg brain");
        if(mousePressed && frameCount%4 == 0) sendNerveBurst(bladder, LEFT_SIDE);
        image(UIbladder,0,0);
        println("bladder nerves");
        break;
      case 5:
        if(brainButton){
          image(UIbrain,0,0);
        }
        println("brain button opens");
        break;
      case 6:
        if(brainButton){
          image(UIdevice,0,0);
        }
        println("device button opens");
        break;
      case 7:
        if(mousePressed && frameCount%4 == 0) sendNerveBurst(arm, RIGHT_SIDE);
        image(UIbrainArm,0,0);
        println("arm motor");
        break;
      case 8:
        if(mousePressed && frameCount%4 == 0) sendNerveBurst(leg, RIGHT_SIDE);
        image(UIbrainLeg,0,0);
        println("leg motor");
        break;
      case 9:
        if(mousePressed && frameCount%4 == 0) sendNerveBurst(bladder, RIGHT_SIDE);
        image(UIbrainBladder,0,0);
        println("bladder motor");
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
  if(mouse.dist(UIbrainpos)<=bigButton && mousePressed && millis()-timeOutStart>timeOut){
    //brain --> unfold menu
    if(mousePressed && millis()-timeOutStart>timeOut){
      timeOutStart = millis(); 
      if(!brainButton){
        brainButton = true;
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
      } else {
        deviceButton = false;
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
    //if shows device, stop showing device
    button = 10;
  }
  if(mouse.dist(UIdevicedevicepos)<=smallButton && deviceButton){
    //show device explanation
    //if shows rings, stop showing rings
    button = 11;
  }
  
  if(mouse.dist(UIexitpos)<=bigButton){
    //device --> unfold menu
    deviceButton = true;
    button = 100;
    println("exit button pressed");
  }
  
  
  //if(mouseX>(buttonX-(buttonSize/2)) && mouseX<(buttonX+(buttonSize/2))){
  //  //a button in the stack
  //  if(mouseY>(height-buttonHeight1-(buttonSize/2)) && mouseY<(height-buttonHeight1+(buttonSize/2))){
  //    //is button 1
  //    button =1;
  //  } else if(mouseY>(height-buttonHeight2-(buttonSize/2)) && mouseY<(height-buttonHeight2+(buttonSize/2))){
  //    //is button 2
  //    button =2;
  //  } else if(mouseY>(height-buttonHeight3-(buttonSize/2)) && mouseY<(height-buttonHeight3+(buttonSize/2))){
  //    //is button 3
  //    button =3;
  //  } else if(mouseY>(height-buttonHeight4-(buttonSize/2)) && mouseY<(height-buttonHeight4+(buttonSize/2))){
  //    //is button 4
  //    button =4;
  //  }
  //} else if(mouseX>(width-exitX - (buttonSize/2)) && mouseX<(width-exitX + (buttonSize/2))){
  //  if(mouseY>(exitY - (buttonSize/2)) && mouseY<(exitY + (buttonSize/2))){
  //    //is exit button
  //    button=100;
  //  }
  //}
  
  return button;
}
