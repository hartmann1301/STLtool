ControlP5 cp5;
GUI gui = new GUI();

final int On = 1;
final int Off = 0;

static final class CheckBoxes
{
  static final int autoRotation = 0;
  static final int coordinateSystem = 1;
  static final int arrayBox = 2;
  static final int concentricData = 3;
}

static final class PreviewStyles
{
  static final int originalSTL = 0;
  static final int arrayOfBoxes = 1;
  static final int optimizedBoxes = 2;
  static final int concentric = 3;
}

class GUI
{
  Textlabel lableVersion;

  CheckBox checkbox;

  DropdownList previewStylesList;
  List previewTypes = Arrays.asList(
    "orginal stl", 
    "array of boxes", 
    "optimized boxes",
    "concentric"
    );

  Accordion accordion;

  Slider2D previewAngle;

  Slider sliderRows;

  Slider sliderFrames;
  Slider sliderBusy;

  Textlabel lablePreviewInfo;

  Slider sliderSlices;
  Slider sliderScale;

  Textlabel lableSlices;
  Textlabel lableDimensions;

  final int xPosCamera = 0;
  final int yPosCamera = 1;

  final int accWidth = 220;
  final int gap = 5;

  final int sliderHeight = 20;
  final int sliderWidth = 150;

  void init()
  {    
    PFont font = createFont("arial", 12);
    cp5.setFont(font);    

    // create a new button with name 'buttonA'
    cp5.addButton("loadFile")
      .setValue(0)
      .setPosition(gap, gap)
      .setSize(sliderWidth, sliderHeight)
      ;

    lableVersion = cp5.addTextlabel("lableVersion")
      .setPosition(width - 80, height - 30)
      //.setPosition(0, 0)
      .setText(slicerVersion)
      ; 

    checkbox = cp5.addCheckBox("CheckBox")
      .setPosition(gap, 80)
      .setSize(30, 30)
      .setItemsPerRow(1)
      .setSpacingRow(10)
      .setColorActive(stdColor.dark_green_1)
      .setColorBackground(stdColor.dark_red_1)
      .addItem("Auto Rotation", CheckBoxes.autoRotation)
      .addItem("Coordinate System", CheckBoxes.coordinateSystem)
      .addItem("Array Box", CheckBoxes.arrayBox)
      .addItem("Concentric Data", CheckBoxes.concentricData);
      
    // set default values
    checkbox.getItem(CheckBoxes.autoRotation).setValue(Off);
    checkbox.getItem(CheckBoxes.coordinateSystem).setValue(On);
    checkbox.getItem(CheckBoxes.arrayBox).setValue(On);
    checkbox.getItem(CheckBoxes.concentricData).setValue(Off);

    // groupCamera
    final color accBCcolor = color(255, 50);
    final int angelSliderheight = 100;
    Group groupCamera = cp5.addGroup("Camera and Preview")
      .setBackgroundHeight(2 * sliderHeight + angelSliderheight + 4 * gap)
      .setBackgroundColor(accBCcolor)
      .setBarHeight(sliderHeight);
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

    sliderRows = cp5.addSlider("rows")
      .setPosition(gap, angelSliderheight + 3 * gap + sliderHeight)
      .setSize(sliderWidth, 20)
      .setGroup(groupCamera)
      .setDecimalPrecision(0)
      ;

    // groupFramesAndCPU
    Group groupFramesAndCPU = cp5.addGroup("Frames and CPU")
      //.setBackgroundHeight(sliderHeight * 2 + gap * 3)
      .setBackgroundColor(accBCcolor)
      .setBarHeight(sliderHeight);
    ;

    sliderBusy = cp5.addSlider("busy")
      .setPosition(gap, gap)
      .setMin(0)
      .setMax(100)
      .setSize(sliderWidth, sliderHeight)
      .setGroup(groupFramesAndCPU)
      ;

    sliderFrames = cp5.addSlider("frames")
      .setPosition(gap, gap * 2 + sliderHeight)
      .setMin(0)
      .setSize(sliderWidth, sliderHeight)
      .setGroup(groupFramesAndCPU)
      ;

    lablePreviewInfo = cp5.addTextlabel("lablePreviewInfo")
      .setPosition(gap, gap * 3 + sliderHeight * 2)
      .setGroup(groupFramesAndCPU)
      ;  

    // groupScaleAndSlices
    Group groupScaleAndSlices = cp5.addGroup("Scale and Slices")
      //.setBackgroundHeight(sliderHeight * 1 + gap * 2)
      .setBackgroundColor(accBCcolor)
      .setBarHeight(sliderHeight);
    ;

    final float sliderRange = 5.0;
    sliderScale = cp5.addSlider("sCale")
      .setPosition(gap, gap)
      .setSize(sliderWidth, sliderHeight)
      .setValue(1)
      .setMin(1.0 / sliderRange) 
      .setMax(sliderRange) 
      .setGroup(groupScaleAndSlices)
      ;

    lableDimensions = cp5.addTextlabel("lableDimensions")
      .setPosition(gap, gap * 2 + sliderHeight)
      .setGroup(groupScaleAndSlices)
      ;

    sliderSlices = cp5.addSlider("slices")
      .setPosition(gap, gap * 3 + sliderHeight * 2)
      .setSize(sliderWidth, sliderHeight)
      .setValue(1)
      .setMin(1.0 / sliderRange) 
      .setMax(sliderRange) 
      .setGroup(groupScaleAndSlices)
      ;

    lableSlices = cp5.addTextlabel("lableSlices")
      .setPosition(gap, gap * 4 + sliderHeight * 3)
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

    // Warning, deprecated, should use addScrollableList
    //cp5.addScrollableList("View Type")
    previewStylesList = cp5.addDropdownList("previewStyle")  
      .setPosition(width / 2 - sliderWidth / 2, gap)
      .setSize(sliderWidth, sliderHeight * (previewTypes.size() + 1))
      .setItemHeight(sliderHeight)
      .setBarHeight(sliderHeight)
      .addItems(previewTypes)
      .setValue(PreviewStyles.optimizedBoxes)
      .close()  
      ;
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

void previewStyle(int n)
{
  //println("update previewStyle");
  String s = new String();
  switch(n) 
  {
  case PreviewStyles.originalSTL: 
    s = "Triangles: " + parser.getListSize();
    break;
  case PreviewStyles.arrayOfBoxes: 
    s = "Shell: " + data.cntShell + ", Inside: " + data.cntInside + ", Outside: " + data.cntOutside;
    break;
  case PreviewStyles.optimizedBoxes: 
    s = "Optimized Boxes: " + fastData.drawData.size();
    break;
  case PreviewStyles.concentric: 

    break;    
    
  }
  gui.lablePreviewInfo.setText(s);
}

public void loadFile() {
  if (setupDone == false)
    return;

  selectInput("Select a file to process:", "fileSelected", sketchFile(sketchPath()));
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());

    parser.loadFile(selection.getAbsolutePath());
  }
}

public void resetCameraAngle() {
  // println("Reset Camera Angle:");

  gui.previewAngle.setValue(0, 0);
}

public void slices(float v) {

  if (setupDone == false)
    return;

  boxer.setSliceFaktor(v);
}

public void sCale(float v) {

  if (setupDone == false)
    return;

  boxer.setScaleFaktor(v);
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
