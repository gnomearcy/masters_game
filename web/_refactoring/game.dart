library Game;

import 'package:three/three.dart' hide Path;
import 'package:vector_math/vector_math.dart';
import 'package:three/extras/image_utils.dart' as ImageUTILS;
import 'dart:html';
import 'dart:async';
import 'ObjectManager.dart';
import 'Parser.dart';
import 'CoreManager.dart';

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
Path path;

//Gameplay
double strafe = 3.0;
double strafeDt = strafe / 60.0;
double strafeMin = -strafe;
double strafeMax = strafe;
double strafeTotal = 0.0;

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
                      objectManager.handleGeometries(scene, geometries);
                      path = objectManager.path;
//                      var curve = new SplineCurve3(geometries.elementAt(0).vertices);
//                      TubeGeometry tube = new TubeGeometry(curve, curve.points.length - 1, 1.0, 1, false, false);
//                      path = new Path(tube.binormals, tube.tangents.length, tube.path);
                      coreManager.generate(scene, path, strafe);
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
     
//     loadWithParser();
//     loadWithManager();
//     loadWithLoader();
     
}

void loadWithParser()
{
//     mojParser.MojParser mp = new mojParser.MojParser();

     String trackpath = 'testiram_jedan_segment_6.obj';
     String track_texture = "combined_layout_test1_export.jpg";
     
     Texture tex = ImageUTILS.loadTexture(track_texture);
     MeshPhongMaterial track_material = new MeshPhongMaterial(map: tex);
     
     mp.load(trackpath).then((object)
     {
           Mesh track = new Mesh(object, track_material);
           track.scale.scale(20.0);
           scene.add(track);          
     });
}

void loadWithManager()
{
//     objManager = new ObjectManager();
//     objManager.init()
//     .then((value)
//     {
////          scene.add(objManager.track);
////          print(objManager.track.geometry.vertices.length);
////          print(objManager.path.geometry.vertices.length);   
////          objManager.path.toString();
//          print(objManager.path == null ? "da" : "ne");
//          print(objManager.track == null ? "da" : "ne");
//     });
     
//     objManager.someFunction();
//     print(objManager.path == null ? "da" : "ne");
//     print(objManager.track == null ? "da" : "ne");
//     
//     print(objManager.pathGeo.vertices.length);
     
}

void loadWithLoader()
{
     Object3D track;

     String trackpath = 'testiram_jedan_segment_6.obj';
     String track_texture = "combined_layout_test1_export.jpg";
     
     Texture tex = ImageUTILS.loadTexture(track_texture);
     Material mat = new MeshPhongMaterial(map: tex);

     var loader = new OBJLoader();

     loader.load(trackpath).then((object) 
               {

          object.children.forEach((e) {
               if (e is Mesh) {
                    (e as Mesh).material = mat;
               }
          });
          
          //Cache locally
          track = object;   
          track.scale.scale(30.0);
          scene.add(track);
     });
}

void addLights()
{
     AmbientLight ambientLight = new AmbientLight(0xffffff);
     
     PointLight spotLightCenter = new PointLight(0xffffff, intensity: 1.0);
     spotLightCenter.position = new Vector3.zero();     
     
     scene.add(ambientLight);
     scene.add(spotLightCenter);
}

render()
{
     //WRITE ANIMATION LOGIC HERE
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