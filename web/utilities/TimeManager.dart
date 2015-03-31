

class TimeManager
{
     //duration of one loop in seconds
     int duration;
     //
     double fraction;
     bool _isRunning;     
     
     Stopwatch stopwatch;
     Duration elapsed;
     
     //set the duration in seconds, use as milliseconds
     TimeManager(int duration, [bool start])
     {          
          this.duration = duration * 1000;
          stopwatch = new Stopwatch();
          
          //odmah pokreni ako start == true
          if(start)
          {
               stopwatch.start();
          }
//          _isRunning = false;
     }
     
     bool get isRunning => _isRunning;
     /**
      * Starts the timer which runs a loop for duration seconds
      * incrementing by fraction
      */
     void start()
     {
          stopwatch.start(); //dvaput zvati start nema efekta, tu smo sigurni
          _isRunning = true;
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
     
     void pause()
     {
//          if(!isRunning)
//               return;
          
//          _isRunning = true;
          stopwatch.stop(); //stani sa mjerenjem, elapsed je i dalje tu
     }
     
     void reset()
     {
          _isRunning = false;
          stopwatch.stop();
          stopwatch.reset();
          this.elapsed = null;          
     }
     
     //returns a number in range 0-1 that corresponds to 0-duration range.
     //called in render loop
     double getCurrentTime()
     {
//          if(!isRunning)
//               return 0.0;
          //elapsed % duration -> konvert u [0...1] (postotak)          
          return (stopwatch.elapsedMilliseconds % duration) / duration;          
     }
}