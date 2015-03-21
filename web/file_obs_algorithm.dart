import 'package:three/three.dart';
import 'package:vector_math/vector_math.dart';
import 'package:three/extras/image_utils.dart' as IMAGEUtils;
import 'package:three/extras/scene_utils.dart' as SceneUtils;
import 'dart:html';
import 'dart:math' as Math;
import 'dart:core';
import 'dart:io' as IO;
import 'utilities/PathParser.dart';
import 'utilities/Keyboard.dart';

Scene scene;
PerspectiveCamera camera;
CameraHelper cameraHelper;
WebGLRenderer renderer;
Element container;

Vector3 cameraPosition = new Vector3(50.0, 100.0, 0.0);
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
TubeGeometry tube;
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
double strafeDt = strafe / 10.0;
double strafeMin = -strafe;
double strafeMax = strafe;
double strafeTotal = 0.0;

//algoritam finished results
List globalTs = [];
List obstacleList = [];
List scoreItemList = [];
SplineCurve3 curve;
List<Vector3> binormals;
int segs; //nr of tangents;

void main() 
{
     addCurves();
}

void addRandom() 
{
//     //adds random obstacles
//     DateTime date = new DateTime.now();
//     random = new Math.Random(date.millisecondsSinceEpoch);
//
//     Mesh score;
//
//     double nrOfVertSegs = -planeHeight / 2.0;
//
//     List xPos = [-(horSeg * (3 / 2)), -(horSeg * (1 / 2)), (horSeg * (1 / 2)), (horSeg * (3 / 2))];
//
//     while (nrOfVertSegs < (planeHeight / 2.0)) //manji od 250
//     {
//          //generate obstacle patch
//          int patchSize = random.nextInt(2) + 3; //0,1,2,3,4 desno
//          int horPos = random.nextInt(4); //0,1,2,3 gore dolje 0 ->
//          double newX = xPos[horPos];
//
//          for (int i = 0; i < patchSize; i++) {
//               obs = new Mesh(new SphereGeometry(radius), obstableMat);
//               obs.position.x = newX;
//               obs.position.z = nrOfVertSegs; //-250 na pocetku
//               scene.add(obs);
//
//               nrOfVertSegs += 1.0;
//          }
//          //generate void
//          int voidWidth = random.nextInt(5) + 5; //0,1,2,3,4
//          double voidSeg = 0.5;
//
//          if (voidWidth != 0) {
//               Mesh voidPlane = new Mesh(new PlaneGeometry(planeWidth * 0.8, voidWidth.toDouble()), new MeshBasicMaterial(color: 0x0000ff));
//               voidPlane.rotation.x = -90 * Math.PI / 180.0;
//               voidPlane.position.y = 2.0;
//               voidPlane.position.z = nrOfVertSegs + (voidWidth - 1) * voidSeg;
//               scene.add(voidPlane);
//               nrOfVertSegs += voidWidth.toDouble();
//          }
//     }
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
     List result = [];
     double sum = 0.0; //sumiraj u while petlji, ako prevrsi "dist" resetiraj, spremi zadnji "t" u result

     double t = 0.0; //starting position

     Vector3 previous = curve.getPoint(t); //pocetna pozicija
     logg("Novi dt: " + dt.toString());
     t += dt;

     while (t <= 1.0 + dt) //sve dok ne izadjes iz krivulje van
     {
          Vector3 current = curve.getPoint(t);

          double diff = current.absoluteError(previous);

          sum = sum + diff;

          if (sum >= dist) {
               result.add(t);
               sum = 0.0;
          }

          //zapamti trenutni
          previous.setFrom(current.clone());
          t += dt;
     }
     int count = result.length;
     var tt = result.first;
     Vector3 abab = curve.getPoint(tt);
     Vector3 baba = curve.getPoint(0.0);
     logg("test: " + abab.absoluteError(baba).toString() + " tt je: " + tt.toString());

     addPrepreke(curve, result);
}

void addPrepreke(SplineCurve3 k, List ts) {
     //plavi markeri
     for (var t in ts) {
          Mesh m = new Mesh(new SphereGeometry(radius / 2.0), new MeshBasicMaterial(color: 0x0000ff));
          Vector3 pos = k.getPoint(t);
          pos.scale(scale);
          m.position.setFrom(pos);
          parent.add(m);
     }

     //za svaki t uzmi point (position) i odredi segment, uzmi binormalu za taj segment, zbroji, nacrtaj
//     int segments = tube.tangents.length;
     for (double t in ts) 
     {
          //"test" obstacle na rubovima binormala
          Vector3 binorm = getBinormal(t);
          Vector3 pos = k.getPoint(t);
//          binorm.scale(scale);
          pos.scale(scale);
          //lijeva strana
          Vector3 noviPos = pos + binorm;
          Mesh mm = new Mesh(new SphereGeometry(0.6), new MeshBasicMaterial(color: 0x00ffff));
          mm.position.setFrom(noviPos);
          parent.add(mm);
          //desna strana
          Vector3 rightBinorm = new Vector3.copy(binorm);
          rightBinorm.negate();
          noviPos = pos + rightBinorm;
          Mesh mmm = new Mesh(new SphereGeometry(0.6), new MeshBasicMaterial(color: 0x00ffff));
          mmm.position.setFrom(noviPos);
          parent.add(mmm);
          //kraj - "test" obstacle na rubovima binormala

          //horizontalne tockice
          Mesh left1 = new Mesh(new SphereGeometry(radius / 2.0), new MeshBasicMaterial(color: 0x00ff00));
          Mesh left2 = new Mesh(new SphereGeometry(radius / 2.0), new MeshBasicMaterial(color: 0x00ff00));
          Mesh right1 = new Mesh(new SphereGeometry(radius / 2.0), new MeshBasicMaterial(color: 0x00ff00));
          Mesh right2 = new Mesh(new SphereGeometry(radius / 2.0), new MeshBasicMaterial(color: 0x00ff00));

          Vector3 left1v = binorm.clone().scale(0.8);
          Vector3 left2v = binorm.clone().scale(0.4);
          Vector3 right1v = rightBinorm.clone().scale(0.4);
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
     int totalT = ts.length - ignoreLastN; //pretpostavka da je ts veci od ignoreLastN

     int lastVertPos = random.nextInt(4); //od 0 do 4-1 -> 0,1,2,3 //npr. 2
     int newVertPos;

     //TODO provjera da currentT + voidSize + (eventualno) patchSize < totalT, ako je, ne radi nista
     //totalT ce biti oko 600-700, dakle provjera voidsize + patchsize (max -> 8) parcijalno vece od totalT nema smisla, samo breakaj
     while (currentT < totalT) 
     {
          //generiram void size i patch size
          voidSize = random.nextInt(4); //0,1,2,3
          patchSize = random.nextInt(3) + 3; //3,4,5
          newVertPos = generateNextVertPos(lastVertPos, voidSize);

          //imam staru i novu vert poziciju - mogu napraviti prepreke na voidu
          if (voidSize != 0) 
          {
               generateVoidData(lastVertPos, newVertPos, ts.sublist(currentT, currentT + voidSize), voidSize);
               currentT += voidSize; //pomakni se udesno
          }
          
          generatePatchData(newVertPos, ts.sublist(currentT, currentT + patchSize));
          currentT += patchSize;

     }
}

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
     
     Vector3 position = curve.getPoint(t);
     
     position.scale(scale); //TODO skaliraj curve odmah dok konstruiras ????
     int segment = (t * segs).floor();
     
//     Vector3 binormal = tube.binormals[segment].clone(); //clone for safety
     Vector3 binormal = binormals[segment].clone();
     binormal.normalize();
     binormal.scale(strafe);
     
     return binormal;
}

void generatePatchData(int position, List subTs)
{
     
}

void generateVoidData(int lastPosition, int newPosition, List subTs, int voidSize) 
{ 
     if(voidSize == 0)
          return;
     if(voidSize == 1)
     {
         //generiraj 1 mozda
         if(random.nextInt(2) == 0)
              return;
         else
         {
           //dobio 1, dohvati binormalu, izracunaj 
            double percent = generateBinormalPercentage(lastPosition, newPosition);
            double tempScale = generateScaleFromPercentage(percent);
            
            Vector3 binormal = getBinormal(subTs[0]);
            binormal = percent > 0.5 ? binormal.negate() : binormal;
            binormal.scale(tempScale);
            
         }
         
     }
}

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
     
     return percent <= 0.5 ? (1 - percent * 2.0) : (2.0 * (percent - 0.5));
}

double generateBinormalPercentage(int first, int second)
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

int generateRandomIntBounds(int lower, int higher)
{
     return random.nextInt((higher + 1) - lower) + lower;
}

int generateNextVertPos(int last, int size) {
     //last moze biti 0/1/2/3
     //size moze biti 0/1/2/3

     //ako je size 2 ili 3 vrati random od 0 do 3
     //ako je size 0 vrati rezultat je u range-u [last-1, last+1]
     //ako je size 1 vrati rezultat je u range-u [last-2, last+2]

     if (size > 1) return random.nextInt(4); //0/1/2/3
     else {
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
//          return random.nextInt((upperBound + 1) - lowerBound) + lowerBound;
          return generateRandomIntBounds(lowerBound, upperBound);
     }
}

class Void 
{
     int lastVerticalPosition; //last patch
     int newVerticalPosition; //next patch
     int size; //size in horizontal dimension, size equals ts.length;
     List ts; //sublist of global list of all valid t values
}

class Patch 
{
     int size;
     List ts;
}

class Obstacle 
{
     Geometry obsGeo;
     MeshBasicMaterial obsMat;
}

class ScoreItem {
     Geometry scGeo;
     MeshBasicMaterial scMat;
}


double vectorDistance(Vector3 first, Vector3 second) {
     double xSquare = Math.pow((first.x - second.x), 2);
     double ySquare = Math.pow((first.y - second.y), 2);
     return Math.sqrt(xSquare + ySquare);
}

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

          pp.load(halfCurve).then((object) {
               halfSpline = new SplineCurve3(pp.getVertices);
          }).whenComplete(() {
               halfContainer = connect(halfSpline, 0x00ff00);
               halfContainer.position.x = 20.0;
               parent.add(halfContainer);

               animate(0);
          });
     });
}

Object3D connect(SplineCurve3 curve, num hex) {
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

     tube = new TubeGeometry(c, c.points.length - 1, tuberadius, radiussegments, closed, false);
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

init() {
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
     int time = new DateTime.now().millisecondsSinceEpoch;
     int looptime = loopSeconds * 1000;
     double t = (time % looptime) / looptime;
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

update() {
     if (keyboard.isPressed(KeyCode.D)) {
          strafeTotal -= strafeDt;
          if (strafeTotal <= strafeMin) strafeTotal = strafeMin;
     }

     if (keyboard.isPressed(KeyCode.A)) {
          strafeTotal += strafeDt;
          if (strafeTotal >= strafeMax) strafeTotal = strafeMax;
     }
}

render() {
     //WRITE ANIMATION LOGIC HERE
     moveTheObject();
     parent.rotation.y += (targetRotation - parent.rotation.y) * 0.05;

}

animate(num time) {
     update();
     render();
//     moveTheObject();
//     renderer.render(scene, camera);
//     renderer.render(scene, toggle ? camera : orthoCamera);
     renderer.render(scene, animation == true ? splineCamera : orthoCamera);
//     parent.rotation.y += (targetRotation - parent.rotation.y) * 0.05;
     window.requestAnimationFrame(animate);
}

onWindowResize(Event e) {
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
