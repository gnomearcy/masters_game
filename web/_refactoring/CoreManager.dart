/**
 * Class used to generate Game obstacles and score items.
 */

import 'package:three/three.dart' hide Path;
import 'package:vector_math/vector_math.dart';
import 'dart:math';
import 'ObjectManager.dart';

class CoreManager
{
     //Fine tuning interface
     double Lref = 20.0;
     //referentni pomak za izracun aktualnog pomaka ovisno o duljini krivulje
     double dtref = 0.03;
     //threshold iznad kojeg biljezim trenutnu vrijednost "t"
     double dist = 0.8;
     
     List vertPositions = [0, 1, 2, 3];
     
     //defines a coefficient by which to expand (> 1.0) or compress (< 1.0) bounding boxes of obstacle items
     double obstacleBoxSquish = 0.5;
     //defines a coefficient by which to expand (> 1.0) or compress (< 1.0) bounding boxes of scoreItem items
     double scoreItemBoxSquish = 1.0;
     
//     int segs;
//     int binormals;
//     SplineCurve3 curve;
     
     Random random;
     
     List globalTs = [];      //valid t values for scoreitem/obstacle horizontal position
     
     CoreManager();
     
//     Path path;               //holds curve, number of segments and binormals for vertical offset
//     Curve3D path;
     Object3D parent;
     double strafe;           //maximum vertical offset from middle (binormal multiplier)
     
     double a = 0.125;
     double b = 0.125;
     
     ObjectManager objM;
     
     //generate a set of hit objects
     //we need a parent to add the object to
     generate(Object3D pp, ObjectManager m, double s)
     {
          objM = m;
          parent = pp;
          strafe = s;
          
          random = new Random(new DateTime.now().millisecondsSinceEpoch);
          double L = objM.path.length; 
          double dt = (Lref * dtref / L);

          double sum = 0.0; 
          double t = 0.0;
          t += dt;

          Vector3 previous = objM.path.getPoint(t);           

          while (t <= 1.0 + dt)
          {
               Vector3 current = objM.path.getPoint(t);

               double diff = current.absoluteError(previous);

               sum = sum + diff;

               if (sum >= dist) 
               {
                    globalTs.add(t);
                    sum = 0.0;
               }

               previous.setFrom(current.clone());
               t += dt;
          }

          //generiranje prepreka
        int patchSize; //3/4/5
        int voidSize; //0/1/2/3
        int ignoreFirstN = 0; //ignore first N t-s
        int ignoreLastN = 0; //ignore last N t-s to give time to generate new set of obstacles and score items.
        int currentT = 0 + ignoreFirstN;
        int totalT = globalTs.length - ignoreLastN; //pretpostavka da je ts veci od ignoreLastN

        int previousVertPos = random.nextInt(4); //od 0 do 4-1 -> 0,1,2,3 //npr. 2
        int nextVertPos;
        
//          logg("Total Ts - " + totalT.toString());
//          logg("Current T - " + currentT.toString());     
//          logg("Prvi previous: " + previousVertPos.toString());

//        int voids = 1;
//        int patches = 1;
//        TODO provjera da currentT + voidSize + (eventualno) patchSize < totalT, ako je, ne radi nista
        //totalT ce biti oko 600-700, dakle provjera voidsize + patchsize (max -> 8) parcijalno vece od totalT nema smisla, samo breakaj
        while (currentT < totalT) 
        {
             //generiram void size i patch size
             voidSize = random.nextInt(4); //0,1,2,3
//               logg("Void " + voids.toString() + " size - " + voidSize.toString());
//             voids++;
             
             if(currentT + voidSize > totalT)
             {
                  break;
             }
             
             nextVertPos = generateNextVerticalIndex(previousVertPos, voidSize);
//               logg("Next vert - " + nextVertPos.toString());
             
             if (voidSize != 0) 
             {
                  generateVoidData(previousVertPos, nextVertPos, globalTs.sublist(currentT, currentT + voidSize), voidSize);
                  currentT += voidSize; //pomakni se udesno
             }
             
             patchSize = random.nextInt(3) + 3; //3,4,5
//               logg("Patch " + patches.toString() + " size - " + patchSize.toString());
//             patches++;
             
             //if both the
             if(currentT + patchSize > totalT)
             {
                  break;
             }         
             
             generatePatchData(nextVertPos, globalTs.sublist(currentT, currentT + patchSize), patchSize);
             currentT += patchSize;
             
             previousVertPos = nextVertPos; //get ready for the next void + patch field generation.
        }     
        
        parent.updateMatrixWorld(force: true);
   }

     /**
      * Used in [generateItemPosition] to retrieve value of a 
      * binormal vector on a curve.
      * [t] - value in range [0.0, 1.0] where 0.0 represents the start
      * of the curve and 1.0 the end.
      */
     Vector3 getBinormal(double t)
     {
          /*//"test" obstacle na rubovima binormala
               Vector3 pos = k.getPoint(t);
               pos.scale(scale);
               double kojiSeg = t * segments;
               logg("Za t: " + t.toStringAsFixed(5) + " seg: " + kojiSeg.toString());

               Vector3 binorm = tube.binormals[kojiSeg.floor()];
               binorm.normalize();
               binorm.scale(strafe);*/
//     SplineCurve3 curve = tube.path;
//     int segments = tube.tangents.length;
          
//     Vector3 position = curve.getPoint(t);
          
//     position.scale(scale); //TODO skaliraj curve odmah dok konstruiras ????
//          int segment = (t * path.segments).floor();
          
//     Vector3 binormal = tube.binormals[segment].clone(); //clone for safety
          
          //Safety measure to prevent index out of bounds exception
          //binormal in prelast and last segments don't differ that much.
//          if(segment == path.segments) 
//              segment -= 1;
          
//          Vector3 binormal = path.binormals[segment].clone();
//          binormal.normalize();
//          binormal.scale(strafe);
          
//          return binormal;
          
          Vector3 tangent = objM.path.getTangentAt(t);
          Vector3 normal = new Vector3(0.0, 1.0, 0.0);
          Vector3 binormal = new Vector3.zero();
          binormal = normal.clone().crossInto(tangent, binormal);
          binormal.normalize().scale(strafe);
          
          return binormal;
     }

     /**
      * Generates score and obstacle item positions for the patch field.
      * [reserved] is used in calculating positions for score items and to flag
      * the reserved position for obstacle items.
      * [subTs] array of valid "t" values for the horizontal position.
      * [patchSize] value to switch on for different number of obstacles.
      * [subTs.length] is equal to [patchSize].
      */
     void generatePatchData(int reserved, List subTs, int patchSize)
     {
          /*  int rndhorizontal = random.nextInt(h.length); //3 = h.length
//               int whichPosition = h[rndhorizontal]; //[0,2,3], random da 1, to je 2
//               
//               if(whichPosition > reserved)
//               {
//                    lastPosition = reserved + 1;
//                    nextPosition = h.last;
//               }
//               else
//               {
//                    lastPosition = h.first;
//                    nextPosition = reserved - 1;
//               }*/
          
          //TODO refactor........
          
          //Add score items in a horizontal patch at same position on each T
          for(double t in subTs)
          {
               addScoreItem(generateItemPosition(t, reserved, reserved));
          }
          
          if(patchSize == 3)
          {
               //1 mozda
               if(random.nextInt(2) == 0)
                    return;
               else
               {
                    int whichT = random.nextInt(3); //3 = subTs.length;
                    Positions p = generateVerticalPositions(reserved);
                    addObstacle(generateItemPosition(subTs[whichT], p._last, p._next));
               }
          }
          
          if(patchSize == 4)          
          {
               //1 sigurno
               int whichT = random.nextInt(4);          
               Positions p = generateVerticalPositions(reserved);
               addObstacle(generateItemPosition(subTs[whichT], p._last, p._next));

          }
          
          if(patchSize == 5)
          {
               int whichT = random.nextInt(5);          
               Positions p = generateVerticalPositions(reserved);
               addObstacle(generateItemPosition(subTs[whichT], p._last, p._next));
               
               subTs.removeAt(whichT);
               
               //1 mozda
               if(random.nextInt(2) == 0)
               {
                    return;
               }
               else
               {
                    int whichT = random.nextInt(4);
                    Positions p = generateVerticalPositions(reserved);
                    addObstacle(generateItemPosition(subTs[whichT], p._last, p._next));
               }                 
          }
     }

     /**
      * Used to add obstacles to patch field.
      * [reserved] value represents the vertical position at
      * which the obstacles can not live for the current patch field.
      */
     Positions generateVerticalPositions(int reserved)
     {
          List temp = vertPositions.toList();
          temp.remove(reserved);
          
          int lastPosition;
          int nextPosition;
          
          int rnd = random.nextInt(temp.length); //3 = temp.length
          int generated = temp[rnd]; //[0,2,3], random da 1, to je 2
          
          if(generated > reserved)
          {
               lastPosition = reserved + 1;
               nextPosition = temp.last;
          }
          else
          {
               lastPosition = temp.first;
               nextPosition = reserved - 1;
          }
          
          return new Positions(lastPosition, nextPosition);     
     }


//     class Positions
//     {
//          int _last;
//          int _next;
//          
//          Positions(this._last, this._next);
//     }

     /**
      * Depending on the [voidSize], instantiate new obstacle items.
      * Obstacle horizontal position is determined from [subTs] elements.
      * Obstacle vertical position is calculated from the vertical alignment
      * of score items of the trailing and following patch field, namely
      * [previous] and [next].
      */
     void generateVoidData(int previous, int next, List subTs, int voidSize) 
     { 
          /*  
                //dobio 1, dohvati binormalu, izracunaj 
                 double percent = generateBinormalPercentage(lastPosition, newPosition);
                 double binormalScale = generateScaleFromPercentage(percent);
                 
                 Vector3 binormal = getBinormal(subTs[0]);
                 binormal = percent > 0.5 ? binormal.negate() : binormal;
                 binormal.scale(binormalScale);
                 
                 Vector3 position = curve.getPoint(subTs[0]);
                 position.scale(scale);
                 
                 Vector3 finalPosition = binormal + position;
      
          */
          
          //TODO refactor...
          if(voidSize == 0)
          {
               return;
          }
          
          if(voidSize == 1)
          {
              //1 mozda
              if(random.nextInt(2) == 0)
              {
//                   logg("VDG - voidSize 1 -> returning!!!");
                   return;
              }
              else
              {
//                   logg("VDG - voidSize 1 -> t = 0");
                   addObstacle(generateItemPosition(subTs[0], previous, next));  
              }         
          }
          
          if(voidSize == 2)
          {
               int whichT = random.nextInt(2); 
//               logg("VDG - voidSize 2 -> t = " + whichT.toString());

               addObstacle(generateItemPosition(subTs[whichT], previous, next));

          }
          
          if(voidSize == 3)
          {
               //1 sigurno
             int whichT = random.nextInt(3);
//             logg("VDG - voidSize 3 -> t = " + whichT.toString());
             addObstacle(generateItemPosition(subTs[whichT], previous, next));
             
               
            
             //1 mozda
            if(random.nextInt(2) == 0)
            {
//                 logg("VDG - voidSize 3 -> returning!!!!");
                 return;
            }
            else
            {
                 subTs.removeAt(whichT);
                 int rnd = random.nextInt(2);
//                 logg("VDG - voidSize 3 -> t = " + rnd.toString());
//            addObstacle(generateItemPosition(subTs[rnd], previous, next));
                 
                 //Change - any other extra obstacle should be free 
                 addObstacle(generateItemPosition(subTs[rnd], vertPositions.first, vertPositions.last));

            }
          }
     }

     void addScoreItem(Vector3 position)
     {
          ScoreItem scoreItemMesh = new ScoreItem(new CubeGeometry(a, a, a), new MeshBasicMaterial(color: 0x09BCED));
          scoreItemMesh.position.setFrom(position);
          scoreItemMesh.geometry.boundingBox = new BoundingBox.fromObject(scoreItemMesh);
          Vector3 min = scoreItemMesh.geometry.boundingBox.min;
          Vector3 max = scoreItemMesh.geometry.boundingBox.max;
          Vector3 center = scoreItemMesh.geometry.boundingBox.center.clone();
          min.setFrom(min.sub(center).scale(scoreItemBoxSquish).add(center).clone());
          max.setFrom(max.sub(center).scale(scoreItemBoxSquish).add(center).clone());
          parent.add(scoreItemMesh);
          objM.hitObjects.add(scoreItemMesh);
     }

     void addObstacle(Vector3 position)
     {
          Obstacle obstacleMesh = new Obstacle(new CubeGeometry(a, a, a), new MeshBasicMaterial(color: 0xEB07DB));
          obstacleMesh.position.setFrom(position);  
          obstacleMesh.geometry.boundingBox = new BoundingBox.fromObject(obstacleMesh);
         
          //debug
//          print("Min prije: " + obstacleMesh.geometry.boundingBox.min.toString());
//          print("Max prije: " + obstacleMesh.geometry.boundingBox.max.toString());
//          print("Center:  " + obstacleMesh.geometry.boundingBox.center.toString());
          
          Vector3 min = obstacleMesh.geometry.boundingBox.min;
          Vector3 max = obstacleMesh.geometry.boundingBox.max;
          Vector3 center = obstacleMesh.geometry.boundingBox.center.clone();
          min.setFrom(min.sub(center).scale(obstacleBoxSquish).add(center).clone());
          max.setFrom(max.sub(center).scale(obstacleBoxSquish).add(center).clone());
                    
          //debug
//          print("Min poslije: " + obstacleMesh.geometry.boundingBox.min.toString());
//          print("Max poslije: " + obstacleMesh.geometry.boundingBox.max.toString());
          
          parent.add(obstacleMesh);
          objM.hitObjects.add(obstacleMesh);
     }

     /**
      * Computes the final position of an score or obstacle item.
      * [t] - vertical position
      * [previous] - previous horizontal position
      * [next] - next horizontal position
      */
     Vector3 generateItemPosition(double t, int previous, int next)
     {
           double percent = generateVerticalPercentage(previous, next);
           double binormalScale = percent <= 0.5 ? (1 - percent * 2.0) : (2.0 * (percent - 0.5));
//           logg("For previous/next -> " + previous.toString() + "-" + next.toString() + ": percent: " + percent.toString());
           
           Vector3 binormal = getBinormal(t);
           binormal = percent > 0.5 ? binormal.negate() : binormal;
           binormal.scale(binormalScale);
           
           Vector3 position = objM.path.getPoint(t);
//           position.scale(scale);
           
           Vector3 finalPosition = binormal + position;
           
           return finalPosition;      
     }
     
     /**
      * Interval 0%----------50%---------100% where 0% is 1.0, 50% is 0.0, and 100% is -1.0.
      * Given a [percent] value in interval [0.0, 1.0]
      * returns the scale factor by which to multiply the binormal vector.
      * The returned value depends on the position of the [percent] in the above graphical interval.
      */
     double generateScaleFromPercentage(double percent)
     {
//     double result;
//     
//     if(percent <= 0.5)
//     {
//          result = 1 - percent * 2.0;
//     }
//     else
//     {
//          result = 2 * (percent - 0.5);
//     }
//     
//     return result;
          return null;     
     }

     /**
      * The graph:
      * 0 ----------------------- ^ - 0%
      * 1 ----------------------- |
      * 2 ----------------------- |
      * 3 ----------------------- v - 100%
      * 
      * Numbers [0-3] represent all possible vertical indices for an item.
      * Given two such numbers, calculate the possible range (in %) for the items' vertical position.  
      */
     double generateVerticalPercentage(int first, int second)
     {
          //TODO not tested for other values, TODO extract to public interface for tweaking
          double max = 0.9;
          double min = 0.1;
          double third = (max - min) / 3; //26.666666667
          
          double lowerBound;
          double upperBound;          
          double result;
          
          if(first == second)
          {
               result = min + first * third; 
          }
          else if((first - second).abs() == 3)
          {
               lowerBound = min;
               upperBound = max;
               result = generateRandomDoubleBounds(lowerBound, upperBound);
          }
          else
          {
               int lower = first < second ? first : second;
               int higher = first > second ? first : second;
               
               lowerBound = lower * third + min;
               upperBound = higher * third + min;
               
               result = generateRandomDoubleBounds(lowerBound, upperBound);
          }
          
          return result;
     }

//TODO add exception support if lower is higher than higher.
     /**Returns a double number expressed as a percentage in interval [0.0, 100.0]
      * [lower] is a number in range [0.0, 1.0];
      * [higher] is a number in range [0.0, 1.0];
      */
     double generateRandomDoubleBounds(double lower, double higher)
     {
          return (generateRandomDoubleBoundsPercentage(lower,higher)) / 100.0;
     }

     /**Returns a double number expressed in interval [0.0, 1.0]
      * [lower] is a number in range [0.0, 1.0];
      * [higher] is a number in range [0.0, 1.0];
      */
     double generateRandomDoubleBoundsPercentage(double lower, double higher)
     {
          return random.nextInt(((higher + 0.01 - lower) * 100).toInt()) + (lower*100);
     }

     /**Returns an int number expressed in interval [0, 100]
      * [lower] is a number in range [0, 100];
      * [higher] is a number in range [0, 100];
      */
     int generateRandomIntBounds(int lower, int higher)
     {
          return random.nextInt((higher + 1) - lower) + lower;
     }

     /**
      * Given the [previous] vertical index of a patch field score items
      * and the [voidSize] of the following void field, calculate the new
      * vertical index for the following patch field score items.
      */
     int generateNextVerticalIndex(int previous, int voidSize) {
          //last moze biti 0/1/2/3
          //size moze biti 0/1/2/3

          //ako je size 2 ili 3 vrati random od 0 do 3
          //ako je size 0 vrati rezultat je u range-u [last-1, last+1]
          //ako je size 1 vrati rezultat je u range-u [last-2, last+2]

          if (voidSize > 1) return random.nextInt(4); //0/1/2/3
          else {
               int deviate = voidSize + 1;
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
               upperBound = ((previous + deviate) >= 3) ? 3 : previous + deviate;
               lowerBound = ((previous - deviate) < 0) ? 0 : previous - deviate;

//          print("Lower " + lowerBound.toString());
//          print("Upper " + upperBound.toString());

               /**Return random number in between inclusive [upperBound] and inclusive [lowerBound]*/
//          return random.nextInt((upperBound + 1) - lowerBound) + lowerBound;
               return generateRandomIntBounds(lowerBound, upperBound);
          }
     }
}

class Positions
{
     int _last;
     int _next;
     
     Positions(this._last, this._next);
}
