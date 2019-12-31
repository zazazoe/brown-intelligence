

void setup(){
  size(500,500);
  background(0);
  stroke(255);
  noFill();
  
  //generate a tree
  generateTree(100, -90, new PVector(width/2, height), 6); //segement length, rotation, starting point, gen limit
}


void draw() {
  background(0);
  render();
  point.update();
  point.display();
}


void mousePressed(){
  background(0);
  generateTree(100, 0, new PVector(0, height/2), 7);
} //<>//
