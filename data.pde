Data data = new Data();

class Data
{
  byte[][][] byteArray;
  IntV3 axisLength = new IntV3();
  ArrayList<IntV3> fillStack = new ArrayList<IntV3>();

  long cntShell, cntInside, cntOutside;

  final String taskName = new String("taskRawData");

  long getArrayPixels()
  {
    return axisLength.x * axisLength.y * axisLength.z;
  }

  int zArrayLen = 0;

  void update()
  {
    timeMonitor.startTask(taskName);

    // int() statt round() führt dazu, dass bei minuswerten die erste box abgeschnitten wird
    int x = round(boxer.objectSlices.x + 1);
    int y = round(boxer.objectSlices.y + 1);
    int z = round(boxer.objectSlices.z + 1);

    // add 2 that object is surrounded with empty bytes
    x += 2;
    y += 2;
    z += 2;  

    zArrayLen = z / 4;
    if (z % 4 != 0)
      zArrayLen += 1;

    axisLength =  new IntV3(x, y, z);

    //println("allocate 2bit byteArray[" + x + "][" +  y + "][" + z / 4 + 1 + "]");
    byteArray = new byte[x][y][zArrayLen];

    // the counter will be counted in the addParserTriangles() function
    cntShell = 0;

    // do the actual calculation of all points
    addParserTriangles();

    //println("Set " + cntShell + " Shell of " + getArrayPixels() + " Pixels as Shell");

    fillWithBoxes();

    timeMonitor.stopTask(taskName);
  }

  void draw()
  {
    for (int x = 0; x < axisLength.x - 1; x++)
    {
      for (int y = 0; y < axisLength.y - 1; y++)
      {
        for (int z = 0; z < axisLength.z - 1; z++)
        {
          if (int(gui.sliderRows.getValue()) < z)
            continue;

          BitStatus s = getPoint(x, y, z);

          if (s == BitStatus.OUTSIDE)
            continue;

          if (s == BitStatus.INSIDE)
            continue;

          preview.drawBox(s, x, y, z);
        }
      }
    }
  }

  private void fillWithBoxes()
  {
    fillStack.clear();

    // this point is always outside because the object was moved +1
    addToStack(0, 0, 0);

    // fill the outside
    cntOutside = 1;
    while (fillStack.size() > 0)
    {
      ArrayList<IntV3> tempStack = new ArrayList<IntV3>(fillStack);    

      fillStack.clear();

      // this indicator works only if the algorithm starts at x=0, y=0, z=0
      int progressIndicator = 0;
      final int progressMax = axisLength.x + axisLength.y + axisLength.z;

      // add new points to fillStack for new row
      for (IntV3 v : tempStack)
      {
        addToStack(v.x + 1, v.y, v.z);
        addToStack(v.x - 1, v.y, v.z);
        addToStack(v.x, v.y + 1, v.z);
        addToStack(v.x, v.y - 1, v.z);
        addToStack(v.x, v.y, v.z + 1);
        addToStack(v.x, v.y, v.z - 1);

        progressIndicator = v.x + v.y + v.z;
      }

      //println("fillStack.size: " + fillStack.size() + " progress:" + ((float)progressIndicator) / progressMax);
      timeMonitor.updateTask(taskName, 0.2, 0.7, progressIndicator, progressMax);
    }

    //println("put " + cntOutside + " boxes around Object");

    // fill the inside
    cntInside = 0;
    for (int x = 0; x < axisLength.x; x++)
    {
      for (int y = 0; y < axisLength.y; y++)
      {
        for (int z = 0; z < axisLength.z; z++)
        {               
          timeMonitor.updateTask(taskName, 0.9, 0.1, z, axisLength.z);

          if (BitStatus.UNKNOWN == getPoint(x, y, z))
          {
            setPoint(BitStatus.INSIDE, x, y, z);
            cntInside++;
          }
        }
      }
    }

    //println("filled Object with: " + cntInside + " boxes");
  }

  private void addToStack(int x, int y, int z)
  {
    if (x < 0 || y < 0 || z < 0)
      return;  

    if (x > axisLength.x - 1 || 
      y > axisLength.y - 1 || 
      z > axisLength.z - 1)
    {
      return;
    }

    if (getPoint(x, y, z) != BitStatus.UNKNOWN)
      return;

    setPoint(BitStatus.OUTSIDE, x, y, z);

    cntOutside++;

    IntV3 p = new IntV3(x, y, z);

    //println("add to Stack x:" + p.x + ",  y:" + p.y + ",  z:" + p.z + ")");

    fillStack.add(p);
  }


  private void addParserTriangles()
  {
    for (int i = 0; i < parser.getListSize(); i++)
    {
      timeMonitor.updateTask(taskName, 0.0, 0.2, i, parser.getListSize());

      //println("add triangle " + i);
      addPixelTriangle(boxer.getTriangle(i));
    }
  }

  private void addPixelTriangleLists(ArrayList<IntV3> bottomList, ArrayList<IntV3> topList, ArrayList<IntV3> longList)
  {
    for (int i = 0; i < bottomList.size() - 1; i++)
    {
      bresenham3D(bottomList.get(i), longList.get(i));
    }

    for (int i = 0; i < topList.size() - 1; i++)
    {
      bresenham3D(topList.get(i), longList.get(i + bottomList.size() - 1));
    }
  }

  private void addPixelTriangle(Triangle tDraw)
  {
    // draw outer Triangle without filling
    bresenham3D(tDraw.p1.getInt(), tDraw.p2.getInt());
    bresenham3D(tDraw.p2.getInt(), tDraw.p3.getInt());
    bresenham3D(tDraw.p3.getInt(), tDraw.p1.getInt());  

    tDraw.sortDirectionX();

    ArrayList<IntV3> bottomList = getListX(tDraw.p1.getInt(), tDraw.p2.getInt());
    ArrayList<IntV3> topList = getListX(tDraw.p2.getInt(), tDraw.p3.getInt());  
    ArrayList<IntV3> longList = getListX(tDraw.p1.getInt(), tDraw.p3.getInt());  

    addPixelTriangleLists(bottomList, topList, longList);

    tDraw.sortDirectionY();

    bottomList = getListY(tDraw.p1.getInt(), tDraw.p2.getInt());
    topList = getListY(tDraw.p2.getInt(), tDraw.p3.getInt());  
    longList = getListY(tDraw.p1.getInt(), tDraw.p3.getInt());  

    addPixelTriangleLists(bottomList, topList, longList);

    tDraw.sortDirectionZ();

    bottomList = getListZ(tDraw.p1.getInt(), tDraw.p2.getInt());
    topList = getListZ(tDraw.p2.getInt(), tDraw.p3.getInt());  
    longList = getListZ(tDraw.p1.getInt(), tDraw.p3.getInt()); 

    addPixelTriangleLists(bottomList, topList, longList);
  }

  ArrayList<IntV3> getListX(IntV3 pMin, IntV3 pMax)
  {
    ArrayList<IntV3> output = new ArrayList<IntV3>();

    float zDiff = pMax.z - pMin.z;  
    float yDiff = pMax.y - pMin.y;  
    int xDiff = pMax.x - pMin.x;

    for (int i = 0; i <= xDiff; i++)
    {
      IntV3 pTemp = new IntV3();

      pTemp.x = pMin.x + i;
      pTemp.z = pMin.z + round(zDiff / xDiff * i);
      pTemp.y = pMin.y + round(yDiff / xDiff * i);

      output.add(pTemp);
    }

    return output;
  }

  ArrayList<IntV3> getListY(IntV3 pMin, IntV3 pMax)
  {
    ArrayList<IntV3> output = new ArrayList<IntV3>();

    float zDiff = pMax.z - pMin.z;  
    float xDiff = pMax.x - pMin.x;  
    int yDiff = pMax.y - pMin.y;

    for (int i = 0; i <= yDiff; i++)
    {
      IntV3 pTemp = new IntV3();

      pTemp.y = pMin.y + i;
      pTemp.z = pMin.z + round(zDiff / yDiff * i);
      pTemp.x = pMin.x + round(xDiff / yDiff * i);

      output.add(pTemp);
    }

    return output;
  }

  ArrayList<IntV3> getListZ(IntV3 pMin, IntV3 pMax)
  {
    ArrayList<IntV3> output = new ArrayList<IntV3>();

    float xDiff = pMax.x - pMin.x;  
    float yDiff = pMax.y - pMin.y;  
    int zDiff = pMax.z - pMin.z;

    for (int i = 0; i <= zDiff; i++)
    {
      IntV3 pTemp = new IntV3();

      pTemp.z = pMin.z + i;
      pTemp.x = pMin.x + round(xDiff / zDiff * i);
      pTemp.y = pMin.y + round(yDiff / zDiff * i);

      output.add(pTemp);
    }

    return output;
  }

  // must be private
  private void addPoint(int x, int y, int z)
  {
    // add one extra to center object in plus 2 byteArray
    x += 1;
    y += 1;
    z += 1;

    // 
    if (BitStatus.SHELL == getPoint(x, y, z))
    {
      return;
    }

    // count the defined pixels in byteArray
    cntShell += 1;

    setPoint(BitStatus.SHELL, x, y, z);
  }

  public void setPoint(BitStatus s, int x, int y, int z)
  {
    if (x < 0 || y < 0 || z < 0)
    {
      println("WARNING: Point (x:" + x + ",  y:" + y + ",  z:" + z + ") out of bounds");
      return;
    }

    if (x > axisLength.x - 1 || 
      y > axisLength.y - 1 || 
      z > axisLength.z - 1)
    {
      println("WARNING: Point (x:" + x + ",  y:" + y + ",  z:" + z + ") out of bounds");
      return;
    }

    if (s == getPoint(x, y, z))
    {
      return;
    }

    int newData = (int) s.getValue();

    //debug.println("set point (x:" + x + ",  y:" + y + ",  z:" + z + ") to " + newData); 

    // bitshifting
    // create aktual z pos und shifter
    final int zPos = z / 4; // divide Z by 4
    final int zMod4 = z % 4;    

    // shift new data
    newData = newData << (zMod4 * 2);

    // save the old byte
    int backup = byteArray[x][y][zPos];

    // delete the two bits for the new data
    backup = backup & getZerosMask(zMod4);

    // put backup and new data together
    newData = newData | backup;

    byteArray[x][y][zPos] = (byte) newData;
  }

  final private int getOnesMask(int shift)
  {
    //return shift == 0 ? 0b00000011 : (shift == 1 ? 0b00001100 : (shift == 2 ? 0b00110000 : 0b11000000));
    return shift == 0 ? 3 : (shift == 1 ? 12 : (shift == 2 ? 48 : 192));
  }

  final private int getZerosMask(int shift)
  {
    //return shift == 0 ? 0b11111100 : (shift == 1 ? 0b11110011 : (shift == 2 ? 0b11001111 : 0b00111111));
    return shift == 0 ? 252 : (shift == 1 ? 243 : (shift == 2 ? 207 : 63));
  }

  public boolean isObject(int x, int y, int z)
  {
    BitStatus s = getPoint(x, y, z);

    return s == BitStatus.SHELL || s == BitStatus.INSIDE;
  }

  public BitStatus getPoint(IntV3 v)
  {
    return getPoint(v.x, v.y, v.z, true);
  }

  public BitStatus getPoint(IntV3 v, boolean printError)
  {
    return getPoint(v.x, v.y, v.z, printError);
  }

  public BitStatus getPoint(int x, int y, int z)
  {
    return getPoint(x, y, z, true);
  }

  public BitStatus getPoint(int x, int y, int z, boolean printError)
  {
    if (x >= axisLength.x || y >= axisLength.y || z >= axisLength.z || x < 0 || y < 0 || z < 0)
    {
      if (printError)
        debug.println("Error: getPoint(x:" + x + ",  y:" + y + ",  z:" + z + ") axis: " + axisLength.toString());

      return BitStatus.UNKNOWN;
    }

    // create aktual z pos und shifter
    final int zPos = z / 4; // divide Z by 4
    final int zMod4 = z % 4;    

    int newData = 0; // = byteArray[x][y][zPos];

    try {
      newData = byteArray[x][y][zPos];
    } 
    catch (Exception e) {      
      //debug.println("Error: getPoint(x:" + x + ",  y:" + y + ",  z:" + z + ") axis: " + axisLength.toString());    
      e.printStackTrace();
      
      // TODO set flag to redo
    }

    // do the bitshifting, get only the two relevant bits
    newData = newData & getOnesMask(zMod4);

    // shift relevant bytes to correct position
    newData = newData >> (zMod4 * 2);

    return BitStatus.fromInt(newData);
  }

  private void bresenham3D(IntV3 p1, IntV3 p2)
  {
    bresenham3D(p1.x, p1.y, p1.z, p2.x, p2.y, p2.z);
  }

  private void bresenham3D(int x1, int y1, int z1, int x2, int y2, int z2)
  {
    int i, dx, dy, dz, l, m, n, x_inc, y_inc, z_inc, err_1, err_2, dx2, dy2, dz2;
    int[] point = new int[3];
    point[0] = x1;
    point[1] = y1;
    point[2] = z1;
    dx = x2 - x1;
    dy = y2 - y1;
    dz = z2 - z1;
    x_inc = (dx < 0) ? -1 : 1;
    l = abs(dx);
    y_inc = (dy < 0) ? -1 : 1;
    m = abs(dy);
    z_inc = (dz < 0) ? -1 : 1;
    n = abs(dz);
    dx2 = l << 1;
    dy2 = m << 1;
    dz2 = n << 1;

    if ((l >= m) && (l >= n)) {
      err_1 = dy2 - l;
      err_2 = dz2 - l;
      for (i = 0; i < l; i++) {
        addPoint(point[0], point[1], point[2]);
        if (err_1 > 0) {
          point[1] += y_inc;
          err_1 -= dx2;
        }
        if (err_2 > 0) {
          point[2] += z_inc;
          err_2 -= dx2;
        }
        err_1 += dy2;
        err_2 += dz2;
        point[0] += x_inc;
      }
    } else if ((m >= l) && (m >= n)) {
      err_1 = dx2 - m;
      err_2 = dz2 - m;
      for (i = 0; i < m; i++) {
        addPoint(point[0], point[1], point[2]);
        if (err_1 > 0) {
          point[0] += x_inc;
          err_1 -= dy2;
        }
        if (err_2 > 0) {
          point[2] += z_inc;
          err_2 -= dy2;
        }
        err_1 += dx2;
        err_2 += dz2;
        point[1] += y_inc;
      }
    } else {
      err_1 = dy2 - n;
      err_2 = dx2 - n;
      for (i = 0; i < n; i++) {
        addPoint(point[0], point[1], point[2]);
        if (err_1 > 0) {
          point[1] += y_inc;
          err_1 -= dz2;
        }
        if (err_2 > 0) {
          point[0] += x_inc;
          err_2 -= dz2;
        }
        err_1 += dy2;
        err_2 += dx2;
        point[2] += z_inc;
      }
    }
    addPoint(point[0], point[1], point[2]);
  }
};

public enum BitStatus
{
  UNKNOWN(0), 
    SHELL(1), 
    INSIDE(2), 
    OUTSIDE(3);

  private BitStatus(int v_in)
  {
    this.value = v_in;
  }

  final int value;

  public static BitStatus fromInt(int x) {
    switch(x) {
    case 0:
      return UNKNOWN;
    case 1:
      return SHELL;
    case 2:
      return INSIDE;
    case 3:
      return OUTSIDE;
    }
    return null;
  }

  public int getValue()
  {
    return value;
  }
};
