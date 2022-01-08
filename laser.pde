Laser laser = new Laser();

class Laser
{
  boolean[][] objectFootprint;

  int startHeight;
  final String taskName = new String("taskLaser");
  final int cutRadius = 1;

  void init()
  {
    timeMonitor.startTask(taskName);

    startHeight = data.axisLength.z - 2;

    createTopData();
    createCutFrame();

    timeMonitor.stopTask(taskName);
  }

  void createTopData()
  {
    for (int x = 0; x < data.axisLength.x - 1; x++)
    {
      for (int y = 0; y < data.axisLength.y - 1; y++)
      {
        int highestSolid = startHeight;

        for (int z = startHeight; z > 0; z--)
        {
          BitStatus s = data.getPoint(x, y, z);  

          if (s == BitStatus.OUTSIDE)
            continue;

          highestSolid = z;

          break;
        }

        for (int z = startHeight; z > highestSolid; z--)
        {
          data.setPoint(BitStatus.UNKNOWN, x, y, z);
        }
      }
    }
  }

  void createCutFrame()
  {
    ArrayList<IntV3> cutFrame = new ArrayList<IntV3>();

    for (int r = 0; r < cutRadius; r++)
    {
      for (int x = 0; x < data.axisLength.x - 1; x++)
      {
        for (int y = 0; y < data.axisLength.y - 1; y++)
        {
          BitStatus s = data.getPoint(x, y, startHeight);  

          if (s != BitStatus.UNKNOWN)
            continue;

          cutFrame.add(new IntV3(x + 1, y, 0));
          cutFrame.add(new IntV3(x - 1, y, 0));
          cutFrame.add(new IntV3(x, y + 1, 0));
          cutFrame.add(new IntV3(x, y - 1, 0));
        }
      }

      // this size is crazy high, maybe i should use a simple array
      //println("cutFrame.size() :" + cutFrame.size());

      // for each radius 
      for (IntV3 p : cutFrame)
      {
        data.setPoint(BitStatus.UNKNOWN, p.x, p.y, startHeight);
      }   
      cutFrame.clear();
    }

    for (int x = 0; x < data.axisLength.x - 1; x++)
    {
      for (int y = 0; y < data.axisLength.y - 1; y++)
      {
        if ((data.getPoint(x, y, startHeight) == BitStatus.UNKNOWN) && (data.getPoint(x, y, startHeight - 1) == BitStatus.OUTSIDE))
        {
          //println("fill Line x:" + x + ",  y:" + y + " ");

          // fill the whole line
          for (int z = 0; z < data.axisLength.z - 1; z++)
          {
            data.setPoint(BitStatus.UNKNOWN, x, y, z);
          }
        }
      }
    }
  }

  void update()
  {
  }
}
