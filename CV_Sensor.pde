import gab.opencv.*;
import java.awt.Rectangle;
import processing.video.*;
import controlP5.*;
import ch.bildspur.realsense.*;

RealSenseCamera camera = new RealSenseCamera(this);

OpenCV opencv;
ArrayList<Contour> contours;

int threshold = 65;
int blobSizeThreshold = 100;
int blurSize = 5;

void initCV(){
  camera.start(640, 480, 30, true, false);
 
  opencv = new OpenCV(this, 640, 480);
  contours = new ArrayList<Contour>(); 
}

void updateCV(){
  camera.readFrames();
  camera.createDepthImage(0, 2100);
  
  opencv.loadImage(camera.getDepthImage());
  //src = opencv.getSnapshot();
  
  opencv.threshold(threshold);
  opencv.dilate();
  opencv.erode();
  opencv.blur(blurSize);
  
  contours = opencv.findContours(true, true);  
  
  displayContoursBoundingBoxes();
}

void displayContoursBoundingBoxes() {  
  blobCount=0;
  
  for (int i=0; i<contours.size(); i++) {
    
    Contour contour = contours.get(i);
    Rectangle r = contour.getBoundingBox();
    
    if ((r.width < blobSizeThreshold || r.height < blobSizeThreshold))
      continue;
    
    float rx = map(r.x, 0, 640, 0, width);
    float ry = map(r.y, 0, 480, 0, height);
    float rwidth = map(r.width, 0, 640, 0, width);
    float rheight = map(r.height, 0, 480, 0, height);
    
    blobx = rx+(rwidth/2);
    bloby = ry+(rheight/2);
    
    //stroke(255, 0, 0);
    //fill(255, 0, 0, 150);
    //strokeWeight(2);
    //rect(rx, ry, rwidth, rheight);
    //noStroke();
    //fill(255, 255, 0);
    //ellipse(blobx, bloby, 10,10);
        
    updateCurvePoints();
    blobCount++;  
  }
  
  println(blobCount);

}
