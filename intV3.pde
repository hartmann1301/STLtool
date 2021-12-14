class IntV3
{
  IntV3()
  {
    x = y = z = 0;
  }

  IntV3(int ix, int iy, int iz)
  {
    x = ix;
    y = iy;
    z = iz;
  }

  IntV3(float ix, float iy, float iz)
  {
    x = round(ix);
    y = round(iy);
    z = round(iz);
  }

  String toString() 
  {
    return new String("x:" + x + ", y:" + y + ", z:" + z);
  }

  int x, y, z;
}
