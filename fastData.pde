

FastData fastData = new FastData();

class FastData
{
  FastData()
  {
    // create a dictionary to print the entrys
    dataLables.add(" x:");
    dataLables.add(", y:");
    dataLables.add(", z:");
    dataLables.add(", xLen:");
    dataLables.add(", yLen:");
    dataLables.add(", zLen:");
  }

  private static final int X_POS = 0;
  private static final int Y_POS = 1;
  private static final int Z_POS = 2;
  private static final int X_LEN = 3;
  private static final int Y_LEN = 4;
  private static final int Z_LEN = 5;  

  private ArrayList<String> dataLables = new ArrayList<String>();

  ArrayList<ArrayList<Integer>> drawData = new ArrayList<ArrayList<Integer>>();

  public void update()
  {
    createPixelsAndLines();

    //printDataSize();

    optimizeDirectionY();

    //printDataSize();

    optimizeDirectionZ();

    //printDataSize();
    //printData();
  }

  public void draw()
  {
    for (ArrayList<Integer> entry : drawData)
    {
      if (entry.size() < 3)
      {
        println("Error wrong entry with len:" + entry.size());
        continue;
      }

      // coordinates
      float xPos = entry.get(X_POS);
      float yPos = entry.get(Y_POS);
      float zPos = entry.get(Z_POS);

      // optional lengths 
      float xLen = 1;
      float yLen = 1;
      float zLen = 1;

      // get xLen and correct xPos for drawing box from center
      if (entry.size() > X_LEN)
      {
        xLen = entry.get(X_LEN);
        xPos += (xLen - 1) / 2;
      }

      // get yLen and correct yPos for drawing Rect with height 1 from center
      if (entry.size() > Y_LEN)
      {
        yLen = entry.get(Y_LEN);
        yPos += (yLen - 1) / 2;
      }

      // get zLen and correct zPos for drawing a centered Box
      if (entry.size() > Z_LEN)
      {
        zLen = entry.get(Z_LEN);
        zPos += (zLen - 1) / 2;
      }

      // warning the -1 is a bad workaround because without it the was a bug after rotation
      if (int(gui.sliderRows.getValue()) < zPos - 1)
        continue;

      final int grayTone = 200;
      final color strokeColor = color(255, 255, 255);  
      final color fillColor = color(grayTone, grayTone, grayTone);  

      preview.drawBox(strokeColor, fillColor, xPos, yPos, zPos, xLen, yLen, zLen);
    }
  }

  private int getLenX(int x, int y, int z)
  {
    int len = 1;

    // check the rest of this y line, start with the next pixel
    for (int xCheck = x + 1; xCheck < data.axisLength.x; xCheck++)
    {   
      if (data.isObject(xCheck, y, z) == false) 
        return len;   

      len++;
    } 

    return len;
  }

  private void createPixelsAndLines()
  {
    drawData.clear();

    for (int z = 0; z < data.axisLength.z; z++)
    {
      for (int x = 0; x < data.axisLength.x; x++)
      {
        for (int y = 0; y < data.axisLength.y; y++)
        {   
          // nothing to do when pixel is unknown or outside
          if (data.isObject(x, y, z) == false)
            continue;

          // check if this is the first pixel in a line
          if (data.isObject(x - 1, y, z))
            continue;          

          //println("found first pixel (x:" + x + ",  y:" + y + ",  z:" + z + ")");

          // create entry and add coordinates
          ArrayList<Integer> entry = new ArrayList<Integer>();
          entry.add(x);
          entry.add(y);
          entry.add(z);

          int xLen = getLenX(x, y, z);
          //println(" returned len:" + xLen);

          // put xLen only if it is longer than one pixel
          if (xLen != 1) 
            entry.add(xLen);      

          // add entry with len 3 or 4
          drawData.add(entry);
        }
      }
    }
  }

  private void optimizeDirectionY()
  {
    ArrayList<Integer> last = new ArrayList<Integer>();  

    for (int i = drawData.size() - 1; i >= 0; i--) {
      // get last entry
      ArrayList<Integer> entry = drawData.get(i);

      // lines to plates
      if (entry.size() > 3 && last.size() > 3)
      {
        // check for same ecpect the y pos
        if (
          int(entry.get(X_POS)) == int(last.get(X_POS)) &&
          int(entry.get(Y_POS)) == int(last.get(Y_POS) - 1) &&
          int(entry.get(Z_POS)) == int(last.get(Z_POS)) &&
          int(entry.get(X_LEN)) == int(last.get(X_LEN))
          )
        {
          // remove the last one
          drawData.remove(i + 1);

          int yLen = 2;

          // if last was already a rect increase its width
          if (last.size() == 5)
            yLen = last.get(Y_LEN) + 1;

          entry.add(yLen);
        }
      }
      // pixels in y direction to lines
      else if (entry.size() > 2 && last.size() > 2)
      {
        // check for same ecpect the y pos
        if (
          int(entry.get(X_POS)) == int(last.get(X_POS)) &&
          int(entry.get(Y_POS)) == int(last.get(Y_POS) - 1) &&
          int(entry.get(Z_POS)) == int(last.get(Z_POS))
          )
        {
          // remove the last one
          drawData.remove(i + 1);

          int yLen = 2;

          // if last was already a line increase its width
          if (last.size() == 5)
            yLen = last.get(Y_LEN) + 1;

          // add an xLen 1
          entry.add(1);  
          entry.add(yLen);
        }    
      }

      // create a deep copy for next loop
      last.clear();
      for (int j = 0; j < entry.size(); j++)
      {
        last.add(entry.get(j));
      }
    }
  }

  private void optimizeDirectionZ()
  {

    ArrayList<Integer> deleteList = new ArrayList<Integer>();

    for (int i = drawData.size() - 1; i >= 0; i--) {
      // get last entry
      ArrayList<Integer> entry = drawData.get(i);

      //print(i + " - ");
      //printEntry(entry);

      int matchCnt = 0;

      boolean skipThis = false;
      for (int j = deleteList.size() - 1; j >= 0; j--) {
        int id = deleteList.get(j);
        if (id == i) {
          skipThis = true;

          deleteList.remove(j);
        }
      }

      if (skipThis)
      {
        //println("  remove This");
        drawData.remove(i);
        continue;
      }

      ArrayList<Integer> check = new ArrayList<Integer>();

      // find entrys with same z
      for (int j = i - 1; j >= 0; j--) {

        check = drawData.get(j);

        //println("compare " + entry.get(Z_POS) + " with " + (check.get(Z_POS) - 1));

        boolean foundMatch = false;

        if (
          int(entry.size()) == 5 && 
          int(check.size()) == 5 && 
          int(entry.get(X_POS)) == int(check.get(X_POS)) &&
          int(entry.get(Y_POS)) == int(check.get(Y_POS)) &&
          int(entry.get(Z_POS)) == int(check.get(Z_POS) + 1) &&
          int(entry.get(X_LEN)) == int(check.get(X_LEN)) &&
          int(entry.get(Y_LEN)) == int(check.get(Y_LEN))
          )   
        {
          foundMatch = true;
        }
        else if (
          int(entry.size()) == 4 && 
          int(check.size()) == 4 && 
          int(entry.get(X_POS)) == int(check.get(X_POS)) &&
          int(entry.get(Y_POS)) == int(check.get(Y_POS)) &&
          int(entry.get(Z_POS)) == int(check.get(Z_POS) + 1) &&
          int(entry.get(X_LEN)) == int(check.get(X_LEN))
          )
        {
          foundMatch = true;
          
          // add yLen of 1
          entry.add(1);
        }

        else if (
          int(entry.size()) == 3 && 
          int(check.size()) == 3 && 
          int(entry.get(X_POS)) == int(check.get(X_POS)) &&
          int(entry.get(Y_POS)) == int(check.get(Y_POS)) &&
          int(entry.get(Z_POS)) == int(check.get(Z_POS) + 1)
          )
        {
          foundMatch = true;

          // add xLen und yLen of 1
          entry.add(1);
          entry.add(1);
        }

        if (foundMatch)
        {
          // manipulate z of entry minus one
          entry.set(Z_POS, entry.get(Z_POS) - 1);

          deleteList.add(j);

          matchCnt++;
        }
      }

      if (matchCnt > 0) {
        //println("  matchCnt " + matchCnt); 
        entry.add(matchCnt + 1);
      }
    }
  }

  /*
  private void printDataSize()
  {
    debug.println("drawData.size(): " + drawData.size());
  }
  
  private void printEntry(ArrayList<Integer> entry)
  {
    for (int i = 0; i < entry.size(); i++)
    {
      debug.print(dataLables.get(i) + entry.get(i));
    }
    debug.println();
  }

  private void printData()
  {
    printDataSize();

    for (ArrayList<Integer> entry : drawData)
    {
      printEntry(entry);
    }

    debug.println();
  }
  */

};
