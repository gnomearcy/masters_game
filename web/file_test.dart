import 'dart:html';
import 'dart:core';
import 'dart:math' as Math;
import 'package:three/three.dart';
import 'package:three/extras/image_utils.dart' as ImageUTILS;
import 'package:vector_math/vector_math.dart';

import 'utilities/Keyboard.dart';
import 'utilities/PathParser.dart';
import 'utilities/WindowHelper.dart';

Element canvasContainer;
WebGLRenderer renderer;
Scene scene;
PerspectiveCamera camera;
Geometry geometry;
MeshBasicMaterial matBasic;

Texture tex;
Mesh square;

double kockaY; //current kocka y position
bool onGround = true;
bool isJumping = false;


double pos = 0.0;
double vrijeme = 0.0;


double t_dt = 1.0 / 30.0; //30 fps
double pocBrzina = 10.0; //m/s
double silaTeza = 9.81;

double camera_roll = 0.0;
double camera_pitch = 0.0;
double camera_yaw = 0.0;

double camera_roll_radians = 0.0;
double camera_pitch_radians = 0.0;
double camera_yaw_radians = 0.0;

double dtrRatio = (Math.PI / 180.0);

Vector3 axisX = new Vector3(1.0, 0.0, 0.0);
Vector3 axisY = new Vector3(0.0, 1.0, 0.0);
Vector3 axisZ = new Vector3(0.0, 0.0, 1.0);
Vector3 camPos = new Vector3(0.0, 800.0, 0.0);

double fps = 10.0;
int previous = 0;
double frameDuration = 1000 / fps;
double lag = 0.0;

double scale = 40.0;

Keyboard keyboard;
Mesh cubeMesh;
Mesh cubeFollower;

var targetRotation = 0;
var targetRotationOnMouseDown = 0;
var mouseX = 0;
var mouseXOnMouseDown = 0;
var windowHalfX = window.innerWidth / 2;
var windowHalfY = window.innerHeight / 2;


List<Vector3> vertices;
List<Vector3> normals;
List<Vector2> uvs;
List<double> indexes = new List<double>();

GeometryAttribute position;
GeometryAttribute normal;
GeometryAttribute uv;
GeometryAttribute color;
GeometryAttribute index;

BufferGeometry bufferGeo = new BufferGeometry();
Mesh bufferGeoMesh;

void main() {

     PathParser pp = new PathParser();
     pp.load('obj_test/textured_plane_triangle.obj').then((object) {
               
          vertices = pp.getVertices;
          normals = pp.getNormals;
          uvs = pp.getUVS;
          
     }).then((object) 
     {
          init();
          
          double r = 20.0;
          
          position = new GeometryAttribute.float32(vertices.length * 3, 3);
          normal = new GeometryAttribute.float32(normals.length * 3, 3);
          uv = new GeometryAttribute.float32(uvs.length * 2, 2);          
          color = new GeometryAttribute.float32(vertices.length * 3, 3);
          index = new GeometryAttribute.float32(6, 1);
          
//         print(vertices.length);
//         print("\n");
//         print(normals.length);
//         print("\n");
//         print(uvs.length);
         
          //Fill with data
          for(var i = 0; i < vertices.length; i++)
          {
               var x = vertices.elementAt(i).x;
               var y = vertices.elementAt(i).y;
               var z = vertices.elementAt(i).z;
               
               position.array[i * 3] = x;
               position.array[i * 3 + 1] = y;
               position.array[i * 3 + 2] = z;
               
               color.array[ i * 3 ] = ( x / r ) + 0.5;
               color.array[ i * 3 + 1 ] = ( y / r ) + 0.5;
               color.array[ i * 3 + 2 ] = ( z / r ) + 0.5;
          }
          
          for(var i = 0; i < normals.length; i++)
          {
               var x = normals.elementAt(i).x;
              var y = normals.elementAt(i).y;
              var z = normals.elementAt(i).z;
              
              normal.array[i * 3] = x;
              normal.array[i * 3 + 1] = y;
              normal.array[i * 3 + 2] = z;     
          }
          
          for(var i = 0; i < uvs.length; i++)
          {
               var u = uvs.elementAt(i).x;
               var t = uvs.elementAt(i).y;
               
               uv.array[i * 2] = u;
               uv.array[i * 2 + 1] = t;
          }
          
          print(position.array);
          print(normal.array);
          print(uv.array);
//          position.array[0] = 10.0;
//          position.array[1] = 0.0;
//          position.array[2] = -10.0;
//          
//          position.array[3] = 10.0;
//          position.array[4] = 0.0;
//          position.array[5] = 10.0;
//          
//          position.array[6] = -10.0;
//          position.array[7] = 0.0;
//          position.array[8] = -10.0;
//          
//          position.array[9] = -10.0;
//          position.array[10] = 0.0;
//          position.array[11] = 10.0;
//          
//          normal.array[0] = 0.0;
//          normal.array[1] = 1.0;
//          normal.array[2] = 0.0;
//          
//          uv.array[0] = 1.0;
//          uv.array[1] = 0.0;
//          uv.array[2] = 1.0;
//          uv.array[3] = 1.0;
//          uv.array[4] = 0.0;
//          uv.array[5] = 1.0;
//          uv.array[6] = 0.0;
//          uv.array[7] = 0.0;
          
           indexes.add(1.0);
           indexes.add(2.0);
           indexes.add(3.0);
           indexes.add(3.0);
           indexes.add(2.0);
           indexes.add(4.0);
           
           index.array[0] = 1.0;
           index.array[1] = 3.0;
           index.array[2] = 2.0;
           index.array[3] = 2.0;
           index.array[4] = 3.0;
           index.array[5] = 4.0;
          
          bufferGeo.attributes[GeometryAttribute.POSITION] = position;
          bufferGeo.attributes[GeometryAttribute.NORMAL] = normal;
          bufferGeo.attributes[GeometryAttribute.UV] = uv;
          bufferGeo.attributes[GeometryAttribute.COLOR] = color;
          bufferGeo.attributes[GeometryAttribute.INDEX] = index;
          
//          bufferGeo.computeBoundingSphere();
          bufferGeoMesh = new Mesh(bufferGeo, new MeshBasicMaterial(map: ImageUTILS.loadTexture('textures_test/crate.png')));
          
//          ParticleSystem ps = new ParticleSystem(bufferGeo);
          scene.add(bufferGeoMesh);
                    
          animate(0);
          
     });


}



void animate(num time) {

     window.requestAnimationFrame(animate);

     if (keyboard.isPressed(KeyCode.D)) {

          cubeMesh.rotation.y += 2.0 * Math.PI / 180.0;

     }

     if (keyboard.isPressed(KeyCode.A)) {
          cubeMesh.rotation.y -= 2.0 * Math.PI / 180.0;
     }
     
     bufferGeoMesh.rotation.y += (targetRotation - bufferGeoMesh.rotation.y) * 0.05;
     renderer.render(scene, camera);

}

Object3D dummy = new Object3D();

void loadPath() {

     Texture tex = ImageUTILS.loadTexture('textures/uvlayout.png');
     var loader = new OBJLoader();

     loader.load('obj/cube_model.obj').then((object) {

          object.children.forEach((e) {
               if (e is Mesh) {
                    ((e as Mesh).material as MeshLambertMaterial).map = tex;
               }
          });

          object.scale = new Vector3(scale, scale, scale);
          //object.position.y = 10.0;
//          scene.add(object);
          dummy = object;

          //makebuffer geometry object with objects vertices, colors, normals, uvs and so on
//          BufferGeometry bg = new BufferGeometry();
//          GeometryAttribute position = new GeometryAttribute.float32(object., 3);
//          print(object.geometry.vertices.length);
//          position.array = object.positionArray;
//          bg.attributes[GeometryAttribute.POSITION] = position;
//          bg.attributes[GeometryAttribute.NORMAL] = object.normalArray;
//          bg.attributes[GeometryAttribute.UV] = object.uvArray;
//          bg.attributes[GeometryAttribute.COLOR] = object.colorArray;
//


//          Mesh m = new Mesh(bg);
//          scene.add(m);


     });
}


double cubeSide = 30.0;

void init() {
     canvasContainer = new Element.tag('div');
     document.body.nodes.add(canvasContainer);

     scene = new Scene();
     keyboard = new Keyboard();

     camera = new PerspectiveCamera(45.0, window.innerWidth / window.innerHeight, 1.0, 2000.00);
     camera.position.setValues(3.0, 3.0, 3.0);
     camera.lookAt(new Vector3.zero());
     scene.add(camera);

     var directional = new DirectionalLight(0xffffff);
     directional.position.setValues(0.0, 0.0, 800.0);
     scene.add(directional);

     Texture tex = ImageUTILS.loadTexture('textures/crate.png');

     cubeMesh = new Mesh(new CubeGeometry(cubeSide, cubeSide, cubeSide), new MeshBasicMaterial(map: tex));
//     cubeFollower = new Mesh(new CubeGeometry(10.0, 10.0, 10.0), new MeshBasicMaterial(map: ImageUTILS.loadTexture( 'texture/crate.png')));
//     cubeFollower.position.setValues(50.0, 0.0, 0.0);
//     cubeMesh.add(cubeFollower);
     cubeMesh.material.side = DoubleSide;
//     scene.add(cubeMesh);

     Mesh sphere = new Mesh(new SphereGeometry(20.0, 30, 30), new MeshPhongMaterial(bumpMap: tex));
//     scene.add(sphere);


//     //Buffer Geometry
//     int particlesNr = 200;
//     BufferGeometry bg = new BufferGeometry();
//
//     GeometryAttribute positions = new GeometryAttribute.float32(particlesNr * 3, 3);
//     GeometryAttribute colors = new GeometryAttribute.float32(particlesNr * 3, 3);
////     GeometryAttribute size = new GeometryAttribute.float32(particlesNr, 1);
//
//     double r = 800.0;
//     Math.Random random = new Math.Random();
//     //Compute data
//     for (var i = 0; i < particlesNr; i++) {
//          var x = random.nextDouble() * r - r / 2;
//          var y = random.nextDouble() * r - r / 2;
//          var z = random.nextDouble() * r - r / 2;
//
//          positions.array[i * 3] = x;
//          positions.array[i * 3 + 1] = y;
//          positions.array[i * 3 + 2] = z;
//
//          //colors
//          colors.array[i * 3] = (x / r) + 0.5;
//          colors.array[i * 3 + 1] = (y / r) + 0.5;
//          colors.array[i * 3 + 2] = (z / r) + 0.5;
//     }
//
//     bg.attributes[GeometryAttribute.POSITION] = positions;
//     bg.attributes[GeometryAttribute.COLOR] = colors;
//     bg.computeBoundingSphere();

//
////     ParticleSystem ps = new ParticleSystem(bg);
////     scene.add(ps);
////     Mesh m = new Mesh(bg, new LineBasicMaterial(color: 0xff0000, vertexColors: VertexColors));
//     var m = new Mesh(bg, new LineBasicMaterial(color: 0xff0000));
////     scene.add(m);
//
////     loadPath();

     makeAxes();
     renderer = new WebGLRenderer(antialias: true);
     renderer.setSize(window.innerWidth, window.innerHeight);
     canvasContainer.nodes.add(renderer.domElement);
     renderer.domElement.addEventListener('mousedown', onDocumentMouseDown, false);
     renderer.domElement.addEventListener('touchstart', onDocumentTouchStart, false);
     renderer.domElement.addEventListener('touchmove', onDocumentTouchMove, false);
     window.addEventListener('resize', onWindowResize, false);

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
