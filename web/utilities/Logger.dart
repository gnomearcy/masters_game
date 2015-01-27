
class Logger
{
     static bool debug = true;
     static bool enableTimestamp = true;
     static DateTime timeNow = null; 
     
     static void Log(String tag, String message)
     {         
          if(debug)
          {
               if(tag.isEmpty || tag == null)
               {
                    tag = "Unknown tag";
               }
               
               if(enableTimestamp)
               {
                    timeNow = new DateTime.now();
                    print("[" + timeNow.toString() + "]-[" + tag + "]-[" + message + "]");
               }
               else
               {
                    print("[" + tag + "]-[" + message + "]");
               }               
          }
          else
          {
               print("Debug mode is not activated.");
          }
     }
          
}