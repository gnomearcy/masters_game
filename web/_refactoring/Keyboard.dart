library Keyboard;

import 'dart:html';
import 'dart:collection';

class Keyboard
{
     HashMap<int, int> _keys = new HashMap<int, int>();
     
     Keyboard()
     {
          window.onKeyDown.listen((KeyboardEvent e)
          {        
             if (!_keys.containsKey(e.keyCode))
             {
                  _keys[e.keyCode] = e.timeStamp;                  
             }
          });
          
          window.onKeyUp.listen((KeyboardEvent e)
          {
             _keys.remove(e.keyCode);
          });
     }
     
     isPressed(int keyCode) => _keys.containsKey(keyCode);
}