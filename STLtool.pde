String slicerVersion = "slicer 0.1";

import java.util.Collections;
import java.util.Comparator;
import controlP5.*;

boolean setupDone = false;
void setup() 
{
  size(1200, 800, P3D);
  //fullScreen(P3D);
  smooth();

  cp5 = new ControlP5(this);
  gui.init();

  drawMonitor.setFrameRate(30);  

  background(0); // Set background to black

  println(slicerVersion);
  textSize(20);
  text(slicerVersion, 0, 20);


  //parser.loadFile("eve.stl");
  parser.loadFile("stl-examples/abstaktT.stl");
  //parser.loadFile("stl-examples/owl.stl");

  //parser.printTriangles();
  parser.printReport();

  boxer.printReport();

  data.loadParsedTriangles();

  fastData.calc();

  //calcLines();

  println("done with setup");
  setupDone = true;
}

void draw() 
{
  if (focused == false)
    return;
  
  background(0);  // Set background to black  
  text(slicerVersion, 10, 20, 0); 

  drawMonitor.start();  

  if (mousePressed)
    mouseCurrentlyPressed();

  //camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0), width/2.0, height/2.0, 0, 0, 1, 0); 

  preview.draw();

  drawMonitor.stop();
}

DrawMonitor drawMonitor = new DrawMonitor();
class DrawMonitor
{
  int sollFrames = 0;
  long timeStart, timeElapsed;
  float percent = 0;
  float percentAvarage = 0;

  void setFrameRate(int f)
  {
    sollFrames = f;
    frameRate(f);
    gui.framesSlider.setMax(f + 1);
  }

  void start()
  {
    timeStart = System.nanoTime();
  }

  void stop()
  {
    timeElapsed = System.nanoTime() - timeStart;

    percent = (((timeElapsed / 1000) * sollFrames) / 1000) / 10;

    //println(((float) (timeElapsed/1000) / 1000) + "ms -> * frameRate:" + frameRate + " = " + percent);

    percentAvarage = percentAvarage * 0.9 + percent * 0.1;

    cp5.getController("frames").setValue(frameRate);
    cp5.getController("percent").setValue(percentAvarage);
  }
}
