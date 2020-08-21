
RealSenseCamera camera = new RealSenseCamera(this);

ArrayList<Contour> contours;
OpenCV  opencv;
boolean displayContours = false;
PImage  background;
PImage  contoursImage;

int     threshold = 72;
int     blobSizeThreshold = 48;
boolean isBackgroundSave = false;
boolean sensorConnected = true;

float   blobx;
float   bloby;
PVector blobDir;
PVector blobDirModel;
PVector blobBack;
PVector blobBackModel;
PVector blobFront;
PVector blobFrontModel;
int     blobBackDist = -2000;
int     blobFrontDist = 2000;
float   blobxPrev;
float   blobyPrev;
int     blobCount = 0;
int     blobCountPrev = 0;

int     blobCountLeft  = 0;
int     blobCountRight = 0;
int     blobCountLeftPrev  = 0;
int     blobCountRightPrev = 0;
int     blobCountBuffer = 0;
int     blobCountBufferPrev = 0;

int     bufferSpace = 400;
long    blobTimer=0;
int     giveHintTime = 10000;
long    hintTimer = 0;
int     hintTime = 7000;

boolean displayHint = false;
boolean hintShown = false;

void initCV(){
  camera.start(640, 480, 30, true, false);
  opencv     = new OpenCV(this, 640, 480);
  contours   = new ArrayList<Contour>(); 
  background = loadImage("BGcapture.jpg");
  
  blobTimer = millis();
}

void updateCV(){ 
  blobx = -width;
  bloby = -height;
  blobDir   = new PVector(0,0,0);
  blobBack  = new PVector(0,0,0);
  blobFront = new PVector(0,0,0);
  
  if(sensorConnected && camera.isCameraAvailable()){
    if(frameCount%2==0) {
      camera.readFrames();
      camera.createDepthImage(0, 3000);
      
      opencv.loadImage(camera.getDepthImage());
      opencv.diff(background);
      opencv.threshold(threshold);
      
      contours = opencv.findContours(true, true);  
    }
  }
  
  calculateContourBoundingBoxes();
}

void calculateContourBoundingBoxes() {  
  blobCountPrev=blobCount;
  blobCountLeftPrev=blobCountLeft;
  blobCountRightPrev=blobCountRight;
  blobCountBufferPrev=blobCountBuffer;
  blobCount=0;
  blobCountLeft=0;
  blobCountRight=0;
  blobCountBuffer=0;
  
  if(DEBUG){
    float tmp = map(mouseY, 0, height, -0.2*height, 0.2*height);
    float tmp2 = map(mouseX, 0, width, 2,0);
    blobx = mouseX+tmp2*translateX; 
    bloby = translateY+tmp; 
    
    blobBack = new PVector(blobx, bloby, blobBackDist);
    blobFront = new PVector(blobx, bloby, blobFrontDist);
    blobDir = PVector.sub(blobFront, blobBack);
    saveModelCoordinates();   
    updateCurvePoints();
    blobCount++; 
  } else {
  
    for (int i=0; i<contours.size(); i++) {
      
      Contour contour = contours.get(i);
      Rectangle r = contour.getBoundingBox();
      
      if ((r.width < blobSizeThreshold || r.height < blobSizeThreshold))
        continue;
      
      float rx = map(r.x, 0, 640, 0, width);
      float ry = map(r.y, 0, 480, 0, height);
      float rwidth = map(r.width, 0, 640, 0, width);
      float rheight = map(r.height, 0, 480, 0, height);
      rx = rx + (rwidth/2);
      rx = map(rx, 0, width, width, 0);
      ry = ry + (rheight/2);
      
      float transformY = map(ry, 0, height, -0.2*height, 0.2*height);
      float transformX = map(rx, 0, width, 2,0);
      
      blobx = rx+transformX*translateX;
      bloby = translateY+transformY; 
      
      blobBack = new PVector(blobx, bloby, blobBackDist);
      blobFront = new PVector(blobx, bloby, blobFrontDist);
      blobDir = PVector.sub(blobFront, blobBack);
      
      if(displayContours) displayCountours(rx, ry, rwidth, rheight);
      
      if(rx <= width/2-bufferSpace){
        if(blobCountLeftPrev==0 && blobCountLeft==0 && blobCountBufferPrev==0){ //first on left
          for(int j=0; j<particles.size(); j++){
            for(int k=0;k<5; k++){
              particles.get(j).particleBurst(SENSOR_SIDE, random(3.5,4.5));
            }
            //play sound
            if(!nerveTrigger.isPlaying()) playSound(NERVETRIGGER);
          }
        }
        blobCountLeft +=1;
      } else if(rx >= width/2+bufferSpace){
        if(blobCountRightPrev == 0 && blobCountRight == 0 && blobCountBufferPrev==0){ //first on right
          for(int j=0; j<particles.size(); j++){
            for(int k=0;k<5; k++){
              particles.get(j).particleBurst(MOTOR_SIDE, random(3.5,4.5));
            }
            //play sound
            if(!nerveTrigger.isPlaying()) playSound(NERVETRIGGER);
          }
        }
        blobCountRight +=1;
      } else if(rx >= width/2-bufferSpace && rx <= width/2+bufferSpace){
        blobCountBuffer += 1;
      }
      
      saveModelCoordinates();   
      updateCurvePoints();
      blobCount++;  
    } 
  }
  
  //HINT TO TOUCH/INTERACT
  if(blobCount > 0 && millis()-blobTimer>giveHintTime && !hintShown){
    displayHint = true;
    blobTimer = millis();
    hintTimer = millis();
    hintShown = true;
    println("trigger hint");
  } else if(blobCount == 0){
    blobTimer = millis();
    blobx = -width;
    bloby = -height;
    hintShown = false;
  }
  
  if(millis()-hintTimer>hintTime && displayHint==true){
    displayHint = false;
  }
}

void displayCountours(float rx,float ry,float rwidth,float rheight){
  stroke(255, 0, 0);
  fill(255, 0, 0, 150);
  strokeWeight(2);
  rect(rx-(rwidth/2), ry-(rheight/2), rwidth, rheight);
  noStroke();
  fill(255, 255, 0);
  ellipse(rx, ry, 10,10);
  strokeWeight(20); 
}

void saveModelCoordinates(){
  pushMatrix();
  rotateX(rotateX*-1);
  rotateY(rotateY*-1);
  rotateZ(rotateZ*-1);
  translate(translateX*-1, translateY*-1, translateZ*-1);
  blobBackModel.x = modelX(blobBack.x, blobBack.y, blobBack.z);
  blobBackModel.y = modelY(blobBack.x, blobBack.y, blobBack.z);
  blobBackModel.z = modelZ(blobBack.x, blobBack.y, blobBack.z);
  
  blobFrontModel.x = modelX(blobFront.x, blobFront.y, blobFront.z);
  blobFrontModel.y = modelY(blobFront.x, blobFront.y, blobFront.z);
  blobFrontModel.z = modelZ(blobFront.x, blobFront.y, blobFront.z);
  
  blobDirModel = PVector.sub(blobFrontModel, blobBackModel);
  popMatrix();
}
