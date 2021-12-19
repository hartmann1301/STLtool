class Vector
{
  Vector()
  {
    x = y = z = 0;
  }

  Vector(Vector p)
  {
    x = p.x;
    y = p.y;
    z = p.z;
  }

  Vector(IntV3 p)
  {
    x = p.x;
    y = p.y;
    z = p.z;
  }

  Vector(float ix, float iy, float iz)
  {
    x = ix;
    y = iy;
    z = iz;
  }

  Vector(int ix, int iy, int iz)
  {
    x = (float) ix;
    y = (float) iy;
    z = (float) iz;
  }

  Vector(PVector v)
  {
    x = v.x;
    y = v.y;
    z = v.z;
  }

  IntV3 getInt()
  {
    return new IntV3(x, y, z);
  }

  void setData(String dx, String dy, String dz)
  {
    x = float(dx);
    y = float(dy);
    z = float(dz);
  }  

  void setData(int dx, int dy, int dz)
  {
    x = dx;
    y = dy;
    z = dz;
  }

  void setData(Vector p)
  {
    x = p.x;
    y = p.y;
    z = p.z;
  }

  void minus(Vector p)
  {
    x -= p.x;
    y -= p.y;    
    z -= p.z;
  }

  void multiply(float f)
  {
    x *= f;
    y *= f;   
    z *= f;
  }

  void divide(float f)
  {
    if (f == 0)
    {
      println("Error: Divide Vector by 0!");
      return;     
    }

    x /= f;
    y /= f;   
    z /= f;
  }

  void rotate()
  {
    float temp;
    
    switch (keyCode)
    {
    case LEFT:
      temp = x;
      x = y;
      y = -temp;
      break;
    case RIGHT:
      temp = x;
      x = -y;
      y = temp;
      break;
    case UP:
      temp = x;
      x = z;
      z = -temp; 
      break;
    case DOWN:
      temp = x;
      x = -z;
      z = temp;
      break;
    }
  }

  Vector getData()
  {
    return new Vector(x, y, z);
  }

  String toString() 
  {
    return new String("x:" + x + ",  y:" + y + ",  z:" + z + " ");
  }

  float x, y, z;
}
