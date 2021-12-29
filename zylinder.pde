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

  void update()
  {
    if (gui.checkbox.getArrayValue()[CheckBoxes.concentricData] == Off)
      return;

    timeMonitor.startTask();

    createArray();

    fillArray();

    timeMonitor.stopTask("update zylinder");
  }

  void createArray()
  {
    rMax = ceil(boxer.radiusMaxXY);
    zylinderHeight = ceil(boxer.objectSlices.z);

    //debug.println("Zylinder: createArray() rMax:" + rMax + " zylinderHeight:" + zylinderHeight);

    byteArray = new byte[getDataLen(rMax, zylinderHeight)];
  }

  void fillArray()
  {
    //debug.println("Zylinder: fillArray()");

    for (int i = 0; i < byteArray.length; i++)
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

    if (gui.checkbox.getArrayValue()[CheckBoxes.concentricData] == Off)
    {
      rotateZ(radians(90));
      rotateX(radians(-90));      
      text("no Data", -boxer.objectLen.x / 2, -boxer.objectLen.x / 2);
      return;
    }

    if (byteArray == null)
    {
      boxer.update();
    }

    final float sf = boxer.sliceFaktor;
    translate(sf, sf, sf);

    for (int i = 0; i < byteArray.length; i++)
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
    final byte d = byteArray[i];

    return BitStatus.fromByte(d);
  }


  void setPoint(BitStatus s, int i)
  {
    if (i < 0 || i > byteArray.length - 1)
    {
      println("WARNING: Zylinder Point (i:" + i + " out of bounds, byteArray.length:" + byteArray.length);
      return;
    }

    if (s == getPoint(i))
    {
      return;
    }

    byte newByte = s.getValue();

    byteArray[i] = newByte;
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
    final int layer = byteArray.length / zylinderHeight;

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
