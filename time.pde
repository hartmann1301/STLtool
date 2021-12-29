TimeMonitor timeMonitor = new TimeMonitor();

class TimeMonitor
{
  int sollFrames = 0;
  
  long timeElapsed, timeDrawStart, timeTaskStart;
  
  float busy = 0;
  float busyAvarage = 0;

  void setFrameRate(int f)
  {
    sollFrames = f;
    frameRate(f);
    gui.sliderFrames.setMax(f + 1);
  }

  void startTask()
  {
    timeTaskStart = System.nanoTime(); 
  }

  void stopTask()
  {
    stopTask(null);
  }

  void stopTask(String msg)
  {
    timeElapsed = System.nanoTime() - timeTaskStart;
    
    if (msg == null)
      return;
      
    debug.println(msg + " took: " + timeMonitor.toString());
  }
  
  String toString() 
  {
    return new String((timeElapsed/1000000) + "ms");
  }

  void startDraw()
  {
    timeDrawStart = System.nanoTime();
  }

  void stopDraw()
  {
    timeElapsed = System.nanoTime() - timeDrawStart;

    busy = (((timeElapsed / 1000) * sollFrames) / 1000) / 10;

    //println(((float) (timeElapsed/1000) / 1000) + "ms -> * frameRate:" + frameRate + " = " + busy);

    busyAvarage = busyAvarage * 0.95 + busy * 0.05;

    cp5.getController("frames").setValue(frameRate);
    cp5.getController("busy").setValue(busyAvarage);
  }
}
