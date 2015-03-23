import 'package:three/three.dart';
import 'package:vector_math/vector_math.dart';
import 'dart:html';

import 'utilities/Keyboard.dart';

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

ButtonInputElement btn;
Mesh toHit;
Keyboard kb;
Mesh cube;

void main()
{
     init();
     animate(0);
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
     
     makeAxes(); 
     renderer = new WebGLRenderer(antialias: true);
     renderer.setClearColor(new Color(0xf0f0f0), 1.0);
     renderer.setSize(window.innerWidth, window.innerHeight);
     container.append(renderer.domElement);
     renderer.domElement.addEventListener('mousedown', onDocumentMouseDown, false);
     renderer.domElement.addEventListener('touchstart', onDocumentTouchStart, false);
     renderer.domElement.addEventListener('touchmove', onDocumentTouchMove, false);
     window.addEventListener('resize', onWindowResize, false);
     
     btn = querySelector('#hit');
     kb = new Keyboard();
     
     //ADD OBJECTS TO SCENE HERE
     cube = new Mesh(new CubeGeometry(20.0, 20.0, 20.0), new MeshBasicMaterial(color:0xff0000));
     scene.add(cube);     
     
     toHit = new Mesh(new CubeGeometry(20.0, 20.0, 20.0), new MeshBasicMaterial(color:0x123456));
     toHit.position.x = 50.0;
     scene.add(toHit);
     
     cube.geometry.computeBoundingBox();
     String one = cube.geometry.boundingBox.min.toString();
     String two = cube.geometry.boundingBox.max.toString();
     
     btn.value = one + " " + two;
     
     cube.geometry.computeBoundingSphere();
     
     btn.value = cube.geometry.boundingSphere.radius.toString();
     
     double radius = cube.geometry.boundingSphere.radius;
     
     Geometry geo = new Geometry();
     geo.vertices.add(new Vector3.zero());
     geo.vertices.add(new Vector3(radius, radius,radius));
     
     Line m = new Line(geo, new LineBasicMaterial(color: 0xff0000,linewidth: 5));
     scene.add(m);
     
     
     scene.add(new Mesh(new SphereGeometry(10.0), new MeshBasicMaterial(color: 0x00f00f)));
     
     Geometry test = new Geometry();
     
     test.vertices.add(new Vector3(10.0, 0.0, 10.0));
     test.vertices.add(new Vector3(10.0, 0.0, -10.0));
     test.vertices.add(new Vector3(-10.0, 0.0, 0.0));
     
     test.computeBoundingBox();
     
     btn.value = test.boundingBox.min.toString() + " " + test.boundingBox.max.toString();

     
     
     
     
     
     //-------------------------
}

double factor = 2.0;

render()
{
     //WRITE ANIMATION LOGIC HERE
     if(kb.isPressed(KeyCode.W))
     {
          cube.position.x += factor;
     }
     
     if(kb.isPressed(KeyCode.A))
     {
          cube.position.x -= factor;
     }
}

animate(num time)
{
     window.requestAnimationFrame(animate);
     render();    
     renderer.render(scene, camera);
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