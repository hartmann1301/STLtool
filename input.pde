void mouseWheel(MouseEvent event) {
  switch(event.getCount()) {
    case(-1):
    preview.zoom += 10;
    break;
    case(1):
    preview.zoom -= 10;
    break;
  }
  //println("set zoom to:" + preview.zoom);
}

void mousePressed() {
  if (mouseButton == CENTER) {
    mouseScroll.init();
  }
}

void mouseCurrentlyPressed()
{
  if (mouseButton == CENTER) {
    mouseScroll.update();
  }
}

void mouseReleased() {
}

//void keyTyped() {
void keyPressed() {
  switch(keyCode) {
    case(LEFT):
    case(RIGHT):
    case(UP):
    case(DOWN):
    // global key class will be checked again in rotate() functions
    //debug.println("rotate " + keyCode);   
    parser.rotate();
    break;
  }

  switch(key) {
    case('+'):
    gui.sliderRows.setValue(gui.sliderRows.getValue() + 1);
    break;
    case('-'):
    gui.sliderRows.setValue(gui.sliderRows.getValue() - 1);
    break;
  }
}

MouseScroll mouseScroll = new MouseScroll();
class MouseScroll
{
  int xStart = 0;
  int yStart = 0;

  void init()
  {    
    //println("init mouseScroll x: " + mouseX + " y:" + mouseY);
    xStart = mouseX;
    yStart = mouseY;
  }

  void update()
  {
    int xDiff = mouseX - xStart;
    int yDiff = mouseY - yStart;    

    if (xDiff == 0 && yDiff == 0)
      return;

    xStart += xDiff;
    yStart += yDiff;

    //println("mouse x: " + xDiff + " y:" + yDiff);    

    final float div = 2;
    xDiff /= div;
    yDiff /= div;

    gui.changeCameraAngleX(-xDiff);
    gui.changeCameraAngleY(-yDiff);
  }
};

/*
ArrayList<Vector> cancerStack = new ArrayList<Vector>();
 
 void initCancer()
 {
 // this point is always outside because the object was moved +1
 addToCancerStack(data.axisLength.x/2, data.axisLength.y/2, data.axisLength.z/2);
 }
 
 void doCancer()
 {
 ArrayList<Vector> tempStack = new ArrayList<Vector>(cancerStack);    
 
 cancerStack.clear();
 
 for (Vector v : tempStack)
 {
 addToCancerStack(v.x + 1, v.y, v.z);
 addToCancerStack(v.x - 1, v.y, v.z);
 addToCancerStack(v.x, v.y + 1, v.z);
 addToCancerStack(v.x, v.y - 1, v.z);
 addToCancerStack(v.x, v.y, v.z + 1);
 addToCancerStack(v.x, v.y, v.z - 1);
 }
 
 println("cancerStack.size: " + cancerStack.size());
 }
 
 
 void addToCancerStack(int x, int y, int z)
 {
 if (x < 0 || y < 0 || z < 0)
 return;  
 
 if (x > data.axisLength.x - 1 || 
 y > data.axisLength.y - 1 || 
 z > data.axisLength.z - 1)
 {
 return;
 }
 
 if (data.getPoint(x, y, z) == BitStatus.SHELL)
 return;
 
 if (data.getPoint(x, y, z) == BitStatus.UNKNOWN)
 return;
 
 data.setPoint(BitStatus.UNKNOWN, x, y, z);
 
 Vector p = new Vector(x, y, z);
 
 //println("add to Stack x:" + p.x + ",  y:" + p.y + ",  z:" + p.z + ")");
 
 cancerStack.add(p);
 }
 */
