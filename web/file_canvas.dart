import 'package:three/three.dart' hide Rectangle;
import 'package:vector_math/vector_math.dart';
import 'dart:html';

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

void main() {
  init();
  animate(0);
}

init() 
{
  scene = new Scene();
  
     container = document.createElement('div');
     container.id = "container";
//  container = document.querySelector("#container");
     
     
//  document.body.style.marginLeft = "0px";
//  document.body.style.marginTop = "0px";
//  document.body.style.marginRight = "0px";
//  document.body.style.marginBottom = "0px";
//  document.body.style.marginStart = "0px";
//  document.body.style.marginEnd = "0px";
//  document.body.style.marginAfter = "0px";
//  document.body.style.marginBefore = "0px";
//  document.body.style.paddingTop = "0px";
//     document.body.style.paddingLeft = "0px";
//     document.body.style.paddingRight = "0px";
//     document.body.style.paddingAfter = "0px";
//     document.body.style.paddingBefore = "0px";
//     document.body.style.paddingBottom = "0px";
//     document.body.style.paddingEnd = "0px";
//     document.body.style.paddingStart = "0px";

//     document.body.style.height = "100%";
//     document.body.style.width = "100%";

//     container.style.border = "10px solid";
//     document.body.append(container);


     print("Query container width: " + container.clientWidth.toString());
     print("Query container height: " + container.clientHeight.toString());
     
//  Element e = document.getElementById("container");
  int rendW;
  int rendH;
//  
//  print("Get container width: " + e.clientWidth.toString());
//  print("Get container height: " + e.clientHeight.toString());
  //Dartium viewport size
  rendW = 1600;
  rendH = 795; //-4 piksela
  
  //Firefox viewport size
  rendW = 1600;
  rendH = 795;
  print("Document width: " + document.documentElement.clientWidth.toString());
  print("Document height: " + document.documentElement.clientHeight.toString());
  
  print("Body width: " + document.body.clientWidth.toString());
  print("Body height: " + document.body.clientHeight.toString());

  rendW = document.documentElement.clientWidth;
  rendH = document.documentElement.clientHeight; 
            
  
  print("Novi W/H " + rendW.toString() + ", " + rendH.toString());
  
  camera = new PerspectiveCamera(cameraFov, cameraAspect, cameraNear, cameraFar);
  camera.position.setFrom(cameraPosition);
  camera.lookAt(scene.position);
  scene.add(camera);
  makeAxes();
  
  //Napravi renderer i ubaci ga pa onda postavi size
  CanvasElement canvas = querySelector("#canvas");
  
  renderer = new WebGLRenderer(antialias: true, canvas: canvas);
  renderer.setClearColor(new Color(0xf0f0f0), 1.0);
  renderer.setSize(rendW, rendH);
  renderer.domElement.style..height = "100%"
                           ..position = "fixed"
                           ..background = "orange"
                           ..border = "0px solid #ff0000"
                           ..minHeight = "100%"
                           ..minWidth = "100%";
  
  renderer.domElement.id = "rendererDOm";
  window.onLoad.listen((event){ onLoad(event);});
  
  print("Prozor W " + window.innerWidth.toString());
  print("Prozor H " + window.innerHeight.toString());

  document.body.append(renderer.domElement);
  
  Element rend = document.getElementById("rendererDOm");
  print("Rend " + rend.clientHeight.toString());
  print("Rend W " + rend.clientWidth.toString());

  print("Offset height body: " + document.body.offsetHeight.toString());
  print("Offset width body: " + document.body.offsetWidth.toString());
  
  renderer.domElement.addEventListener('mousedown', onDocumentMouseDown, false);
  renderer.domElement.addEventListener('touchstart', onDocumentTouchStart, false);
  renderer.domElement.addEventListener('touchmove', onDocumentTouchMove, false);
  window.addEventListener('resize', onWindowResize, false);

  //ADD OBJECTS TO SCENE HERE
  cube = new Mesh(new CubeGeometry(20.0, 20.0, 20.0),
      new MeshBasicMaterial(color: 0xff0000));
  scene.add(cube);

//     createCustomDiv();
  //-------------------------
}

void createCustomDiv() {
  DivElement div = document.createElement('div');
  div.style.position = "absolute";
  div.id = "customdiv";
  div.style.width = window.innerWidth.toString();
  div.style.height = window.innerHeight.toString();
  div.style.top = "0px";
  div.innerHtml = "BLALABLASD";

  document.body.append(div);
}
void createCanvas() {
  CanvasElement canvas = document.createElement('canvas');
  canvas.style.position = 'absolute';
  canvas.style.width = window.innerWidth.toString();
  canvas.style.height = window.innerHeight.toString();
  canvas.id = "mycanvas";
  

  document.body.append(canvas);

  CanvasElement c = document.getElementById("mycanvas");
  var ctx = c.getContext("2d");
  ctx.moveTo(0, 0);
  ctx.lineTo(500, 500);
  ctx.stroke();
}

render() {
  //WRITE ANIMATION LOGIC HERE
}

animate(num time) {
  window.requestAnimationFrame(animate);
  render();
  renderer.render(scene, camera);
}


onWindowResize(Event e) 
{
     print("Prozor W " + window.innerWidth.toString());
      print("Prozor H " + window.innerHeight.toString());
  print("Screen: " + window.screen.available.toString() + ", " + window.screen.height.toString());

  windowHalfX = window.innerWidth / 2;
  windowHalfY = window.innerHeight / 2;

  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();

  int rendW = document.documentElement.clientWidth;
  int rendH = document.documentElement.clientHeight - 4;
  
  int bodyRendW = document.body.clientWidth;
  int bodyRendH = document.body.clientHeight;
  
  int finalW = rendW > bodyRendW ? rendW : bodyRendW;
  int finalH = rendH > bodyRendH ? rendH : bodyRendH;
  
  print("Doc W/H: " + document.documentElement.clientWidth.toString() + ", " + document.documentElement.clientHeight.toString() + " | " + "body W/H: "
            + document.body.clientWidth.toString() + ", " + document.body.clientHeight.toString());
  
  print("Offsets " + document.documentElement.offsetWidth.toString() + ", " + document.documentElement.offsetHeight.toString());
//  renderer.setSize(window.innerWidth, window.innerHeight);
//  renderer.setSize(rendW, rendH);
//  renderer.setSize(document.body.clientWidth, document.body.clientHeight);
  renderer.setSize(rendW, rendH);
}

onDocumentMouseDown(MouseEvent e) {
  e.preventDefault();

  renderer.domElement.addEventListener('mousemove', onDocumentMouseMove, false);
  renderer.domElement.addEventListener('mouseup', onDocumentMouseUp, false);
  renderer.domElement.addEventListener('mouseout', onDocumentMouseOut, false);

  mouseXOnMouseDown = e.client.x - windowHalfX;
  targetRotationOnMouseDown = targetRotation;
}

onDocumentMouseMove(MouseEvent e) 
{
  mouseX = e.client.x - windowHalfX;
  targetRotation = targetRotationOnMouseDown + (mouseX - mouseXOnMouseDown) * 0.02;
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
