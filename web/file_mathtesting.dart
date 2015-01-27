import 'package:vector_math/vector_math.dart';
import 'dart:math' as Math;
import 'dart:async';


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

void main() {


     int time = new DateTime.now().millisecondsSinceEpoch;
     var looptime = 20 * 1000;
     var t = (time % looptime) / looptime;
     print(t);

     double t1 = 0.23;
     var t11 = ((t1 + 30) / 16) % 1;
     print(t11);

     double tdelta = 1.0 / 30.0;

     bool nesto = true;


     //Stopwatch
     Stopwatch sw = new Stopwatch();
     sw.start();


     while (true) {
//          print("elapsed: ${sw.elapsed.inSeconds} sin: ${computeSine(sw.elapsed.inSeconds)}");
          print(sw.elapsedTicks / 1000000);
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
