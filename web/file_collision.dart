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

Vector3 cameraPosition = new Vector3(0.0, 100.0, 0.0);
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
BBHelper bbh;

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

String customPath = 'obj_shaders_testing/score_cell_obj_smooth_flipped.obj';
String customLayout = 'obj_shaders_testing/score_cell_layout1test2.jpg';

Mesh firstMesh;
Mesh secondMesh;

List<Vector3> directions;
MojParser mp;
double factor = 0.4;
bool nowYouCanHitMe = false;

void main() {
  nowYouCanHitMe = true;

  mp = new MojParser();
//  init();
//  animate(0);

//  printCustom();

  bbTesting();
  
}

bbTesting() {
  init();

  animate(0);
}

Geometry instantiateGeo() {
  Geometry geo = new Geometry();

  mp.faces.forEach((e) {
    geo.faces.add(e.clone());
  });

  mp.vertices.forEach((e) {
    geo.vertices.add(e.clone());
  });

  mp.normals.forEach((e) {
    geo.normals.add((e as Vector3).clone());
  });

  mp.faceUvs.forEach((e) {
    geo.faceUvs.add(e);
  });

  mp.faceVertexUvs.forEach((faceVertexUvs) {
    faceVertexUvs.forEach((faceVertexUv) {
      geo.faceVertexUvs[0].add(faceVertexUv);
    });
  });

  geo.faces.forEach((e) {
    (e as Face3).normal = (e as Face3).vertexNormals.first;
  });

  return geo;
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
  bbh = new BBHelper();

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

  //Add two hand made meshes to the scene and try to remove the second one by intersecting from the first one

    secondMesh = new Mesh(new CubeGeometry(side * 2.0, side, side), new MeshBasicMaterial(color: 0xff0000));
//  secondMesh = new Mesh(new SphereGeometry(r), new MeshBasicMaterial(color: 0xffaa00, wireframe: true);
  secondMesh.position.x = 50.0;
  secondMesh.geometry.boundingBox = new BoundingBox.fromObject(secondMesh);
  //scale the bounding box
//  secondMesh.geometry.boundingBox.
  secondMesh.add(bbh.outline(secondMesh));
  scene.add(secondMesh);
  
//  Vector3 local = secondMesh.geometry.vertices[0];
//  print("Local " + local.toString());
//  print("Pozicija: " + secondMesh.position.toString());
//  Matrix4 worldMatrix = secondMesh.matrixWorld;
//  print("Matrica (world): " + worldMatrix.toString());
//
//   firstMesh = new Mesh(new CubeGeometry(side, side, side), new MeshBasicMaterial(color: 0xff129A));
  firstMesh = new Mesh(new SphereGeometry(r), new MeshBasicMaterial(color: 0xfff100));
  firstMesh.position.z = 20.0;
//  firstMesh.updateMatrixWorld();
//  firstMesh.add(bbh.outline(firstMesh));
  firstMesh.geometry.boundingBox = new BoundingBox.fromObject(firstMesh);
  Vector3 min = firstMesh.geometry.boundingBox.min;
  Vector3 max = firstMesh.geometry.boundingBox.max;
  
  
  double faktor = 2.0;
  (min as Vector3).setFrom(new Vector3.zero());
  
  print("Min poslije: " + firstMesh.geometry.boundingBox.min.toString());
  print("Max poslije: " + firstMesh.geometry.boundingBox.max.toString());
//  min.scale(faktor);
//  max.scale(faktor);
  scene.add(firstMesh);
//  firstMesh.geometry.boundingBox.applyMatrix4(firstMesh.matrixWorld);
//  hitobjects.addObject(firstMesh);

//  printCustom();
//  addLines();

//  scene.updateMatrixWorld(force: true);
}

updateKeyboard() {
  //WRITE ANIMATION LOGIC HERE
  if (kb.isPressed(KeyCode.S)) {
    secondMesh.position.x += factor;
  }

  if (kb.isPressed(KeyCode.W)) {
    secondMesh.position.x -= factor;
  }

  if (kb.isPressed(KeyCode.A)) {
    secondMesh.position.z += factor;
  }

  if (kb.isPressed(KeyCode.D)) {
    secondMesh.position.z -= factor;
  }

  if (kb.isPressed(KeyCode.Q)) {
    secondMesh.position.y += factor;
  }

  if (kb.isPressed(KeyCode.E)) {
    secondMesh.position.y -= factor;
  }
  
  //Rotation
  if (kb.isPressed(KeyCode.R)) {
      secondMesh.rotation.y += 5.0 * Math.PI / 180.0;
    }
  
  if (kb.isPressed(KeyCode.F)) {
      secondMesh.rotation.y -= 5.0 * Math.PI / 180.0;
    }
  
//  secondMesh.matrixWorldNeedsUpdate = true;
//  secondMesh.updateMatrixWorld(force: true);
//  secondMesh.geometry.boundingBox.applyMatrix4(secondMesh.matrixWorld);
  
  scene.removeObject(secondMesh.children.elementAt(0));
  secondMesh.children.removeAt(0);
  
  secondMesh.geometry.boundingBox = new BoundingBox.fromObject(secondMesh);
  secondMesh.add(bbh.outline(secondMesh)); 
//  print(secondMesh.geometry.boundingBox.min);
//  print(secondMesh.children.length);  
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
//    g1.vertices.add(secondMesh.position);
    var local = secondMesh.geometry.vertices[i].clone();
//    print("LOkalni " + i.toString() + local.toString());
    local.applyProjection(secondMesh.matrixWorld);
    g1.vertices.add(local);

    Line l = new Line(g1, new LineBasicMaterial(color: 0xff0000));
    lineParent.add(l);
  }

  scene.add(lineParent);
}

void update() {
//    Vector3 position = secondMesh.position.clone();
//
//    for(int i = 0; i < secondMesh.geometry.vertices.length; i++)
//    {

//         var local = secondMesh.geometry.vertices[i].clone();
//         var global = local.applyProjection(secondMesh.matrixWorld);
//         var direction = global.sub(position);
//         var ray = new Ray(position, direction.clone());
//         var result = ray.intersectObjects(hitobjects);
//
//         if(result.length > 0 && result[0].distance < direction.length)
////         if(result.length > 0)
//         {
//              window.alert("IMAM GA");
//              scene.remove(result[0].object);
//              hitobjects.remove(result[0].object);
//         }
//    }

//  for(int i = 0; i < hitobjects.length; i++)
//  {
//    Mesh hit = hitobjects[i];
//    if(hit.geometry.boundingBox.isIntersectionBox(secondMesh.geometry.boundingBox))
//    {
//      window.alert("hej");
//    }
//  }

  /**BoundingBox collision Detection*/
  if(firstMesh.geometry.boundingBox.isIntersectionBox(secondMesh.geometry.boundingBox))
  {
//      window.alert("hej");
      btn.value = "HIT!";
  }
  else
    btn.value = "-----";
}

printCustom() {
  Texture tex = ImageUTILS.loadTexture(customLayout);

  mp.load(customPath).then((object) {
    init();

    MeshBasicMaterial matBasicTex = new MeshBasicMaterial(map: tex);

    secondMesh = new Mesh(instantiateGeo());
    secondMesh.position.x = 50.0;
    secondMesh.scale.scale(3.0);
    secondMesh.material = matBasicTex;
    secondMesh.geometry.computeBoundingBox();
    secondMesh.updateMatrixWorld();

    scene.add(secondMesh);

    generateRandom(matBasicTex);

    animate(0);
  });
}

void logg(String input) {
  logcounter++;
  String content = log.innerHtml.toString();
  String toAdd = '<br>' + logcounter.toString() + ". " + input;
  log.innerHtml = content + toAdd;
}

void generateRandom(MeshBasicMaterial mat) {
  int nr = 10;

  Math.Random rnd = new Math.Random(new DateTime.now().millisecondsSinceEpoch);
  Vector3 pos;
  Mesh obs;
  double posscale = 70.0;
  double objscale = 2.0;

  for (int i = 0; i < nr; i++) {
    int degree = rnd.nextInt(360);

    double xpos = Math.cos(degree);
    double zpos = Math.sin(degree);

    pos = new Vector3(xpos, 0.0, zpos);
    pos.scale(posscale);

    obs = new Mesh(instantiateGeo(), mat);
    obs.position.setFrom(pos);
    obs.scale.scale(objscale);
    obs.geometry.computeBoundingBox();
    obs.updateMatrixWorld();
    hitobjects.add(obs);
    scene.add(obs);
  }
}

animate(num time) {
  renderer.render(scene, orthoCamera);
  updateKeyboard();
  update();
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

class BBHelper
{
  dynamic outline(Mesh mesh)
  {
    if(mesh.geometry.boundingBox == null)
      mesh.geometry.computeBoundingBox();
    
//    print(mesh.geometry.boundingBox.size);
    double sidex = mesh.geometry.boundingBox.size.x;
    double sidey = mesh.geometry.boundingBox.size.y;
    double sidez = mesh.geometry.boundingBox.size.z;

    CubeGeometry cube = new CubeGeometry(sidex, sidey, sidez);
    Mesh cubeMesh = new Mesh(cube);
    return cubeMesh;
  }
}
