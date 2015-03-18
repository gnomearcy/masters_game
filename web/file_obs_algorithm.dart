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
double top = value/2;
double bottom = -value/2;
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
MeshBasicMaterial scoreMat = new MeshBasicMaterial(color:0x00ff00, wireframe: false);
Mesh obstacle;
Mesh scoreItem;
double radius = 0.4; //1.0*0.8 
double planeHeight = 500.0;
double planeWidth = 100.0;
Math.Random random;

double vertSeg = planeHeight / planeHeight; //1.0
double horSeg = (planeWidth * 0.8) / 4.0;

//algoritm
PathParser pp;
Keyboard keyboard;
//Path data
ClosedSplineCurve3 mainCurve;
Object3D tubeMesh;
TubeGeometry tube;
bool closed = false;
int radiussegments = 1;
int segments = 100;
double tuberadius = 2.0;
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

int loopSeconds = 5;
Vector3 binormalObject = new Vector3.zero();
Vector3 normalObject = new Vector3.zero();
Vector3 tangentObject = new Vector3.zero();

double strafe = 1.0;
double strafeDt = strafe / 10.0;
double strafeMin = -strafe;
double strafeMax = strafe;
double strafeTotal = 0.0;

void main()
{     
     addCurves();     
}

void addRandom()
{
     //adds random obstacles
     DateTime date = new DateTime.now();
     random = new Math.Random(date.millisecondsSinceEpoch);
     
     //instantiating a new instance of Mesh for obstacle.
     //other solution is to deep copy the one instance to another
     Mesh obs;
     Mesh score;
     
     //dok ne prodes svih 500 vertSeg
     //odredi velicinu patcha (3/4/5)
     //odredi horizontalnu poziciju patcha (random broj od 0 do 3) gore/dolje
     //zapamti prethodnu horizontalnu poziciju
     //poslije patcha generiraj (0/1/2) poziciju
     
     double nrOfVertSegs = -planeHeight / 2.0; //kreni od -250 da koristim taj broj kao poziciju
//     List xPos = [-horSeg * 2, -horSeg, horSeg, horSeg * 2]; //-40, -20, 20, 40
     List xPos = [ -(horSeg*(3/2)), -(horSeg*(1/2)), (horSeg*(1/2)), (horSeg*(3/2))];
     
     while(nrOfVertSegs < (planeHeight / 2.0)) //manji od 250
     {
          //generate obstacle patch
          int patchSize = random.nextInt(2) + 3; //0,1,2,3,4 desno
          int horPos = random.nextInt(4); //0,1,2,3 gore dolje 0 ->
          double newX = xPos[horPos];
          
          for(int i = 0; i < patchSize; i++)
          {
               obs = new Mesh(new SphereGeometry(radius), obstableMat);
               obs.position.x = newX;
               obs.position.z = nrOfVertSegs; //-250 na pocetku
               scene.add(obs);
               
               nrOfVertSegs += 1.0;             
          }      
          //generate void
        int voidWidth = random.nextInt(5) + 5; //0,1,2,3,4
        double voidSeg = 0.5;
        
        if(voidWidth != 0)
        {
             Mesh voidPlane = new Mesh(new PlaneGeometry(planeWidth * 0.8, voidWidth.toDouble()), new MeshBasicMaterial(color:0x0000ff));
             voidPlane.rotation.x = -90 * Math.PI / 180.0;
             voidPlane.position.y = 2.0;
             voidPlane.position.z = nrOfVertSegs + (voidWidth - 1) * voidSeg;
             scene.add(voidPlane);
             nrOfVertSegs += voidWidth.toDouble();
        }    
     }
}

void addCurves()
{
       pp = new PathParser();

       pp.load(fullCurve).then((object) {
            
            //Inicijaliziraj scenu i parent
            init();
            fullSpline = new SplineCurve3(pp.getVertices);
            addTube(fullSpline);
            
       }).whenComplete(()
       {
            fullContainer = connect(fullSpline, 0xff0000);
//            fullContainer.position.x = -30.0;
            parent.add(fullContainer);
            
            pp.resetVertices();
            
            pp.load(halfCurve).then((object)
            {
                 halfSpline = new SplineCurve3(pp.getVertices);
            }).whenComplete(()
                 {
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
     
     for ( Vector3 v in points ) 
     {
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

void addTube(SplineCurve3 curve) 
{     
     if(tubeMesh != null)
     {
          parent.remove(tubeMesh);
     }
     
     print("${curve.toString()}");
     tube = new TubeGeometry(curve, curve.points.length - 1, tuberadius, radiussegments, closed, false);
     tubeMesh = SceneUtils.createMultiMaterialObject(tube, [new MeshLambertMaterial(color: 0xff00ff), new MeshBasicMaterial(color: 0x000000, opacity: 0.3, wireframe: true, transparent: true)]);
     tubeMesh.scale.setFrom(new Vector3(scale, scale, scale));
//     tubeMesh.position.x = -30.0;
     parent.add(tubeMesh);
}

void logg(String input)
{
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
      
      //Moving object - initialisation
       Texture tex = IMAGEUtils.loadTexture(objectTexture);
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


void animateCamera(bool t) 
{
     if (t) 
     {
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

     try
     {
          posObject = (fullSpline.getPointAt((t + 2 / fullSpline.length) % 1));
//          logg(posObject.toString());
     }
     catch(e)
     {
          logg(posObject.toString());
     }
     
     

     //interpolation - moving object
     int segments = tube.tangents.length;
     double t2 = (t + 2 / fullSpline.length) % 1;
     double pickt2 = t2 * segments;
     int pick2 = pickt2.floor();
     int pickNext2 = (pick2 + 1) % segments;

     //Object position
     binormalObject = tube.binormals[pickNext2] - tube.binormals[pick2];
     double bScaleObject = pickt2 - pick2;
     binormalObject.multiply(new Vector3(bScaleObject, bScaleObject, bScaleObject));
     binormalObject.add(tube.binormals[pick2]);
     tangentObject = -fullSpline.getTangentAt(t2);
     normalObject.setFrom(binormalObject).crossInto(tangentObject, normalObject);
     posObject.add(normalObject.clone());
     movingObject.position.setFrom(posObject);

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
     //WRITE ANIMATION LOGIC HERE
     moveTheObject();
     parent.rotation.y += (targetRotation - parent.rotation.y) * 0.05;
     
}

animate(num time)
{
     update();
     render();    
//     moveTheObject();     
//     renderer.render(scene, camera);
//     renderer.render(scene, toggle ? camera : orthoCamera);
     renderer.render(scene, animation == true ? splineCamera : camera);
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