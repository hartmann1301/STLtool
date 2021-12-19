Debug debug = new Debug();

PrintWriter fileOutput;

class Debug
{
  void init()
  {
    fileOutput = createWriter("debug.txt"); 
  }
  
  void print(String s)
  {
    fileOutput.print(s);
    fileOutput.flush();
    
    System.out.print(s);
  }
  
  void println(String s)
  {
    fileOutput.println(s); 
    fileOutput.flush();
    
    System.out.println(s);  
  }
  
    void println()
  {
    fileOutput.println(); 
    fileOutput.flush();
    
    System.out.println();  
  }
};
