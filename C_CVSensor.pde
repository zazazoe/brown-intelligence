import gab.opencv.*;
import java.awt.Rectangle;
import processing.video.*;
import controlP5.*;
import ch.bildspur.realsense.*;

RealSenseCamera camera = new RealSenseCamera(this);

OpenCV opencv;
ArrayList<Contour> contours;
boolean displayContours = false;

int threshold = 65;
int blobSizeThreshold = 100;
int blurSize = 5;


void initCV(){
  camera.start(480, 270, 30, true, false);
  opencv = new OpenCV(this, 480, 270);
  contours = new ArrayList<Contour>(); 
}

void updateCV(){
  if(frameCount%2==0) camera.readFrames();
  camera.createDepthImage(0, 2100);
  
  opencv.loadImage(camera.getDepthImage());
  opencv.threshold(threshold);
  opencv.dilate();
  opencv.erode();
  opencv.blur(blurSize);
  
  contours = opencv.findContours(true, true);  
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
          particles.get(j).particleBurst(LEFT_SIDE);
        }
      } else if(blobx > width/2) {
        for(int j=0; j<particles.size(); j++){
          particles.get(j).particleBurst(RIGHT_SIDE);
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
