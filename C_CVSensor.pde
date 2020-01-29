import gab.opencv.*;
import java.awt.Rectangle;

RealSenseCamera camera = new RealSenseCamera(this);

ArrayList<Contour> contours;
OpenCV  opencv;
boolean displayContours = true;
PImage  background;
PImage  contoursImage;

int     threshold = 39;
int     blobSizeThreshold = 28;
boolean isBackgroundSave = false;
boolean sensorConnected = false;

float   blobx;
float   bloby;
float   blobxPrev;
float   blobyPrev;
int     blobCount = 0;
int     blobCountPrev = 0;

void initCV(){
  camera.start(480, 270, 30, true, false);
  opencv = new OpenCV(this, 480, 270);
  contours = new ArrayList<Contour>(); 
  background = loadImage("BGcapture.jpg");
}

void updateCV(){
  if(frameCount%2==0) {
    camera.readFrames();
    camera.createDepthImage(0, 2500);
    
    opencv.loadImage(camera.getDepthImage());
    opencv.diff(background);
    opencv.threshold(threshold);
    //opencv.dilate();
    //opencv.erode();
    //opencv.blur(blurSize);
    
    contours = opencv.findContours(true, true);  
  }
    calculateContourBoundingBoxes();
}

void calculateContourBoundingBoxes() {  
  blobCountPrev=blobCount;
  blobCount=0;
  
  for (int i=0; i<contours.size(); i++) {
    
    Contour contour = contours.get(i);
    Rectangle r = contour.getBoundingBox();
    
    if ((r.width < blobSizeThreshold || r.height < blobSizeThreshold))
      continue;
    
    float rx = map(r.x, 0, 480, 0, width);
    float ry = map(r.y, 0, 270, 0, height);
    float rwidth = map(r.width, 0, 480, 0, width);
    float rheight = map(r.height, 0, 270, 0, height);
    
    blobx = rx+(rwidth/2);
    bloby = ry+(rheight/2);
    
    if(displayContours) displayCountours(rx, ry, rwidth, rheight);
    
    //send pulse on first blob appears on left or right
    if(blobCountPrev == 0 && blobCount == 0){
      if(blobx <= width/2){
        for(int j=0; j<particles.size(); j++){
          particles.get(j).particleBurst(SENSOR_SIDE, random(3.5,4.5));
        }
      } else if(blobx > width/2) {
        for(int j=0; j<particles.size(); j++){
          particles.get(j).particleBurst(MOTOR_SIDE, random(3.5,4.5));
        }
      }
    }
        
    updateCurvePoints();
    blobCount++;  
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
}
