import 'package:three/three.dart';
import 'package:vector_math/vector_math.dart';
import 'dart:html';
import 'dart:math';
import 'package:three/extras/image_utils.dart' as ImageUTILS;

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
     
     //ADD OBJECTS TO SCENE HERE
     MeshBasicMaterial material =  new MeshBasicMaterial(color:0xff0000);
     Mesh mesh = new Mesh(new CubeGeometry(20.0, 20.0, 20.0), material);
     mesh.position.x = -50.0;
     scene.add(mesh);        
     
     Mesh sphere = new Mesh(new SphereGeometry(80.0));
     int nrVertices = sphere.geometry.vertices.length;
     
     //Define map of attributes, define a float attribute
     Map<String, Attribute> attributes = new Map<String, Attribute>();     
     Attribute displacement = new Attribute.float(null); //type: 'f', value: [];
//     attributes["displacement"] = displacement;
     List values = displacement.value;
     
     for(int i = 0; i < nrVertices; i++)
     {
          values.add(new Random().nextDouble() * 30);
     }
   
     attributes["displacement"] = displacement;
     
     ShaderMaterial sm = new ShaderMaterial(attributes: attributes, fragmentShader: fragmentShader, vertexShader: vertexShader);
     Attribute att = sm.attributes["displacement"];
     sphere.material = sm;
     scene.add(sphere);
     
     //NAPRAVI OBJEKAT
     //PREDAJ UNIFORM VARIJABLE
     //TO JE TO
     Map<String, Uniform> uniforms = new Map<String, Uniform>();
     Uniform fogDensity = new Uniform.float(0.45);
     Uniform fogColor = new Uniform.vector3(0.0, 0.0, 0.0);
     Uniform time = new Uniform.float(1.0);
     Uniform resolution = new Uniform.vector2(0.0, 0.0);
     Uniform uvScale = new Uniform.vector2(3.0, 1.0);
     Uniform texture1 = new Uniform.texture(ImageUTILS.loadTexture('textures_shaders_testing/cloud.png'));
     Uniform texture2 = new Uniform.texture(ImageUTILS.loadTexture('textures_shaders_testing/lavatile.jpg'));
     
     uniforms["fogDensity"] = fogDensity;
     uniforms["fogColor"] = fogColor;
     uniforms["time"] = time;
     uniforms["resolution"] = resolution;
     uniforms["uvScale"] = uvScale;
     uniforms["texture1"] = texture1;
     uniforms["texture2"] = texture2;
     
     (uniforms["texture1"].value as Texture).wrapS = RepeatWrapping;
     (uniforms["texture2"].value as Texture).wrapT = RepeatWrapping;
     (uniforms["texture1"].value as Texture).wrapS = RepeatWrapping;
     (uniforms["texture2"].value as Texture).wrapT = RepeatWrapping;
     
     ShaderMaterial moltenShader = new ShaderMaterial(uniforms: uniforms, vertexShader: moltenVertex, fragmentShader: moltenFragment);
     sphere.material = moltenShader;
     
     //-------------------------
}

/**
 * // All of these seem to be predefined:
// vec3 position;
// mat4 projectionMatrix;
// mat4 modelViewMatrix;
// mat3 normalMatrix;
// vec3 normal;
 */

String moltenFragment = "uniform float time;" + 
                         "uniform vec2 resolution;" + 
                         "uniform float fogDensity;" + 
                         "uniform vec3 fogColor;" + 
                         "uniform sampler2D texture1;" + 
                         "uniform sampler2D texture2;"
                         "varying vec2 vUv;" + 
                         "void main( void ) {" +
                         " vec2 position = -1.0 + 2.0 *vUv;" + 
                         "vec4 noise = texture2D( texture1, vUv )" + 
                         "vec2 T1 = vUv + vec2( 1.5, -1.5 ) * time * 0.02;" + 
                         "vec2 T2 = vUv + vec2( -0.5, 2.0 ) * time * 0.01;" + 
                         "T1.x += noise.x * 2.0;" + 
                         "T1.y += noise.y * 2.0;" +
                         "T2.x -= noise.y * 0.2;" + 
                         "T2.y += noise.z * 0.2;" +
                         "float p = texture2D( texture1, T1 * 2.0 ).a;" +
                         "vec4 color = texture2D( texture2, T2 * 2.0 );" +
                         "vec4 temp = color * ( vec4( p, p, p, p ) * 2.0 ) + ( color * color - 0.1 );" +
                         "if( temp.r > 1.0 ){ temp.bg += clamp( temp.r - 2.0, 0.0, 100.0 ); }" + 
                         "if( temp.g > 1.0 ){ temp.rb += temp.g - 1.0; }" +
                         "if( temp.b > 1.0 ){ temp.rg += temp.b - 1.0; }" +
                         "gl_FragColor = temp;" +
                         "float depth = gl_FragCoord.z / gl_FragCoord.w;" +
                         "const float LOG2 = 1.442695;" +
                         "float fogFactor = exp2( - fogDensity * fogDensity * depth * depth * LOG2 );" +
                         "fogFactor = 1.0 - clamp( fogFactor, 0.0, 1.0 );" +
                         "gl_FragColor = mix( gl_FragColor, vec4( fogColor, gl_FragColor.w ), fogFactor ); }";                         
String moltenVertex =  "uniform vec2 uvScale;" +
                         "varying vec2 vUv;"+
                         
                         "void main() {"+
                              "vUv = uvScale * uv;"+
                              "vec4 mvPosition = modelViewMatrix * vec4( position, 1.0 );"+
                              "gl_Position = projectionMatrix * mvPosition;"+
                         
                         "}";

String vertexShader = "attribute float displacement;"  + "\n"
                    + "varying vec3 vNormal;"     + "\n"
                    + "void main(){"              + "\n"
                    + "vNormal = normal;"         + "\n"
                    + "vec3 newPosition = position + normal * vec3(displacement);" + "\n"
                    + "gl_Position = projectionMatrix * modelViewMatrix * vec4(newPosition, 1.0);" + "\n"
                    + "}"                         + "\n";

String fragmentShader = "varying vec3 vNormal;"                            + "\n"
                       +"void main() {"                                    + "\n"
                       +"vec3 light = vec3(0.0, 100.0, 0.0);"              + "\n"
                       +"light = normalize(light);"                        + "\n"
                       +"float dProd = max(0.0, dot(vNormal, light));"     + "\n"
                       +"gl_FragColor = vec4(dProd, dProd, dProd, 1.0);"   + "\n"
                    + "}"                                                  + "\n";
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