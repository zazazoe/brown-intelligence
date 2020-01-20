
int nrOfButtons = 4;
int buttonSize = 40;

int buttonX = 50;
int buttonHeight1 = 200;
int buttonHeight2 = 150;
int buttonHeight3 = 100;
int buttonHeight4 = 50;

int exitX = 50;
int exitY = 50;


void drawButtons(){
  rectMode(CENTER);
  fill(200);
  rect(buttonX, height-buttonHeight1, buttonSize,buttonSize);
  rect(buttonX, height-buttonHeight2, buttonSize,buttonSize);
  rect(buttonX, height-buttonHeight3, buttonSize,buttonSize);
  rect(buttonX, height-buttonHeight4, buttonSize,buttonSize);
  
  ellipse(width-exitX, exitY, buttonSize, buttonSize);
}

void checkButtons(){
  int button = whichButton();
  println(button);
  
  if(button>0){
    switch(button){
      case 1:
        sendNerveBurst(armMotor);
        break;
      case 2:
        sendNerveBurst(armSensor);
        break;
      case 3:
        sendNerveBurst(legMotor);
        break;
      case 4:
        sendNerveBurst(legSensor);
        break;
      case 100: //exit
        mode = IDLE_MODE;
        updateParticleAmount(curves.size());    
        println("enter idle mode");
        break;
    }
  }
}

int whichButton(){
  int button=0;
  
  if(mouseX>(buttonX-(buttonSize/2)) && mouseX<(buttonX+(buttonSize/2))){
    //a button in the stack
    if(mouseY>(height-buttonHeight1-(buttonSize/2)) && mouseY<(height-buttonHeight1+(buttonSize/2))){
      //is button 1
      button =1;
    } else if(mouseY>(height-buttonHeight2-(buttonSize/2)) && mouseY<(height-buttonHeight2+(buttonSize/2))){
      //is button 2
      button =2;
    } else if(mouseY>(height-buttonHeight3-(buttonSize/2)) && mouseY<(height-buttonHeight3+(buttonSize/2))){
      //is button 3
      button =3;
    } else if(mouseY>(height-buttonHeight4-(buttonSize/2)) && mouseY<(height-buttonHeight4+(buttonSize/2))){
      //is button 4
      button =4;
    }
  } else if(mouseX>(width-exitX - (buttonSize/2)) && mouseX<(width-exitX + (buttonSize/2))){
    if(mouseY>(exitY - (buttonSize/2)) && mouseY<(exitY + (buttonSize/2))){
      //is exit button
      button=100;
    }
  }
  
  return button;
}
