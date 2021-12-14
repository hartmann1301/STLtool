Data data = new Data();

class Data
{
  byte[][][] data;
  long setPixelsCounter = 0;
  IntV3 axisLength = new IntV3();
  ArrayList<IntV3> fillStack = new ArrayList<IntV3>();
  long fillCounter = 0;

  long getArrayPixels()
  {
    return axisLength.x * axisLength.y * axisLength.z;
  }

  void loadParsedTriangles()
  {
    // int() statt round() führt dazu, dass bei minuswerten die erste box abgeschnitten wird
    int x = round(skaler.objectLen.x + 1);
    int y = round(skaler.objectLen.y + 1);
    int z = round(skaler.objectLen.z + 1);

    // add 2 that object is surrounded with empty bytes
    x += 2;
    y += 2;
    z += 2;  

    axisLength =  new IntV3(x, y, z);

    println("allocate 2bit array[" + x + "][" +  y + "][" + z + "]");

    // not sure if this is needed
    data = null;

    //  data = new byte[x][y/4][z];
    data = new byte[x][y][z];

    //Arrays.fill(data, 0);

    // do the actual calculation of all points
    addParserTriangles();

    println("Set " + setPixelsCounter + " Shell of " + getArrayPixels() + " Pixels as Shell");

    fillWithBoxes();
  }

  private void fillWithBoxes()
  {
    fillStack.clear();

    // this point is always outside because the object was moved +1
    addToStack(0, 0, 0);

    // fill the outside
    fillCounter = 0;
    while (fillStack.size() > 0)
    {
      ArrayList<IntV3> tempStack = new ArrayList<IntV3>(fillStack);    

      fillStack.clear();

      // add new points to fillStack for new row
      for (IntV3 v : tempStack)
      {
        addToStack(v.x + 1, v.y, v.z);
        addToStack(v.x - 1, v.y, v.z);
        addToStack(v.x, v.y + 1, v.z);
        addToStack(v.x, v.y - 1, v.z);
        addToStack(v.x, v.y, v.z + 1);
        addToStack(v.x, v.y, v.z - 1);
      }

      //println("fillStack.size: " + fillStack.size());
    }

    println("put " + fillCounter + " boxes around Object");

    // fill the inside
    fillCounter = 0;
    for (int x = 0; x < axisLength.x; x++)
    {
      for (int y = 0; y < axisLength.y; y++)
      {
        for (int z = 0; z < axisLength.z; z++)
        {
          if (BitStatus.UNKNOWN == getPoint(x, y, z))
          {
            setPoint(BitStatus.INSIDE, x, y, z);
            fillCounter++;
          }
        }
      }
    }

    println("filled Object with: " + fillCounter + " boxes");
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

    fillCounter++;

    IntV3 p = new IntV3(x, y, z);

    //println("add to Stack x:" + p.x + ",  y:" + p.y + ",  z:" + p.z + ")");

    fillStack.add(p);
  }


  private void addParserTriangles()
  {
    for (int i = 0; i < parser.getListSize(); i++)
    {
      addPixelTriangle(skaler.getTriangle(i));
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
    // add one extra to center object in plus 2 array
    x += 1;
    y += 1;
    z += 1;

    // 
    if (BitStatus.SHELL == getPoint(x, y, z))
    {
      return;
    }

    // count the defined pixels in array
    setPixelsCounter += 1;

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

    byte newByte = s.getValue();

    // bitshifting

    data[x][y][z] = newByte;
  }

  public boolean isObject(int x, int y, int z)
  {
    BitStatus s = getPoint(x, y, z);

    return s == BitStatus.SHELL || s == BitStatus.INSIDE;
  }

  public BitStatus getPoint(IntV3 v)
  {
    return getPoint(v.x, v.y, v.z);
  }

  public BitStatus getPoint(int x, int y, int z)
  {
    if (x >= axisLength.x || y >= axisLength.y || z >= axisLength.z || x < 0 || y < 0 || z < 0)
    {
      println("Error: getPoint(x:" + x + ",  y:" + y + ",  z:" + z + ") axis: " + axisLength.toString());

      return BitStatus.UNKNOWN;
    }

    byte d = data[x][y][z];

    // do the bitshifting

    BitStatus s = BitStatus.fromByte(d);

    return s;
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

  public static BitStatus fromByte(byte x) {
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

  public byte getValue()
  {
    return byte(value);
  }
};