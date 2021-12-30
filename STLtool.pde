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
  
  String fileName = new String();
  //fileName = "cube247.stl";
  fileName = "ball12.stl";
  //fileName = "abstaktT.stl";
  //fileName = "foxAscii.stl";  
  
  String filePath = new String(sketchPath() + "/stl-examples/" + fileName);
  //filePath = "C:/Users/Thomas/Downloads/Ape50Kennzeichen.stl";
  parser.loadFile(filePath);

  //parser.printTriangles();

  //println("done with setup");
  setupDone = true;
}

void draw() 
{
  if (focused == false)
    return;

  timeMonitor.startDraw();   
  
  background(0);  // Set background to black  

  if (mousePressed)
    mouseCurrentlyPressed();

  //camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0), width/2.0, height/2.0, 0, 0, 1, 0); 

  preview.draw();

  timeMonitor.stopDraw();
}
