import 'package:three/three.dart';
import 'package:vector_math/vector_math.dart';
import 'dart:html';
import 'package:three/extras/image_utils.dart' as ImageUTILS;

Scene scene;
PerspectiveCamera camera;
CameraHelper cameraHelper;
WebGLRenderer renderer;
Element container;

Vector3 cameraPosition = new Vector3(0.0, 0.0, 50.0);
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

void main()
{
     init();
     animate(0);
}

String pathToDiffuse = 'normal_map/5263.jpg';
String pathToNormal = 'normal_map/5263_normal.jpg';

Object3D parent = new Object3D();

init()
{
     scene = new Scene();
     container = document.createElement('div');
     document.body.append(container);          
     camera = new PerspectiveCamera(cameraFov, cameraAspect, cameraNear, cameraFar);
     camera.position.setFrom(cameraPosition); 
     camera.lookAt(scene.position);
     scene.add(camera);
     scene.add(parent);
     
     makeAxes(); 
     renderer = new WebGLRenderer(antialias: true);
     renderer.setClearColor(new Color(0xf0f0f0), 1.0);
     renderer.setSize(window.innerWidth, window.innerHeight);
     container.append(renderer.domElement);
     renderer.domElement.addEventListener('mousedown', onDocumentMouseDown, false);
     renderer.domElement.addEventListener('touchstart', onDocumentTouchStart, false);
     renderer.domElement.addEventListener('touchmove', onDocumentTouchMove, false);
     window.addEventListener('resize', onWindowResize, false);
     
     //ADD OBJECTS TO SCENE HERE
//     Mesh mesh = new Mesh(new CubeGeometry(20.0, 20.0, 20.0), new MeshBasicMaterial(color:0xff0000));
//     scene.add(mesh);
     Texture diffuseTex = ImageUTILS.loadTexture(pathToDiffuse);
     Texture normalTex = ImageUTILS.loadTexture(pathToNormal);
     
     MeshPhongMaterial planePhong = new MeshPhongMaterial(map: diffuseTex);
     MeshPhongMaterial planePhongNormal = new MeshPhongMaterial(map: diffuseTex, normalMap: normalTex);
//     MeshBasicMaterial planeMat = new MeshBasicMaterial(map: diffuseTex);
     Mesh phongPlane = new Mesh(new PlaneGeometry(50.0, 50.0), planePhong);
     Mesh phongNormalPlane = new Mesh(new PlaneGeometry(50.0, 50.0), planePhongNormal);
     
     phongPlane.position.x = -25.0;
     phongNormalPlane.position.x = 25.0;
     
     parent.add(phongPlane);
     parent.add(phongNormalPlane);
     
     PointLight pointLight = new PointLight(0xffffff);
     pointLight.position.z = camera.position.z + 30.0;
     parent.add(pointLight);
     //-------------------------
}

render()
{
     //WRITE ANIMATION LOGIC HERE
     parent.rotation.y += (targetRotation - parent.rotation.y) * 0.05;

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