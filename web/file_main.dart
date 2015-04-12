import 'dart:html';
import 'package:three/three.dart' hide Vector3, JSON;
import 'package:vector_math/vector_math.dart';
import 'dart:collection';
import 'package:three/extras/scene_utils.dart' as SceneUtils;
import 'package:three/extras/image_utils.dart' as ImageUTILS;
import 'dart:core';
import 'dart:math' as Math;
import 'utilities/PathParser.dart';
import 'utilities/WindowHelper.dart';
import 'utilities/Keyboard.dart';

var text;
var targetRotation = 0;
var targetRotationOnMouseDown = 0;
var mouseX = 0;
var mouseXOnMouseDown = 0;
var windowHalfX = window.innerWidth / 2;
var windowHalfY = window.innerHeight / 2;

//Vector3 binormal = new Vector3.zero();
//Vector3 normal = new Vector3.zero();
//Vector3 tangent = new Vector3.zero();
Vector3 binormalObject = new Vector3.zero();
Vector3 normalObject = new Vector3.zero();
Vector3 tangentObject = new Vector3.zero();

PerspectiveCamera camera, splineCamera;
WebGLRenderer renderer;
Element container;
Scene scene;

SelectElement curveTypeElem;
SelectElement scaleElem;
CheckboxInputElement showCurve;
ButtonInputElement animBtnElem;
SpanElement strafeElem;
ButtonInputElement startStopElem;

var pipeSpline = new SplineCurve3([new Vector3(0.0, 10.0, -10.0), new Vector3(10.0, 0.0, -10.0), new Vector3(20.0, 0.0, 0.0), new Vector3(30.0, 0.0, 10.0), new Vector3(30.0, 0.0, 20.0), new Vector3(20.0, 0.0, 30.0), new Vector3(10.0, 0.0, 30.0), new Vector3(0.0, 0.0, 30.0), new Vector3(-10.0, 10.0, 30.0), new Vector3(-10.0, 20.0, 30.0), new Vector3(0.0, 30.0, 30.0), new Vector3(10.0, 30.0, 30.0), new Vector3(20.0, 30.0, 15.0), new Vector3(10.0, 30.0, 10.0), new Vector3(0.0, 30.0, 10.0), new Vector3(-10.0, 20.0, 10.0), new Vector3(-10.0, 10.0, 10.0), new Vector3(0.0, 0.0, 10.0), new Vector3(10.0, -10.0, 10.0), new Vector3(20.0, -15.0, 10.0), new Vector3(30.0, -15.0, 10.0), new Vector3(40.0, -15.0, 10.0), new Vector3(50.0, -15.0, 10.0), new Vector3(60.0, 0.0, 10.0), new Vector3(70.0, 0.0, 0.0), new Vector3(80.0, 0.0, 0.0), new Vector3(90.0, 0.0, 0.0), new Vector3(100.0, 0.0, 0.0)]);

var sampleClosedSpline = new ClosedSplineCurve3([new Vector3(0.0, -40.0, -40.0), new Vector3(0.0, 40.0, -40.0), new Vector3(0.0, 140.0, -40.0), new Vector3(0.0, 40.0, 40.0), new Vector3(0.0, -40.0, 40.0)]);

var cubicBezier = new CubicBezierCurve3(new Vector3(-50.0, 0.0, 0.0), new Vector3(-50.0, 50.0, 0.0), new Vector3(50.0, 50.0, 0.0), new Vector3(50.0, 0.0, 0.0));

var quadraticBezier = new QuadraticBezierCurve3(new Vector3(0.0, 0.0, 0.0), new Vector3(20.0, 20.0, 0.0), new Vector3(40.0, 0.0, 0.0));

var triangleSpline = new SplineCurve3([new Vector3(0.0, 0.0, 0.0), new Vector3(20.0, 20.0, 0.0), new Vector3(40.0, 0.0, 0.0), new Vector3(40.0, 30.0, 0.0)]);

var catmulrom = new SplineCurve3([new Vector3(-50.0, 0.0, 0.0), new Vector3(-50.0, 50.0, 0.0), new Vector3(50.0, 50.0, 0.0), new Vector3(50.0, 0.0, 0.0)]);

var customClosedSpline3 = new ClosedSplineCurve3([new Vector3(-50.0, -50.0, 0.0), new Vector3(-50.0, 50.0, 0.0), new Vector3(50.0, 50.0, 0.0), new Vector3(50.0, -50.0, 0.0)]);


// Keep a dictionary of Curve instances
HashMap<String, Curve> splines = 
{
     "blenderClosedSpline": mainCurve
};

Object3D parent;

bool animation = false;
double scale = 1.0;

bool loadiraj = true;
int demoNr = 14;
//String path = 'za_dart/krivulja_1.obj';
//String track = 'za_dart/traka_1.obj';
//String trackTexture = 'za_dart/combined_layout_test1_export.jpg';
//String path = 'za_dart/krivulja_1.obj';
//String track = 'testiram_jedan_segment/testiram_jedan_segment_6.obj';
String trackTexture = 'testiram_jedan_segment/combined_layout_test1_export.jpg';

//ZidBocni2 testiranje
//String track = 'za_dart/zid_bocni2_testiram2.obj';
//String trackTexture = 'za_dart/combined_layout_test1_export.jpg';

//Testiram cijelu traku
String path = 'testiram_cijelu_traku/testiram_cijelu_traku_krivulja9.obj';
String track = 'testiram_cijelu_traku/testiram_cijelu_traku_traka9.obj';

//Camera specs
double camera_fov = 75.0;
double camera_near = 0.1;
double camera_far = 5000.0;
Vector3 camera_pos = new Vector3(100.0, 100.0, 100.0);
Vector3 camera_pos_preview = new Vector3(-80.0, 10.0, 0.0);
Vector3 lookAtvector = new Vector3.zero();
Vector3 lookAtvector_preview = new Vector3(0.0, 20.0, 0.0);

//Toggle panel
bool previewing = false;
bool toogleAxes = true;
bool moving = true;

//"Speed"
int loopSeconds = 50;

double strafe = 1.0;
double strafeDt = strafe / 10.0;
double strafeMin = -strafe;
double strafeMax = strafe;
double strafeTotal = 0.0;

//Utilities
PathParser pp;
Keyboard keyboard;
Stopwatch sw;
PointLight followBoxLight = new PointLight(0xffffff, intensity: 1.0);

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

//Path data
ClosedSplineCurve3 mainCurve;
Object3D tubeMesh;
TubeGeometry tube;
bool closed = false;
int radiussegments = 1;
int segments = 100;
double radius = 2.0;
Object3D trackMesh;
Mesh plane;

void main() 
{
     pp = new PathParser();

     pp.load(path).then((object) {

          mainCurve = new ClosedSplineCurve3(pp.getVertices);

     }).then((object) {
          init();
          initDOM();
          addRandomObstacles();
          animate(0);
          });     
}

void addLights()
{
     AmbientLight ambientLight = new AmbientLight(0xffffff);
     
     PointLight spotLightCenter = new PointLight(0xffffff, intensity: 1.0);
     spotLightCenter.position = new Vector3.zero();     
     PointLight spotLightCamera = new PointLight(0xffffff, intensity: 0.1);
     spotLightCamera.position.setFrom(camera_pos);
     
     scene.add(ambientLight);
//     scene.add(spotLightCenter);
     scene.add(spotLightCamera);     
}

void addTube() 
{
     if(tubeMesh != null)
     {
          parent.remove(tubeMesh);
     }
     
     tube = new TubeGeometry(mainCurve, mainCurve.points.length - 1, radius, radiussegments, closed, false);
     tubeMesh = SceneUtils.createMultiMaterialObject(tube, [new MeshLambertMaterial(color: 0xff00ff), new MeshBasicMaterial(color: 0x000000, opacity: 0.3, wireframe: true, transparent: true)]);
     parent.add(tubeMesh);
}

void setScale() 
{
     scale = double.parse(scaleElem.value);
     parent.scale.setFrom(new Vector3(scale, scale, scale));      
}

void loadTrack() 
{
     Texture tex = ImageUTILS.loadTexture(trackTexture);
     Material mat = new MeshPhongMaterial(map: tex);

     var loader = new OBJLoader();

     loader.load(track).then((object) {

          object.children.forEach((e) {
               if (e is Mesh) {
//                    ((e as Mesh).material as MeshLambertMaterial).map = tex;
//                    ((e as Mesh).material as MeshBasicMaterial).map = tex;
                    (e as Mesh).material = mat;
               }
          });
          
          //Cache locally
          trackMesh = object;
          if(previewing)
          {
               trackMesh.scale.scale(3.0);
               trackMesh.position.y = 2.0;  
          }
          
          parent.add(trackMesh);
     });
}

void animateCamera(bool toggle) 
{
     if (toggle) 
     {
          animation = !animation;
          animBtnElem.value = "Camera Spline Animation View: " + (animation == true ? "ON" : "OFF");
     }
}

void moveToggle()
{
     moving = !moving;
}

//Sine movement up down
double getSine(int elapsedTicks) 
{
   double t = elapsedTicks / 1000000;
   double amplitude = 2.0;
   double period = 3.0;
   double frequency = 1 / period;

   return amplitude * Math.sin(2 * Math.PI * frequency * t);
}

void showPath()
{
     if(showCurve.checked)
     {
          parent.add(tubeMesh);
          tubeMesh.visible = true;
     }
     else
     {
          parent.remove(tubeMesh);
          tubeMesh.visible = false;
     }
}

void initDOM() 
{
     String dropdown = "";
     splines.forEach((key, value) 
     {
          dropdown += '<option value="' + key + '"';
          dropdown += '>' + key + '</option>';
     });

     curveTypeElem = querySelector('#curvetype');
     curveTypeElem.innerHtml = dropdown;
     curveTypeElem.selectedIndex = 0;
     curveTypeElem.onChange.listen((e) => addTube());

     scaleElem = querySelector('#scale');
     scaleElem.selectedIndex = 4; //1 changed 06.03.2015.
     scaleElem.onChange.listen((e) => setScale());     

     showCurve = querySelector('#showcurve');
     showCurve.onChange.listen((e) => showPath());

     animBtnElem = querySelector('#animation');
     animBtnElem.onClick.listen((e) => animateCamera(true));

     strafeElem = querySelector("#strafe");
     
     startStopElem = querySelector('#startstop');
     startStopElem.onClick.listen((e) => moveToggle());

     addTube();
}

addRandomObstacles() 
{
     ClosedSplineCurve3 curve = tube.path;

     Math.Random random = new Math.Random();
     double randomNr;
     int step = 20; //broj obstacle-a
     int brojac = step;
     Vector3 start, end;

     while (brojac < curve.points.length) 
     {
          randomNr = random.nextDouble();
          start = curve.points.elementAt(brojac).clone();
//          start.scale(scale);

          if (brojac == curve.points.length) 
               end = curve.points.elementAt(0).clone();
          else 
               end = curve.points.elementAt(brojac + 1).clone();
          
          Vector3 difference = end - start;
          difference.multiply(new Vector3(randomNr, randomNr, randomNr));
          Vector3 finalPos = start + difference;

          Mesh obstacle = new Mesh(new CubeGeometry(side, side, side), new MeshBasicMaterial(color: 0xff0000));
          
          obstacle.position.setFrom(finalPos);
          obstacle.position.y = side / 2;

          //Add random lights to obstacle positions
//          PointLight light = new PointLight(0xffffff, intensity: 1.0);
//          light.position.setFrom(obstacle.position);
//          scene.add(light);
//          obstacle.scale = new Vector3(scale, scale, scale);
//          scene.add(obstacle);
          parent.add(obstacle);

          brojac += step;
     }
}


init() 
{
     container = document.createElement('div');
     document.body.append(container);

     camera = new PerspectiveCamera(camera_fov, window.innerWidth / window.innerHeight, camera_near, camera_far);
     if(previewing)
     {
          camera.position.setFrom(camera_pos_preview);
     }
     else
     {
          camera.position.setFrom(camera_pos);      
     }    

     scene = new Scene();
     keyboard = new Keyboard();
     sw = new Stopwatch();
     
     if(toogleAxes)
     {
          makeAxes();
     }


     parent = new Object3D();
     scene.add(parent);

     //TESTIRAM PATH
     if (loadiraj) 
     {
          loadTrack(); 
     }     

     //changed 06.03.2015.
     //Lights
//     addLights();
     
     //Moving object - initialisation
     Texture tex = ImageUTILS.loadTexture(objectTexture);
     movingObject = new Mesh(new CubeGeometry(side, side, side), new MeshBasicMaterial(map: tex));
     splineCamera = new PerspectiveCamera(movingCam_fov, window.innerWidth / window.innerHeight, movingCam_near, movingCam_far);
     splineCamera.position.setFrom(movingCam_pos);
     splineCamera.lookAt(movingCam_lookAt);     
     PointLight pointlightFollower = new PointLight(0xffffff, intensity: 0.5, distance: 0);     
//     pointlightFollower.position.setFrom(splineCamera.position);
     pointlightFollower.position.setFrom(new Vector3(0.0, side/2, 0.0));        
     pointlightFollower.lookAt(spotlightFollower_lookAt);
     movingObject.add(splineCamera);
     movingObject.add(pointlightFollower);
     
     //changed 06.03.2015.
     if(!previewing)
     {
          parent.add(movingObject);
     }
     
     plane = new Mesh(new PlaneGeometry(1000.0, 1000.0), new MeshBasicMaterial(color: 0x00ff00));
     plane.rotation.x = -90.0 * Math.PI / 180.0;
     plane.position.z = -200.0;
     
     if(previewing)
          parent.add(plane);

     renderer = new WebGLRenderer(antialias: true);
     renderer.setClearColor(new Color(0xf0f0f0), 1.0); //Alpha = 1.0?)
     renderer.setSize(window.innerWidth, window.innerHeight);

     container.append(renderer.domElement);

     renderer.domElement.addEventListener('mousedown', onDocumentMouseDown, false);
     renderer.domElement.addEventListener('touchstart', onDocumentTouchStart, false);
     renderer.domElement.addEventListener('touchmove', onDocumentTouchMove, false);
     window.addEventListener('resize', onWindowResize, false);

}

animate(num time) 
{
     update();
     render();
     window.requestAnimationFrame(animate);
}


update() 
{
     if (keyboard.isPressed(KeyCode.D)) {
          strafeTotal -= strafeDt;
          if (strafeTotal <= strafeMin) strafeTotal = strafeMin;
     }

     if (keyboard.isPressed(KeyCode.A)) {
          strafeTotal += strafeDt;
          if (strafeTotal >= strafeMax) strafeTotal = strafeMax;
     }
     
     if(previewing)
     {
          if(keyboard.isPressed(KeyCode.T))
          {
               parent.position.x += 2.5;
          }
          if(keyboard.isPressed(KeyCode.G))
          {
               parent.position.x -= 2.5;
          }
          if(keyboard.isPressed(KeyCode.H))
          {
               parent.position.z += 2.5;
          }
          if(keyboard.isPressed(KeyCode.F))
          {
               parent.position.z -= 2.5;
          }
          if(keyboard.isPressed(KeyCode.R))
          {
               parent.position.y += 2.5;
          }
          if(keyboard.isPressed(KeyCode.Z))
          {
               parent.position.y -= 2.5;
          }  
     }     

     strafeElem.innerHtml = strafeTotal.toString();
}

//render() 
//{
//
//     ClosedSplineCurve3 putanja;
//     double levitation = 0.0;
////     offset = 15.0, offsetObject = 12.0
////     double offset = 15.0;
//     double offsetObject = side / 2 + 2.0 + levitation; //5.0 = amplituda u getSine();
//
//     //camera animation
//     int time = new DateTime.now().millisecondsSinceEpoch;
//     int looptime = loopSeconds * 1000;
//     double t = (time % looptime) / looptime;
//
//     //t in range [0 ... 1], get points at curve, and scale it since the curve is scaled.
////     putanja = tube.path;
//     putanja = mainCurve;
//
//     Vector3 posObject = (putanja.getPointAt((t + 2 / putanja.length) % 1)).multiply(new Vector3(scale, scale, scale));
//
//     //interpolation - moving object
//     int segments = tube.tangents.length;
//     double t2 = (t + 2 / putanja.length) % 1;
//     double pickt2 = t2 * segments;
//     int pick2 = pickt2.floor();
//     int pickNext2 = (pick2 + 1) % segments;
//
//     //Object position
//     binormalObject = tube.binormals[pickNext2] - tube.binormals[pick2];
//     double bScaleObject = pickt2 - pick2;
//     binormalObject.multiply(new Vector3(bScaleObject, bScaleObject, bScaleObject));
//     binormalObject.add(tube.binormals[pick2]);
//     tangentObject = -putanja.getTangentAt(t2);
//     normalObject.setFrom(binormalObject).crossInto(tangentObject, normalObject);
//     posObject.add(normalObject.clone().add(new Vector3(0.0, offsetObject, 0.0)));
//     movingObject.position.setFrom(posObject);
//
//
//     print("ScenePos: ${scene.position}, P: ${movingObject.position}");
//
//
//     //Object lookAt
//     Vector3 smjerGledanja = tangentObject.clone().normalize().scale(2.0).add(movingObject.position);
//     Matrix4 lookAtObjectMatrix = new Matrix4.identity();
//     lookAtObjectMatrix = makeLookAt(lookAtObjectMatrix, smjerGledanja, movingObject.position, normalObject);
//     movingObject.matrix = lookAtObjectMatrix;
//     movingObject.rotation = calcEulerFromRotationMatrix(movingObject.matrix);
//
//     //Adjust strafe movement
//     Vector3 toMove = binormalObject.clone().normalize();
//     toMove.multiply(new Vector3(strafeTotal, strafeTotal, strafeTotal));
//     posObject.add(toMove);
//     movingObject.position.setFrom(posObject);
//
////     cameraHelper.update();
//     camera.lookAt(scene.position);
//     parent.rotation.y += (targetRotation - parent.rotation.y) * 0.05;
//     renderer.render(scene, animation == true ? splineCamera : camera);
//}

render() 
{
     if(!previewing)
     {
          if(moving)
          {

               //camera animation
               int time = new DateTime.now().millisecondsSinceEpoch;
               int looptime = loopSeconds * 1000;
               double t = (time % looptime) / looptime;

               Vector3 posObject = (mainCurve.getPointAt((t + 2 / mainCurve.length) % 1));

               //interpolation - moving object
               int segments = tube.tangents.length;
               double t2 = (t + 2 / mainCurve.length) % 1;
               double pickt2 = t2 * segments;
               int pick2 = pickt2.floor();
               int pickNext2 = (pick2 + 1) % segments;

               //Object position
               binormalObject = tube.binormals[pickNext2] - tube.binormals[pick2];
               double bScaleObject = pickt2 - pick2;
               binormalObject.multiply(new Vector3(bScaleObject, bScaleObject, bScaleObject));
               binormalObject.add(tube.binormals[pick2]);
               tangentObject = -mainCurve.getTangentAt(t2);
               normalObject.setFrom(binormalObject).crossInto(tangentObject, normalObject);
               posObject.add(normalObject.clone());
               movingObject.position.setFrom(posObject);

               //added 19.03.2015.
               normalObject.y = normalObject.y.abs();   

               //Object lookAt
               Vector3 smjerGledanja = tangentObject.clone().normalize().add(movingObject.position);
               Matrix4 lookAtObjectMatrix = new Matrix4.identity();
               lookAtObjectMatrix = makeLookAt(lookAtObjectMatrix, smjerGledanja, movingObject.position, normalObject);
               movingObject.matrix = lookAtObjectMatrix;
               movingObject.rotation = calcEulerFromRotationMatrix(movingObject.matrix);

               //Adjust strafe movement
//               Vector3 toMove = binormalObject.clone().normalize();
//               toMove.multiply(new Vector3(strafeTotal, strafeTotal, strafeTotal));
//               posObject.add(toMove);
//               movingObject.position.setFrom(posObject);
//               movingObject.position.y = side / 2;

          }
     }
     
//changed 06.03.2015.
//     camera.lookAt(scene.position);
     
     if(!previewing)
     {
          camera.lookAt(lookAtvector); //0, 0, 0
     }
     else
     {
          camera.lookAt(lookAtvector_preview); //0, 20, 0
     }    
    
     renderer.render(scene, animation == true ? splineCamera : camera);

     parent.rotation.y += (targetRotation - parent.rotation.y) * 0.05;

}
