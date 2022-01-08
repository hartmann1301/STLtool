TimeMonitor timeMonitor = new TimeMonitor();

class TimeMonitor
{
  int sollFrames = 0;

  long lastProgressUpdateMS = 0;
  final long progressUpdateIntervalMS = 100;

  IntDict taskDict= new IntDict();

  float busyAvarage = 0;

  void setFrameRate(int f)
  {
    sollFrames = f;
    frameRate(f);
    gui.sliderFrames.setMax(f + 1);
  }

  boolean isBusy(final String name)
  {
    return taskDict.hasKey(name);
  }

  void printTasks()
  {
    print("Tasks:");
    for (int i = 0; i < taskDict.size(); i++)
    {
      print(" " + i + " " + taskDict.key(i)); 
    }
  }

  void startTask(final String name)
  {
    if (taskDict.hasKey(name))
    {
      debug.println("Warning: task:" + name + " started twice!");
      return;
    }

    long taskStartMS = getCurrentMS();

    taskDict.add(name, (int) taskStartMS);

    // draw tasks runs all the time, no need to show it
    if (name == drawTaskName)
      return;

    debug.println("start:" + name);

    gui.lableProgressTask.setText(name);

    // to make sure the first updateTask will be done after interval
    lastProgressUpdateMS = taskStartMS;
  }

  long getCurrentMS()
  {
    return System.nanoTime() / 1000000;
  }

  long getTaskTimeMS(final String name)
  {
    if (taskDict.hasKey(name) == false)
    {
      debug.println("Warning: unable to get time, task:" + name);
      return 0;
    }

    return getCurrentMS() - taskDict.get(name);
  }

  void updateTask(final String name, float cDone, float cFactor, float cCurrent, float cMax, boolean isInverse)
  {
    if (isInverse)
      cCurrent = cMax - cCurrent;

    updateTask(name, cDone, cFactor, cCurrent, cMax);
  }

  void updateTask(final String name, float cDone, float cFactor, float cCurrent, float cMax)
  {
    long taskTimeMS = getTaskTimeMS(name);

    // return because task didn´t last long enough yet
    if (taskTimeMS < progressUpdateIntervalMS)
      return;

    final long currentMS = getCurrentMS();

    // return because last update was closer than interval
    if (currentMS < lastProgressUpdateMS + progressUpdateIntervalMS)
      return;

    if (name == drawTaskName)
      return;

    // save system time 
    lastProgressUpdateMS = currentMS;

    if (cMax == 0)
      return;

    // do the divide operation and the gui update here
    float progress = cDone + cFactor * (cCurrent/cMax);

    //println(name + " progress: " + progress);
    gui.sliderProgress.setValue(progress);
  }

  void stopTask(final String name)
  {
    if (taskDict.hasKey(name) == false)
    {
      debug.println("Warning: task:" + name + " can not be stopped");
      return;
    }

    if (name == drawTaskName) 
    {
      float busy = (getTaskTimeMS(name)  * sollFrames) / 10;

      //println(((float) (timeElapsed/1000) / 1000) + "ms -> * frameRate:" + frameRate + " = " + busy);
      busyAvarage = busyAvarage * 0.95 + busy * 0.05;

      cp5.getController("frames").setValue(frameRate);
      cp5.getController("busy").setValue(busyAvarage);
    } else
    {
      debug.println("done: " + name + " took: " + getTaskTimeMS(name) + "ms");

      gui.sliderProgress.setValue(0);
      gui.lableProgressTask.setText("");
    }

    taskDict.remove(name);
  }
}
