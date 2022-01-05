Zylinder zylinder = new Zylinder();

class ZVector
{
  ZVector(int rPos, float degPos, int hPos)
  {
    r = rPos;
    deg = degPos;
    h = hPos;
  }

  int r = 0;
  float deg = 0;
  int h = 0;

  String toString()
  {
    return new String("r: " + r + ", deg:" + deg + ", h:" + h);
  }
}; 

class Zylinder
{
  int rMax = 0;
  int zylinderHeight = 0;

  byte[] byteArray = null;
  int byteArrayItems, byteArrayLength;

  final String taskName = new String("taskZylinder");  

  void update()
  {
    timeMonitor.startTask(taskName);

    createArray();

    fillArray();

    timeMonitor.stopTask(taskName);
  }

  void createArray()
  {
    rMax = ceil(boxer.radiusMaxXY);
    zylinderHeight = ceil(boxer.objectSlices.z);

    //debug.println("Zylinder: createArray() rMax:" + rMax + " zylinderHeight:" + zylinderHeight);

    byteArrayItems = getDataLen(rMax, zylinderHeight);
    byteArrayLength = byteArrayItems / 4;

    if (byteArrayItems % 4 != 0)
      byteArrayLength += 1;

    byteArray = new byte[byteArrayLength];
  }

  int getDataLen(int r, int h)
  {
    int cnt = 0;
    for (int i = 0; i <= r; i++)
    {
      cnt += getRingCount(i);
    }
    return cnt * h;
  }

  void fillArray()
  {
    //debug.println("Zylinder: fillArray()");

    for (int i = 0; i < byteArrayItems; i++)
    {
      PVector p = getPVectorFromArray(i);

      // try to do the same as in data.update() reverse      
      float xPos = p.x + round((boxer.objectSlices.x + 1.0) / 2);
      float yPos = p.y + round((boxer.objectSlices.y + 1.0) / 2);
      IntV3 ip = new IntV3(xPos, yPos, p.z + 1);

      //debug.println(" IntV3: " + ip.toString());

      setPoint(data.getPoint(ip, false), i);
    }
  }

  void draw()
  {
    translate(boxer.objectLen.x / 2, boxer.objectLen.y / 2, 0);

    if (byteArray == null)
    {
      // do not call thread here
      updateBoxer();
    }

    final float sf = boxer.sliceFaktor;
    translate(sf, sf, sf);

    for (int i = 0; i < byteArrayItems; i++)
    {
      BitStatus s = getPoint(i);

      if (s != BitStatus.SHELL)
        continue;

      ZVector z = getZVectorFromArray(i);

      if (gui.sliderRows.getValue() < z.h)
        continue;

      // return vector pointing in x,y direction with len 1
      PVector offset = PVector.fromAngle(radians(z.deg));
      offset.mult(z.r);
      offset.z = z.h;

      preview.drawBox(offset.x, offset.y, offset.z);
    }
  }

  public BitStatus getPoint(int i)
  {
    // create aktual z pos und shifter
    final int iPos = i / 4; // divide Z by 4
    final int iMod4 = i % 4;    

    // get full byte with four items
    int newData = byteArray[iPos];

    // do the bitshifting, get only the two relevant bits
    newData = newData & data.getOnesMask(iMod4);

    // shift relevant bytes to correct position
    newData = newData >> (iMod4 * 2);

    return BitStatus.fromInt(newData);

    // without bitshifting
    //return BitStatus.fromInt(byteArray[i]);
  }


  void setPoint(BitStatus s, int i)
  {
    if (i < 0 || i > byteArrayItems - 1)
    {
      println("WARNING: Zylinder Point (i:" + i + " out of bounds, byteArrayItems:" + byteArrayItems);
      return;
    }

    if (s == getPoint(i))
    {
      return;
    }

    // create aktual z pos und shifter
    final int iPos = i / 4; // divide Z by 4
    final int iMod4 = i % 4;    

    int newData = s.getValue();

    // shift new data
    newData = newData << (iMod4 * 2);

    // save the old byte
    int backup = byteArray[iPos];

    // delete the two bits for the new data
    backup = backup & data.getZerosMask(iMod4);

    // put backup and new data together
    newData = newData | backup;

    byteArray[iPos] = (byte) newData;

    // without bitshifting
    //byteArray[i] = (byte) s.getValue();
  }

  int getRingCount(int i)
  {
    return (i == 0) ? 1 : ceil(PI * i * 2);  // umfang is PI * r * 2, erster ring hat 1
  }

  int getRadius(int i)
  {
    int r = 0; 
    while (i > 0)
    {
      r++;  
      i -= getRingCount(r);
    }
    return r;
  }

  float getDegStep(int r)
  {
    return 360.0 / getRingCount(r);
  }

  int getRingPos(int i, int r)
  {
    while (r > 0)
    {
      i -= getRingCount(r - 1);
      r--;
    }
    return i;
  }

  ZVector getZVectorFromArray(int i)
  {
    final int layer = byteArrayItems / zylinderHeight;

    int heightPos  = i / layer;

    i -= layer * heightPos;

    int radius = getRadius(i);

    float deg = getDegStep(radius) * getRingPos(i, radius);

    return new ZVector(radius, deg, heightPos);
  }

  PVector getPVectorFromArray(int i)
  {
    ZVector z = getZVectorFromArray(i);

    PVector offset = PVector.fromAngle(radians(z.deg));
    offset.mult(z.r);
    offset.z = z.h;

    return offset;
  }
}

/*
      rotateZ(radians(90));
 rotateX(radians(-90));      
 text("no Data", -boxer.objectLen.x / 2, -boxer.objectLen.x / 2);
 return;
 */
