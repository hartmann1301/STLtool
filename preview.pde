Preview preview = new Preview();


class Preview 
{
  public float zoom = 0;

  public void draw()
  {
    pushMatrix();

    // because z should point up not out of the screen  
    rotate90degrees(); 

    // now z is pointing up, y out of the screen and x to the right

    // translate to center of screen
    translate(width/2, 0, -height/2);

    // push or pull object for zoom
    translateForZoom();

    rotatePreview();

    //offset to the object
    translateToPoint(boxer.objectLen, -0.5);  

    // default style, is maybe changed later
    stroke(255);
    lights();

    if (gui.checkbox.getArrayValue()[checkBoxes.coordinateSystem] == On)
    {
      drawCoordinateSystem();
    }

    if (gui.checkbox.getArrayValue()[checkBoxes.arrayBox] == On)
    {
      drawArrayBox();
    }

    switch((int) gui.previewTypeList.getValue()) 
    {
    case 0: 
      drawParsedTriangles();
      break;
    case 1: 
      drawRawData();
      break;
    case 2: 
      fastData.draw();
      break;
    default:
      println("Error unknown preview type");
      break;
    }

    //fastData.draw();

    popMatrix();
  }

  private void translateForZoom()
  {
    int maxDimension = (int) max(boxer.objectLen.x, boxer.objectLen.y, boxer.objectLen.z);

    // default camera height: (height/2.0) / tan(PI*30.0 / 180.0) => (height/2.0) * 0,577 
    float cameraOffsetZ = (height/2.0) / tan(PI*30.0 / 180.0);

    float defaultPosition = cameraOffsetZ - (maxDimension + 50);

    // maybe zoom in or out
    defaultPosition += zoom;

    translate(0, defaultPosition, 0);
  }

  private void rotatePreview()
  {
    if (gui.checkbox.getArrayValue()[checkBoxes.autoRotation] == On)
    {
       gui.changeCameraAngleX(1);
    }

    //dann kann um z gedreht werden um das objekt zu zeigen
    rotateZ(radians(-90)+ radians(gui.previewAngle.getArrayValue()[0]));

    //rotateX(radians(gui.previewAngle.getArrayValue()[0]));
    rotateY(radians(gui.previewAngle.getArrayValue()[1]));
  }



  void translateToPoint(IntV3 p, float f)
  {
    PVector v = new PVector(p.x, p.y, p.z);

    translateToPoint(v, f);
  }

  void translateToPoint(Vector p, float f)
  {
    PVector v = new PVector(p.x, p.y, p.z);

    translateToPoint(v, f);
  }

  void translateToPoint(PVector p)
  {
    translateToPoint(p, 1.0);
  }

  void translateToPoint(PVector p, float f)
  {
    translate(p.x * f, p.y * f, p.z * f);
  }

  void rotate90degrees()
  {
    //z kommt normal aus dem Bildschirm, soll aber nach oben zeigen
    rotateX(radians(90));
  }

  void drawRawData()
  {
    for (int x = 0; x < data.axisLength.x - 1; x++)
    {
      for (int y = 0; y < data.axisLength.y - 1; y++)
      {
        for (int z = 0; z < data.axisLength.z - 1; z++)
        {
          if (rows < z)
            continue;

          BitStatus s = data.getPoint(x, y, z);

          if (s == BitStatus.OUTSIDE)
            continue;

          if (s == BitStatus.INSIDE)
            continue;

          drawBox(s, x, y, z);
        }
      }
    }
  }

  void drawBox(BitStatus s, int xPos, int yPos, int zPos)
  {
    drawBox(s, xPos, yPos, zPos, 1, 1, 1);
  }

  void drawBox(BitStatus s, int xPos, int yPos, int zPos, int xLen, int yLen, int zLen)
  {
    //println("set Box at x: " + x + " y:" + y + " z:" + z);

    color fillColor = 0;

    if (rows == zPos)
    {
      s = BitStatus.UNKNOWN;
    }

    switch (s) {
    case UNKNOWN: 
      fillColor = color(255, 0, 0); // red, no transparency
      break;
    case SHELL: 
      fillColor = color(0, 255, 0, 50); // 
      break;
    case INSIDE: 
      fillColor = color(0, 0, 255, 255); // 
      break;
    case OUTSIDE: 
      fillColor = color(255, 255, 255, 20); // is not painted anyways 
      break;
    }
    
    color strokeColor = color(255, 255, 255);   
    drawBox(strokeColor, fillColor, xPos, yPos, zPos, xLen, yLen, zLen);
  }

  void drawBox(color s, color f, float xPos, float yPos, float zPos, float xLen, float yLen, float zLen)
  {
    pushMatrix();
    pushStyle();
    
    stroke(s);
    fill(f);
    
    // hier werden die werte zurückgerechnet
    final float fak = boxer.sliceFaktor;
    xPos *= fak;
    yPos *= fak;
    zPos *= fak;    
    xLen *= fak;
    yLen *= fak;
    zLen *= fak;      
    
    translate(xPos, yPos, zPos);
    box(xLen, yLen, zLen);

    popStyle();
    popMatrix();  
  }

  void drawParsedTriangles()
  {   
    for (Triangle t : parser.triangleList)
    {
      if (rows < t.getMinZ())
        continue;

      // im data array werden die werte schon ohne minLen abgelegt
      float xMin = parser.minLen.x;
      float yMin = parser.minLen.y;
      float zMin = parser.minLen.z;

      beginShape();
      vertex(t.p1.x - xMin, t.p1.y - yMin, t.p1.z - zMin);
      vertex(t.p2.x - xMin, t.p2.y - yMin, t.p2.z - zMin);
      vertex(t.p3.x - xMin, t.p3.y - yMin, t.p3.z - zMin);     
      endShape();
    }
  }

  void drawCoordinateSystem()
  {
    //line(x1, y1, z1, x2, y2, z2)  
    int lineOffset = 10;

    pushStyle();
    pushMatrix();

    // this is the coordinate system offset
    translateToPoint(parser.minLen, -1.0);

    strokeWeight(4);

    stroke(color(255, 0, 0)); // x = red 
    line(0, 0, 0, parser.maxLen.x + lineOffset, 0, 0); 

    stroke(color(0, 255, 0)); // y = green 
    line(0, 0, 0, 0, parser.maxLen.y + lineOffset, 0);

    stroke(color(0, 0, 255)); // z = blue
    line(0, 0, 0, 0, 0, parser.maxLen.z + lineOffset);

    popMatrix();
    popStyle();
  }
  
  void drawObjectLenString()
  {
    // TODO do a better format
    text(boxer.objectLen.toString() + " mm", 0, 20);
  }
  
  void drawArrayBox()
  {
    pushStyle();
    pushMatrix();

    stroke(stdColor.white);
    noFill();
    
    float f = boxer.sliceFaktor;

    translate(-f / 2, -f / 2, -f / 2);

    pushMatrix();
    rotateZ(radians(90));
    rotateX(radians(-90));
    textSize(5);
    text(data.axisLength.toString(), 0, 10);
    drawObjectLenString();
    popMatrix();

    int xLen = data.axisLength.x;
    int yLen = data.axisLength.y;
    int zLen = data.axisLength.z;    

    for (int i = 1; i < xLen; i++)
    {
      float xOffset = i * f;
      line(xOffset, 0, 0, xOffset, float(yLen) * f, 0);  
    }

    for (int i = 1; i < yLen; i++)
    {
      float yOffset = i * f;
      line(0, yOffset, 0, float(xLen) * f, yOffset, 0);  
    }

    Vector origin = new Vector(xLen, yLen, zLen); 
    origin.multiply(f);

    // go to Center because box draws from center
    translateToPoint(origin, 0.5);

    box(xLen * f, yLen * f, zLen * f);

    popMatrix();
    popStyle();
  }
};
