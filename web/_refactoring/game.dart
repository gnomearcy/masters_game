library Game;

import 'package:three/three.dart' hide Path;
import 'package:vector_math/vector_math.dart' hide Ray;
import 'package:three/extras/image_utils.dart' as ImageUTILS;
import 'dart:html';
import 'dart:async';
import 'ObjectManager.dart';
import 'Parser.dart';
import 'CoreManager.dart';
import 'Keyboard.dart';
import 'TimeManager.dart';
import 'package:stats/stats.dart';

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
Keyboard keyboard;
TimeManager timeManager;
Stats stats;

//Gameplay
double strafe = 0.6;
double strafeDt = strafe / 60.0;
double strafeMin = -strafe;
double strafeMax = strafe;
double strafeTotal = 0.0;
int loopSeconds = 420;

Vector3 binormalObject = new Vector3.zero();
Vector3 normalObject = new Vector3(0.0, 1.0, 0.0);  //up
Vector3 tangentObject = new Vector3.zero();
Vector3 positionObject = new Vector3.zero();        //center
Matrix4 lookAtMatrix = new Matrix4.identity();    
double t;       //current time

ButtonInputElement toggleBtn;
ButtonInputElement scoreBtn;
ButtonInputElement healthBtn;
ButtonInputElement startStopBtn;
bool toggle = false;
String start = "Start";
String stop = "Stop";
bool animation = false;

int score = 0;
int health = 3;

void main()
{    
     initObjects();
     
     var string_literals = objectManager.resources;
     
     Future.wait(string_literals.map((literal) => HttpRequest.request(literal, responseType: "String")))
               .then((List<HttpRequest> responses) 
               {
                    List<Object> rs = new List<Object>();
                    
                    for(HttpRequest r in responses)
                    {
                         rs.add(r.response);
                    }
                    
                    Future.wait(rs.map((response) => parser.parse(response)))
                    .then((List<Geometry> geometries)
                    {                      
                      objectManager.handleGeometries(scene, geometries); //imam ship, path, track, scoreitem, obstacle
//                      path = objectManager.path;   //drzi referencu na krivulju, njezine binormale i segmente (sluzi za pomicanje broda)
                      
                      coreManager.generate(scene, objectManager, strafe); //generiraj prepreke i iteme za bodove, ubaci ih u scenu
                      
                      animate(0);                      
                    });
               });     
}

/**
 * Creates instances of all helper objects.
 * Initialises a renderer and a scene graph.
 */

initObjects()
{
     objectManager = new ObjectManager();
     coreManager = new CoreManager();
     parser = new Parser();
     keyboard = new Keyboard();
     stats = new Stats();
     
     stats.container.style..position = "absolute"
                         ..left = "0px"
                         ..top = "50px"
                         ..zIndex = "10";
     
     document.body.append(stats.container);
     
     scene = new Scene();
//     container = document.querySelector('#renderer_wrapper');
     camera = new PerspectiveCamera(cameraFov, cameraAspect, cameraNear, cameraFar);
     camera.position.setFrom(cameraPosition); 
     camera.lookAt(scene.position);
     scene.add(camera);
     
     makeAxes(); 
     renderer = new WebGLRenderer(antialias: true);
     renderer.setClearColor(new Color(0xf0f0f0), 1.0);
     renderer.setSize(window.innerWidth, window.innerHeight);
     
     //add id - external css script will take care of the rest 
     renderer.domElement.id = "renderer"; 
     document.body.append(renderer.domElement);
     
     renderer.domElement.addEventListener('mousedown', onDocumentMouseDown, false);
     renderer.domElement.addEventListener('touchstart', onDocumentTouchStart, false);
     renderer.domElement.addEventListener('touchmove', onDocumentTouchMove, false);
     window.addEventListener('resize', onWindowResize, false);
     
     //ADD OBJECTS TO SCENE HERE
     cube = new Mesh(new CubeGeometry(20.0, 20.0, 20.0), new MeshBasicMaterial(color:0xff0000));
//     scene.add(cube);
     
      toggleBtn = querySelector('#toggle');
//     toggleBtn.onClick.listen((e) => toggle = !toggle);
      toggleBtn.onClick.listen((e) => animateCamera(true));
      scoreBtn = querySelector('#score');
      healthBtn = querySelector('#health');
      startStopBtn = querySelector('#startstop');
      startStopBtn.value = stop;
      startStopBtn.onClick.listen((MouseEvent e) {timeManager.toggle();});
      
      scoreBtn.value = "Score: " + score.toString();
      healthBtn.value = "Health: " + health.toString();     
}

void addLights()
{
     AmbientLight ambientLight = new AmbientLight(0xffffff);
     
     PointLight spotLightCenter = new PointLight(0xffffff, intensity: 1.0);
     spotLightCenter.position = new Vector3.zero();     
     
     scene.add(ambientLight);
     scene.add(spotLightCenter);
}

void animateCamera(bool t) {
     if (t) {
          animation = !animation;
          toggleBtn.value = "Camera Spline Animation View: " + (animation == true ? "ON" : "OFF");
     }
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
}

render()
{
      if(timeManager == null)
       {
            print("Initializing a new TimeManager object");
            timeManager = new TimeManager(loopSeconds, true);
       }
       
       t = timeManager.getCurrentTime();
       
       /*
        * double t = timeManager.getCurrentTime();
+     double someT = ((t + 2 / path.curve.length) % 1);
+     double pickt2 = someT * path.segments; //unfloored
+     int pick2 = (someT * path.segments).floor(); //floored
+     double bScaleObject = pickt2 - pick2;
+     int pickNext2 = (pick2 + 1) % path.segments; //sljedeci segment
        */
       
       double nekiT = (t + 2 / objectManager.path.length) % 1;
       if(nekiT > 1.0)
         nekiT -= 1.0;
//       int nextSeg = (nekiT * objectManager.segments).floor();
       
       print("current: " + t.toString() + " | next: " + nekiT.toString());
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
       binormalObject = normalObject.clone().normalize().crossInto(-tangentObject, binormalObject);
       binormalObject.multiply(new Vector3(strafeTotal, 0.0, strafeTotal));
       objectManager.ship.position.setFrom(positionObject.add(binormalObject));
//       print(objectManager.ship.position.toString());
//       objectManager.ship.geometry.computeBoundingBox();
//       objectManager.ship.updateMatrixWorld();
       objectManager.ship.geometry.boundingBox = new BoundingBox.fromObject(objectManager.ship);
}

checkCollision() 
{
//    Vector3 position = objectManager.ship.position.clone();
//
//    for(int i = 0; i < objectManager.ship.geometry.vertices.length; i++)
//    {
//         var local = objectManager.ship.geometry.vertices[i].clone();
//         var global = local.applyProjection(objectManager.ship.matrixWorld);
//         var direction = global.sub(position);
//         var ray = new Ray(position, direction.clone());
//         var result = ray.intersectObjects(objectManager.hitObjects);
//
//         if(result.length > 0 && result[0].distance < direction.length)
////         if(result.length > 0)
//         {    
////              window.alert("IMAM GA");
//              scene.remove(result[0].object);
//              objectManager.hitObjects.remove(result[0].object);
//              print(result[0].object.runtimeType);
//              if(result[0].object is ScoreItem)
//              {
//                   score++;
//                   scoreBtn.value = "Score: " + score.toString();
//                   print("pogodio sam score item");
//              }
//              if(result[0].object is Obstacle)
//              {
//                   health--;
//                   healthBtn.value = "Health: " + health.toString();
//                   print("pogodio sam obstacle");
//              }
//         }
//    }
  
    Mesh hitObject;
    
    for(int i = 0; i < objectManager.hitObjects.length; i++)
    {
        hitObject = objectManager.hitObjects[i];
        
        if(hitObject.geometry.boundingBox.isIntersectionBox(objectManager.ship.geometry.boundingBox))
        {
            if(hitObject is ScoreItem)
            {
                score++;
                scoreBtn.value = "Score: " + score.toString();
//                print("pogodio sam score item");
            }
            if(hitObject is Obstacle)
            {
                 health--;
                 healthBtn.value = "Health: " + health.toString();
//                 print("pogodio sam obstacle");
            }
            
            scene.remove(hitObject);
            objectManager.hitObjects.remove(hitObject);
        }
    }
}

animate(num time)
{
     stats.begin();
     update();
     render();
     scene.rotation.y += (targetRotation - scene.rotation.y) * 0.05;

     checkCollision();
     stats.end();
//     renderer.render(scene, camera);
     renderer.render(scene, animation == true ? objectManager.splineCamera : camera);
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