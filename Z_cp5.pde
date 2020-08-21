
ControlP5 cp5;

ColorPicker cpL1;
ColorPicker cpL2;
ColorPicker cpP;

color labelColor = color(255);

void initCP5(){
  cp5 = new ControlP5(this);
  cp5.getProperties().setFormat(ControlP5.SERIALIZED);

  cp5.setColorBackground(color(150));

  cp5.addSlider("particleSize")
     .setRange(1, 15)
     .setValue(2)
     .setPosition(20, 55)
     .setSize(100, 10)
     .setColorLabel(labelColor)
     ;
     
  cp5.addSlider("curveWeight")
     .setRange(1, 10)
     .setValue(1)
     .setPosition(20, 70)
     .setSize(100, 10)
     .setColorLabel(labelColor)
     ;
  
  cp5.addSlider("attractionToOrigin")
     .setRange(1, 60)
     .setValue(1.5)
     .setPosition(20, 85)
     .setSize(100, 10)
     .setColorLabel(labelColor)
     ;
  
   cp5.addSlider("repulseFromMouse")
     .setRange(1, 60)
     .setValue(2.5)
     .setPosition(20, 100)
     .setSize(100, 10)
     .setColorLabel(labelColor)
     ;
    
   cp5.addSlider("mouseAffectRadius")
     .setRange(1, 800)
     .setValue(150  )
     .setPosition(20, 115)
     .setSize(100, 10)
     .setColorLabel(labelColor)
     ;
   
   cp5.addToggle("fixEndPoints")
     .setPosition(20, 130)
     .setSize(10,10)
     .setValue(true)
     .getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE, CENTER)
     ;
     
  cp5.addSlider("curveOpacityMin")
     .setRange(0.0, 1.0)
     .setValue(0.4)
     .setPosition(20, 145)
     .setSize(100, 10)
     .setColorLabel(labelColor)
     ;

  cp5.hide();
  
}
