import AULib.*;

void setup(){
  size(500,500);
  
  frameRate(60);
  smooth(8);
  
  //generate a tree
  generateTree(100, -90, new PVector(width/2, height), 6); //segement length, rotation, starting point, gen limit
}

void draw() {
  background(0);
  render();
  
  for(int i=0; i<particles.size(); i++){
    color c = color((100/(i+1))*linesToSave.size(),0,(200/linesToSave.size())*i);
    particles.get(i).update();
    particles.get(i).display(c);
  }
}

void mousePressed(){
  background(0);
  generateTree(100, -90, new PVector(width/2, height), 6);
} //<>//
