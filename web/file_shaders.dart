library Shaders;
/**
 * // All of these seem to be predefined:
// vec3 position;
// mat4 projectionMatrix;
// mat4 modelViewMatrix;
// mat3 normalMatrix;
// vec3 normal;
 */

String glowVertex = "uniform vec3 viewVector;\n" +
                    "uniform float c;\n" +
                    "uniform float p;\n" +
                    "varying float intensity;\n" +
                    "void main()\n" +
                    "{\n" +
                    "vec3 vNormal = normalize( normalMatrix * normal );\n" +
                    "vec3 vNormel = normalize( normalMatrix * viewVector );\n" +
                    "intensity = pow( c - dot(vNormal, vNormel), p );\n" +
                    "gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );\n" +
                    "}";

String glowFragment = "uniform vec3 glowColor;" + 
                      "varying float intensity;" +
                      "void main() {" +
                      "vec3 glow = glowColor * intensity;" +
                      "gl_FragColor = vec4( glow, 1.0); }";

String moltenFragment = "uniform float time;\n" +
                         "\t\t\tuniform vec2 resolution;\n" +
                         "\n" +
                         "\t\t\tuniform float fogDensity;\n" +
                         "\t\t\tuniform vec3 fogColor;\n" +
                         "\n" +
                         "\t\t\tuniform sampler2D texture1;\n" +
                         "\t\t\tuniform sampler2D texture2;\n" +
                         "\n" +
                         "\t\t\tvarying vec2 vUv;\n" +
                         "\n" +
                         "\t\t\tvoid main( void ) {\n" +
                         "\n" +
                         "\t\t\t\tvec2 position = -1.0 + 2.0 * vUv;\n" +
                         "\n" +
                         "\t\t\t\tvec4 noise = texture2D( texture1, vUv );\n" +
                         "\t\t\t\tvec2 T1 = vUv + vec2( 1.5, -1.5 ) * time  *0.02;\n" +
                         "\t\t\t\tvec2 T2 = vUv + vec2( -0.5, 2.0 ) * time * 0.01;\n" +
                         "\n" +
                         "\t\t\t\tT1.x += noise.x * 2.0;\n" +
                         "\t\t\t\tT1.y += noise.y * 2.0;\n" +
                         "\t\t\t\tT2.x -= noise.y * 0.2;\n" +
                         "\t\t\t\tT2.y += noise.z * 0.2;\n" +
                         "\n" +
                         "\t\t\t\tfloat p = texture2D( texture1, T1 * 2.0 ).a;\n" +
                         "\n" +
                         "\t\t\t\tvec4 color = texture2D( texture2, T2 * 2.0 );\n" +
                         "\t\t\t\tvec4 temp = color * ( vec4( p, p, p, p ) * 2.0 ) + ( color * color - 0.1 );\n" +
                         "\n" +
                         "\t\t\t\tif( temp.r > 1.0 ){ temp.bg += clamp( temp.r - 2.0, 0.0, 100.0 ); }\n" +
                         "\t\t\t\tif( temp.g > 1.0 ){ temp.rb += temp.g - 1.0; }\n" +
                         "\t\t\t\tif( temp.b > 1.0 ){ temp.rg += temp.b - 1.0; }\n" +
                         "\n" +
                         "\t\t\t\tgl_FragColor = temp;\n" +
                         "\n" +
                         "\t\t\t\tfloat depth = gl_FragCoord.z / gl_FragCoord.w;\n" +
                         "\t\t\t\tconst float LOG2 = 1.442695;\n" +
                         "\t\t\t\tfloat fogFactor = exp2( - fogDensity * fogDensity * depth * depth * LOG2 );\n" +
                         "\t\t\t\tfogFactor = 1.0 - clamp( fogFactor, 0.0, 1.0 );\n" +
                         "\n" +
                         "\t\t\t\tgl_FragColor = mix( gl_FragColor, vec4( fogColor, gl_FragColor.w ), fogFactor );\n" +
                         "\n" +
                         "\t\t\t}";
//                         "uniform float time;" + 
//                         "uniform vec2 resolution;" + 
//                         "uniform float fogDensity;" + 
//                         "uniform vec3 fogColor;" + 
//                         "uniform sampler2D texture1;" + 
//                         "uniform sampler2D texture2;"
//                         "varying vec2 vUv;" + 
//                         "void main( void ) {" +
//                         " vec2 position = -1.0 + 2.0 *vUv;" + 
//                         "vec4 noise = texture2D( texture1, vUv )" + 
//                         "vec2 T1 = vUv + vec2( 1.5, -1.5 ) * time * 0.02;" + 
//                         "vec2 T2 = vUv + vec2( -0.5, 2.0 ) * time * 0.01;" + 
//                         "T1.x += noise.x * 2.0;" + 
//                         "T1.y += noise.y * 2.0;" +
//                         "T2.x -= noise.y * 0.2;" + 
//                         "T2.y += noise.z * 0.2;" +
//                         "float p = texture2D( texture1, T1 * 2.0 ).a;" +
//                         "vec4 color = texture2D( texture2, T2 * 2.0 );" +
//                         "vec4 temp = color * ( vec4( p, p, p, p ) * 2.0 ) + ( color * color - 0.1 );" +
//                         "if( temp.r > 1.0 ){ temp.bg += clamp( temp.r - 2.0, 0.0, 100.0 ); }" + 
//                         "if( temp.g > 1.0 ){ temp.rb += temp.g - 1.0; }" +
//                         "if( temp.b > 1.0 ){ temp.rg += temp.b - 1.0; }" +
//                         "gl_FragColor = temp;" +
//                         "float depth = gl_FragCoord.z / gl_FragCoord.w;" +
//                         "const float LOG2 = 1.442695;" +
//                         "float fogFactor = exp2( - fogDensity * fogDensity * depth * depth * LOG2 );" +
//                         "fogFactor = 1.0 - clamp( fogFactor, 0.0, 1.0 );" +
//                         "gl_FragColor = mix( gl_FragColor, vec4( fogColor, gl_FragColor.w ), fogFactor ); }";                         
String moltenVertex =  "uniform vec2 uvScale;\n" +
                         "\t\t\tvarying vec2 vUv;\n" +
                         "\n" +
                         "\t\t\tvoid main()\n" +
                         "\t\t\t{\n" +
                         "\n" +
                         "\t\t\t\tvUv = uvScale * uv;\n" +
                         "\t\t\t\tvec4 mvPosition = modelViewMatrix * vec4( position, 1.0 );\n" +
                         "\t\t\t\tgl_Position = projectionMatrix * mvPosition;\n" +
                         "\n" +
                         "\t\t\t}";
//                         "uniform vec2 uvScale;" +
//                         "varying vec2 vUv;"+
//                         
//                         "void main() {"+
//                              "vUv = uvScale * uv;"+
//                              "vec4 mvPosition = modelViewMatrix * vec4( position, 1.0 );"+
//                              "gl_Position = projectionMatrix * mvPosition;"+
//                         
//                         "}";

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
                    + "}";            