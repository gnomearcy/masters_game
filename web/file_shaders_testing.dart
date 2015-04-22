import 'package:three/three.dart';
import 'package:vector_math/vector_math.dart';
import 'dart:html';
import 'dart:math' as Math;
import 'package:three/extras/image_utils.dart' as ImageUTILS;
import 'file_shaders.dart';
import 'package:three/extras/shaders/shaders.dart';
import 'package:datgui/datgui.dart';
import 'dart:async';
import 'mojparser.dart';

Scene scene;
PerspectiveCamera camera;
CameraHelper cameraHelper;
WebGLRenderer renderer;
Element container;

Vector3 cameraPosition = new Vector3(0.0, 0.0, 300.0);
//Vector3 cameraPosition = new Vector3(100.0, 100.0, 400.0);
double cameraFov = 45.0;
double cameraNear = 1.0;
double cameraFar = 20000.0;
double cameraAspect = window.innerWidth / window.innerHeight;

var targetRotation = 0;
var targetRotationOnMouseDown = 0;
var mouseX = 0;
var mouseXOnMouseDown = 0;
var windowHalfX = window.innerWidth / 2;
var windowHalfY = window.innerHeight / 2;


Object3D scoreCell;
Object3D planeContainer;
InputElement sliderC;
InputElement sliderP;
SpanElement sliderCtext;
SpanElement sliderPtext;
RadioButtonInputElement rbBackSide;
RadioButtonInputElement rbFrontSide;

Mesh moonGlow1;
Mesh moonGlow2;
Mesh meshCustom1;
Mesh meshCustom2;
ShaderMaterial shaderGlow;
ShaderMaterial shaderCustom;
Map<String, Uniform> uniformsGlow;
Map<String, Uniform> uniformsCustom;

Geometry testGeo = new Geometry();
Geometry testGeo2 = new Geometry();

bool usingCustom = false;

void main() {

     init();
     animate(0);
}

init() {
     scene = new Scene();
     container = document.createElement('div');
     document.body.append(container);
     camera = new PerspectiveCamera(cameraFov, cameraAspect, cameraNear, cameraFar);
     camera.position.setFrom(cameraPosition);
     camera.lookAt(scene.position);
//     scene.add(camera);

     makeAxes();
     renderer = new WebGLRenderer(antialias: true);
     renderer.setClearColor(new Color(0xf0f0f0), 1.0);
     renderer.setSize(window.innerWidth, window.innerHeight);
     container.append(renderer.domElement);
     renderer.domElement.addEventListener('mousedown', onDocumentMouseDown, false);
     renderer.domElement.addEventListener('touchstart', onDocumentTouchStart, false);
     renderer.domElement.addEventListener('touchmove', onDocumentTouchMove, false);
     window.addEventListener('resize', onWindowResize, false);

     planeContainer = new Object3D();
     //comment next line for object rotation, otherwise camera follows object
     planeContainer.add(camera);
     scoreCell = new Object3D();

     scene.add(planeContainer);


     addLight();
     printCustom();
//     addGlowSphere();

}

printCustom() 
{
     usingCustom = true;

     MojParser mp = new MojParser();
     Texture tex = ImageUTILS.loadTexture('obj_shaders_testing/score_cell_layout1test2.jpg');

     mp.load('obj_shaders_testing/score_cell_obj_smooth_flipped.obj').then((object) {
          //Materials
          List materials = [];
          materials.add(new MeshBasicMaterial(map: ImageUTILS.loadTexture('textures_shaders_testing/dawnmountain-xneg.png')));
          materials.add(new MeshBasicMaterial(map: ImageUTILS.loadTexture('textures_shaders_testing/dawnmountain-xpos.png')));
          materials.add(new MeshBasicMaterial(map: ImageUTILS.loadTexture('textures_shaders_testing/dawnmountain-yneg.png')));
          materials.add(new MeshBasicMaterial(map: ImageUTILS.loadTexture('textures_shaders_testing/dawnmountain-ypos.png')));
          materials.add(new MeshBasicMaterial(map: ImageUTILS.loadTexture('textures_shaders_testing/dawnmountain-zneg.png')));
          materials.add(new MeshBasicMaterial(map: ImageUTILS.loadTexture('textures_shaders_testing/dawnmountain-zpos.png')));

          MeshFaceMaterial matFace = new MeshFaceMaterial(materials);
          MeshBasicMaterial matBasic = new MeshBasicMaterial(color: 0xff0000);
          MeshLambertMaterial matLambert = new MeshLambertMaterial(color: 0xff0000);
          MeshBasicMaterial matBasicTex = new MeshBasicMaterial(map: tex);
          MeshLambertMaterial matLambertTex = new MeshLambertMaterial(map: tex);

          testGeo.vertices = mp.vertices;
          testGeo.faceUvs = mp.faceUvs;
          testGeo.normals = mp.normals;
          testGeo.faces = mp.faces;
          testGeo.faceVertexUvs = mp.faceVertexUvs;

          print((mp.vertices as List).length);
          print((mp.faceUvs as List).length);
          print((mp.normals as List).length);
          print((mp.faces as List).length);

          testGeo.faces.forEach((e) {
               (e as Face3).normal = (e as Face3).vertexNormals.first;
//                                                (e as Face3).materialIndex = 0;
          });
          //KLONIRANJE GEOMETRIJE???

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
                    testGeo2.faceVertexUvs[0].add(faceVertexUv);
               });
          });

          //navodno isto -> probaj expandad ovo gore da u svaku listu liste doda posebno po tri UV-a sa clone();
//             print("[${((faceVertexUv as UV).u)}, ${((faceVertexUv as UV).v)}]");
//             testGeo.faceVertexUvs.forEach((faceVertexUvs){
//
//                              faceVertexUvs.forEach((faceVertexUv){
//                                  (faceVertexUv as List).forEach((e){
//                                       print("[${((e as UV).u)}, ${((e as UV).v)}]");
//                                  });
//                              });
//             });
//
//             print("testgeo2");
//             testGeo2.faceVertexUvs.forEach((faceVertexUvs){
//
//                                           faceVertexUvs.forEach((faceVertexUv){
//                                               (faceVertexUv as List).forEach((e){
//                                                    print("[${((e as UV).u)}, ${((e as UV).v)}]");
//                                               });
//                                           });
//                          });
          //PROVJERA FACE VERTEX UVA


//             int i = 0;
//             print("\nFaces:");
//             testGeo..faces.forEach((e){
//                  print("Face ${++i}:");
//                  print("Indices: [${((e as Face3).a)}, ${((e as Face3).b)}, ${((e as Face3).c)}]");
//                  print("Normal: ${((e as Face3).normal.toString())}");
//                  print("Vertex normals: ");
//                  ((e as Face3).vertexNormals.forEach((e){
//                     print("${((e as Vector3).toString())}");
//                  }));
//                  print("Material Index: ${((e as Face3).materialIndex)}");
//             });

          ////MESH FACE MATERIAL
          int h = 0;
          CubeGeometry matFaceGeo = new CubeGeometry(50.0, 50.0, 50.0);
          Mesh matFaceMesh = new Mesh(matFaceGeo);
          matFaceGeo.faces.forEach((e) {
               e.materialIndex = h++;
          });
          matFaceMesh.material = matFace;
//             planeContainer.add(matFaceMesh);
          /////////////////////////

          meshCustom1 = new Mesh(testGeo);
          meshCustom1.scale.scale(40.0);
          meshCustom1.material = matBasicTex;
          print("${meshCustom1.position}");
          planeContainer.add(meshCustom1);

          //stvori istu kocku ali desno

//             meshCustom2 = new Mesh(testGeo);
//             meshCustom2.scale.scale(50.0);
//             meshCustom2.material = matBasicTex;
//             meshCustom2.position.x = 50.0;
//             planeContainer.add(meshCustom2);

          //GLOW NA CUSTOM GEOMETRIJU
          uniformsCustom = new Map<String, Uniform>();
          Uniform c = new Uniform.float(0.0);
          Uniform p = new Uniform.float(1.0);
          Uniform glowColor = new Uniform.color(0x00ff0f);
          Uniform viewVector = new Uniform.vector3(camera.position.x, camera.position.y, camera.position.z);

          uniformsCustom["c"] = c;
          uniformsCustom["p"] = p;
          uniformsCustom["glowColor"] = glowColor;
          uniformsCustom["viewVector"] = viewVector;

          shaderCustom = new ShaderMaterial(uniforms: uniformsCustom, vertexShader: glowVertex, fragmentShader: glowFragment, side: FrontSide, blending: AdditiveBlending, transparent: true);

          meshCustom2 = new Mesh(testGeo2);
          meshCustom2.scale.x = 43.0;
          meshCustom2.scale.y = 39.5;
          meshCustom2.scale.z = 50.0;
          meshCustom2.material = shaderCustom;
          print("${meshCustom2.position}");
          planeContainer.add(meshCustom2);

//             meshCustom2 = new Mesh(new SphereGeometry(100.0), shaderCustom);
//             meshCustom2.scale.scale(1.2);
//             meshCustom2.material = shaderCustom;
//             planeContainer.add(meshCustom2);

//             scene.add(planeContainer);
     });

     addSkyBox();
     addSliders();
}



addLight() {
     AmbientLight ambientLight = new AmbientLight(0xaaaaaa);
     scene.add(ambientLight);
     PointLight pointLight = new PointLight(0xffffff, intensity: 1.0);
     pointLight.position.y = 15.0;
     pointLight.position.x = 70.0;
//     scene.add(pointLight);

//     HemisphereLight hemiLight = new HemisphereLight(0xffffff, 0xffffff);
//     scene.add(hemiLight);
}



addGlowSphere() {
     usingCustom = false;

     //BLOOM SHADER CUBE - Stenkovski Shader-Glow
     SphereGeometry sphereGeom = new SphereGeometry(100.0, 32, 16);
     Texture moonTexture = ImageUTILS.loadTexture('textures_shaders_testing/moon.jpg');
     MeshBasicMaterial moonMaterial = new MeshBasicMaterial(map: moonTexture);
//     moonGlow1 = new Mesh(sphereGeom, moonMaterial);
     moonGlow1 = new Mesh(sphereGeom);
     planeContainer.add(moonGlow1);
//     scene.add(moon);

     uniformsGlow = new Map<String, Uniform>();
     Uniform c = new Uniform.float(1.0);
     Uniform p = new Uniform.float(1.4);
     Uniform glowColor = new Uniform.color(0xffff00);
     Uniform viewVector = new Uniform.vector3(camera.position.x, camera.position.y, camera.position.z);

     uniformsGlow["c"] = c;
     uniformsGlow["p"] = p;
     uniformsGlow["glowColor"] = glowColor;
     uniformsGlow["viewVector"] = viewVector;

     shaderGlow = new ShaderMaterial(uniforms: uniformsGlow, vertexShader: glowVertex, fragmentShader: glowFragment, side: FrontSide, blending: AdditiveBlending, transparent: true);

     SphereGeometry sphereGeomGlow = new SphereGeometry(100.0, 32, 16);
     moonGlow2 = new Mesh(sphereGeomGlow, shaderGlow);
     moonGlow2.scale.scale(1.2);
     planeContainer.add(moonGlow2);

     scene.add(planeContainer);

     addSkyBox();
     addSliders();
}

addSliders() {
     String sliderHTML = """<input id="slider_c" type="range" min="0" max="1" value="1" step="0.1"></input><span id="slider_c_text"></span><br>
          <input id="slider_p" type="range" min="0" max="6" value="0" step="0.1"></input><span id="slider_p_text"></span><br>
           <form>
          <input id="rb_front" type="radio" name="side" value="front" checked>Front Side
          <br>
          <input id="rb_back" type="radio" name="side" value="back">Back Side
          </form> """;

     querySelector('#glow_sliders').innerHtml = sliderHTML;

     sliderC = new InputElement();
     sliderP = new InputElement();
     sliderCtext = new SpanElement();
     sliderPtext = new SpanElement();
     rbBackSide = new RadioButtonInputElement();
     rbFrontSide = new RadioButtonInputElement();

     sliderC = querySelector('#slider_c');
     sliderP = querySelector('#slider_p');
     sliderCtext = querySelector('#slider_c_text');
     sliderPtext = querySelector('#slider_p_text');
     sliderCtext.innerHtml = sliderC.value;
     sliderPtext.innerHtml = sliderP.value;

     rbFrontSide = querySelector('#rb_front');
     rbBackSide = querySelector('#rb_back');

     sliderC.onInput.listen((e) {

          sliderCtext.innerHtml = sliderC.value;

          if (usingCustom) uniformsCustom["c"].value = double.parse(sliderC.value); else uniformsGlow["c"].value = double.parse(sliderC.value);

     });

     sliderP.onInput.listen((e) {

          sliderPtext.innerHtml = sliderP.value;

          if (usingCustom) uniformsCustom["p"].value = double.parse(sliderP.value); else uniformsGlow["p"].value = double.parse(sliderP.value);

     });

     rbFrontSide.onChange.listen((e) {

          if (usingCustom) shaderCustom.side = FrontSide; else shaderGlow.side = FrontSide;
     });

     rbBackSide.onChange.listen((e) {

          if (usingCustom) shaderCustom.side = BackSide; else shaderGlow.side = BackSide;
     });
}

addScoreCell() {
     String objPath = 'obj_shaders_testing/score_cell_obj.obj';
     String texPath = 'textures_shaders_testing/score_cell_layout1test2.jpg';
     String p = 'obj_shaders_testing/plane_obj.obj';
     String t = 'obj_shaders_testing/path_texturing_2_uvlayout_test.png';
//     loadObj(objPath, texPath);
     loadObj(p, t);
}

addSkyBox() {
     //SkyBox
     PlaneGeometry plane1 = new PlaneGeometry(5000.0, 5000.0);
     PlaneGeometry plane2 = new PlaneGeometry(5000.0, 5000.0);
     PlaneGeometry plane3 = new PlaneGeometry(5000.0, 5000.0);
     PlaneGeometry plane4 = new PlaneGeometry(5000.0, 5000.0);
     PlaneGeometry plane5 = new PlaneGeometry(5000.0, 5000.0);
     PlaneGeometry plane6 = new PlaneGeometry(5000.0, 5000.0);

     Mesh plane1Mesh = new Mesh(plane1, new MeshBasicMaterial(map: ImageUTILS.loadTexture('textures_shaders_testing/dawnmountain-yneg.png')));
     plane1Mesh.rotation.x = -90.0 * Math.PI / 180.0;
     plane1Mesh.position.y = -2500.0;
//     planeContainer.add(plane1Mesh);

     Mesh plane2Mesh = new Mesh(plane2, new MeshBasicMaterial(map: ImageUTILS.loadTexture('textures_shaders_testing/dawnmountain-ypos.png')));
     plane2Mesh.rotation.x = 90.0 * Math.PI / 180.0;
     plane2Mesh.position.y = 2500.0;
//     planeContainer.add(plane2Mesh);

     Mesh plane3Mesh = new Mesh(plane3, new MeshBasicMaterial(map: ImageUTILS.loadTexture('textures_shaders_testing/dawnmountain-xneg.png')));
     plane3Mesh.rotation.y = 90.0 * Math.PI / 180.0;
     plane3Mesh.rotation.x = 180.0 * Math.PI / 180.0;
     plane3Mesh.position.x = -2500.0;
//     planeContainer.add(plane3Mesh);

     Mesh plane4Mesh = new Mesh(plane4, new MeshBasicMaterial(map: ImageUTILS.loadTexture('textures_shaders_testing/dawnmountain-xpos.png')));
     plane4Mesh.rotation.y = -90.0 * Math.PI / 180.0;
     plane4Mesh.rotation.x = 180.0 * Math.PI / 180.0;
     plane4Mesh.position.x = 2500.0;
//     planeContainer.add(plane4Mesh);

     Mesh plane5Mesh = new Mesh(plane5, new MeshBasicMaterial(map: ImageUTILS.loadTexture('textures_shaders_testing/dawnmountain-zpos.png')));
     plane5Mesh.rotation.y = 180.0 * Math.PI / 180.0;
     plane5Mesh.rotation.z = 180.0 * Math.PI / 180.0;
     plane5Mesh.position.z = 2500.0;
//     planeContainer.add(plane5Mesh);

     Mesh plane6Mesh = new Mesh(plane6, new MeshBasicMaterial(map: ImageUTILS.loadTexture('textures_shaders_testing/dawnmountain-zneg.png')));
     plane6Mesh.rotation.z = 180.0 * Math.PI / 180.0;
     plane6Mesh.position.z = -2500.0;
//     planeContainer.add(plane6Mesh);

     List materials = [];
     materials.add(new MeshBasicMaterial(map: ImageUTILS.loadTexture('textures_shaders_testing/dawnmountain-xpos.png'), side: BackSide));
     materials.add(new MeshBasicMaterial(map: ImageUTILS.loadTexture('textures_shaders_testing/dawnmountain-xneg.png'), side: BackSide));
     materials.add(new MeshBasicMaterial(map: ImageUTILS.loadTexture('textures_shaders_testing/dawnmountain-ypos.png'), side: BackSide));
     materials.add(new MeshBasicMaterial(map: ImageUTILS.loadTexture('textures_shaders_testing/dawnmountain-yneg.png'), side: BackSide));
     materials.add(new MeshBasicMaterial(map: ImageUTILS.loadTexture('textures_shaders_testing/dawnmountain-zpos.png'), side: BackSide));
     materials.add(new MeshBasicMaterial(map: ImageUTILS.loadTexture('textures_shaders_testing/dawnmountain-zneg.png'), side: BackSide));

     int index = 0;
     CubeGeometry skyBox = new CubeGeometry(5000.0, 5000.0, 5000.0);
     Mesh skyBoxMesh = new Mesh(skyBox, new MeshFaceMaterial(materials));
     skyBox.faces.forEach((e) {
          e.materialIndex = index++;
     });

//     planeContainer.add(skyBoxMesh);
     scene.add(skyBoxMesh);
}

//rotateCamera()
//{
//
//    var x = camera.position.x,
//        y = camera.position.y,
//        z = camera.position.z;
//
//    if (keyboard.pressed("left")){
//        camera.position.x = x * Math.cos(rotSpeed) + z * Math.sin(rotSpeed);
//        camera.position.z = z * Math.cos(rotSpeed) - x * Math.sin(rotSpeed);
//    } else if (keyboard.pressed("right")){
//        camera.position.x = x * Math.cos(rotSpeed) - z * Math.sin(rotSpeed);
//        camera.position.z = z * Math.cos(rotSpeed) + x * Math.sin(rotSpeed);
//    }
//
//    camera.lookAt(scene.position);
//}

update() {
     //WRITE ANIMATION LOGIC HERE
     planeContainer.rotation.y += (targetRotation - planeContainer.rotation.y) * 0.05;
     scoreCell.rotation.y += (targetRotation - scoreCell.rotation.y) * 0.05;
//     camera.rotation.y += (targetRotation - camera.rotation.y) * 0.05;
//     camera.position.x = camera.position.x * Math.cos(targetRotation);
//     camera.position.z = camera.position.y * Math.sin(targetRotation);

//     print("TargetRot: ${camera.position}");

//     if(usingCustom)
//          if(uniformsCustom != null)
//               uniformsCustom["viewVector"].value = camera.position.sub(meshCustom2.position);
//     else
//     {
//          if(uniformsGlow != null)
//          {
//               uniformsGlow["viewVector"].value = camera.position.sub(moonGlow2.position);
//               print("Cam: ${camera.position.toString()}, Glow: ${moonGlow2.position}");
//               print("Diff: ${camera.position.sub(moonGlow2.position)}");
//          }
//
//     }
}


render() {
     renderer.render(scene, camera);
}

animate(num time) {
     window.requestAnimationFrame(animate);
     render();
     update();
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

printPaper() {
     Geometry paperGeo = new Geometry();
     paperGeo.vertices.add(new Vector3(-50.0, 0.0, 50.0));
     paperGeo.vertices.add(new Vector3(50.0, 0.0, 50.0));
     paperGeo.vertices.add(new Vector3(50.0, 0.0, -50.0));
     paperGeo.vertices.add(new Vector3(-50.0, 0.0, -50.0));

//     paperGeo.faces.add(new Face4(0, 1, 2, 3));
     paperGeo.faces.add(new Face3(0, 1, 2));
     paperGeo.faces.add(new Face3(2, 3, 0));

     Texture paperTex = ImageUTILS.loadTexture('obj_shaders_testing/path_texturing_2_uvlayout_test.png');
     MeshBasicMaterial paperMat = new MeshBasicMaterial(map: paperTex, side: DoubleSide);

     Mesh paperMesh = new Mesh(paperGeo, paperMat);
//     List faceuv = [new UV(0.0, 1.0), new UV(1.0, 1.0), new UV(1.0, 0.0), new UV(0.0, 0.0)];
//     List faceuv = [new UV(0.0, 1.0), new UV(1.0, 1.0), new UV(1.0, 0.0)];
//     List faceuv1 = [new UV(1.0, 0.0), new UV(0.0, 0.0), new UV(0.0, 1.0)];
     List faceuv = [new UV(0.0, 0.5), new UV(1.0, 0.5), new UV(1.0, 0.0)];
     List faceuv1 = [new UV(1.0, 0.0), new UV(0.0, 0.0), new UV(0.0, 0.5)];

     paperGeo.faceVertexUvs[0].add(faceuv);
     paperGeo.faceVertexUvs[0].add(faceuv1);
     planeContainer.add(paperMesh);
     scene.add(planeContainer);
}

addCustomCube() {
     Geometry customCube = new Geometry();

     Vector3 v0 = new Vector3(-50.0, -50.0, 50.0);
     Vector3 v1 = new Vector3(50.0, -50.0, 50.0);
     Vector3 v2 = new Vector3(50.0, -50.0, -50.0);
     Vector3 v3 = new Vector3(-50.0, -50.0, -50.0);
     Vector3 v4 = new Vector3(-50.0, 50.0, 50.0);
     Vector3 v5 = new Vector3(50.0, 50.0, 50.0);
     Vector3 v6 = new Vector3(50.0, 50.0, -50.0);
     Vector3 v7 = new Vector3(-50.0, 50.0, -50.0);

     customCube.vertices.addAll([v0, v1, v2, v3, v4, v5, v6, v7]);
     Face4 f1 = new Face4(0, 1, 2, 3); //bottom
     Face4 f2 = new Face4(4, 5, 6, 7); //top
     Face4 f3 = new Face4(3, 0, 4, 7); //left
     Face4 f4 = new Face4(1, 2, 6, 5); //right
     Face4 f5 = new Face4(0, 1, 5, 4); //front
     Face4 f6 = new Face4(2, 3, 7, 6); //back
     customCube.faces.addAll([f1, f2, f3, f4, f5, f6]);


     uniformsGlow = new Map<String, Uniform>();
     Uniform c = new Uniform.float(0.6);
     Uniform p = new Uniform.float(5.1);
     Uniform glowColor = new Uniform.color(0x00823d);
     Uniform viewVector = new Uniform.vector3(camera.position.x, camera.position.y, camera.position.z);

     uniformsGlow["c"] = c;
     uniformsGlow["p"] = p;
     uniformsGlow["glowColor"] = glowColor;
     uniformsGlow["viewVector"] = viewVector;

     ShaderMaterial glowShader = new ShaderMaterial(uniforms: uniformsGlow, vertexShader: glowVertex, fragmentShader: glowFragment, side: BackSide, blending: AdditiveBlending, transparent: true);

     Texture tex = ImageUTILS.loadTexture(texPath);
     Material mat = new MeshLambertMaterial(map: tex);
}

loadObj(String objPath, String texPath) {
     var mat = new MeshLambertMaterial(map: ImageUTILS.loadTexture(texPath));

     var loader = new OBJLoader();

//      loader.load(objPath).then((Object3D object)
//               {
//            print(object.geometry.toString());
//
//
////          print((object.children.first.runtimeType));
////          Geometry geo = (object.children.first as Mesh).geometry;
////          Mesh cellGlow = new Mesh(geo, glowShader);
////          cellGlow.scale.scale(12.0);
////          cellGlow.position.setFrom(object.position);
////          scoreCell.add(cellGlow);
////
//          object.children.forEach((e) {
//               if (e is Mesh) {
//                    (e as Mesh).material = mat;
//               }
//          });
//
//          object.scale.scale(20.0);
//          scoreCell.add(object);
//          scene.add(scoreCell);
//     });

}

//loadWithMTL() {
//     var loader = new OBJLoader();
//     loader.load('obj_shaders_testing/cube_obj.obj').then((object) {
//          object.scale.scale(40.0);
//          scene.add(object);
//     });
//}
