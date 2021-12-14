Skaler skaler = new Skaler();

class Skaler
{
  // those scale with faktor
  Vector minLen, maxLen, objectLen;

  private float faktor = 0;

  public void setFaktor(float f)
  {
    if (faktor == f)
      return;

    faktor = f;

    println("changed faktor to: " + faktor);

    // set maximum values for the min() max() funtions to work
    minLen = new Vector(parser.minLen.getData()); 
    maxLen = new Vector(parser.maxLen.getData());
    objectLen = new Vector(parser.objectLen.getData());

    minLen.divide(faktor);
    maxLen.divide(faktor);
    objectLen.divide(faktor);
    
    updateGui();
  }

  public Triangle getTriangle(int i)
  {
    Triangle temp = new Triangle(parser.getTriangle(i));

    temp.minus(parser.minLen);

    temp.divide(faktor);

    return temp;
  }  

  private void updateGui()
  {
    gui.previewRowsSlider.setRange(1, objectLen.z + 1);
    gui.previewRowsSlider.setValue(objectLen.z + 1);
    gui.previewRowsSlider.setDecimalPrecision(1);
    //gui.previewRowsSlider.setNumberOfTickMarks(objectLen.z + 1);
  }

  public void printReport()
  {
    println("Skaler Report:");
    println("  min: " + minLen.toString());
    println("  max: " + maxLen.toString());
    println("  len: " + objectLen.toString());
  };
}
