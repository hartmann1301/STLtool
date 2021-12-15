ControlP5 cp5;
GUI gui = new GUI();

int rows;

final int On = 1;
final int Off = 0;

CheckBoxes checkBoxes = new CheckBoxes();
final static class CheckBoxes
{
  final int autoRotation = 0;
  final int coordinateSystem = 1;
  final int arrayBox = 2;
}

class GUI
{
  CheckBox checkbox;
  DropdownList previewTypeList;

  Accordion accordion;

  Slider2D previewAngle;

  Slider previewRowsSlider;

  Slider slicesSlider;

  Slider framesSlider;
  Slider percentSlider;

  final int xPosCamera = 0;
  final int yPosCamera = 1;

  final int accWidth = 200;
  final int gap = 5;

  final int sliderHeight = 20;
  final int sliderWidth = 150;

  void init()
  {    
    checkbox = cp5.addCheckBox("CheckBox")
      .setPosition(10, 50)
      .setSize(40, 40)
      .setItemsPerRow(1)
      .setSpacingColumn(30)
      .setSpacingRow(20)
      .setColorActive(stdColor.dark_green_1)
      .setColorBackground(stdColor.dark_red_1)
      .addItem("Auto Rotation", checkBoxes.autoRotation)
      .addItem("Coordinate System", checkBoxes.coordinateSystem)
      .addItem("Array Box", checkBoxes.arrayBox);

    // set default values
    checkbox.getItem(checkBoxes.autoRotation).setValue(Off);
    checkbox.getItem(checkBoxes.coordinateSystem).setValue(On);
    checkbox.getItem(checkBoxes.arrayBox).setValue(On);

    // groupCamera
    final color accBCcolor = color(255, 50);
    final int angelSliderheight = 100;
    Group groupCamera = cp5.addGroup("Camera and Preview")
      .setBackgroundHeight(2 * sliderHeight + angelSliderheight + 4 * gap)
      .setBackgroundColor(accBCcolor)
      ;

    final int horizontalMax = 180;
    final int verticalMax = 100;
    previewAngle = cp5.addSlider2D("Adjust Angle")
      .setPosition(gap, gap)
      .setSize(accWidth - 2 * gap, angelSliderheight)
      .setMinMax(-horizontalMax, -verticalMax, horizontalMax, verticalMax)
      .setValue(0, 0)
      .setGroup(groupCamera)
      ;

    cp5.addButton("resetCameraAngle")
      .setValue(0)
      .setPosition(gap, angelSliderheight + 2 * gap)
      .setSize(sliderWidth, sliderHeight)
      .setLabel("Reset Angle")
      .setGroup(groupCamera)
      ;

    previewRowsSlider = cp5.addSlider("rows")
      .setPosition(gap, angelSliderheight + 3 * gap + sliderHeight)
      .setSize(sliderWidth, 20)
      .setGroup(groupCamera)
      ;

    // groupFramesAndCPU
    Group groupFramesAndCPU = cp5.addGroup("Frames and CPU")
      //.setBackgroundHeight(sliderHeight * 2 + gap * 3)
      .setBackgroundColor(accBCcolor)
      ;

    percentSlider = cp5.addSlider("percent")
      .setPosition(gap, gap)
      .setMin(0)
      .setMax(100)
      .setSize(sliderWidth, sliderHeight)
      .setGroup(groupFramesAndCPU)
      ;

    framesSlider = cp5.addSlider("frames")
      .setPosition(gap, gap * 2 + sliderHeight)
      .setMin(0)
      .setSize(sliderWidth, sliderHeight)
      .setGroup(groupFramesAndCPU)
      ;

    // groupScaleAndSlices
    Group groupScaleAndSlices = cp5.addGroup("Scale and Slices")
      //.setBackgroundHeight(sliderHeight * 1 + gap * 2)
      .setBackgroundColor(accBCcolor)
      ;

    slicesSlider = cp5.addSlider("sCale")
      .setPosition(gap, gap)
      .setSize(sliderWidth, sliderHeight)
      .setValue(1)
      .setMin(0.3) 
      .setMax(3) 
      .setGroup(groupScaleAndSlices)
      ;

    slicesSlider = cp5.addSlider("slices")
      .setPosition(gap, gap * 2 + sliderHeight)
      .setSize(sliderWidth, sliderHeight)
      .setValue(1)
      .setMin(0.3) 
      .setMax(3) 
      .setGroup(groupScaleAndSlices)
      ;

    // create accordion
    accordion = cp5.addAccordion("acc")
      .setPosition(width - accWidth - gap, gap)
      .setWidth(accWidth)
      .addItem(groupCamera)
      .addItem(groupFramesAndCPU)
      .addItem(groupScaleAndSlices)
      ;

    accordion.open(0, 1, 2);
    accordion.setCollapseMode(Accordion.MULTI);

    previewTypeList = cp5.addDropdownList("View Type")
      .setPosition(width / 2, 10)
      .setBackgroundColor(color(190))
      .setItemHeight(20)
      .setBarHeight(15)
      .setValue(2)
      .close()
      ;

    String[] previewTypeStrings = {
      "orginal stl", 
      "array of boxes", 
      "optimized boxes"
    };


    for (int i=0; i<3; i++) {
      previewTypeList.addItem(previewTypeStrings[i], i);
    }
  }

  void changeCameraAngleX(float diff)
  {
    float value =  previewAngle.getArrayValue()[xPosCamera] + diff;

    if (value < gui.previewAngle.getMinX())
      value += 360;

    if (value > gui.previewAngle.getMaxX())
      value -= 360;

    previewAngle.setValue(value, previewAngle.getArrayValue()[yPosCamera]);
  }

  void changeCameraAngleY(float diff)
  {
    float value =  previewAngle.getArrayValue()[yPosCamera] + diff;

    final float vMin = gui.previewAngle.getMinY();
    if (value < vMin)
      value = vMin;

    final float vMax = gui.previewAngle.getMaxY();
    if (value > vMax)
      value = vMax;

    previewAngle.setValue(previewAngle.getArrayValue()[xPosCamera], value);
  }
};

public void resetCameraAngle() {
  // println("Reset Camera Angle:");

  gui.previewAngle.setValue(0, 0);
}

public void slices(float v) {

  if (setupDone == false)
    return;

  boxer.setSliceFaktor(v);

  updateObject();
}

public void sCale(float v) {

  if (setupDone == false)
    return;

  boxer.setScaleFaktor(v);

  updateObject();
}

void updateObject()
{
  data.loadParsedTriangles();

  fastData.calc();
}

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isFrom(gui.checkbox)) {
    //println("CHECKBOX:");
    //println(gui.checkbox.getArrayValue());
  } else if (theEvent.isController()) {
    //println("event from controller : "+theEvent.getController().getValue()+" from "+theEvent.getController());
  }


  /*
    if (gui.checkbox.getArrayValue()
   {
   println("checkbox event " + gui.checkbox.getArrayValue()); 
   }
   */
}
