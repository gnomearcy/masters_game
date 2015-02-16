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
import 'utilities/Logger.dart';

var text, plane;
var targetRotation = 0;
var targetRotationOnMouseDown = 0;
var mouseX = 0;
var mouseXOnMouseDown = 0;
var windowHalfX = window.innerWidth / 2;
var windowHalfY = window.innerHeight / 2;
Vector3 binormal = new Vector3.zero();
Vector3 normal = new Vector3.zero();
Vector3 tangent = new Vector3.zero();
Vector3 binormalObject = new Vector3.zero();
Vector3 normalObject = new Vector3.zero();
Vector3 tangentObject = new Vector3.zero();

CameraHelper cameraHelper;
Mesh cameraEye;
PerspectiveCamera camera, splineCamera;
WebGLRenderer renderer;
Element container;
Scene scene;

SelectElement curveTypeElem;
SelectElement scaleElem;
SelectElement extrusionElem;
SelectElement radiusSegmentsElem;
CheckboxInputElement closedElem;
CheckboxInputElement lookaheadElem;
CheckboxInputElement camerahelperElem;
ButtonInputElement animBtnElem;
SpanElement strafeElem;

var pipeSpline = new SplineCurve3([new Vector3(0.0, 10.0, -10.0), new Vector3(10.0, 0.0, -10.0), new Vector3(20.0, 0.0, 0.0), new Vector3(30.0, 0.0, 10.0), new Vector3(30.0, 0.0, 20.0), new Vector3(20.0, 0.0, 30.0), new Vector3(10.0, 0.0, 30.0), new Vector3(0.0, 0.0, 30.0), new Vector3(-10.0, 10.0, 30.0), new Vector3(-10.0, 20.0, 30.0), new Vector3(0.0, 30.0, 30.0), new Vector3(10.0, 30.0, 30.0), new Vector3(20.0, 30.0, 15.0), new Vector3(10.0, 30.0, 10.0), new Vector3(0.0, 30.0, 10.0), new Vector3(-10.0, 20.0, 10.0), new Vector3(-10.0, 10.0, 10.0), new Vector3(0.0, 0.0, 10.0), new Vector3(10.0, -10.0, 10.0), new Vector3(20.0, -15.0, 10.0), new Vector3(30.0, -15.0, 10.0), new Vector3(40.0, -15.0, 10.0), new Vector3(50.0, -15.0, 10.0), new Vector3(60.0, 0.0, 10.0), new Vector3(70.0, 0.0, 0.0), new Vector3(80.0, 0.0, 0.0), new Vector3(90.0, 0.0, 0.0), new Vector3(100.0, 0.0, 0.0)]);

var sampleClosedSpline = new ClosedSplineCurve3([new Vector3(0.0, -40.0, -40.0), new Vector3(0.0, 40.0, -40.0), new Vector3(0.0, 140.0, -40.0), new Vector3(0.0, 40.0, 40.0), new Vector3(0.0, -40.0, 40.0)]);

var cubicBezier = new CubicBezierCurve3(new Vector3(-50.0, 0.0, 0.0), new Vector3(-50.0, 50.0, 0.0), new Vector3(50.0, 50.0, 0.0), new Vector3(50.0, 0.0, 0.0));

var quadraticBezier = new QuadraticBezierCurve3(new Vector3(0.0, 0.0, 0.0), new Vector3(20.0, 20.0, 0.0), new Vector3(40.0, 0.0, 0.0));

var triangleSpline = new SplineCurve3([new Vector3(0.0, 0.0, 0.0), new Vector3(20.0, 20.0, 0.0), new Vector3(40.0, 0.0, 0.0), new Vector3(40.0, 30.0, 0.0)]);

var catmulrom = new SplineCurve3([new Vector3(-50.0, 0.0, 0.0), new Vector3(-50.0, 50.0, 0.0), new Vector3(50.0, 50.0, 0.0), new Vector3(50.0, 0.0, 0.0)]);

var customClosedSpline3 = new ClosedSplineCurve3([new Vector3(-50.0, -50.0, 0.0), new Vector3(-50.0, 50.0, 0.0), new Vector3(50.0, 50.0, 0.0), new Vector3(50.0, -50.0, 0.0)]);

SplineCurve3 blenderClosedSpline;
//ClosedSplineCurve3 blenderClosedSpline;


// Keep a dictionary of Curve instances
HashMap<String, Curve> splines = {
     "PipeSpline": pipeSpline,
     "SampleClosedSpline": sampleClosedSpline,
     "CubicBezier": cubicBezier,
     "QuadraticBezier": quadraticBezier,
     "TriangleSpline": triangleSpline,
     "CatmulRom": catmulrom,
     "bezier1": bezier1,
     "bezier2": bezier2,
     "customClosed": customClosedSpline3,
     "blenderClosedSpline": blenderClosedSpline
};



bool closed2 = true;
Object3D parent;
Object3D tubeMesh;
TubeGeometry tube;
bool animation = false;
bool lookAhead = false;
double scale = 2.5;
bool showCameraHelper = false;

int radiusSegments;
int segments;
var extrudePath;

//Spajanje dvije bezier krivulje -> JERKY na konekciji
Vector3 v0 = new Vector3(-12.28042, 0.84006, 0.0);
Vector3 v1 = new Vector3(-12.67468, -12.28512, 0.0);
Vector3 v2 = new Vector3(0.25566, -5.38598, 0.0);
Vector3 v3 = new Vector3(-0.14664, -0.40219, 0.0);
Vector3 v4 = new Vector3(-0.14664, -0.40219, 0.0);
Vector3 v5 = new Vector3(-0.63263, 5.61838, 0.0);
Vector3 v6 = new Vector3(12.23045, 6.03005, 0.0);
Vector3 v7 = new Vector3(12.46749, 0.00094, 0.0);
var bezier1 = new CubicBezierCurve3(v0, v1, v2, v3);
var bezier2 = new CubicBezierCurve3(v4, v5, v6, v7);

List<CubicBezierCurve3> beziers;
List<TubeGeometry> tubes;

bool loadiraj = true;
int demoNr = 14;
String path = 'track_work1/track_work1_path.obj';
String track = 'track_work1/track_work1_track.obj';
String trackTexture = 'track_work1/track_layout_1_out.jpg';

String objectTexture = 'textures_main/crate.png';
PathParser pp;

//Camera specs
double camera_fov = 75.0;
double camera_near = 0.1;
double camera_far = 5000.0;
Vector3 camera_pos = new Vector3(100.0, 100.0, 100.0);

//"Speed"
int loopSeconds = 500;

Mesh movingObject;
int i = 0;

Keyboard keyboard;

double strafe = 5.0;
double strafeDt = 0.5;
double strafeMin = -strafe;
double strafeMax = strafe;
double strafeTotal = 0.0;

double side = 2.0; //square "a"

Stopwatch sw = new Stopwatch();

PointLight followBoxLight = new PointLight(0xffffff, intensity: 1.0);

//Sine movement up down
double getSine(int elapsedTicks) {
     double t = elapsedTicks / 1000000;
     double amplitude = 2.0;
     double period = 3.0;
     double frequency = 1 / period;

     return amplitude * Math.sin(2 * Math.PI * frequency * t);
}

void main() {

     beziers = new List<CubicBezierCurve3>();
     beziers.add(bezier1);
     beziers.add(bezier2);

     tubes = new List<TubeGeometry>();
     tubes.add(new TubeGeometry(bezier1, 200, 2.0, 6, false, false));
     tubes.add(new TubeGeometry(bezier2, 200, 2.0, 6, false, false));

     pp = new PathParser();

     pp.load(path).then((object) {

          blenderClosedSpline = new SplineCurve3(pp.getVertices);
//          blenderClosedSpline = new ClosedSplineCurve3(pp.getVertices);

     }).then((object) {
          init();
          Logger.Log("neki tag", "neka poruka");
          initDOM();
          addRandomObstacles();
          animate(0);
     });


//     init();
//     initDOM();
//     animate(0);
//
//
//     animBtnElem = querySelector('#animation');
//     animBtnElem.onClick.listen((e) => animateCameraTest(true));
//
//     addGeometryTest(tubes.elementAt(0), 0xff00ff);
//     addGeometryTest(tubes.elementAt(1), 0xff00ff);

}

void addTube() {

     if (tubeMesh != null) parent.remove(tubeMesh);

     extrudePath = splines[curveTypeElem.value];
//     int segs = int.parse(extrusionElem.value);
//     segments = blenderClosedSpline.points.length;
//     print(segments);
     radiusSegments = int.parse(radiusSegmentsElem.value);
     closed2 = closedElem.checked;

     //blenderClosedSpline.points.length - 1 => broj segmenata -> broj tangenti u svakom segmentu
     tube = new TubeGeometry(extrudePath, blenderClosedSpline.points.length - 1, 2.0, radiusSegments, closed2, false);

     addGeometry(tube, 0xff00ff);
     setScale();
}

void addGeometry(Geometry tube, num color) {
     tubeMesh = SceneUtils.createMultiMaterialObject(tube, [new MeshLambertMaterial(color: color), new MeshBasicMaterial(color: 0x000000, opacity: 0.3, wireframe: true, transparent: true)]);

     parent.add(tubeMesh);
}

void setScale() {

     scale = double.parse(scaleElem.value);
     tubeMesh.scale.setFrom(new Vector3(scale, scale, scale));
}

void setScaleTest() {

     tubeMesh.scale.setFrom(new Vector3(scale, scale, scale));
}
void addGeometryTest(Geometry tube, num color) {
     tubeMesh = SceneUtils.createMultiMaterialObject(tube, [new MeshLambertMaterial(color: color), new MeshBasicMaterial(color: 0x000000, opacity: 0.3, wireframe: true, transparent: true)]);
     setScaleTest();
     parent.add(tubeMesh);
}

void loadPath() {


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

          object.scale = new Vector3(scale, scale, scale);
          object.positionArray;
//          object.position.y = 10.0;
          parent.add(object);
     });
}

void animateCamera(bool toggle) {
     if (toggle) {

          animation = !animation;
          animBtnElem.value = "Camera Spline Animation View: " + (animation == true ? "ON" : "OFF");
     }

     lookAhead = lookaheadElem.checked;
     showCameraHelper = camerahelperElem.checked;

     cameraHelper.visible = showCameraHelper;
     cameraEye.visible = showCameraHelper;
}

void animateCameraTest(bool toggle) {
     if (toggle) {

          animation = !animation;
          animBtnElem.value = "Camera Spline Animation View: " + (animation == true ? "ON" : "OFF");
     }

}
double distance(Vector3 a, Vector3 b) {
     return Math.sqrt(Math.pow(a.x - b.x, 2) + Math.pow(a.y - b.y, 2));
}

void initDOM() {
     String dropdown = "";
     splines.forEach((key, value) {
          dropdown += '<option value="' + key + '"';
          dropdown += '>' + key + '</option>';
     });

     curveTypeElem = querySelector('#curvetype');
     curveTypeElem.innerHtml = dropdown;
     curveTypeElem.selectedIndex = 9;
     curveTypeElem.onChange.listen((e) => addTube());

     scaleElem = querySelector('#scale');
     scaleElem.selectedIndex = 4;
     scaleElem.onChange.listen((e) => setScale());

     extrusionElem = querySelector('#segments');
     extrusionElem.selectedIndex = 3;
     extrusionElem.onChange.listen((e) => addTube());

     radiusSegmentsElem = querySelector('#radiussegments');
     radiusSegmentsElem.selectedIndex = 0;
     radiusSegmentsElem.onChange.listen((e) => addTube());

     closedElem = querySelector('#closed');
     closedElem.onChange.listen((e) => addTube());

     animBtnElem = querySelector('#animation');
     animBtnElem.onClick.listen((e) => animateCamera(true));

     lookaheadElem = querySelector('#lookahead');
     lookaheadElem.onChange.listen((e) => animateCamera(false));

     camerahelperElem = querySelector('#camerahelper');
     camerahelperElem.onChange.listen((e) => animateCamera(false));

     strafeElem = querySelector("#strafe");

     addTube();
}

addRandomObstacles() {
     SplineCurve3 curve = tube.path;

     Math.Random random = new Math.Random();
     double randomNr;
     int step = 20;
     int brojac = step;
     Vector3 start, end;

     while (brojac < curve.points.length) {
//
//          print(brojac);
//
//          //random broj od 0 do 1
//          //pozicija dva cvora, puta random broj
//          //

          randomNr = random.nextDouble();
          print(randomNr);
          start = curve.points.elementAt(brojac).clone();
          start.scale(scale);

          if (brojac == curve.points.length) end = curve.points.elementAt(0).clone().scale(scale); else end = curve.points.elementAt(brojac + 1).clone().scale(scale);
          Vector3 difference = end - start;
          difference.multiply(new Vector3(randomNr, randomNr, randomNr));
          Vector3 finalPos = start + difference;

          Mesh obstacle = new Mesh(new CubeGeometry(10.0, 10.0, 10.0), new MeshBasicMaterial(color: 0xff0000));
          obstacle.position.setFrom(finalPos);

          //Add random lights to obstacle positions
//          PointLight light = new PointLight(0xffffff, intensity: 1.0);
//          light.position.setFrom(obstacle.position);
//          scene.add(light);
//          obstacle.scale = new Vector3(scale, scale, scale);
          scene.add(obstacle);
          parent.add(obstacle);

          brojac += step;
     }
}


init() {

     container = document.createElement('div');
     document.body.append(container);

     camera = new PerspectiveCamera(camera_fov, window.innerWidth / window.innerHeight, camera_near, camera_far);
     camera.position.setFrom(camera_pos);
     //camera.position.setValues(0.0, 0.0, 900.0);

     scene = new Scene();
     keyboard = new Keyboard();
     makeAxes();
//
//     var light2 = new AmbientLight(0xaaaaaa);
//     scene.add(light2);
//     DirectionalLight light = new DirectionalLight(0xffffff, 1.0); //color, intensity
//     light.position.setValues(0.0, 100.0, 0.0);
//     light.lookAt(scene.position);
//     scene.add(light);
//     SpotLight spotlight = new SpotLight(0xffffff, 1.0, 0.0, Math.PI/2, 7);
//     spotlight.position.setValues(0.0, 150.0, 0.0);
//     scene.add(spotlight);

     PointLight spotlightFollower = new PointLight(0xffffff, intensity: 1.0, distance: 0);

     parent = new Object3D();
     scene.add(parent);

     //TESTIRAM PATH
     if (loadiraj) loadPath();
     ShaderMaterial sm = new ShaderMaterial();

     //MOVING OBJECT
     Texture tex = ImageUTILS.loadTexture(objectTexture);
     movingObject = new Mesh(new CubeGeometry(side, side, side), new MeshBasicMaterial(map: tex));
//     parent.add(movingObject);


     splineCamera = new PerspectiveCamera(84.0, window.innerWidth / window.innerHeight, 0.01, 3000.0);
     splineCamera.position.setValues(0.0, 4.3, 10.0);
     splineCamera.lookAt(new Vector3.zero());
     spotlightFollower.position.setFrom(splineCamera.position);
     spotlightFollower.lookAt(new Vector3.zero());
     movingObject.add(splineCamera);
     movingObject.add(spotlightFollower);


     parent.add(movingObject);
     cameraHelper = new CameraHelper(splineCamera);
     scene.add(cameraHelper);

     //Debug point
     cameraEye = new Mesh(new SphereGeometry(5.0), new MeshBasicMaterial(color: 0xdddddd));
     parent.add(cameraEye);

     cameraHelper.visible = showCameraHelper; //TODO add html for showCameraHelper
     cameraEye.visible = showCameraHelper;

     renderer = new WebGLRenderer(antialias: true);
     renderer.setClearColor(new Color(0xf0f0f0), 1.0); //Alpha = 1.0?)
     renderer.setSize(window.innerWidth, window.innerHeight);

     container.append(renderer.domElement);

     renderer.domElement.addEventListener('mousedown', onDocumentMouseDown, false);
     renderer.domElement.addEventListener('touchstart', onDocumentTouchStart, false);
     renderer.domElement.addEventListener('touchmove', onDocumentTouchMove, false);
     window.addEventListener('resize', onWindowResize, false);

}



animate(num time) {
     update();
     render();
     window.requestAnimationFrame(animate);
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

     strafeElem.innerHtml = strafeTotal.toString();
}

render() {

     double levitation = 0.0;

//     if(!sw.isRunning)
//     {
//          sw.start();
//     }
//     else
//     {
//          levitation = getSine(sw.elapsedTicks);
//     }

     SplineCurve3 putanja;
//     offset = 15.0, offsetObject = 12.0
//     double offset = 15.0;
     double offsetObject = side / 2 + 2.0 + levitation; //5.0 = amplituda u getSine();

     //camera animation
     int time = new DateTime.now().millisecondsSinceEpoch;
     int looptime = loopSeconds * 1000;
     double t = (time % looptime) / looptime;

     //t in range [0 ... 1], get points at curve, and scale it since the curve is scaled.
//     putanja = tube.path;
     putanja = blenderClosedSpline;

     Vector3 posObject = (putanja.getPointAt((t + 2 / putanja.length) % 1)).multiply(new Vector3(scale, scale, scale));

     //interpolation - moving object
     int segments = tube.tangents.length;
     double t2 = (t + 2 / putanja.length) % 1;
     double pickt2 = t2 * segments;
     int pick2 = pickt2.floor();
     int pickNext2 = (pick2 + 1) % segments;

     //Object position
     binormalObject = tube.binormals[pickNext2] - tube.binormals[pick2];
     double bScaleObject = pickt2 - pick2;
     binormalObject.multiply(new Vector3(bScaleObject, bScaleObject, bScaleObject));
     binormalObject.add(tube.binormals[pick2]);
     tangentObject = -putanja.getTangentAt(t2);
     normalObject.setFrom(binormalObject).crossInto(tangentObject, normalObject);
     posObject.add(normalObject.clone().add(new Vector3(0.0, offsetObject, 0.0)));
     movingObject.position.setFrom(posObject);


     print("ScenePos: ${scene.position}, P: ${movingObject.position}");


     //Object lookAt
     Vector3 smjerGledanja = tangentObject.clone().normalize().scale(2.0).add(movingObject.position);
     Matrix4 lookAtObjectMatrix = new Matrix4.identity();
     lookAtObjectMatrix = makeLookAt(lookAtObjectMatrix, smjerGledanja, movingObject.position, normalObject);
     movingObject.matrix = lookAtObjectMatrix;
     movingObject.rotation = calcEulerFromRotationMatrix(movingObject.matrix);

     //Adjust strafe movement
     Vector3 toMove = binormalObject.clone().normalize();
     toMove.multiply(new Vector3(strafeTotal, strafeTotal, strafeTotal));
     posObject.add(toMove);
     movingObject.position.setFrom(posObject);

     cameraHelper.update();
     camera.lookAt(scene.position);
     parent.rotation.y += (targetRotation - parent.rotation.y) * 0.05;
     renderer.render(scene, animation == true ? splineCamera : camera);
}
