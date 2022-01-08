FastData fastData = new FastData();

class FastData extends Thread
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

  // this is used to optimize direction y and z 
  ArrayList<Integer> deleteList = new ArrayList<Integer>();

  final String taskName = new String("taskFastData");

  public void update()
  {
    timeMonitor.startTask(taskName);

    drawData.clear();
    optimizeDirectionX();
    optimizeDirectionY();
    optimizeDirectionZ();
    //printData();

    timeMonitor.stopTask(taskName);
  }

  public void draw()
  {
    for (int i = 0; i < drawData.size(); i++)
    {
      // usingn for (ArrayList<Integer> entry : drawData) cause errors
      ArrayList<Integer> entry = drawData.get(i);

      if (entry == null)
        return;

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

      preview.drawBox(xPos, yPos, zPos, int(xLen), int(yLen), int(zLen));
    }
  }

  private void optimizeDirectionX()
  {
    for (int z = 0; z < data.axisLength.z; z++)
    {
      timeMonitor.updateTask(taskName, 0, 0.3, z, data.axisLength.z);

      // this would be fast and easy but it is not sorted correctly in y-direction
      for (int y = 0; y < data.axisLength.y; y++)
      {      
        for (int x = 0; x < data.axisLength.x; x++)
        {       
          // will be incremented on first call
          int xLen = 0;
          boolean skipThis = true;

          while (data.isObject(x + xLen, y, z))
          {
            xLen++;
            skipThis = false;
          }

          if (skipThis)
            continue;

          // create entry and add coordinates
          ArrayList<Integer> entry = new ArrayList<Integer>();
          entry.add(x);
          entry.add(y);
          entry.add(z);

          //println(" returned len:" + xLen);

          // put xLen only if it is longer than one pixel
          if (xLen != 1) 
            entry.add(xLen);      

          // add entry with len 3 or 4
          drawData.add(entry);

          x += xLen;
        }
      }
    }
  }

  boolean isIndexInDeleteList(int i)
  {
    boolean skipThis = false;
    for (int j = deleteList.size() - 1; j >= 0; j--) {
      int id = deleteList.get(j);
      if (id == i) {
        skipThis = true;

        deleteList.remove(j);
      }
    }
    return skipThis;
  }

  private void optimizeDirectionY()
  {
    deleteList.clear();

    for (int i = drawData.size() - 1; i >= 0; i--) {

      timeMonitor.updateTask(taskName, 0.3, 0.3, i, drawData.size() - 1, true);

      // get last entry
      ArrayList<Integer> entry = drawData.get(i);

      int matchCnt = 0;

      // if this entry is in the delete list delete it now and remove it from deletelist
      if (isIndexInDeleteList(i))
      {
        drawData.remove(i);
        continue;
      }

      ArrayList<Integer> check = new ArrayList<Integer>();

      boolean addYLen = false;

      // find entrys with same z
      for (int j = i - 1; j >= 0; j--) {

        check = drawData.get(j);

        // this speeds up the process because next z levels are compared
        if (entry.get(Y_POS) > check.get(Y_POS) + 1)
          break;

        boolean foundMatch = false;

        if (
          int(entry.size()) == 4 && 
          int(check.size()) == 4 && 
          int(entry.get(X_POS)) == int(check.get(X_POS)) &&
          int(entry.get(Y_POS)) == int(check.get(Y_POS) + 1) &&
          int(entry.get(Z_POS)) == int(check.get(Z_POS)) &&
          int(entry.get(X_LEN)) == int(check.get(X_LEN))
          )
        {
          foundMatch = true;
        } else if (
          int(entry.size()) == 3 && 
          int(check.size()) == 3 && 
          int(entry.get(X_POS)) == int(check.get(X_POS)) &&
          int(entry.get(Y_POS)) == int(check.get(Y_POS) + 1) &&
          int(entry.get(Z_POS)) == int(check.get(Z_POS))
          )
        {
          foundMatch = true;
          addYLen = true;
        }

        if (foundMatch)
        {
          // manipulate y of entry minus one
          entry.set(Y_POS, entry.get(Y_POS) - 1);

          deleteList.add(j);

          matchCnt++;
        }
      }

      if (matchCnt > 0) {
        
        if (addYLen)
        {
          entry.add(1);
        }

        //println("  matchCnt " + matchCnt); 
        entry.add(matchCnt + 1);
      }
    }
  }

  private void optimizeDirectionZ()
  {
    deleteList.clear();

    for (int i = drawData.size() - 1; i >= 0; i--) {

      timeMonitor.updateTask(taskName, 0.6, 0.4, i, drawData.size() - 1, true);

      // get last entry
      ArrayList<Integer> entry = drawData.get(i);

      //debug.print(i + " - ");
      //printEntry(entry);

      int matchCnt = 0;

      // if this entry is in the delete list delete it now and remove it from deletelist
      if (isIndexInDeleteList(i))
      {
        drawData.remove(i);
        continue;
      }

      ArrayList<Integer> check = new ArrayList<Integer>();

      int extraOnes = 0;

      // find entrys with same z
      for (int j = i - 1; j >= 0; j--) {

        check = drawData.get(j);

        //debug.println("compare " + entry.get(Z_POS) + " with " + (check.get(Z_POS) - 1));

        // this speeds up the process because next z levels are compared
        if (entry.get(Z_POS) > check.get(Z_POS) + 1)
          break;

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
        } else if (
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
          extraOnes = 1;
        } else if (
          int(entry.size()) == 3 && 
          int(check.size()) == 3 && 
          int(entry.get(X_POS)) == int(check.get(X_POS)) &&
          int(entry.get(Y_POS)) == int(check.get(Y_POS)) &&
          int(entry.get(Z_POS)) == int(check.get(Z_POS) + 1)
          )
        {
          foundMatch = true;

          // add xLen und yLen of 1
          extraOnes = 2;
        }

        if (foundMatch)
        {
          //debug.println("found Match");

          // manipulate z of entry minus one
          entry.set(Z_POS, entry.get(Z_POS) - 1);

          deleteList.add(j);

          matchCnt++;
        }
      }

      if (matchCnt > 0) {
        // add ones because I found lines oder pixels above each other
        for (int k = 0; k < extraOnes; k++)
        {
          entry.add(1);
        }

        //println("  matchCnt " + matchCnt); 
        entry.add(matchCnt + 1);
      }
    }
  }

  void printDataSize()
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

  void printData()
  {
    printDataSize();

    for (ArrayList<Integer> entry : drawData)
    {
      printEntry(entry);
    }

    debug.println();
  }
};
