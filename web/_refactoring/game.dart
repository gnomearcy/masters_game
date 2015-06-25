library Game;

import 'package:three/three.dart' hide Path;
import 'package:vector_math/vector_math.dart' hide Ray;
import 'package:three/extras/image_utils.dart' as ImageUTILS;
import 'dart:html';
import 'dart:async';
import 'ObjectManager.dart';
import 'Parser.dart';
import 'CoreManager.dart';
//import 'Keyboard.dart';
import 'TimeManager.dart';
import 'HUDManager.dart';
import 'package:stats/stats.dart';
import 'dart:math';
import 'dart:collection';
import 'dart:core';

Scene scene;
PerspectiveCamera camera;
CameraHelper cameraHelper;
WebGLRenderer renderer;
Element container;

Vector3 cameraPosition = new Vector3(100.0, 100.0, 100.0);
double cameraFov = 75.0;
double cameraNear = 1.0;
double cameraFar = 1000.0;
double cameraAspect = window.innerWidth / window.innerHeight;

var targetRotation = 0;
var targetRotationOnMouseDown = 0;
var mouseX = 0;
var mouseXOnMouseDown = 0;
var windowHalfX = window.innerWidth / 2;
var windowHalfY = window.innerHeight / 2;

Mesh cube;

CoreManager coreManager;
ObjectManager objectManager;
Parser parser;
//Path path;
//Keyboard keyboard;
TimeManager timeManager;
HUDManager hudManager;

//Gameplay
double strafe = 0.6;
double strafeDt = strafe / 15.0;
double strafeMin = -strafe;
double strafeMax = strafe;
double strafeTotal = 0.0;
double currentStrafe = 0.0;
//int loopSeconds = 400;

Vector3 binormalObject = new Vector3.zero();
Vector3 normalObject = new Vector3(0.0, 1.0, 0.0); //up
Vector3 tangentObject = new Vector3.zero();
Vector3 positionObject = new Vector3.zero(); //center
Matrix4 lookAtMatrix = new Matrix4.identity();
double t; //current time

ButtonInputElement toggleBtn;
ButtonInputElement scoreBtn;
ButtonInputElement healthBtn;
ButtonInputElement startStopBtn;
bool toggle = false;
String start = "Start";
String stop = "Stop";
bool animation = true;

int score = 0;
int health = 3;

//time used to calculate strafe in render()
int previousTime = 0;
int currentTime = 0;
int elapsedTime = 0;
int threshhold = 250; 
double increment = 0.0001; //TODO remove


//html total countdown animation length in milliseconds
const countdownLength = 4050;
bool countdownFinished = false;
bool isStartVisible = true;

bool isGameOver = false;
bool isTimerRunning = false;

double previousTimerTime = 0.0;
double currentTimerTime = 0.0;
bool isNewLap = false;

HashMap<int, int> _keys = new HashMap<int, int>();
     
isPressed(int keyCode) => _keys.containsKey(keyCode);

//handle div animations
initDivs()
{
//  querySelector("#div_start").onClick.listen((event)
  hudManager.start.onClick.listen((event)
  {
//    print("Starting countdown...");
//    const d = const Duration(milliseconds: countdownLength);
//    new Timer.periodic(d, (Timer t) 
//    {
//      print("Stopping countdown!");
//      t.cancel();
//      countdownFinished = true;      
//    });
        print("Starting countdown...");
        if(isStartVisible)
        {
          isStartVisible = false;
          const d = const Duration(milliseconds: countdownLength);
          new Timer.periodic(d, (Timer t) 
          {
            print("Stopping countdown!");
            t.cancel();
            countdownFinished = true; 
            isStartVisible = true;
          });
          hudManager.countdown();
        }
  });
  
  hudManager.tryAgain.onClick.listen((event)
      {
        print("tryAgain click handler");
        objectManager.ship.position.setFrom(new Vector3.zero());
        objectManager.ship.rotation.y = -90 * PI/180.0;
        countdownFinished = false;
        isGameOver = false;
        timeManager.reset();
        unhideAssets();
        hudManager.reset();
      });
  
//  hudManager.start.onClick.listen((event)
//      {
//          if(isStartVisible)
//          {
//            isStartVisible = false;
//            const d = const Duration(milliseconds: 500);
//            new Timer.periodic(d, (Timer t)
//                {
//                  isStartVisible = true;
//                });
//            hudManager.countdown();
//          }
//      });
}

updateInternal(KeyboardEvent e)
 {
   if (isPressed(KeyCode.D)) {
       
       strafeTotal -= strafeDt;
       print("Update D -> " + strafeTotal.toString());
       if (strafeTotal <= strafeMin) strafeTotal = strafeMin;
     }

     if (isPressed(KeyCode.A)) {
       print("Update A -> " + strafeTotal.toString());
       strafeTotal += strafeDt;
       if (strafeTotal >= strafeMax) strafeTotal = strafeMax;
     }
 }

void main() {
  
     window.onKeyDown.listen((KeyboardEvent e)
     {        
          if (!_keys.containsKey(e.keyCode))
          {
               _keys[e.keyCode] = e.timeStamp;  
          }
          else
            updateInternal(e);

     });
     
     window.onKeyUp.listen((KeyboardEvent e)
     {
          _keys.remove(e.keyCode);          
     });

  initObjects();
  initDivs();
  
  
  var string_literals = objectManager.resources;

  Future
      .wait(string_literals.map(
          (literal) => HttpRequest.request(literal, responseType: "String")))
      .then((List<HttpRequest> responses) {
    List<Object> rs = new List<Object>();

    for (HttpRequest r in responses) {
      rs.add(r.response);
    }

    Future
        .wait(rs.map((response) => parser.parse(response)))
        .then((List<Geometry> geometries) {
      objectManager.handleGeometries(
          scene, geometries); //imam ship, path, track, scoreitem, obstacle
//                      path = objectManager.path;   //drzi referencu na krivulju, njezine binormale i segmente (sluzi za pomicanje broda)

      coreManager.generate(scene, objectManager,
          strafe); //generiraj prepreke i iteme za bodove, ubaci ih u scenu

      //print out number of generated score items
//      int generated = 0;
//      scene.children.forEach((a) {
//        if (a.runtimeType == ScoreItem) generated++;
//        print(a.runtimeType);
//        print(generated);
//      });

      gameLoop(0);
    });
  });
}

/**
 * Creates instances of all helper objects.
 * Initialises a renderer and a scene graph.
 */

initObjects() {
  objectManager = new ObjectManager();
  coreManager = new CoreManager();
  parser = new Parser();
  timeManager = new TimeManager(forceStart: false);
  hudManager = new HUDManager();
  
  scene = new Scene();
//     container = document.querySelector('#renderer_wrapper');
  camera =
      new PerspectiveCamera(cameraFov, cameraAspect, cameraNear, cameraFar);
  camera.position.setFrom(cameraPosition);
  camera.lookAt(scene.position);
  scene.add(camera);

  makeAxes();

  renderer = new WebGLRenderer(antialias: true);
  renderer.setClearColor(new Color(0xf0f0f0), 1.0);
  renderer.setSize(window.innerWidth, window.innerHeight);

  //add id - external css script will take care of the rest
  renderer.domElement.id = "renderer";
  
  /**testing inserting renderer dom element into a wrapper*/  
//  renderer.domElement.style..width = "400px"..height = "250px";
//  querySelector("#renderer_wrapper").append(renderer.domElement);  
  
//  renderer.domElement.style.zIndex = "0";
  document.body.append(renderer.domElement);

  renderer.domElement.addEventListener('mousedown', onDocumentMouseDown, false);
  renderer.domElement.addEventListener(
      'touchstart', onDocumentTouchStart, false);
  renderer.domElement.addEventListener('touchmove', onDocumentTouchMove, false);
  window.addEventListener('resize', onWindowResize, false);

  //ADD OBJECTS TO SCENE HERE
//  cube = new Mesh(new CubeGeometry(20.0, 20.0, 20.0),
//      new MeshBasicMaterial(color: 0xff0000));
//     scene.add(cube);
  
  //TODO obsolete
  ButtonInputElement randomize = querySelector("#randomize");  
  randomize.onClick.listen((event){
    
    //testenvironment
//    querySelector("#div_game_over").style.visibility = "visible";
//    hudManager.updateScore(new Random().nextInt(9999));
    });
  
  ButtonInputElement reset = querySelector("#reset");
  
  reset.onClick.listen((event)
  {
//    print("Inside reset button click event.");
//    //reset everything
//    countdownFinished = false;
//    objectManager.ship.position.setFrom(new Vector3.zero());
//    unhideAssets();
//    hudManager.reset();
  });
  
  toggleBtn = querySelector('#toggle');
//     toggleBtn.onClick.listen((e) => toggle = !toggle);
  toggleBtn.onClick.listen((e) => animateCamera(true));
  scoreBtn = querySelector('#score');
  healthBtn = querySelector('#health');
  startStopBtn = querySelector('#startstop');
  startStopBtn.value = stop;
  startStopBtn.onClick.listen((MouseEvent e) {
    timeManager.toggle();
  });

  scoreBtn.value = "Score: " + score.toString();
  healthBtn.value = "Health: " + health.toString();
}

void addLights() {
  AmbientLight ambientLight = new AmbientLight(0xffffff);

  PointLight spotLightCenter = new PointLight(0xffffff, intensity: 1.0);
  spotLightCenter.position = new Vector3.zero();

  scene.add(ambientLight);
  scene.add(spotLightCenter);
}

void animateCamera(bool t) {
  if (t) {
    animation = !animation;
    toggleBtn.value =
        "Camera Spline Animation View: " + (animation == true ? "ON" : "OFF");
  }
}

unhideAssets()
{
  for (int i = 0; i < objectManager.hitObjects.length; i++)
  {
    (objectManager.hitObjects[i] as Mesh).visible = true;
  }
}
update() 
{
//  if (timeManager == null) {
////    print("Initializing a new TimeManager object");
//    timeManager = new TimeManager(forceStart: true);
//  }

  t = timeManager.getCurrentTime();
  
  currentTimerTime = t;
//  print("Current / Previous: [" + currentTimerTime.toString() + " | " + previousTimerTime.toString() + "]");
  if(currentTimerTime < previousTimerTime) // 0.1 < 0.0, ne,
  {
    isNewLap = true;
//    print("NEW LAP!!!!!!!!");
  }
  previousTimerTime = currentTimerTime;
  
  if(isNewLap)
  {
    unhideAssets();
    isNewLap = false;
  }
  
  currentTime = new DateTime.now().millisecondsSinceEpoch;
  elapsedTime = currentTime - previousTime;
  previousTime = currentTime;
  
  double percentage = elapsedTime / threshhold;
  double toMove = percentage * strafe;
    
  if(!(isPressed(KeyCode.D) && isPressed(KeyCode.A)))
  {
    if(isPressed(KeyCode.A))
    {
      if(currentStrafe + toMove > strafe)
        currentStrafe = strafe;
      else
        currentStrafe += toMove;
    }
    
    if(isPressed(KeyCode.D))
    {
      if(currentStrafe - toMove < -strafe)
        currentStrafe = -strafe;
      else
        currentStrafe -= toMove;
    }
  }
  

  /*
        * double t = timeManager.getCurrentTime();
+     double someT = ((t + 2 / path.curve.length) % 1);
+     double pickt2 = someT * path.segments; //unfloored
+     int pick2 = (someT * path.segments).floor(); //floored
+     double bScaleObject = pickt2 - pick2;
+     int pickNext2 = (pick2 + 1) % path.segments; //sljedeci segment
        */

//       double nekiT = (t + 2 / objectManager.path.length) % 1;
//       if(nekiT > 1.0)
//         nekiT -= 1.0;
//       int nextSeg = (nekiT * objectManager.segments).floor();

//       print("current: " + t.toString() + " | next: " + nekiT.toString());
  //center
  positionObject = objectManager.path.getPointAt(t);
//       Vector3 positionEye = objectManager.path.getPointAt(nekiT);
  //eye
  tangentObject = -objectManager.path.getTangentAt(t);
//       Vector3 tangentEye = -objectManager.path.getTangentAt(nekiT);
//       Vector3 tangentObjectNext = -objectManager.path.getTangentAt(nekiT);
//       Vector3 eye = objectManager.path.getPointAt(nekiT);
//       Vector3 eye = tangentObject.clone().normalize().add(positionObject);
  Vector3 eye = tangentObject.clone().normalize().add(positionObject);

  //lookatmatrix
  lookAtMatrix = makeLookAt(lookAtMatrix, eye, positionObject, normalObject);
  objectManager.ship.rotation = calcEulerFromRotationMatrix(lookAtMatrix);

  //adjust strafe
  binormalObject = new Vector3.zero();
  binormalObject = normalObject
      .clone()
      .normalize()
      .crossInto(-tangentObject, binormalObject);
  //trenutni strafe total
//  print("Render -> " + strafeTotal.toString());
//  binormalObject.multiply(new Vector3(strafeTotal, 0.0, strafeTotal));
  binormalObject.multiply(new Vector3(currentStrafe, 0.0, currentStrafe));
  objectManager.ship.position.setFrom(positionObject.add(binormalObject));
//       print(objectManager.ship.position.toString());
//       objectManager.ship.geometry.computeBoundingBox();
//       objectManager.ship.updateMatrixWorld();
  objectManager.ship.geometry.boundingBox =
      new BoundingBox.fromObject(objectManager.ship);
  
  //update score item rotation
  scene.children.forEach((child){
    if(child.runtimeType == ScoreItem)
      (child as ScoreItem).rotation.y += 2 * PI / 180.0;
  });
}

collision() 
{
  Mesh hitObject;

  for (int i = 0; i < objectManager.hitObjects.length; i++) {
    hitObject = objectManager.hitObjects[i];

    if (hitObject.geometry.boundingBox
        .isIntersectionBox(objectManager.ship.geometry.boundingBox)) 
    {
      if (hitObject is ScoreItem)
      {
        hudManager.updateScore(score++);
        scoreBtn.value = "Score: " + score.toString(); //TODO remove
      }
      if (hitObject is Obstacle) 
      {
        health--;
        print("Hit an obstacle!!! current health " + health.toString()); //TODO remove

        if(health == 0)
        {
          print("Health is zero, setting flag to true"); //TODO remove
          isGameOver = true;
        }
        
        hudManager.updateHealth(health);
        
        healthBtn.value = "Health: " + health.toString(); //TODO remove
      }

      hitObject.visible = false;
//      scene.remove(hitObject);
//      objectManager.hitObjects.remove(hitObject);
    }
  }
}

gameLoop(num time) 
{
  if(countdownFinished)
  {
//     if(timeManager == null)
//     {
//        timeManager = new TimeManager(forceStart: true);
//     }
    if(!timeManager.isRunning)
    {
      timeManager.start();
    }
     
     if(!isGameOver)
     {
        update();
        collision();
     }     
  }
   
    //TODO remove
  scene.rotation.y += (targetRotation - scene.rotation.y) * 0.05;
  renderer.render(
        scene, animation == true ? objectManager.splineCamera : camera);
  window.requestAnimationFrame(gameLoop);
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
  targetRotation =
      targetRotationOnMouseDown + (mouseX - mouseXOnMouseDown) * 0.02;
}

onDocumentMouseUp(MouseEvent event) {
  renderer.domElement.removeEventListener(
      'mousemove', onDocumentMouseMove, false);
  renderer.domElement.removeEventListener('mouseup', onDocumentMouseUp, false);
  renderer.domElement.removeEventListener(
      'mouseout', onDocumentMouseOut, false);
}

onDocumentMouseOut(MouseEvent event) {
  renderer.domElement.removeEventListener(
      'mousemove', onDocumentMouseMove, false);
  renderer.domElement.removeEventListener('mouseup', onDocumentMouseUp, false);
  renderer.domElement.removeEventListener(
      'mouseout', onDocumentMouseOut, false);
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
    targetRotation =
        targetRotationOnMouseDown + (mouseX - mouseXOnMouseDown) * 0.05;
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

  scene.add(new Line(
      geometrija1, new LineBasicMaterial(color: 0xff0000, opacity: 1.0)));
  scene.add(new Line(
      geometrija2, new LineBasicMaterial(color: 0x00ff00, opacity: 1.0)));
  scene.add(new Line(
      geometrija3, new LineBasicMaterial(color: 0x0000ff, opacity: 1.0)));
}
