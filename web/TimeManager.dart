library TimeManager;

class TimeManager
{
    int duration = 120 * 1000;
    Stopwatch stopwatch;
     
    bool _isRunning;    
    bool get isRunning => _isRunning;
     
    TimeManager({bool forceStart})
    {          
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
     
    toggle()
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
    
    reset()
    {    
       toggle();
       this.stopwatch.reset();
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