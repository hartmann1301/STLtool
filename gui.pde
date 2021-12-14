ControlP5 cp5;
GUI gui = new GUI();

int previewRows;

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
  Slider2D previewAngle;

  Slider previewRowsSlider;

  Slider slicesSlider;

  Slider framesSlider;
  Slider percentSlider;

  final int xPosCamera = 0;
  final int yPosCamera = 1;

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

    previewRowsSlider = cp5.addSlider("previewRows")
      .setPosition(width - 50, height / 2)
      .setSize(20, 150)
      ;

    percentSlider = cp5.addSlider("percent")
      .setPosition(10, height - 60)
      .setMin(0)
      .setMax(100)
      .setSize(150, 20)
      ;

    // top right corner
    Group botomLeftGroup = cp5.addGroup("Frames And CPU")
      .setPosition(10, height - 30)
      .setBackgroundHeight(100)
      .setBackgroundColor(color(255, 50))
      ;

    framesSlider = cp5.addSlider("frames")
      .setPosition(10, height - 30)
      .setMin(0)
      .setSize(150, 20)
      ;

    slicesSlider = cp5.addSlider("slices")
      .setPosition(width - 50, 200)
      .setSize(20, 150)
      .setValue(1)
      .setMin(0.3) 
      .setMax(3) 
      ;

    // funktioniert leider nicht richtig
    previewRowsSlider.getValueLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE);
    previewRowsSlider.getValueLabel().setVisible(false);   
    previewRowsSlider.getCaptionLabel().setVisible(false);

    // top right corner
    Group topRightGroup = cp5.addGroup("Preview Angle")
      .setPosition(width - 120, 20)
      .setBackgroundHeight(100)
      .setBackgroundColor(color(255, 50))
      ;

    previewAngle = cp5.addSlider2D("Adjust Angle")
      .setPosition(0, 0)
      .setSize(100, 100)
      .setMinMax(-180, -100, 180, 100)
      .setValue(0, 0)
      .setGroup(topRightGroup)
      ;

    cp5.addButton("resetCameraAngle")
      .setValue(0)
      .setPosition(0, 120)
      .setSize(100, 20)
      .setLabel("Reset Angle")
      .setGroup(topRightGroup)
      ;

    //float x = previewAngle.getAbsolutePosition()[0];

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

  //println("slices: " + v + "mm");

  skaler.setFaktor(v);

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

StdColor stdColor = new StdColor();
final static class StdColor
{
  final int black = #000000;
  final int dark_grey_4 = #434343;
  final int dark_grey_3 = #666666;
  final int dark_grey_2 = #999999;
  final int dark_grey_1 = #b7b7b7;
  final int grey = #cccccc;
  final int light_grey_1 = #d9d9d9;
  final int light_grey_2 = #efefef;
  final int light_grey_3 = #f3f3f3;
  final int white = #ffffff;
  final int red_berry = #980000;
  final int red = #ff0000;
  final int orange = #ff9900;
  final int yellow = #ffff00;
  final int green = #00ff00;
  final int cyan = #00ffff;
  final int cornflower_blue = #4a86e8;
  final int blue = #0000ff;
  final int purple = #9900ff;
  final int magenta = #ff00ff;
  final int light_red_berry_3 = #e6b8af;
  final int light_red_3 = #f4cccc;
  final int light_orange_3 = #fce5cd;
  final int light_yellow_3 = #fff2cc;
  final int light_green_3 = #d9ead3;
  final int light_cyan_3 = #d0e0e3;
  final int light_cornflower_blue_3 = #c9daf8;
  final int light_blue_3 = #cfe2f3;
  final int light_purple_3 = #d9d2e9;
  final int light_magenta_3 = #ead1dc;
  final int light_red_berry_2 = #dd7e6b;
  final int light_red_2 = #ea9999;
  final int light_orange_2 = #f9cb9c;
  final int light_yellow_2 = #ffe599;
  final int light_green_2 = #b6d7a8;
  final int light_cyan_2 = #a2c4c9;
  final int light_cornflower_blue_2 = #a4c2f4;
  final int light_blue_2 = #9fc5e8;
  final int light_purple_2 = #b4a7d6;
  final int light_magenta_2 = #d5a6bd;
  final int light_red_berry_1 = #cc4125;
  final int light_red_1 = #e06666;
  final int light_orange_1 = #f6b26b;
  final int light_yellow_1 = #ffd966;
  final int light_green_1 = #93c47d;
  final int light_cyan_1 = #76a5af;
  final int light_cornflower_blue_1 = #6d9eeb;
  final int light_blue_1 = #6fa8dc;
  final int light_purple_1 = #8e7cc3;
  final int light_magenta_1 = #c27ba0;
  final int dark_red_berry_1 = #a61c00;
  final int dark_red_1 = #cc0000;
  final int dark_orange_1 = #e69138;
  final int dark_yellow_1 = #f1c232;
  final int dark_green_1 = #6aa84f;
  final int dark_cyan_1 = #45818e;
  final int dark_cornflower_blue_1 = #3c78d8;
  final int dark_blue_1 = #3d85c6;
  final int dark_purple_1 = #674ea7;
  final int dark_magenta_1 = #a64d79;
  final int dark_red_berry_2 = #85200c;
  final int dark_red_2 = #990000;
  final int dark_orange_2 = #b45f06;
  final int dark_yellow_2 = #bf9000;
  final int dark_green_2 = #38761d;
  final int dark_cyan_2 = #134f5c;
  final int dark_cornflower_blue_2 = #1155cc;
  final int dark_blue_2 = #0b5394;
  final int dark_purple_2 = #351c75;
  final int dark_magenta_2 = #741b47;
  final int dark_red_berry_3 = #5b0f00;
  final int dark_red_3 = #660000;
  final int dark_orange_3 = #783f04;
  final int dark_yellow_3 = #7f6000;
  final int dark_green_3 = #274e13;
  final int dark_cyan_3 = #0c343d;
  final int dark_cornflower_blue_3 = #1c4587;
  final int dark_blue_3 = #073763;
  final int dark_purple_3 = #20124d;
  final int dark_magenta_3 = #4c1130;
}
