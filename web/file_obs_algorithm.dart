import 'package:three/three.dart';
import 'package:vector_math/vector_math.dart' hide Ray;
import 'package:three/extras/image_utils.dart' as IMAGEUtils;
import 'package:three/extras/scene_utils.dart' as SceneUtils;
import 'dart:html';
import 'dart:math' as Math;
import 'dart:core';
//import 'dart:io' as IO;
import 'utilities/PathParser.dart';
import 'utilities/Keyboard.dart';
import 'utilities/TimeManager.dart';

Scene scene;
PerspectiveCamera camera;
CameraHelper cameraHelper;
WebGLRenderer renderer;
Element container;

Vector3 cameraPosition = new Vector3(0.0, 100.0, 0.0);
double cameraFov = 75.0;
double cameraNear = 1.0;
double cameraFar = 1000.0;
double cameraAspect = window.innerWidth / window.innerHeight;

//ortho camera
OrthographicCamera orthoCamera;
double value = 150.0;
double left = -value;
double right = value;
double top = value / 2;
double bottom = -value / 2;
Vector3 cameraOrthoPosition = new Vector3(0.0, 100.0, 0.0);

var targetRotation = 0;
var targetRotationOnMouseDown = 0;
var mouseX = 0;
var mouseXOnMouseDown = 0;
var windowHalfX = window.innerWidth / 2;
var windowHalfY = window.innerHeight / 2;

ButtonInputElement toggleBtn;
ButtonInputElement scoreBtn;
ButtonInputElement healthBtn;
ButtonInputElement startStopBtn;
bool toggle = false;

MeshBasicMaterial obstableMat = new MeshBasicMaterial(color: 0xff0000, wireframe: false);
MeshBasicMaterial scoreMat = new MeshBasicMaterial(color: 0x00ff00, wireframe: false);
Mesh obstacle;
Mesh scoreItem;
double radius = 0.4; //1.0*0.8
double planeHeight = 500.0;
double planeWidth = 100.0;
Math.Random random; //initialized in init() method

double vertSeg = planeHeight / planeHeight; //1.0
double horSeg = (planeWidth * 0.8) / 4.0;

//algoritm
PathParser pp;
Keyboard keyboard;
//Path data
ClosedSplineCurve3 mainCurve;
//Object3D tubeMesh;
//TubeGeometry tube;
//bool closed = false;
//int radiussegments = 1;
//int segments = 100;
//double tuberadius = 2.0;
Object3D parent;
double scale = 10.0;
DivElement log;
int logCounter = 1;

//Moving object
Mesh movingObject;
double side = 0.2; //square "a"
String objectTexture = 'textures_main/crate.png';
double movingCam_fov = 75.0;
double movingCam_near = 0.1;
double movingCam_far = 5000.0;
Vector3 movingCam_pos = new Vector3(0.0, side, side * 6.0); //parented to moving object
Vector3 movingCam_lookAt = new Vector3.zero();
Vector3 spotlightFollower_lookAt = new Vector3.zero();
PerspectiveCamera splineCamera;

//Full and half
SplineCurve3 fullSpline;
SplineCurve3 halfSpline;
Object3D fullContainer;
Object3D halfContainer;
String fullCurve = 'obstacle_planning/path_full.obj';
String halfCurve = 'obstacle_planning/path_half.obj';
bool animation = false;

int loopSeconds = 30;
Vector3 binormalObject = new Vector3.zero();
Vector3 normalObject = new Vector3.zero();
Vector3 tangentObject = new Vector3.zero();

double strafe = 3.0;
double strafeDt = strafe / 60.0;
double strafeMin = -strafe;
double strafeMax = strafe;
double strafeTotal = 0.0;

//algoritam finished results
List globalTs = [];
SplineCurve3 curve;
List<Vector3> binormals;
int segs; //nr of tangents;
List vertPositions = [0, 1, 2, 3];

int health = 3;
int score = 0;

List hitobjects = [];
String start = "Start";
String stop = "Stop";

TimeManager timeManager;

class Obstacle extends Mesh
{
     Obstacle(Geometry geometry, [Material material]) : super(geometry, material);
}

class ScoreItem extends Mesh
{
     ScoreItem(Geometry geometry, [Material material]) : super(geometry, material);
}

void main() 
{
     addCurves();
}

initObstacles() 
{
     //Reference
     double Lref = 10.0;
     double dtref = 0.01; //referentni pomak za izracun aktualnog pomaka ovisno o duljini krivulje
     double dist = 0.4; //threshold iznad kojeg biljezim trenutnu vrijednost "t"

//     SplineCurve3 curve = tube.path; //krivulja u pitanju
     double L = curve.length; //duljina krivulje
     double dt = (Lref * dtref / L); //npr. duljina 14.42 ima dt = 0.006933 => 144 iteracije od 0 do 1 za t

     //Lista "t" vrijednosti za koje su te pozicije medusobno udaljene istu duljinu
//     List result = [];
     double sum = 0.0; //sumiraj u while petlji, ako prevrsi "dist" resetiraj, spremi zadnji "t" u result

     double t = 0.0; //starting position

     Vector3 previous = curve.getPoint(t); //pocetna pozicija
//     logg("Novi dt: " + dt.toString());
     t += dt;

     while (t <= 1.0 + dt) //sve dok ne izadjes iz krivulje van
     {
          Vector3 current = curve.getPoint(t);

          double diff = current.absoluteError(previous);

          sum = sum + diff;

          if (sum >= dist) {
               globalTs.add(t);
               sum = 0.0;
          }

          //zapamti trenutni
          previous.setFrom(current.clone());
          t += dt;
     }
     int count = globalTs.length;
     var tt = globalTs.first;
     Vector3 abab = curve.getPoint(tt);
     Vector3 baba = curve.getPoint(0.0);
//     logg("test: " + abab.absoluteError(baba).toString() + " tt je: " + tt.toString());

     addPrepreke();
}

void addPrepreke() 
{
     //plavi markeri
     for (var t in globalTs) 
     {
          Mesh m = new Mesh(new SphereGeometry(radius / 2.0), new MeshBasicMaterial(color: 0x0000ff));
          Vector3 pos = curve.getPoint(t);
          pos.scale(scale);
          m.position.setFrom(pos);
//          parent.add(m);
     }

     //za svaki t uzmi point (position) i odredi segment, uzmi binormalu za taj segment, zbroji, nacrtaj
//     int segments = tube.tangents.length;
     for (double t in globalTs) 
     {
          //"test" obstacle na rubovima binormala
          Vector3 binorm = getBinormal(t);
          Vector3 pos = curve.getPoint(t);
          pos.scale(scale);          
          
          //lijeva strana
          Vector3 noviPos = pos + binorm;
          Mesh mm = new Mesh(new SphereGeometry(0.6), new MeshBasicMaterial(color: 0x00ffff));
          mm.position.setFrom(noviPos);
//          parent.add(mm);
          //desna strana
          Vector3 rightBinorm = new Vector3.copy(binorm);
          rightBinorm.negate();
          noviPos = pos + rightBinorm;
          Mesh mmm = new Mesh(new SphereGeometry(0.6), new MeshBasicMaterial(color: 0x00ffff));
          mmm.position.setFrom(noviPos);
//          parent.add(mmm);
          //kraj - "test" obstacle na rubovima binormala

          //horizontalne tockice
          Mesh left1 = new Mesh(new SphereGeometry(radius / 2.0), new MeshBasicMaterial(color: 0x00ff00));
          Mesh left2 = new Mesh(new SphereGeometry(radius / 2.0), new MeshBasicMaterial(color: 0x00ff00));
          Mesh right1 = new Mesh(new SphereGeometry(radius / 2.0), new MeshBasicMaterial(color: 0x00ff00));
          Mesh right2 = new Mesh(new SphereGeometry(radius / 2.0), new MeshBasicMaterial(color: 0x00ff00));

          double nearScaleLeft = 0.28;
          double nearScaleRight = 0.26666666666;
          Vector3 left1v = binorm.clone().scale(0.8);
          Vector3 left2v = binorm.clone().scale(nearScaleLeft);
          Vector3 right1v = rightBinorm.clone().scale(nearScaleRight);
          Vector3 right2v = rightBinorm.clone().scale(0.8);

          Vector3 left1pos = pos + left1v;
          Vector3 left2pos = pos + left2v;
          Vector3 right1pos = pos + right1v;
          Vector3 right2pos = pos + right2v;

          left1.position.setFrom(left1pos);
          left2.position.setFrom(left2pos);
          right1.position.setFrom(right1pos);
          right2.position.setFrom(right2pos);

          parent.add(left1);
          parent.add(left2);
          parent.add(right1);
          parent.add(right2);
          //kraj - horizontalne tockice
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
     
     logg("Total Ts - " + totalT.toString());
     logg("Current T - " + currentT.toString());     
     logg("Prvi previous: " + previousVertPos.toString());

     int voids = 1;
     int patches = 1;
     //TODO provjera da currentT + voidSize + (eventualno) patchSize < totalT, ako je, ne radi nista
     //totalT ce biti oko 600-700, dakle provjera voidsize + patchsize (max -> 8) parcijalno vece od totalT nema smisla, samo breakaj
     while (currentT < totalT) 
     {
          //generiram void size i patch size
          voidSize = random.nextInt(4); //0,1,2,3
          logg("Void " + voids.toString() + " size - " + voidSize.toString());
          voids++;
          
          if(currentT + voidSize > totalT)
          {
               break;
          }
          
          nextVertPos = generateNextVerticalIndex(previousVertPos, voidSize);
          logg("Next vert - " + nextVertPos.toString());
          
          if (voidSize != 0) 
          {
               generateVoidData(previousVertPos, nextVertPos, globalTs.sublist(currentT, currentT + voidSize), voidSize);
               currentT += voidSize; //pomakni se udesno
          }
          
          patchSize = random.nextInt(3) + 3; //3,4,5
          logg("Patch " + patches.toString() + " size - " + patchSize.toString());
          patches++;
          
          //if both the
          if(currentT + patchSize > totalT)
          {
               break;
          }         
          
          generatePatchData(nextVertPos, globalTs.sublist(currentT, currentT + patchSize), patchSize);
          currentT += patchSize;
          
          previousVertPos = nextVertPos; //get ready for the next void + patch field generation.
     }
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
     int segment = (t * segs).floor();
     
//     Vector3 binormal = tube.binormals[segment].clone(); //clone for safety
     Vector3 binormal = binormals[segment].clone();
     binormal.normalize();
     binormal.scale(strafe);
     
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


class Positions
{
     int _last;
     int _next;
     
     Positions(this._last, this._next);
}

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
              logg("VDG - voidSize 1 -> returning!!!");
              return;
         }
         else
         {
              logg("VDG - voidSize 1 -> t = 0");
              addObstacle(generateItemPosition(subTs[0], previous, next));  
         }         
     }
     
     if(voidSize == 2)
     {
          int whichT = random.nextInt(2); 
          logg("VDG - voidSize 2 -> t = " + whichT.toString());

          addObstacle(generateItemPosition(subTs[whichT], previous, next));

     }
     
     if(voidSize == 3)
     {
          //1 sigurno
        int whichT = random.nextInt(3);
        logg("VDG - voidSize 3 -> t = " + whichT.toString());
        addObstacle(generateItemPosition(subTs[whichT], previous, next));
        
          
       
        //1 mozda
       if(random.nextInt(2) == 0)
       {
            logg("VDG - voidSize 3 -> returning!!!!");
            return;
       }
       else
       {
            subTs.removeAt(whichT);
            int rnd = random.nextInt(2);
            logg("VDG - voidSize 3 -> t = " + rnd.toString());
//            addObstacle(generateItemPosition(subTs[rnd], previous, next));
            
            //Change - any other extra obstacle should be free 
            addObstacle(generateItemPosition(subTs[rnd], vertPositions.first, vertPositions.last));

       }
     }
}

void addScoreItem(Vector3 position)
{
     //placeholder score item 
     double a = 0.5;
//     Mesh scoreItemMesh = new Mesh(new CubeGeometry(a, a, a), new MeshBasicMaterial(color: 0x09BCED));
     ScoreItem scoreItemMesh = new ScoreItem(new CubeGeometry(a, a, a), new MeshBasicMaterial(color: 0x09BCED));
     scoreItemMesh.position.setFrom(position);
     parent.add(scoreItemMesh);
     hitobjects.add(scoreItemMesh);
}

void addObstacle(Vector3 position)
{
     double a = 0.5;
//     Mesh obstacleMesh = new Mesh(new CubeGeometry(a, a, a), new MeshBasicMaterial(color: 0xEB07DB));
     Obstacle obstacleMesh = new Obstacle(new CubeGeometry(a, a, a), new MeshBasicMaterial(color: 0xEB07DB));
     obstacleMesh.position.setFrom(position);
     parent.add(obstacleMesh);
     hitobjects.add(obstacleMesh);
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
      logg("For previous/next -> " + previous.toString() + "-" + next.toString() + ": percent: " + percent.toString());
      
      Vector3 binormal = getBinormal(t);
      binormal = percent > 0.5 ? binormal.negate() : binormal;
      binormal.scale(binormalScale);
      
      Vector3 position = curve.getPoint(t);
      position.scale(scale);
      
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

//renamed from update() in file_collision.dart file
void checkCollision() 
{
    Vector3 position = movingObject.position.clone();

    for(int i = 0; i < movingObject.geometry.vertices.length; i++)
    {
         var local = movingObject.geometry.vertices[i].clone();
         var global = local.applyProjection(movingObject.matrixWorld);
         var direction = global.sub(position);
         var ray = new Ray(position, direction.clone());
         var result = ray.intersectObjects(hitobjects);

         if(result.length > 0 && result[0].distance < direction.length)
//         if(result.length > 0)
         {    
//              window.alert("IMAM GA");
              parent.remove(result[0].object);
              hitobjects.remove(result[0].object);
              print(result[0].object.runtimeType);
              if(result[0].object is ScoreItem)
              {
                   score++;
                   scoreBtn.value = "Score: " + score.toString();
                   print("pogodio sam score item");
              }
              if(result[0].object is Obstacle)
              {
                   health--;
                   healthBtn.value = "Health: " + health.toString();
                   print("pogodio sam obstacle");
              }
         }
    }

}

//class Obstacle 
//{
//     Geometry obsGeo;
//     MeshBasicMaterial obsMat;
//}
//
//class ScoreItem {
//     Geometry scGeo;
//     MeshBasicMaterial scMat;
//}

void addCurves() 
{
     pp = new PathParser();

     pp.load(fullCurve).then((object) {

          //Inicijaliziraj scenu i parent
          init();
          fullSpline = new SplineCurve3(pp.getVertices);
          addTube(fullSpline);
          initObstacles();

     }).whenComplete(() {
          fullContainer = connect(fullSpline, 0xff0000);
//            fullContainer.position.x = -30.0;
          parent.add(fullContainer);

          pp.resetVertices();

          pp.load(halfCurve).then((object) 
          {
               halfSpline = new SplineCurve3(pp.getVertices);
          }).whenComplete(() {
               halfContainer = connect(halfSpline, 0x00ff00);
               halfContainer.position.x = 20.0;
               parent.add(halfContainer);

               animate(0);
          });
     });
}

Object3D connect(SplineCurve3 curve, num hex) 
{
     List<Vector3> points = curve.points;
     Geometry lines = new Geometry();
     Object3D container = new Object3D();

     for (Vector3 v in points) {
          v.scale(scale);
          lines.vertices.add(v);
          Mesh point = new Mesh(new SphereGeometry(radius), new MeshBasicMaterial(color: hex));
          point.position.setFrom(v);
//          parent.add(point);
          container.add(point);
     }

     container.add(new Line(lines, new LineBasicMaterial(color: hex)));

     return container;
}

void addTube(SplineCurve3 c) 
{
//     if (tubeMesh != null) 
//     {
//          parent.remove(tubeMesh);
//     }

     int radiussegments = 1;
     double tuberadius = 2.0;
     bool closed = false;

     TubeGeometry tube = new TubeGeometry(c, c.points.length - 1, tuberadius, radiussegments, closed, false);
//     Object3D tubeMesh = SceneUtils.createMultiMaterialObject(tube, [new MeshLambertMaterial(color: 0xff00ff), new MeshBasicMaterial(color: 0x000000, opacity: 0.3, wireframe: true, transparent: true)]);
//     Mesh tubeMesh = new Mesh(tube);
//     tubeMesh.scale.setFrom(new Vector3(scale, scale, scale));
//     tubeMesh.position.x = -30.0;
//     parent.add(tubeMesh);
     
     segs = tube.tangents.length; 
     binormals = tube.binormals;
     curve = tube.path;     
}

void logg(String input) {
     String content = log.innerHtml.toString();
     String toAdd = '<br>' + logCounter.toString() + ". " + input;
     log.innerHtml = content + toAdd;
     logCounter++;
}

init() 
{
     scene = new Scene();
     container = document.createElement('div');
     document.body.append(container);
     camera = new PerspectiveCamera(cameraFov, cameraAspect, cameraNear, cameraFar);
     camera.position.setFrom(cameraPosition);
     camera.lookAt(scene.position);
     scene.add(camera);

     //algoritm
     parent = new Object3D();
     scene.add(parent);

     keyboard = new Keyboard();
     random = new Math.Random(new DateTime.now().millisecondsSinceEpoch);
//     timeManager = new TimeManager(loopSeconds);

     //Moving object - initialisation
     Texture tex = IMAGEUtils.loadTexture(objectTexture);
     movingObject = new Mesh(new CubeGeometry(side, side, side), new MeshBasicMaterial(map: tex));
     splineCamera = new PerspectiveCamera(movingCam_fov, window.innerWidth / window.innerHeight, movingCam_near, movingCam_far);
     splineCamera.position.setFrom(movingCam_pos);
     splineCamera.lookAt(movingCam_lookAt);
     PointLight pointlightFollower = new PointLight(0xffffff, intensity: 0.5, distance: 0);
//     pointlightFollower.position.setFrom(splineCamera.position);
     pointlightFollower.position.setFrom(new Vector3(0.0, side / 2, 0.0));
     pointlightFollower.lookAt(spotlightFollower_lookAt);
     movingObject.add(splineCamera);
     movingObject.add(pointlightFollower);
     parent.add(movingObject);

     //containers
//       parent.add(fullContainer);
//       parent.add(halfContainer);
//       addTube(fullSpline);

     //orthocamera
     orthoCamera = new OrthographicCamera(left, right, top, bottom);
     orthoCamera.position.setFrom(cameraOrthoPosition);
     orthoCamera.lookAt(scene.position);
     scene.add(orthoCamera);

     makeAxes();
     renderer = new WebGLRenderer(antialias: true);
     renderer.setClearColor(new Color(0xf0f0f0), 1.0);
     renderer.setSize(window.innerWidth, window.innerHeight);
     container.append(renderer.domElement);
     renderer.domElement.addEventListener('mousedown', onDocumentMouseDown, false);
     renderer.domElement.addEventListener('touchstart', onDocumentTouchStart, false);
     renderer.domElement.addEventListener('touchmove', onDocumentTouchMove, false);
     window.addEventListener('resize', onWindowResize, false);

     //Handle html here
     toggleBtn = querySelector('#toggle');
//     toggleBtn.onClick.listen((e) => toggle = !toggle);
     toggleBtn.onClick.listen((e) => animateCamera(true));
     log = querySelector('#log');
     scoreBtn = querySelector('#score');
     healthBtn = querySelector('#health');
     startStopBtn = querySelector('#startstop');
     startStopBtn.value = stop;
     startStopBtn.onClick.listen((MouseEvent e) {timeManager.toggle();});
     
     scoreBtn.value = "Score: " + score.toString();
     healthBtn.value = "Health: " + health.toString();
     

     //ADD OBJECTS TO SCENE HERE
     //lights
     AmbientLight ambientLight = new AmbientLight(0xffffff);
     scene.add(ambientLight);

     //obstacles
//     addRandom();

     String texPath = 'obstacle_planning/crate.png';
     String texPathPlane = 'obstacle_planning/floor.jpg';
     Texture objTex = IMAGEUtils.loadTexture(texPath);
     Texture planeTex = IMAGEUtils.loadTexture(texPathPlane);
     MeshBasicMaterial planeMat = new MeshBasicMaterial(map: planeTex);
     Mesh plane = new Mesh(new PlaneGeometry(planeWidth, planeHeight), planeMat);
     plane.rotation.x = -90.0 * Math.PI / 180.0;
//     scene.add(plane);
     parent.add(plane);

//     MeshBasicMaterial cubeMat = new MeshBasicMaterial(map: objTex);
//         Mesh cube1 = new Mesh(new CubeGeometry(10.0, 10.0, 10.0), cubeMat);
//         cube1.position.x = -50.0;
//         cube1.position.z = -50.0;
//         cube1.position.y = 5.0;
//         scene.add(cube1);
//
//         Mesh cube2 = new Mesh(new CubeGeometry(10.0, 10.0, 10.0), cubeMat);
//         cube2.position.x = 50.0;
//         cube2.position.z = 50.0;
//         cube2.position.y = 5.0;
//         scene.add(cube2);

     //-------------------------
}

void animateCamera(bool t) {
     if (t) {
          animation = !animation;
          toggleBtn.value = "Camera Spline Animation View: " + (animation == true ? "ON" : "OFF");
     }
}

void moveTheObject() 
{
     //use new TimeManager class
//     if(!timeManager.isRunning)
//     {
//          timeManager.start();
//     }
     if(timeManager == null)
     {
          print("Initializing a new TimeManager object");
          timeManager = new TimeManager(loopSeconds, true);
     }
     
     double t = timeManager.getCurrentTime();
//     int time = new DateTime.now().millisecondsSinceEpoch;
//     int looptime = loopSeconds * 1000;
//     double t = (time % looptime) / looptime;
     Vector3 posObject;

     try {
          posObject = (fullSpline.getPointAt((t + 2 / fullSpline.length) % 1));
     } catch (e) {
          logg(posObject.toString());
     }

     //interpolation - moving object
//     int segments = tube.tangents.length;
     double t2 = (t + 2 / fullSpline.length) % 1;
     double pickt2 = t2 * segs;
     int pick2 = pickt2.floor();
     int pickNext2 = (pick2 + 1) % segs;

     //Object position
//     binormalObject = tube.binormals[pickNext2] - tube.binormals[pick2];
     binormalObject = binormals[pickNext2] - binormals[pick2];

     double bScaleObject = pickt2 - pick2;
     binormalObject.multiply(new Vector3(bScaleObject, bScaleObject, bScaleObject));
     binormalObject.add(binormals[pick2]);
     tangentObject = -fullSpline.getTangentAt(t2);
     normalObject.setFrom(binormalObject).crossInto(tangentObject, normalObject);
     posObject.add(normalObject.clone());
     movingObject.position.setFrom(posObject);

     normalObject.y = normalObject.y.abs();

     //Object lookAt
     Vector3 smjerGledanja = tangentObject.clone().normalize().add(movingObject.position);
     Matrix4 lookAtObjectMatrix = new Matrix4.identity();
     lookAtObjectMatrix = makeLookAt(lookAtObjectMatrix, smjerGledanja, movingObject.position, normalObject);
     movingObject.matrix = lookAtObjectMatrix;
     movingObject.rotation = calcEulerFromRotationMatrix(movingObject.matrix);

     //Adjust strafe movement
     Vector3 toMove = binormalObject.clone().normalize();
     toMove.multiply(new Vector3(strafeTotal, strafeTotal, strafeTotal));
     posObject.add(toMove);
     movingObject.position.setFrom(posObject);
     movingObject.position.y = side / 2;
}

double factor = 1.5;

update() {
     if (keyboard.isPressed(KeyCode.D)) {
          strafeTotal -= strafeDt;
          if (strafeTotal <= strafeMin) strafeTotal = strafeMin;
     }

     if (keyboard.isPressed(KeyCode.A)) {
          strafeTotal += strafeDt;
          if (strafeTotal >= strafeMax) strafeTotal = strafeMax;
     }
     if (keyboard.isPressed(KeyCode.H)) {
               parent.position.z += factor;
          }
     if (keyboard.isPressed(KeyCode.F)) {
               parent.position.z -= factor;

          }
     if (keyboard.isPressed(KeyCode.G)) {
               parent.position.x -= factor;
          }
     if (keyboard.isPressed(KeyCode.T)) {
               parent.position.x += factor;
          }
     if (keyboard.isPressed(KeyCode.R)) {
               camera.position.y += factor;
          }
     if (keyboard.isPressed(KeyCode.Z)) {
               camera.position.y -= factor;
          }
}

render() 
{
     //WRITE ANIMATION LOGIC HERE
     moveTheObject();
     parent.rotation.y += (targetRotation - parent.rotation.y) * 0.05;
}

animate(num time) {
     update();
     render();
     checkCollision();
     
//     moveTheObject();
//     renderer.render(scene, camera);
//     renderer.render(scene, toggle ? camera : orthoCamera);
     renderer.render(scene, animation == true ? splineCamera : camera);
//     parent.rotation.y += (targetRotation - parent.rotation.y) * 0.05;
     window.requestAnimationFrame(animate);
}

onWindowResize(Event e) 
{
     windowHalfX = window.innerWidth / 2;
     windowHalfY = window.innerHeight / 2;

     camera.aspect = window.innerWidth / window.innerHeight;
     camera.updateProjectionMatrix();

     renderer.setSize(window.innerWidth, window.innerHeight);
}

onDocumentMouseDown(MouseEvent e) {
     e.preventDefault();

     renderer.domElement.addEventListener('mousemove', onDocumentMouseMove, false);
     renderer.domElement.addEventListener('mouseup', onDocumentMouseUp, false);
     renderer.domElement.addEventListener('mouseout', onDocumentMouseOut, false);

     mouseXOnMouseDown = e.client.x - windowHalfX;
     targetRotationOnMouseDown = targetRotation;

}

onDocumentMouseMove(MouseEvent e) {
     mouseX = e.client.x - windowHalfX;
     targetRotation = targetRotationOnMouseDown + (mouseX - mouseXOnMouseDown) * 0.02;
}

onDocumentMouseUp(MouseEvent event) {

     renderer.domElement.removeEventListener('mousemove', onDocumentMouseMove, false);
     renderer.domElement.removeEventListener('mouseup', onDocumentMouseUp, false);
     renderer.domElement.removeEventListener('mouseout', onDocumentMouseOut, false);

}

onDocumentMouseOut(MouseEvent event) {

     renderer.domElement.removeEventListener('mousemove', onDocumentMouseMove, false);
     renderer.domElement.removeEventListener('mouseup', onDocumentMouseUp, false);
     renderer.domElement.removeEventListener('mouseout', onDocumentMouseOut, false);

}
onDocumentTouchStart(TouchEvent e) {
     if (e.touches.length == 1) {
          e.preventDefault();
          mouseXOnMouseDown = e.touches[0].page.x - windowHalfX;
          targetRotationOnMouseDown = targetRotation;
     }
}

onDocumentTouchMove(TouchEvent e) {
     if (e.touches.length == 1) {
          e.preventDefault();
          mouseX = e.touches[0].page.x - windowHalfX;
          targetRotation = targetRotationOnMouseDown + (mouseX - mouseXOnMouseDown) * 0.05;
     }

}

void makeAxes() {

     Geometry geometrija1 = new Geometry();
     geometrija1.vertices.add(new Vector3(0.0, 0.0, 0.0));
     geometrija1.vertices.add(new Vector3(800.0, 0.0, 0.0)); //x

     Geometry geometrija2 = new Geometry();
     geometrija2.vertices.add(new Vector3(0.0, 0.0, 0.0));
     geometrija2.vertices.add(new Vector3(0.0, 800.0, 0.0)); //y

     Geometry geometrija3 = new Geometry();
     geometrija3.vertices.add(new Vector3(0.0, 0.0, 0.0));
     geometrija3.vertices.add(new Vector3(0.0, 0.0, 800.0)); //z

     scene.add(new Line(geometrija1, new LineBasicMaterial(color: 0xff0000, opacity: 1.0)));
     scene.add(new Line(geometrija2, new LineBasicMaterial(color: 0x00ff00, opacity: 1.0)));
     scene.add(new Line(geometrija3, new LineBasicMaterial(color: 0x0000ff, opacity: 1.0)));
}
