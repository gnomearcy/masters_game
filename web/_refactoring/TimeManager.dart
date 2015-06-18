library TimeManager;
//todo add count down delay function

class TimeManager
{
     //duration of one loop in milliseconds
     int duration = 420 * 1000;
     Stopwatch stopwatch;
     
     bool _isRunning;    
     bool get isRunning => _isRunning;
     
     //set the duration in seconds, use as milliseconds
     TimeManager({bool forceStart})
     {          
//          this.duration = duration * 1000;
          stopwatch = new Stopwatch();
          
          if(forceStart)
          {
               stopwatch.start();
          }
     }
     
     void toggle()
     {          
          if(stopwatch != null)
          {
              if(stopwatch.isRunning)
              {
                   stopwatch.stop();
              }
              else
              {
                   stopwatch.start();
              }
          }
     }
     
     /**
      * Returns [stopwatch.elapsedMilliseconds]'s percentage of [duration]
      * in interval [0, 1]. Used in render loop for ship's movement.
      */
     double getCurrentTime()
     {
          return (stopwatch.elapsedMilliseconds % duration) / duration;
     }
}