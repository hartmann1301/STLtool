Boxer boxer = new Boxer();

class Boxer
{
  // those scale with sliceFaktor
  Vector minLen, maxLen, objectLen, objectSlices;

  private float sliceFaktor = 1.0;
  private float scaleFaktor = 1.0;

  public void setSliceFaktor(float f)
  {
    if (sliceFaktor == f)
      return;

    sliceFaktor = f;

    //println("changed sliceFaktor to: " + sliceFaktor);

    update();
  }

  public void setScaleFaktor(float f)
  {
    if (scaleFaktor == f)
      return;

    scaleFaktor = f;

    println("changed scaleFaktor to: " + scaleFaktor);

    update();
  }

  public Triangle getTriangle(int i)
  {
    Triangle temp = new Triangle(parser.getTriangle(i));

    temp.minus(parser.minLen);

    temp.multiply(scaleFaktor);

    temp.divide(sliceFaktor);

    return temp;
  }  

  void update()
  {
    updateLenVectors();
    updateGui();
  }

  private void updateLenVectors()
  {
    // set maximum values for the min() max() funtions to work
    minLen = new Vector(parser.minLen.getData()); 
    maxLen = new Vector(parser.maxLen.getData());
    objectLen = new Vector(parser.objectLen.getData());
    objectSlices = new Vector(parser.objectLen.getData());

    minLen.multiply(scaleFaktor);
    maxLen.multiply(scaleFaktor);
    objectLen.multiply(scaleFaktor);
    objectSlices.multiply(scaleFaktor);

    objectSlices.divide(sliceFaktor);
  }

  private void updateGui()
  {
    gui.previewRowsSlider.setRange(1, objectSlices.z + 1);
    gui.previewRowsSlider.setValue(objectSlices.z + 1);
    gui.previewRowsSlider.setDecimalPrecision(1);
    //gui.previewRowsSlider.setNumberOfTickMarks(objectSlices.z + 1);
  }

  public void printReport()
  {
    println("Boxer Report:");
    println("  min: " + minLen.toString());
    println("  max: " + maxLen.toString());
    println("  len: " + objectSlices.toString());
  };
}
