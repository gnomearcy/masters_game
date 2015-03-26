import 'package:three/three.dart';
import 'package:vector_math/vector_math.dart' hide Ray;
import 'dart:html';
import 'dart:math' as Math;
import 'mojparser.dart';
import 'package:three/extras/image_utils.dart' as ImageUTILS;

import 'utilities/Keyboard.dart';

Scene scene;
PerspectiveCamera camera;
CameraHelper cameraHelper;
WebGLRenderer renderer;
Element container;

Vector3 cameraPosition = new Vector3(50.0, 50.0, 50.0);
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
DivElement log;
Mesh toHit;
Keyboard kb;
Mesh cube;

//ortho camera
OrthographicCamera orthoCamera;
double value = 150.0;
double left = -value;
double right = value;
double top = value / 2;
double bottom = -value / 2;
Vector3 cameraOrthoPosition = new Vector3(0.0, 100.0, 0.0);

List hitobjects = [];

int logcounter = 0;
Geometry testGeo;
Geometry testGeo2;
Mesh meshCustom1;
Mesh meshCustom2;

String customPath = 'obj_shaders_testing/cube_obj_custom.obj';
String customLayout = 'obj_shaders_testing/cube_obj_custom_layout.png';

Mesh firstMesh;
Mesh secondMesh;

List<Vector3> directions;

void main() {
  directions = new List<Vector3>();
  directions.add(new Vector3(0.0, 0.0, 1.0));
  directions.add(new Vector3(0.0, 0.0, -1.0));
  directions.add(new Vector3(1.0, 0.0, -1.0));
  directions.add(new Vector3(1.0, 0.0, 0.0));
  directions.add(new Vector3(1.0, 0.0, 1.0));
  directions.add(new Vector3(-1.0, 0.0, 1.0));
  directions.add(new Vector3(-1.0, 0.0, -1.0));
  directions.add(new Vector3(0.0, 0.0, 1.0));

  nowYouCanHitMe = true;
  init();
  animate(0);

  //apply global
  Matrix4 m = new Matrix4.identity();
  m.storage[12] = 50.0;

  Vector3 v =
      new Vector3(-4.530324935913086, -1.0669759511947632, 2.3987278938293457);

  print("MAAAAAAtrica: " + m.toString());
  print("VEEEEEEEEktor: " + v.toString());

  v.applyProjection(m);
  print("ASDASD: " + v.toString());
}

init() {
  scene = new Scene();
  container = document.createElement('div');
  document.body.append(container);
  camera =
      new PerspectiveCamera(cameraFov, cameraAspect, cameraNear, cameraFar);
  camera.position.setFrom(cameraPosition);
  camera.lookAt(scene.position);
  scene.add(camera);

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
  renderer.domElement.addEventListener(
      'touchstart', onDocumentTouchStart, false);
  renderer.domElement.addEventListener('touchmove', onDocumentTouchMove, false);
  window.addEventListener('resize', onWindowResize, false);

  btn = querySelector('#hit');
  log = querySelector('#log');
  kb = new Keyboard();

  double side = 5.0;
  double r = 5.0;
  //ADD OBJECTS TO SCENE HERE
  cube = new Mesh(new CubeGeometry(side, side, side, 5, 5, 5),
      new MeshBasicMaterial(color: 0x00ff00));
  cube =
      new Mesh(new SphereGeometry(r), new MeshBasicMaterial(color: 0x00ff00));
  cube.rotation.y = 30.0 * Math.PI / 180.0;
//     scene.add(cube);

  lineParent = new Object3D();
  scene.add(lineParent);

//     toHit = new Mesh(new CubeGeometry(side,side,side), new MeshBasicMaterial(color:0x123456));
//     toHit = new Mesh(new SphereGeometry(r), new MeshBasicMaterial(color: 0x123456));
//     toHit.position.x = 30.0;
//     scene.add(toHit);
//     hitobjects.add(toHit);

  //Add two hand made meshes to the scene and try to remove the second one by intersecting from the first one

//     secondMesh = new Mesh(new CubeGeometry(side, side, side), new MeshBasicMaterial(color: 0xff0000));
  secondMesh =
      new Mesh(new SphereGeometry(r), new MeshBasicMaterial(color: 0xff0000));
//     secondMesh.position.x = 50.0;
//     Matrix4 m = new Matrix4.identity();
//     m.storage[12] = 50.0;

//     m.translate(x)
//     secondMesh.position.x = 50.0; //visual moving to 50.0 on x
  secondMesh.matrixWorld.translate(50.0);
  secondMesh.geometry.applyMatrix(secondMesh.matrixWorld);
  secondMesh.position.applyProjection(secondMesh.matrixWorld);
//     scene.add(secondMesh);

  print(secondMesh.position);

  addLines();
//     Vector3 position = secondMesh.position.clone();
//
//     for(int i = 0; i < secondMesh.geometry.vertices.length; i++)
//     {
//          var local = secondMesh.geometry.vertices[i].clone();
//          var global = local.applyProjection(secondMesh.matrix);
//          var direction = global.sub(position);
//          var ray = new Ray(position, direction.clone());
//          var result = ray.intersectObjects(hitobjects);
//
//          if(result.length > 0)
//          {
//               window.alert("IMAM GA");
//          }
//
//     }

  Vector3 local = secondMesh.geometry.vertices[0];
  print("Local " + local.toString());
  print("Pozicija: " + secondMesh.position.toString());
  Matrix4 localMatrix = secondMesh.matrix;
  print("Matrica: " + localMatrix.toString());

  Vector3 global = local.clone();
  print("Global: " + global.toString());

  //mesh to be removed with the other mesh
//     firstMesh = new Mesh(new CubeGeometry(side, side, side), new MeshBasicMaterial(color: 0xfff100));
  firstMesh =
      new Mesh(new SphereGeometry(r), new MeshBasicMaterial(color: 0xfff100));
//     firstMesh.position.z = 20.0;
  firstMesh.matrixWorld.translate(0.0, 0.0, 20.0);
  firstMesh.geometry.applyMatrix(firstMesh.matrixWorld);
  scene.add(firstMesh);
  hitobjects.add(firstMesh);

  /*Vector3 pos = secondMesh.position.clone();
     int v = 0;
     
//     print("Position " + pos.toString());
     for(v; v < secondMesh.geometry.vertices.length; v++)
     {
//          print("${v} ----------------------------");

          var local = secondMesh.geometry.vertices[v].clone();
//          print("Local " + local.toString());
          
          var global = local.applyProjection(secondMesh.matrix);
          var direction = global.sub(secondMesh.position);
          var ray = new Ray(pos, direction.clone().normalize());
          var collisionResults = ray.intersectObjects(hitobjects);
          
          if(collisionResults.length > 0 && collisionResults[0].distance < direction.length)
          {
               if(nowYouCanHitMe)
               {
                    btn.value = "HIT!";
                    logg("Kaj je ovo: " + collisionResults[0].object.runtimeType.toString());
//                    print("Distance: " + collisionResults[0].distance.toString());
//                    print("Direction length " + direction.length.toString());                             
                    
//                    scene.remove(collisionResults[0].object);
//                    hitobjects.remove(collisionResults[0].object); 
               }                    
          }          
          else
          {
               btn.value = "---";
          }
     }  */
//     printCustom();
}
Object3D lineParent;
void addLines() {
  //Add lines
  scene.remove(lineParent);
  Geometry g1;
  lineParent = new Object3D();

  for (int i = 0; i < secondMesh.geometry.vertices.length; i++) {
    g1 = new Geometry();
    g1.vertices.add(new Vector3.zero());
    var local = secondMesh.geometry.vertices[i].clone();
//    print("LOkalni " + i.toString() + local.toString());
    g1.vertices.add(local);

    Line l = new Line(g1, new LineBasicMaterial(color: 0xff0000));
    lineParent.add(l);
  }

  scene.add(lineParent);
}

void update() {
//     Vector3 position = secondMesh.position.clone();
////          position.applyProjection(secondMesh.matrixWorld);
//
//
//        for(int i = 0; i < directions.length; i++)
//        {
////        var local = secondMesh.geometry.vertices[i].clone();
////        var global = local.applyProjection(secondMesh.matrixWorld);
////        var direction = global.sub(position);
////        var ray = new Ray(position, direction.clone());
////        var result = ray.intersectObjects(hitobjects);
////
////        var a = position + directions[i];
//
//             var ray = new Ray(position, directions[i]);
//             var result = ray.intersectObjects(hitobjects);
//
//             if(result.length > 0)
//             {
//                  window.alert("IMAM GA");
//             }
//        }
//     Vector3 pos = cube.position.clone();
//
//     int v = 0;
//     for(v; v < cube.geometry.vertices.length; v++)
//     {
//          var local = cube.geometry.vertices[v].clone();
//          var global = local.applyProjection(cube.matrix);
//          var direction = global.sub(cube.position);
//          var ray = new Ray(pos, direction.clone().normalize());
//          var collisionResults = ray.intersectObjects(hitobjects);
//
//          if(collisionResults.length > 0 && collisionResults[0].distance < direction.length)
////          if(collisionResults.length > 0 )
//          {
//               btn.value = "HIT!";
////               hitobjects.remove(collisionResults[0].object);
////               scene.remove(collisionResults[0].object);
//          }
//          else btn.value = "---";
//     }

//     if(nowYouCanHitMe == true)
//     {
//          logg("trueee");
//     }
//     else logg("falseee");

//     Vector3 pos = secondMesh.position.clone();
////     pos.applyProjection(secondMesh.matrixWorld);
//     int v = 0;
//
////     print("Position " + pos.toString());
//     for(v; v < secondMesh.geometry.vertices.length; v++)
//     {
////          print("${v} ----------------------------");
//
//          var local = secondMesh.geometry.vertices[v].clone();
////          print("Local " + local.toString());
//
//          var global = local.applyProjection(secondMesh.matrix);
//          var direction = global.sub(secondMesh.position);
//          var ray = new Ray(pos, direction.clone().normalize());
//          var collisionResults = ray.intersectObjects(hitobjects);
//
//          if(collisionResults.length > 0 && collisionResults[0].distance < direction.length)
//          {
//               if(nowYouCanHitMe)
//               {
//                    btn.value = "HIT!";
//                    logg("Kaj je ovo: " + collisionResults[0].object.runtimeType.toString());
////                    print("Distance: " + collisionResults[0].distance.toString());
////                    print("Direction length " + direction.length.toString());
//
//                    scene.remove(collisionResults[0].object);
//                    hitobjects.remove(collisionResults[0].object);
//               }
//          }
//          else
//          {
//               btn.value = "---";
//          }
//     }
//

//     Vector3 position = secondMesh.position.clone();
//
//    for(int i = 0; i < secondMesh.geometry.vertices.length; i++)
//    {
//         var local = secondMesh.geometry.vertices[i].clone();
//         var global = local.applyProjection(secondMesh.matrixWorld);
//         var direction = global.sub(position);
//         var ray = new Ray(position, direction.clone());
//         var result = ray.intersectObjects(hitobjects);
//
//         if(result.length > 0)
//         {
//              window.alert("IMAM GA");
//         }
//    }

}

bool nowYouCanHitMe = false;

printCustom() {

//     MojParser mp = new MojParser();
//     Texture tex = ImageUTILS.loadTexture(customLayout);
//
//     mp.load(customPath).then((object)
//     {
//          MeshBasicMaterial matBasic = new MeshBasicMaterial(color: 0xff0000);
//          MeshLambertMaterial matLambert = new MeshLambertMaterial(color: 0xff0000);
//          MeshBasicMaterial matBasicTex = new MeshBasicMaterial(map: tex);
//          MeshLambertMaterial matLambertTex = new MeshLambertMaterial(map: tex);
//
//          testGeo.vertices = mp.vertices;
//          testGeo.faceUvs = mp.faceUvs;
//          testGeo.normals = mp.normals;
//          testGeo.faces = mp.faces;
//          testGeo.faceVertexUvs = mp.faceVertexUvs;
//
//          testGeo.faces.forEach((e) {
//               (e as Face3).normal = (e as Face3).vertexNormals.first;
//          });
//
//          meshCustom1 = new Mesh(testGeo);
////          meshCustom1.scale.scale(10.0);
//          meshCustom1.material = matBasicTex;
//          meshCustom1.position.z = 20.0;
//          scene.add(meshCustom1);
//          hitobjects.add(meshCustom1);
//
////          testGeo.vertices.forEach((e)
////                    {
////                        testGeo2.vertices.add((e as Vector3).clone());
////                    });
////
////          testGeo.faceUvs.forEach((e)
////                    {
////                        testGeo2.faceUvs.add((e as Face).clone());
////                    });
////
////          testGeo.vertices.forEach((e)
////                    {
////                        testGeo2.vertices.add((e as Vector3).clone());
////                    });
//
//
//          testGeo.faces.forEach((e) {
//                         testGeo2.faces.add(e.clone());
//          });
//
//          testGeo.vertices.forEach((e) {
//               testGeo2.vertices.add(e.clone());
//          });
//
//          testGeo.normals.forEach((e) {
//               testGeo2.normals.add((e as Vector3).clone());
//          });
//
//          testGeo.faceUvs.forEach((e) {
//               testGeo2.faceUvs.add((e as UV).clone());
//          });
//
//          testGeo.faceVertexUvs.forEach((faceVertexUvs) {
//
//               faceVertexUvs.forEach((faceVertexUv) {
//                    testGeo2.faceVertexUvs[0].add(faceVertexUv);
//               });
//          });
//
//
//          meshCustom2 = new Mesh(testGeo2);
////          meshCustom2.scale.scale(10.0);
//          meshCustom2.position.x = 50.0;
//          meshCustom2.material = matBasicTex;
//          scene.add(meshCustom2);
//
//          //Info printing
//          logg("Vertices: " + meshCustom2.geometry.vertices.length.toString());
//          logg("Faces: " + meshCustom2.geometry.faces.length.toString());
//          logg("Normals: " + meshCustom2.geometry.normals.length.toString());
//          logg("Face UVs: " + meshCustom2.geometry.faceUvs.length.toString());
//          logg("Position: " + meshCustom2.position.toString());
//          logg("Matrix: " + meshCustom2.matrix.toString());
//          logg("MatrixWorld: " + meshCustom2.matrixWorld.toString());
//
//          scene.children.forEach((e) {
//                 logg(e.runtimeType.toString());
//              });
//
//              logg("broj djece " + scene.children.length.toString());
//
//
//
////          //GLOW NA CUSTOM GEOMETRIJU
////          uniformsCustom = new Map<String, Uniform>();
////          Uniform c = new Uniform.float(0.0);
////          Uniform p = new Uniform.float(1.0);
////          Uniform glowColor = new Uniform.color(0x00ff0f);
////          Uniform viewVector = new Uniform.vector3(camera.position.x, camera.position.y, camera.position.z);
////
////          uniformsCustom["c"] = c;
////          uniformsCustom["p"] = p;
////          uniformsCustom["glowColor"] = glowColor;
////          uniformsCustom["viewVector"] = viewVector;
////
////          shaderCustom = new ShaderMaterial(uniforms: uniformsCustom, vertexShader: glowVertex, fragmentShader: glowFragment, side: FrontSide, blending: AdditiveBlending, transparent: true);
////
////          meshCustom2 = new Mesh(testGeo2);
////          meshCustom2.scale.x = 43.0;
////          meshCustom2.scale.y = 39.5;
////          meshCustom2.scale.z = 50.0;
////          meshCustom2.material = shaderCustom;
////          print("${meshCustom2.position}");
////          planeContainer.add(meshCustom2);
//     });

  MojParser mp = new MojParser();
  Texture tex = ImageUTILS.loadTexture(customLayout);
  MeshBasicMaterial matBasicTex = new MeshBasicMaterial(map: tex);

  mp.load(customPath).then((obj) {
    mp.vertices.forEach((e) {
      print(e);
    });
    //load first mesh
    testGeo = new Geometry();
    testGeo.vertices = mp.vertices;
    testGeo.faceUvs = mp.faceUvs;
    testGeo.normals = mp.normals;
    testGeo.faces = mp.faces;
    testGeo.faceVertexUvs = mp.faceVertexUvs;

    testGeo.faces.forEach((e) {
      (e as Face3).normal = (e as Face3).vertexNormals.first;
    });

    meshCustom1 = new Mesh(testGeo);
//          meshCustom1.scale.scale(10.0);
    meshCustom1.material = matBasicTex;
    meshCustom1.position.z = 20.0;
    scene.add(meshCustom1);
//          hitobjects.add(meshCustom1);

    logg("broj djece " + scene.children.length.toString());

//         logg("zovem animate!!");
//         nowYouCanHitMe = true;
//         animate(0);

  }).then((obj) {
    //load second mesh
    testGeo2 = new Geometry();

    testGeo.faces.forEach((e) {
      testGeo2.faces.add(e.clone());
    });

    testGeo.vertices.forEach((e) {
      testGeo2.vertices.add(e.clone());
    });

    testGeo.normals.forEach((e) {
      testGeo2.normals.add((e as Vector3).clone());
    });

    testGeo.faceUvs.forEach((e) {
      testGeo2.faceUvs.add((e as UV).clone());
    });

    testGeo.faceVertexUvs.forEach((faceVertexUvs) {
      faceVertexUvs.forEach((faceVertexUv) {
//                    logg(faceVertexUv.runtimeType.toString()); //JSArray when compiled to JS
        print(faceVertexUv.runtimeType.toString());
        print(faceVertexUv[0].runtimeType.toString());
        testGeo2.faceVertexUvs[0].add(faceVertexUv); //
      });
    });

    testGeo2.faces.forEach((e) {
      (e as Face3).normal = (e as Face3).vertexNormals.first;
    });

    meshCustom2 = new Mesh(testGeo2);
//          meshCustom2.scale.scale(10.0);
    meshCustom2.position.x = 50.0;
    meshCustom2.material = matBasicTex;
    scene.add(meshCustom2);
  }).whenComplete(() {
    hitobjects.add(meshCustom1);
    Object3D mmm = hitobjects[0];
    print(mmm.geometry.vertices.length);
    print(mmm.position);

    logg("zovem animate!!");
    logg("velicina: " + hitobjects.length.toString());
    nowYouCanHitMe = true;
    animate(0);
  });

//          MojParser mp = new MojParser();
//
//          Texture tex = ImageUTILS.loadTexture(customLayout);
//
//          mp.load(customPath).whenComplete(()
//          {
//               MeshBasicMaterial matBasicTex = new MeshBasicMaterial(map: tex);
////
////               //Logiraj parsirane podatke - provjera da su vidljivi ovdje
////               logg("Vertices: " + mp.vertices.length.toString());
////               logg("Faces: " + mp.faces.length.toString());
////               logg("Normals: " + mp.normals.length.toString());
////               logg("Face UVs: " + mp.faceUvs.length.toString());
////
////               //Kloniraj njegove podatke
////               Geometry geo = new Geometry();
////
////               mp.faces.forEach((e) {
////                    geo.faces.add(e.clone()); //todo valjda je tri?
////               });
////
////               mp.vertices.forEach((e) {
////                    geo.vertices.add((e as Vector3).clone());
////               });
////
////               mp.normals.forEach((e) {
////                    geo.normals.add((e as Vector3).clone());
////               });
////
////               mp.faceUvs.forEach((e) {
////                    geo.faceUvs.add((e as UV).clone());
////               });
////
////               mp.faceVertexUvs.forEach((faceVertexUvs) {
////
////                    faceVertexUvs.forEach((faceVertexUv) {
////                         geo.faceVertexUvs[0].add(faceVertexUv);
////                    });
////               });
////
////               //Azuriranje normala?
////               geo.faces.forEach((e) {
////                    (e as Face3).normal = (e as Face3).vertexNormals.first;
////               });
////
////               Mesh m = new Mesh(geo, matBasicTex);
//////               Mesh m = new Mesh(geo);
//////               m.material = matBasicTex;
////               m.position.y = 20.0;
////               scene.add(m);
//
//          });
}

void logg(String input) {
  logcounter++;
  String content = log.innerHtml.toString();
  String toAdd = '<br>' + logcounter.toString() + ". " + input;
  log.innerHtml = content + toAdd;
}

bool showOnce = true;

//void update()
//{
// /*// collision detection:
//// determines if any of the rays from the cube's origin to each vertex
//// intersects any face of a mesh in the array of target meshes
//// for increased collision accuracy, add more vertices to the cube;
//// for example, new THREE.CubeGeometry( 64, 64, 64, 8, 8, 8, wireMaterial )
//// HOWEVER: when the origin of the ray is within the target mesh, collisions do not occur
//var originPoint = MovingCube.position.clone();
//clearText();
//for (var vertexIndex = 0; vertexIndex < MovingCube.geometry.vertices.length; vertexIndex++)
//{
//var localVertex = MovingCube.geometry.vertices[vertexIndex].clone();
//var globalVertex = localVertex.applyMatrix4( MovingCube.matrix );
//var directionVector = globalVertex.sub( MovingCube.position );
//var ray = new THREE.Raycaster( originPoint, directionVector.clone().normalize() );
//var collisionResults = ray.intersectObjects( collidableMeshList );
//if ( collisionResults.length > 0 && collisionResults[0].distance < directionVector.length() )
//appendText(" Hit ");
//} */
//
////     Vector3 pos = cube.position.clone();
////
////     int v = 0;
////     for(v; v < cube.geometry.vertices.length; v++)
////     {
////          var local = cube.geometry.vertices[v].clone();
////          var global = local.applyProjection(cube.matrix);
////          var direction = global.sub(cube.position);
////          var ray = new Ray(pos, direction.clone().normalize());
////          var collisionResults = ray.intersectObjects(hitobjects);
////
////          if(collisionResults.length > 0 && collisionResults[0].distance < direction.length)
//////          if(collisionResults.length > 0 )
////          {
////               btn.value = "HIT!";
//////               hitobjects.remove(collisionResults[0].object);
//////               scene.remove(collisionResults[0].object);
////          }
////          else btn.value = "---";
////     }
//
//     Vector3 pos = meshCustom2.position.clone();
////     if(nowYouCanHitMe == true)
////     {
////          logg("trueee");
////     }
////     else logg("falseee");
//
//     int v = 0;
//
//
//
//     if(showOnce)
//     {
//          print("Position " + pos.toString());
//          for(v; v < meshCustom2.geometry.vertices.length; v++)
//          {
//               print("${v} ----------------------------");
//
//               var local = meshCustom2.geometry.vertices[v].clone();
//               print("Local " + local.toString());
//
////               meshCustom2.matrix.storage[12] = pos.x;
////               meshCustom2.matrix.storage[13] = pos.y;
////               meshCustom2.matrix.storage[14] = pos.z;
//
//               var global = local.applyProjection(meshCustom2.matrix);
//               var direction = global.sub(meshCustom2.position);
//               var ray = new Ray(pos, direction.clone().normalize());
//               var collisionResults = ray.intersectObjects(hitobjects);
//
//               print("Global " + global.toString());
//               print("Matrix " + meshCustom2.matrix.toString());
//               print("Direction " + direction.toString());
//
//               print("Broj: " + collisionResults.length.toString());
//               if(collisionResults.length > 0 && collisionResults[0].distance < direction.length)
////               if(collisionResults.length > 0 && collisionResults[0].distance < local.length)
//
////          if(collisionResults.length > 0)
//               {
//                    if(nowYouCanHitMe)
//                    {
//                         btn.value = "HIT!";
//                         logg("Kaj je ovo: " + collisionResults[0].object.runtimeType.toString());
//                         print("Distance: " + collisionResults[0].distance.toString());
//                         print("Direction length " + direction.length.toString());
////                    Mesh m = collisionResults[0].object;
////                    logg(">>>>>>>>>><<<<<<<<<<<<<<");
////                    logg("Vertices: " + m.geometry.vertices.length.toString());
////                    logg("Faces: " + m.geometry.faces.length.toString());
////                    logg("Normals: " + m.geometry.normals.length.toString());
////                    logg("Face UVs: " + m.geometry.faceUvs.length.toString());
////                    logg("Position: " + m.position.toString());
////                    logg("Matrix: " + m.matrix.toString());
////                    logg("MatrixWorld: " + m.matrixWorld.toString());
//
//                         scene.remove(collisionResults[0].object);
//                         hitobjects.remove(collisionResults[0].object);
//                    }
//               }
//               else
//               {
////                    showOnce = !showOnce;
//                    btn.value = "---";
//               }
//          }
//
//          showOnce = false;
//     }
//
//}

void generateRandom() {
  int nr = 10;

  Math.Random rnd = new Math.Random(new DateTime.now().millisecondsSinceEpoch);
  Vector3 pos;
  Mesh obs;
  double side = 5.0;
  double scale = 70.0;

  for (int i = 0; i < nr; i++) {
    int degree = rnd.nextInt(360);

    double xpos = Math.cos(degree);
    double zpos = Math.sin(degree);

    pos = new Vector3(xpos, 0.0, zpos);
    pos.scale(scale);

    obs = new Mesh(new CubeGeometry(side, side, side),
        new MeshBasicMaterial(color: 0xFF3456));
    obs.position.setFrom(pos);
    hitobjects.add(obs);
    scene.add(obs);
  }
}

double factor = 0.4;

render() {
  //WRITE ANIMATION LOGIC HERE
  if (kb.isPressed(KeyCode.S)) {
//          secondMesh.position.x += factor;
    var pos = secondMesh.position;
    pos.x += factor;
//          secondMesh.translateX(factor);
    secondMesh.matrixWorld.translate(pos.x, pos.y, pos.z);
    secondMesh.geometry.applyMatrix(secondMesh.matrixWorld);
    addLines();
  }

  if (kb.isPressed(KeyCode.W)) {
////          secondMesh.position.x -= factor;
//          secondMesh.translateX(-factor);
//
//          addLines();
    var pos = secondMesh.position;
    pos.x -= factor;
//          secondMesh.translateX(factor);
    secondMesh.matrixWorld.translate(pos.x, pos.y, pos.z);
    secondMesh.geometry.applyMatrix(secondMesh.matrixWorld);
    addLines();
  }

  if (kb.isPressed(KeyCode.A)) {
////          secondMesh.position.z += factor;
//          secondMesh.translateZ(factor);
//
//          addLines();
    var pos = secondMesh.position;
    pos.z += factor;
//          secondMesh.translateX(factor);
    secondMesh.matrixWorld.translate(pos.x, pos.y, pos.z);
    secondMesh.geometry.applyMatrix(secondMesh.matrixWorld);
    addLines();
  }

  if (kb.isPressed(KeyCode.D)) {
////          secondMesh.position.z -= factor;
//          secondMesh.translateZ(-factor);
//
//          addLines();
    var pos = secondMesh.position;
    pos.z -= factor;
//          secondMesh.translateX(factor);
    secondMesh.matrixWorld.translate(pos.x, pos.y, pos.z);
    secondMesh.geometry.applyMatrix(secondMesh.matrixWorld);
    addLines();
  }

  if (kb.isPressed(KeyCode.Q)) {
////          secondMesh.position.y += factor;
//          secondMesh.translateY(factor);
//
//          addLines();
    var pos = secondMesh.position;
    pos.y += factor;
//          secondMesh.translateX(factor);
    secondMesh.matrixWorld.translate(pos.x, pos.y, pos.z);
    secondMesh.geometry.applyMatrix(secondMesh.matrixWorld);
    addLines();
  }

  if (kb.isPressed(KeyCode.E)) {
////          secondMesh.position.y -= factor;
//          secondMesh.translateY(-factor);
//
//          addLines();
    var pos = secondMesh.position;
    pos.y -= factor;
//          secondMesh.translateX(factor);
    secondMesh.matrixWorld.translate(pos.x, pos.y, pos.z);
    secondMesh.geometry.applyMatrix(secondMesh.matrixWorld);
    addLines();
  }
}

animate(num time) {
  update();
  render();
  renderer.render(scene, camera);
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
