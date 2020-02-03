
ControlP5 cp5;

ColorPicker cpL1;
ColorPicker cpL2;
ColorPicker cpP;

color labelColor = color(255);

void initCP5(){
  
  
  cp5 = new ControlP5(this);
  cp5.getProperties().setFormat(ControlP5.SERIALIZED);

  cp5.setColorBackground(color(150));
  
  //cpL1 = cp5.addColorPicker("curves1")
  //        .setPosition(20, 10)
  //        .setColorValue(color(215, 215, 148, 128))
  //        .setColorLabel(labelColor)
  //        .setLabel("curveColor upper limit")
  //        ;
          
  //cpL2 = cp5.addColorPicker("curves2")
  //        .setPosition(20, 80)
  //        .setColorValue(color(63, 220, 241, 104))
  //        .setColorLabel(labelColor)
  //        .setLabel("curveColor lower limit")
  //        ;
          
  //cpP = cp5.addColorPicker("particles")
  //        .setPosition(20, 150)
  //        .setColorValue(color(248, 252, 255, 197))
  //        .setColorLabel(labelColor)
  //        .setLabel("particle color")
  //        ;

//  cp5.addSlider("translateX")
//     .setRange(0, width)
//     .setValue(480)
//     .setPosition(20, 205)
//     .setSize(100, 10)
//     .setColorLabel(labelColor)
//     ;
     
//  cp5.addSlider("translateY")
//     .setRange(0, height)
//     .setValue(612)
//     .setPosition(20, 220)
//     .setSize(100, 10)
//     .setColorLabel(labelColor)
//     ;
  
//  cp5.addSlider("translateZ")
//     .setRange(-height, height)
//     .setValue(0)
//     .setPosition(20, 235)
//     .setSize(100, 10)
//     .setColorLabel(labelColor)
//     ;
     
  pushMatrix();
  //cp5.addSlider("rotateX")
  //   .setRange(0, 2*PI)
  //   .setValue(0)
  //   .setPosition(20, 250)
  //   .setSize(100, 10)
  //   .setColorLabel(labelColor)
  //   ;   
  //popMatrix();
  
  //cp5.addSlider("rotateY")
  //   .setRange(0, 2*PI)
  //   .setValue(0)
  //   .setPosition(20, 265)
  //   .setSize(100, 10)
  //   .setColorLabel(labelColor)
  //   ;  
  
  //cp5.addSlider("rotateZ")
  //   .setRange(0, 2*PI)
  //   .setValue(0)
  //   .setPosition(20, 280)
  //   .setSize(100, 10)
  //   .setColorLabel(labelColor)
  //   ; 
     
  //cp5.addSlider("particleSize")
  //   .setRange(1, 15)
  //   .setValue(5)
  //   .setPosition(20, 220)
  //   .setSize(100, 10)
  //   .setColorLabel(labelColor)
  //   ;
     
  //cp5.addSlider("particleTrailSize")
  //   .setRange(1, 10)
  //   .setValue(1)
  //   .setPosition(20, 235)
  //   .setSize(100, 10)
  //   .setColorLabel(labelColor)
  //   ;
  
  //cp5.addToggle("renderParticles")
  //   .setPosition(20, 250)
  //   .setSize(10,10)
  //   .setValue(true)
  //   .getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE, CENTER)
  //   ;
  
  //cp5.addToggle("syncParticles")
  //   .setPosition(20, 265)
  //   .setSize(10,10)
  //   .setValue(false)
  //   .getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE, CENTER)
  //   ;
     
  //cp5.addToggle("disperseParticles")
  //   .setPosition(20, 280)
  //   .setSize(10,10)
  //   .setValue(false)
  //   .getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE, CENTER)
  //   ;
  
  //cp5.addSlider("curveWeight")
  //   .setRange(1, 10)
  //   .setValue(3)
  //   .setPosition(20, 310)
  //   .setSize(100, 10)
  //   .setColorLabel(labelColor)
  //   ;
  
  //cp5.addSlider("curveRandX")
  //   .setRange(1, 30)
  //   .setValue(10)
  //   .setPosition(20, 325)
  //   .setSize(100, 10)
  //   .setColorLabel(labelColor)
  //   ;
  
  //cp5.addSlider("curveRandY")
  //   .setRange(1, 30)
  //   .setValue(10)
  //   .setPosition(20, 340)
  //   .setSize(100, 10)
  //   .setColorLabel(labelColor)
  //   ;
  
  //cp5.addSlider("numGenerations")
  //   .setRange(1, 10)
  //   .setValue(5)
  //   .setPosition(20, 355)
  //   .setSize(100, 10)
  //   .setColorLabel(labelColor)
  //   ;
  
  //cp5.addSlider("minBranches")
  //   .setRange(1, 10)
  //   .setValue(1)
  //   .setPosition(20, 370)
  //   .setSize(100, 10)
  //   .setColorLabel(labelColor)
  //   ;
  
  //cp5.addSlider("maxBranches")
  //   .setRange(1, 10)
  //   .setValue(5)
  //   .setPosition(20, 385)
  //   .setSize(100, 10)
  //   .setColorLabel(labelColor)
  //   ;
  
  //cp5.addSlider("segmentMinLength")
  //   .setRange(1, 200)
  //   .setValue(50)
  //   .setPosition(20, 400)
  //   .setSize(100, 10)
  //   .setColorLabel(labelColor)
  //   ;
  
  //cp5.addSlider("segmentMaxLength")
  //   .setRange(1, 700)
  //   .setValue(500)
  //   .setPosition(20, 415)
  //   .setSize(100, 10)
  //   .setColorLabel(labelColor)
  //   ;
  
  //cp5.addSlider("segmentMinRot")
  //   .setRange(0, -180)
  //   .setValue(-60)
  //   .setPosition(20, 430)
  //   .setSize(100, 10)
  //   .setColorLabel(labelColor)
  //   ;
  
  //cp5.addSlider("segmentMaxRot")
  //   .setRange(0, 180)
  //   .setValue(60)
  //   .setPosition(20, 445)
  //   .setSize(100, 10)
  //   .setColorLabel(labelColor)
  //   ;
  
  cp5.addSlider("attractionToOrigin")
     .setRange(1, 60)
     .setValue(15)
     .setPosition(20, 475)
     .setSize(100, 10)
     .setColorLabel(labelColor)
     ;
  
   cp5.addSlider("repulseFromMouse")
     .setRange(1, 60)
     .setValue(25)
     .setPosition(20, 490)
     .setSize(100, 10)
     .setColorLabel(labelColor)
     ;
    
   cp5.addSlider("mouseAffectRadius")
     .setRange(1, 800)
     .setValue(400)
     .setPosition(20, 505)
     .setSize(100, 10)
     .setColorLabel(labelColor)
     ;
   
  // cp5.addToggle("fixEndPoints")
  //   .setPosition(20, 520)
  //   .setSize(10,10)
  //   .setValue(true)
  //   .getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE, CENTER)
  //   ;
     
  //cp5.addSlider("curveOpacityMin")
  //   .setRange(0.0, 1.0)
  //   .setValue(0.4)
  //   .setPosition(20, 550)
  //   .setSize(100, 10)
  //   .setColorLabel(labelColor)
  //   ;
     
  //cp5.addSlider("curveFadeOutSpeed")
  //   .setRange(0.001, 0.10)
  //   .setValue(0.005)
  //   .setPosition(20, 565)
  //   .setSize(100, 10)
  //   .setColorLabel(labelColor)
  //   ;
     
  //by default do not show   
  //cp5.hide();
  
}
