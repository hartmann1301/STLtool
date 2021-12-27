public class TriangleComparator implements Comparator<Triangle> {

  @Override
    public int compare(Triangle first, Triangle second) 
  {
    Float obj1 = new Float(first.getMinZ());
    Float obj2 = new Float(second.getMinZ());

    return obj1.compareTo(obj2);
  }
}

public class Triangle {
  Triangle()
  {
  }

  Triangle(Vector P1, Vector P2, Vector P3)
  {
    p1 = P1;
    p2 = P2;
    p3 = P3;
  }

  public Triangle(Triangle t)
  {
    this(t.p1.getData(), t.p2.getData(), t.p3.getData());
  }

  Vector p1 = new Vector();
  Vector p2 = new Vector();
  Vector p3 = new Vector();

  void swapP1P2()
  {
    Vector temp = new Vector(p1);
    p1.setData(p2);
    p2.setData(temp);
  }  

  void swapP2P3()
  {
    Vector temp = new Vector(p2);
    p2.setData(p3);
    p3.setData(temp);
  } 

  void sortDirectionZ()
  {     
    if (p1.z > p2.z)
      swapP1P2(); 

    if (p2.z > p3.z)
      swapP2P3(); 

    if (p1.z > p2.z)
      swapP1P2();
  }

  void sortDirectionX()
  {     
    if (p1.x > p2.x)
      swapP1P2(); 

    if (p2.x > p3.x)
      swapP2P3(); 

    if (p1.x > p2.x)
      swapP1P2();
  }

  void sortDirectionY()
  {     
    if (p1.y > p2.y)
      swapP1P2(); 

    if (p2.y > p3.y)
      swapP2P3(); 

    if (p1.y > p2.y)
      swapP1P2();
  }

  void rotate()
  {
    p1.rotate();
    p2.rotate();
    p3.rotate();
  }

  void minus(Vector p)
  {
    p1.minus(p);
    p2.minus(p);
    p3.minus(p);
  }

  void multiply(float f)
  {
    p1.multiply(f);
    p2.multiply(f);
    p3.multiply(f);
  }

  void divide(float f)
  {
    p1.divide(f);
    p2.divide(f);
    p3.divide(f);
  }

  float getRadiusMaxXY(Vector offset)
  {
    return max(p1.getRadiusXY(offset), p2.getRadiusXY(offset), p3.getRadiusXY(offset));
  }

  float getMinX() 
  {
    return min(p1.x, p2.x, p3.x);
  }

  float getMaxX()
  {
    return max(p1.x, p2.x, p3.x);
  }

  float getMinY() 
  {
    return min(p1.y, p2.y, p3.y);
  }

  float getMaxY()
  {
    return max(p1.y, p2.y, p3.y);
  }

  float getMinZ() 
  {
    return min(p1.z, p2.z, p3.z);
  }

  float getMaxZ()
  {
    return max(p1.z, p2.z, p3.z);
  }

  void toTerminal() 
  {    
    println(" p1: " + p1.toString());
    println(" p2: " + p2.toString());
    println(" p3: " + p3.toString());
  }
};
