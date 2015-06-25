library TimeManager;
//todo add count down delay function

class TimeManager
{
     //duration of one loop in milliseconds
     int duration = 40 * 1000;
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
             _isRunning = true;
          }
          else
          {
            _isRunning = false;
          }
     }
     
     void toggle()
     {          
          if(stopwatch != null)
          {
              if(stopwatch.isRunning)
              {
                   stopwatch.stop();
                   _isRunning = false;
              }
              else
              {
                   stopwatch.start();
                   _isRunning = true;
              }
          }
     }
     
     /**
      * Returns [stopwatch.elapsedMilliseconds]'s percentage of [duration]
      * in interval [0, 1]. Used in render loop to determined ship's position
      * along the curve (0 being the start and 1 being the end)
      */
     double getCurrentTime()
     {
          return (stopwatch.elapsedMilliseconds % duration) / duration;
     }
}