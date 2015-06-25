import 'package:vector_math/vector_math.dart';
import 'dart:math' as Math;
import 'dart:async';
import 'dart:html';


double key_x = 0.0;
double key_y = 1.0;
double key_z = 0.0;

double camera_x_delta = 1.0;
double camera_y_delta = 1.0;
double camera_z_delta = 1.0;

double camera_roll = 0.0;
double camera_pitch = 0.0;
double camera_yaw = 0.0;

double camera_roll_radians = 0.0;
double camera_pitch_radians = 0.0;
double camera_yaw_radians = 0.0;
double dtrRatio = Math.PI / 180.0;

List axisAngle = new List(4);

Math.Random random = new Math.Random(new DateTime.now().millisecondsSinceEpoch);

class A
{
     int a;
     
     A(this.a);
}

class B
{
     int b;
     B(this.b);
}

void main() {


     int time = new DateTime.now().millisecondsSinceEpoch;
     var looptime = 5 * 1000;
     var t = (time % looptime) / looptime;
     print(t);
     
     print("Milisekunde ${time}");
     print("Looptime ${looptime}");
     print("milisekunde / looptime ${(time%looptime)}");
     print("konacan ${((time%looptime)/looptime)}");

     double t1 = 0.23;
     var t11 = ((t1 + 30) / 16) % 1;
//     print(t11);
     
     double tdelta = 1.0 / 30.0;

     bool nesto = true;


     //Stopwatch
     Stopwatch sw = new Stopwatch();
     sw.start();


     
     A a = new A(10);
     B b = new B(20);
     
     List abs = [];
     abs.add(a);
     abs.add(b);
     
     //testiram generateNextVertPos(int last, int size)
     int upperBound = 3;
     int lowerBound = 0;
     Math.Random r = new Math.Random(new DateTime.now().millisecondsSinceEpoch);
     print(r.nextInt((upperBound  + 1) - lowerBound) + lowerBound);     
     int last = 0;
     int size = 0;     
     int res = generateNextVertPos(last, size);
     print(res);
     
     List prva = [1,2,3,4,5,6,7,8,9];
     List druga = prva.sublist(1, 4 + 1);
     
     druga[2] = 10;
     print(prva);
     
     print(druga);
     
     int prvi = 3;
     int drugi = 5;
     
     print((prvi - drugi));
     
     int x = 1;
     
     if(x < 2)
          print("va je");
     else if(x < 3)
          print("tri je");
     else print("neznam");
     
     double lower = 0.1;
     double higher = 0.14; 
     
     //random.nextInt((upperBound + 1) - lowerBound) + lowerBound;
     int xmy = random.nextInt(((higher - lower) * 100).toInt()) + (lower*100).toInt();
//     print(higher * 100);
     print(xmy);
     
     print(generateRandomDoubleBoundsPercentage(lower,  higher));
     
     double percent = 0.6;
     Vector3 binormal = new Vector3(10.0, 5.0, 2.0);
     binormal = percent > 0.5 ? binormal.negate() : binormal;
     print(binormal);
     
     List l = [10,20,30];
     print(l);
     l.removeAt(1);
     print(l);
     
     int position = 2;
     List h = [0, 1, 2, 3];
     h.remove(position);
     print(h);
     
     print(h.length);
     List<int> lll = new List(5);
     
     lll[1] = 2;
     print(lll);
     
     double zero = 0.0001;
     double first = 0.1;
     double second = 0.3;
     print(((second/first)));
//     print(first.remainder(second));
//     first.truncate()
     print(second/zero);
     
     
     // digit parsing
     int nekibroj = 5674;
     parseDigits(nekibroj);
}

parseDigits(int parse)
{
  int thousands =  parse ~/ 1000;
  print(thousands);
  int hundred = (parse - thousands * 1000) ~/ 100;
  print(hundred);
  int ten = (parse - thousands * 1000 - hundred * 100) ~/ 10;
  print(ten);
  
  int ones = parse % 10;
  print(ones);
}

timerCallback()
{
     print("jedandvatri");
}

List vertPositions = [0, 1, 2, 3];


class Positions
{
     int _last;
     int _next;
     
     Positions(this._last, this._next);
     get last => _last; 
     get next => _next;
}

int generateVerticalPosition()
{
     List temp = vertPositions.toList();   
     
     temp.add(2);
     print(temp);
}

double generateRandomDoubleBoundsPercentage(double lower, double higher)
{
     return (random.nextInt(((higher + 0.01 - lower) * 100).toInt()) + (lower*100))/100.0;
}

int generateNextVertPos(int last, int size)
{
    //last moze biti 0/1/2/3
    //size moze biti 0/1/2/3
     
     //ako je size 2 ili 3 vrati random od 0 do 3
     //ako je size 0 vrati rezultat je u range-u [last-1, last+1]
     //ako je size 1 vrati rezultat je u range-u [last-2, last+2]
     
     if(size > 1)
          return random.nextInt(4); //0/1/2/3
     else
     {
          int deviate = size + 1;
          int lowerBound;
          int upperBound;
          
//          if((last - deviate) < 0)
//          {
//               lowerBound = 0;
//          }
//          if((last - deviate) >= 0)
//          {
//               lowerBound = last - deviate;
//          }
//          
//          
//          if((last + deviate) >= 3)
//          {
//               upperBound = 3;
//          }
//          if((last + deviate) < 3)
//          {
//               upperBound = last + deviate;
//          }
          
          //ekvivalent gornjem kodu
          upperBound = ((last + deviate) >= 3) ? 3 : last + deviate;
          lowerBound = ((last - deviate) < 0) ? 0 : last - deviate;
          
          print("Lower " + lowerBound.toString());
          print("Upper " + upperBound.toString());
          
          /**Return random number in between inclusive [upperBound] and inclusive [lowerBound]*/
          return random.nextInt((upperBound + 1) - lowerBound) + lowerBound;
     }     
}

double computeSine(int seconds) {
     int t = seconds;
     double period = 3.0;
     double frekvencija = 1 / period;
     double amplituda = 5.0;

     return amplituda * Math.sin(2 * Math.PI * frekvencija * t);
}


Matrix4 quatToRotationMatrix(Quaternion q) {

     List<double> values = new List<double>(9);
     Matrix4 s = new Matrix4.identity();

     values[0] = Math.pow(q.w, 2).toDouble() + Math.pow(q.x, 2).toDouble() - Math.pow(q.y, 2).toDouble() - Math.pow(q.z, 2).toDouble();
     values[1] = 2 * q.x * q.y - 2 * q.w * q.z;
     values[2] = 2 * q.x * q.z + 2 * q.w * q.y;
     values[3] = 2 * q.x * q.y + 2 * q.w * q.z;
     values[4] = Math.pow(q.w, 2).toDouble() - Math.pow(q.x, 2).toDouble() + Math.pow(q.y, 2).toDouble() - Math.pow(q.z, 2).toDouble();
     values[5] = 2 * q.y * q.z + 2 * q.w * q.x;
     values[6] = 2 * q.x * q.z - 2 * q.w * q.y;
     values[7] = 2 * q.y * q.z - 2 * q.w * q.x;
     values[8] = Math.pow(q.w, 2).toDouble() - Math.pow(q.x, 2).toDouble() - Math.pow(q.y, 2).toDouble() + Math.pow(q.z, 2).toDouble();

     s.setEntry(0, 0, values[0]);
     s.setEntry(0, 1, values[1]);
     s.setEntry(0, 2, values[2]);
     s.setEntry(1, 0, values[3]);
     s.setEntry(1, 1, values[4]);
     s.setEntry(1, 2, values[5]);
     s.setEntry(2, 0, values[6]);
     s.setEntry(2, 1, values[7]);
     s.setEntry(2, 2, values[8]);

     return s;

}

void quatToAxisAngle(Quaternion q) {

     double x, y, z, angle;

     if (q.w > 1) q.normalize();
     angle = 2 * Math.acos(q.w);
     double s = Math.sqrt(1 - q.w * q.w);

     if (s < 0.001) {
          x = q.x;
          y = q.y;
          z = q.z;
     } else {
          x = q.x / s;
          y = q.y / s;
          z = q.z / s;
     }

     axisAngle[0] = x;
     axisAngle[1] = y;
     axisAngle[2] = z;
     axisAngle[3] = angle;

}
