import controlP5.*;

ControlP5 cp5;

ColorPicker cpL1;
ColorPicker cpL2;
ColorPicker cpP;

void setupCP5(){
  
  cp5 = new ControlP5(this);
   
  cpL1 = cp5.addColorPicker("picker1")
          .setPosition(20, 10)
          .setColorValue(color(215, 215, 148, 128))
          .setColorLabel(0)
          .setLabel("lineColor upper limit")
          ;
          
  cpL2 = cp5.addColorPicker("picker2")
          .setPosition(20, 80)
          .setColorValue(color(63, 220, 241, 104))
          .setColorLabel(0)
          .setLabel("lineColor lower limit")
          ;
          
  cpP = cp5.addColorPicker("picker3")
          .setPosition(20, 150)
          .setColorValue(color(248, 252, 255, 197))
          .setColorLabel(0)
          .setLabel("particle color")
          ;
          
  cp5.addSlider("particleSpeed")
     .setRange(0.001, 0.100)
     .setValue(0.005)
     .setPosition(20, 220)
     .setSize(100, 10)
     .setColorLabel(0)
     ;
     
     
  //by default do not show   
  cp5.hide();
}
