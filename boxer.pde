Boxer boxer = new Boxer(); //<>//

void updateBoxerThread()
{
  thread("updateBoxer");
}

void updateBoxer()
{
  if (timeMonitor.isBusy(boxer.taskName))
    return;  

  boxer.update();
}

class Boxer
{
  // those scale with sliceFaktor
  Vector minLen, maxLen, objectLen, objectSlices;

  private float sliceFaktor = 1.0;
  private float scaleFaktor = 1.0;
  private float boxFaktor = 1.0;

  private float combinedFaktor = 1.0;

  public boolean busy = false;

  float radiusMaxXY = 0;

  final String taskName = new String("taskBoxer");

  public void setSliceFaktor(float f)
  {
    if (sliceFaktor == f)
      return;

    sliceFaktor = f;

    //debug.println("changed sliceFaktor to: " + sliceFaktor);

    updateBoxerThread();
  }

  public void setScaleFaktor(float f)
  {
    if (scaleFaktor == f)
      return;

    scaleFaktor = f;

    updateBoxerThread();
  }

  public Triangle getTriangle(int i)
  {
    Triangle temp = new Triangle(parser.getTriangle(i));

    temp.minus(parser.minLen);

    // do all in one, this is way faster
    temp.multiply(combinedFaktor);

    return temp;
  }  

  void update()
  {    
    timeMonitor.startTask(boxer.taskName);

    // they are needed in the raw data array
    updateLenVectors();

    // it is faster to use this than  do 3 calculations
    combinedFaktor = ((scaleFaktor * boxFaktor) / sliceFaktor);

    radiusMaxXY = parser.getRadiusMaxXY() * combinedFaktor;

    // do not use threads here, very dangerous!
    data.update();

    if (gui.previewStylesList.getValue() == PreviewStyles.optimizedBoxes)
      fastData.update();

    if (gui.previewStylesList.getValue() == PreviewStyles.concentric)
      zylinder.update();

    updateGui();

    timeMonitor.stopTask(boxer.taskName);
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
    objectSlices.multiply(scaleFaktor / sliceFaktor);

    // because instead of a point a box is placed
    float max = objectLen.getMaxValue();
    boxFaktor = (max - 1)/ max; 
    //println("set Boxfaktor to: " + boxFaktor);
  }

  private void updateGui()
  {
    gui.sliderRows.setRange(1, objectSlices.z + 1);
    gui.sliderRows.setValue(objectSlices.z + 1);

    gui.lableSlices.setText(data.axisLength.toString());
    gui.lableDimensions.setText(getObjectLenString());

    gui.updateInfoLables();
  }

  String getObjectLenString()
  {
    final int d = 1; 
    return "x:" + nf(objectLen.x, 0, d) + " * y:" +  nf(objectLen.y, 0, d) + " * z:" +  nf(objectLen.z, 0, d) + "mm";
  }

  public void printReport()
  {
    debug.println("Boxer Report:");
    debug.println("  min: " + minLen.toString());
    debug.println("  max: " + maxLen.toString());
    debug.println("  len: " + objectSlices.toString());
  };
}
