String slicerVersion = "slicer 0.1";

//import java.util.Collections;
//import java.util.Comparator;

import java.io.*;
import java.util.*;
import controlP5.*;


boolean setupDone = false;
void setup() 
{
  size(1200, 800, P3D);
  //fullScreen(P3D);
  smooth();

  debug.init();
  debug.print(slicerVersion);

  cp5 = new ControlP5(this);
  gui.init();

  drawMonitor.setFrameRate(30);  
  
  //parser.loadFile(sketchPath() + "/stl-examples/cube03.stl");
  parser.loadFile(sketchPath() + "/stl-examples/foxBin.stl");
  //parser.loadFile(sketchPath() + "/stl-examples/foxAscii.stl");
  //parser.loadFile("C:/Users/Thomas/Downloads/Ape50Kennzeichen.stl");

  //parser.printTriangles();
  //parser.printReport();
  //boxer.printReport();

  println("done with setup");
  setupDone = true;
}

void draw() 
{
  if (focused == false)
    return;

  background(0);  // Set background to black  

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
  float busy = 0;
  float busyAvarage = 0;

  void setFrameRate(int f)
  {
    sollFrames = f;
    frameRate(f);
    gui.sliderFrames.setMax(f + 1);
  }

  void start()
  {
    timeStart = System.nanoTime();
  }

  void stop()
  {
    timeElapsed = System.nanoTime() - timeStart;

    busy = (((timeElapsed / 1000) * sollFrames) / 1000) / 10;

    //println(((float) (timeElapsed/1000) / 1000) + "ms -> * frameRate:" + frameRate + " = " + busy);

    busyAvarage = busyAvarage * 0.95 + busy * 0.05;

    cp5.getController("frames").setValue(frameRate);
    cp5.getController("busy").setValue(busyAvarage);
  }
}
