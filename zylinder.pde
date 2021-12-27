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

  byte[] data;

  void update()
  {
    createArray();

    fillArray();
  }

  void createArray()
  {
    rMax = ceil(boxer.radiusMaxXY);
    zylinderHeight = ceil(boxer.objectSlices.y);

    data = new byte[getDataLen(rMax, zylinderHeight)];
  }

  void fillArray()
  {
    for (int i = 0; i < data.length; i++)
    {
      data[i] = 1;
    }
  }

  void draw()
  {
    translate(boxer.objectLen.x / 2, boxer.objectLen.y / 2, 0);
    
    float boxSize = 1.0;

    for (int i = 0; i < data.length; i++)
    {
      ZVector z = getZVectorFromArray(i);

      // return vector pointing in x,y direction with len 1
      PVector offset = PVector.fromAngle(radians(z.deg));
      offset.mult(z.r);
      offset.z = z.h;

      offset.mult(boxSize);

      pushMatrix();
      translate(offset.x, offset.y, offset.z);
      box(boxSize);
      popMatrix();
    }
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
    final int layer = data.length / zylinderHeight;

    int heightPos  = i / layer;

    i -= layer * heightPos;

    int radius = getRadius(i);

    float deg = getDegStep(radius) * getRingPos(i, radius);

    return new ZVector(radius, deg, heightPos);
  }
}
