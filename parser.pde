Parser parser = new Parser();

void parserLoadFileThread()
{
  // no need to check busy, because it will only be called rarely
  thread("parserLoadFile");
}

void parserLoadFile()
{
  parser.loadFile();
}

class Parser
{
  // those scale with faktor
  Vector minLen, maxLen, objectLen;

  private ArrayList<Triangle> triangleList = null;

  String fileName = new String();
  String filePath = null;

  boolean busy = false;

  public void setExampleFile(String name)
  {
    fileName = name;
    filePath = new String(sketchPath() + "/stl-examples/" + name);
    //filePath = "C:/Users/Thomas/Downloads/Ape50Kennzeichen.stl";
  }

  public void loadFile() 
  {
    if (filePath == null)
      return;

    busy = true;

    // create a new empty triangles list
    triangleList = new ArrayList<Triangle>();      

    if (isASCIICheck(filePath))
    {
      loadASCIIFile(filePath);
    } else
    {
      loadBinaryFile(filePath);
    }

    update();

    busy = false;
  }

  private boolean isASCIICheck(String filePath) 
  {
    boolean isASCII = false;

    try {
      //Open the file from the createWriter() example
      BufferedReader reader = createReader(filePath);

      char[] array = new char[80];

      // read first 80 bytes of the header
      int cnt = reader.read(array, 0, array.length);

      String header = new String(array, 0, cnt);

      String[] pieces = split(header, " ");

      isASCII = pieces[0].equals("solid");

      reader.close();
    } 
    catch(IOException e) {
      e.printStackTrace();
    }   

    return isASCII;
  }

  public void loadASCIIFile(String filePath) 
  {
    try {
      //Open the file from the createWriter() example
      BufferedReader reader = createReader(filePath);
      String line = null;

      ParseToken p = ParseToken.NONE;

      Triangle tempTriangle = new Triangle();

      while ((line = reader.readLine()) != null) {
        line = trim(line);
        String[] pieces = split(line, " ");

        if (pieces.length == 0)
          continue;

        //debug.println(line);

        switch(p)
        {
        case NONE :
          if (pieces[0].equals("outer"))
          {
            //debug.println("start triangle");
            p = ParseToken.P1;
          }
          break;
        case P1:
          tempTriangle.p1.setData(pieces[1], pieces[2], pieces[3]);        
          p = ParseToken.P2;
          break;
        case P2:
          tempTriangle.p2.setData(pieces[1], pieces[2], pieces[3]);        
          p = ParseToken.P3;
          break;
        case P3:
          tempTriangle.p3.setData(pieces[1], pieces[2], pieces[3]);       
          p = ParseToken.NONE;

          // create a deep copy
          Triangle newTriangle = new Triangle(tempTriangle);

          triangleList.add(newTriangle);
          break;
        }
      }
      reader.close();
    } 
    catch(IOException e) {
      e.printStackTrace();
    }
  } 

  public void loadBinaryFile(String fileName) 
  {
    try {
      DataInputStream stream = new DataInputStream(new FileInputStream(fileName));

      // skip header
      byte[] header = new byte[80];
      stream.read(header);

      // do not use this number now
      Integer.reverseBytes(stream.readInt());

      while (stream.available() > 0 ) {
        float[] normal = new float[3];
        for (int i = 0; i < normal.length; i++) {
          normal[i] = Float.intBitsToFloat(Integer.reverseBytes(stream.readInt()));
        }   

        Vector[] vectors = new Vector[3];
        for (int i = 0; i < vectors.length; i++) {
          float[] values = new float[3];
          for (int d = 0; d < values.length; d++) {
            values[d] = Float.intBitsToFloat(Integer.reverseBytes(stream.readInt()));
          }
          vectors[i] = new Vector(values[0], values[1], values[2]);
        }

        // those two bytes should always be zeros
        Short.reverseBytes(stream.readShort()); // not used (yet)

        triangleList.add(new Triangle(vectors[0], vectors[1], vectors[2]));
      }

      stream.close();
    } 
    catch(IOException e) {
      e.printStackTrace();
    }
  } 

  public void update()
  {
    minLen = new Vector(Float.MAX_VALUE, Float.MAX_VALUE, Float.MAX_VALUE); 
    maxLen = new Vector(-Float.MAX_VALUE, -Float.MAX_VALUE, -Float.MAX_VALUE); 

    for (Triangle t : triangleList)
    {
      updateMinMaxLen(t);
    }

    objectLen = new Vector(maxLen.getData());
    objectLen.minus(minLen);

    // sortiert die liste nach z values
    Collections.sort(triangleList, new TriangleComparator());

    updateBoxerThread();
  }

  public void draw()
  {
    if (busy)
      return;

    for (Triangle t : triangleList)
    {
      float rowsPercent = 0;
      if (gui.sliderRows.getMax() != 0)
        rowsPercent = gui.sliderRows.getValue() / gui.sliderRows.getMax();

      if (t.getMinZ() > maxLen.z * rowsPercent)
        continue;

      // im data array werden die werte schon ohne minLen abgelegt
      float xMin = minLen.x;
      float yMin = minLen.y;
      float zMin = minLen.z;

      float f = boxer.scaleFaktor;

      beginShape();
      vertex((t.p1.x - xMin) * f, (t.p1.y - yMin) * f, (t.p1.z - zMin) * f);
      vertex((t.p2.x - xMin) * f, (t.p2.y - yMin) * f, (t.p2.z - zMin) * f);
      vertex((t.p3.x - xMin) * f, (t.p3.y - yMin) * f, (t.p3.z - zMin) * f);
      endShape();
    }
  }

  public int getListSize()
  {
    if (triangleList == null)
      return 0;

    return triangleList.size();
  }

  public Triangle getTriangle(int i)
  {
    if (i < 0 || i > getListSize() - 1)
      return null;

    return triangleList.get(i);
  }

  float getRadiusMaxXY()
  {
    // the centerpoint is half of objectLen, z will be ignored    
    Vector offset = new Vector(objectLen.getData());
    offset.multiply(0.5);
    offset.plus(minLen);

    //println("offset: " + offset.toString());

    float r = 0;
    for (Triangle t : triangleList)
    {      
      r = max(r, t.getRadiusMaxXY(offset));
    }

    return r;
  }

  // private
  private void updateMinMaxLen(Triangle t)
  {
    minLen.x = min(minLen.x, t.getMinX());
    maxLen.x = max(maxLen.x, t.getMaxX());

    minLen.y = min(minLen.y, t.getMinY());
    maxLen.y = max(maxLen.y, t.getMaxY());

    minLen.z = min(minLen.z, t.getMinZ());
    maxLen.z = max(maxLen.z, t.getMaxZ());
  }

  void rotate()
  {
    for (Triangle t : triangleList)
    {
      t.rotate();
    }
    update();
  }

  public void printReport()
  {
    debug.println("Parser Report:");
    debug.println("  min: " + minLen.toString());
    debug.println("  max: " + maxLen.toString());
    debug.println("  len: " + objectLen.toString());
  };

  public void printTriangles()
  {
    debug.println("Found " + triangleList.size() + " Triangles"); 

    for (int i = 0; i < triangleList.size(); i++) 
    {
      debug.println(i + ":");

      triangleList.get(i).toTerminal();
    }
  }
}

public enum ParseToken
{
  NONE, P1, P2, P3
}
