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
  debug.println(slicerVersion);

  cp5 = new ControlP5(this);
  gui.init();

  timeMonitor.setFrameRate(30);  
  
  //  parser.setExampleFile("cube247.stl");
  parser.setExampleFile("ball12.stl");
  //  parser.setExampleFile("abstaktT.stl");
  //parser.setExampleFile("foxAscii.stl");  
  
  // do this without theard to init all the values
  parser.loadFile();

  //println("done with setup");
  setupDone = true;
}

final String drawTaskName = new String("taskDraw");
void draw() 
{  
  if (focused == false)
    return;

  timeMonitor.startTask(drawTaskName);   
  
  background(0);  // Set background to black  

  if (mousePressed)
    mouseCurrentlyPressed();

  //camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0), width/2.0, height/2.0, 0, 0, 1, 0); 

  preview.draw();

  timeMonitor.stopTask(drawTaskName);
}
