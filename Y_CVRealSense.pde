import gab.opencv.*;
import java.awt.Rectangle;

RealSenseCamera camera = new RealSenseCamera(this);

ArrayList<Contour> contours;
OpenCV  opencv;
boolean displayContours = false;
PImage  background;
PImage  contoursImage;

int     threshold = 39;
int     blobSizeThreshold = 28;
boolean isBackgroundSave = false;
boolean sensorConnected = false;

float   blobx;
float   bloby;
PVector blobDir;
PVector blobDirModel;
PVector blobBack;
PVector blobBackModel;
PVector blobFront;
PVector blobFrontModel;
int     blobBackDist = -200;
int     blobFrontDist = 200;
float   blobxPrev;
float   blobyPrev;
int     blobCount = 0;
int     blobCountPrev = 0;

int     blobCountLeft  = 0;
int     blobCountRight = 0;
int     blobCountLeftPrev  = 0;
int     blobCountRightPrev = 0;

int     bufferSpace = 400;
int     blobTimer=0;
int     giveHintTime = 2000;

void initCV(){
  camera.start(480, 270, 30, true, false);
  opencv     = new OpenCV(this, 480, 270);
  contours   = new ArrayList<Contour>(); 
  background = loadImage("BGcapture.jpg");
  
  blobTimer = millis();
  
}

void updateCV(){
  if(frameCount%2==0) {
    camera.readFrames();
    camera.createDepthImage(0, 2000);
    
    opencv.loadImage(camera.getDepthImage());
    opencv.diff(background);
    opencv.threshold(threshold);
    
    contours = opencv.findContours(true, true);  
  }
    calculateContourBoundingBoxes();
}

void calculateContourBoundingBoxes() {  
  blobCountPrev=blobCount;
  blobCountLeftPrev=blobCountLeft;
  blobCountRightPrev=blobCountRight;
  blobCount=0;
  blobCountLeft=0;
  blobCountRight=0;
  
  for (int i=0; i<contours.size(); i++) {
    
    Contour contour = contours.get(i);
    Rectangle r = contour.getBoundingBox();
    
    if ((r.width < blobSizeThreshold || r.height < blobSizeThreshold))
      continue;
    
    float rx = map(r.x, 0, 480, width, 0);
    float ry = map(r.y, 0, 270, 0, height);
    float rwidth = map(r.width, 0, 480, 0, width);
    float rheight = map(r.height, 0, 270, 0, height);
    
    blobx = rx+(rwidth/2);
    bloby = translateY; //bloby = ry+(rheight/2);
    
    blobBack = new PVector(blobx, bloby, blobBackDist);
    blobFront = new PVector(blobx, bloby, blobFrontDist);
    blobDir = PVector.sub(blobFront, blobBack);
    
    if(displayContours) displayCountours(rx, ry, rwidth, rheight);
    
    if(blobx <= width/2-bufferSpace){
      if(blobCountLeftPrev == 0 && blobCountLeft == 0){ //first on left
        for(int j=0; j<particles.size(); j++){
          for(int k=0;k<5; k++){
            particles.get(j).particleBurst(SENSOR_SIDE, random(3.5,4.5));
          }
          //play sound
          if(!nerveTrigger.isPlaying()) playSound(NERVETRIGGER);
        }
      }
      blobCountLeft +=1;
    } else if(blobx >= width/2+bufferSpace){
      if(blobCountRightPrev == 0 && blobCountRight == 0){ //first on right
        for(int j=0; j<particles.size(); j++){
          for(int k=0;k<5; k++){
            particles.get(j).particleBurst(MOTOR_SIDE, random(3.5,4.5));
          }
          //play sound
          if(!nerveTrigger.isPlaying()) playSound(NERVETRIGGER);
        }
      }
      blobCountRight +=1;
    }
    
    saveModelCoordinates();   
    updateCurvePoints();
    blobCount++;  
  }
  
  //PLACE TO INSERT HINT TO TOUCH/INTERACT
  if(blobCount > 0 && millis()-blobTimer>giveHintTime){
    println("trigger hint");
    blobTimer = millis();
  } else if(blobCount == 0){
    blobTimer = millis();
    blobx = -width;
    bloby = -height;
  }
}

void displayCountours(float rx,float ry,float rwidth,float rheight){
  stroke(255, 0, 0);
  fill(255, 0, 0, 150);
  strokeWeight(2);
  rect(rx, ry, rwidth, rheight);
  noStroke();
  fill(255, 255, 0);
  ellipse(blobx, bloby, 10,10);
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
