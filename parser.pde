Parser parser = new Parser();

class Parser
{
  // those scale with faktor
  Vector minLen, maxLen, objectLen;

  private ArrayList<Triangle> triangleList;

  public void loadFile(String fileName) 
  {
    //Open the file from the createWriter() example
    BufferedReader reader = createReader(fileName);
    String line = null;

    minLen = new Vector(Float.MAX_VALUE, Float.MAX_VALUE, Float.MAX_VALUE); 
    maxLen = new Vector(-Float.MAX_VALUE, -Float.MAX_VALUE, -Float.MAX_VALUE); 

    triangleList = new ArrayList<Triangle>();    

    try {
      ParseToken p = ParseToken.NONE;

      Triangle tempTriangle = new Triangle();

      while ((line = reader.readLine()) != null) {
        line = trim(line);
        String[] pieces = split(line, " ");

        if (pieces.length == 0)
          continue;

        //println(line);

        switch(p)
        {
        case NONE :
          if (pieces[0].equals("outer"))
          {
            //println("start triangle");
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

          updateMinMaxLen(newTriangle);

          triangleList.add(newTriangle);

          //newTriangle.toTerminal();

          //println("end triangle");
          break;
        }
      }
      reader.close();
    } 
    catch(IOException e) {
      e.printStackTrace();
    }

    objectLen = new Vector(maxLen.getData());
    objectLen.minus(minLen);

    // sortiert die liste nach z values
    Collections.sort(triangleList, new TriangleComparator());

    skaler.setFaktor(1.0);
  } 

  public int getListSize()
  {
    return triangleList.size();
  }

  public Triangle getTriangle(int i)
  {
    if (i < 0 || i > getListSize() - 1)
      return null;

    return triangleList.get(i);
  }

  public void printReport()
  {
    println("Parser Report:");
    println("  min: " + minLen.toString());
    println("  max: " + maxLen.toString());
    println("  len: " + objectLen.toString());
  };

  public void printTriangles()
  {
    println("Found " + triangleList.size() + " Triangles"); 

    for (int i = 0; i < triangleList.size(); i++) 
    {
      println(i + ":");

      triangleList.get(i).toTerminal();
    }
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
}

public enum ParseToken
{
  NONE, P1, P2, P3
}
