import 'package:vector_math/vector_math.dart';
import 'package:three/three.dart';
import 'dart:html';
import 'dart:async';

class MojParser
{      
     RegExp vertex_pattern = new RegExp(r"v( +[\d|\.|\+|\-|e]+)( +[\d|\.|\+|\-|e]+)( +[\d|\.|\+|\-|e]+)");
     RegExp normal_pattern = new RegExp(r"vn( +[\d|\.|\+|\-|e]+)( +[\d|\.|\+|\-|e]+)( +[\d|\.|\+|\-|e]+)");
     RegExp uv_pattern = new RegExp(r"vt( +[\d|\.|\+|\-|e]+)( +[\d|\.|\+|\-|e]+)");     
     RegExp face_pattern1 = new RegExp(r"f( +-?\d+)( +-?\d+)( +-?\d+)( +-?\d+)?");
     RegExp face_pattern2 = new RegExp(r"f( +(-?\d+)\/(-?\d+))( +(-?\d+)\/(-?\d+))( +(-?\d+)\/(-?\d+))( +(-?\d+)\/(-?\d+))?");
     RegExp face_pattern3 = new RegExp(r"f( +(-?\d+)\/(-?\d+)\/(-?\d+))( +(-?\d+)\/(-?\d+)\/(-?\d+))( +(-?\d+)\/(-?\d+)\/(-?\d+))( +(-?\d+)\/(-?\d+)\/(-?\d+))?");
     RegExp face_pattern4 = new RegExp(r"f( +(-?\d+)\/\/(-?\d+))( +(-?\d+)\/\/(-?\d+))( +(-?\d+)\/\/(-?\d+))( +(-?\d+)\/\/(-?\d+))?");

//     List<Vector3> _pathVertices;
//     List<Vector3> _colors;
//     List<Vector2> _uVs;
//     List<Vector3> _normals;

     //Output Geometry
//     Geometry geometry;
     
//     var vertices        = new List();
//     var normals         = new List();
//     var faceUvs         = new List();
//     var faces           = new List();
//     var faceVertexUvs   = new List<List>();
     var vertices;
     var normals;
     var faceUvs;
     var faces;
     var faceVertexUvs;

     MojParser();
//               : _pathVertices = new List<Vector3>(),
//                 _colors = new List<Vector3>(),
//                 _uVs = new List<Vector2>(),
//                 _normals = new List<Vector3>();

//     List<Vector3> get getVertices => _pathVertices;
//     List<Vector3> get getColors => _colors;
//     List<Vector2> get getUVS => _uVs;
//     List<Vector3> get getNormals => _normals;

//     Future load(url) => HttpRequest.request(url, responseType: "String").then((req) => _parse(req.response));
//     Future<Geometry> load(url) => HttpRequest.request(url, responseType: "String").then((req) => parse(req.response));
     
     Future<Geometry> load(url) => HttpRequest.request(url, responseType: "String").then((req) {
          return parse(req.response);
     });


//     _parse(String text) {
//          var lines = text.split('\n');
//
//          lines.forEach((line) {
//
//               line = line.trim();
//               var result;
//
//               if (!(line.length == 0 || line.startsWith('#'))) {
//                    if ((result = vertex_pattern.firstMatch(line)) != null) {
//                         _pathVertices.add(new Vector3(double.parse(result[1]), double.parse(result[2]), double.parse(result[3])));
//                    }
//
//                    if ((result = normal_pattern.firstMatch(line)) != null) {
//                         _normals.add(new Vector3(double.parse(result[1]), double.parse(result[2]), double.parse(result[3])));
//                    }
//                    
//                    if ((result = uv_pattern.firstMatch(line)) != null) {
//                         _uVs.add(new Vector2(double.parse(result[1]), double.parse(result[2])));
//                    }
//               }
//
//
//
//          });
//     }

  void _addFace(Geometry geometry, int face_offset,
                String a, String b, String c,
                [List normals, List normals_inds]) {
    var normalOrVertexNormals;
    
    if (normals != null && normals_inds != null) {
          normalOrVertexNormals = [
              normals[int.parse(normals_inds[0]) - 1].clone(),
              normals[int.parse(normals_inds[1]) - 1].clone(),
              normals[int.parse(normals_inds[2]) - 1].clone()
            ];
        }

    geometry.faces.add(new Face3(
        int.parse(a) - (face_offset + 1),
        int.parse(b) - (face_offset + 1),
        int.parse(c) - (face_offset + 1),
        normalOrVertexNormals
      ));
  }

  _addUvs(Geometry geometry, List uvs, String a, String b, String c) =>
      geometry.faceVertexUvs[0].add( [
        uvs[int.parse(a) - 1].clone(),
        uvs[int.parse(b) - 1].clone(),
        uvs[int.parse(c) - 1].clone()
      ]);

  _handle_face_line(Geometry geometry, int faceOffset, normals, List uvs, List<String> faces, [List<String> uvsLine = null, normals_inds = null]) {    
    if (faces[ 3 ] == null)  {
      _addFace(geometry, faceOffset, faces[0], faces[1], faces[2], normals, normals_inds);
      if (uvsLine != null && uvsLine.length > 0) {
        _addUvs(geometry, uvs, uvsLine[0], uvsLine[1], uvsLine[2]);
      }
    } else {
      if (normals_inds != null && normals_inds.length > 0) {
        _addFace(geometry, faceOffset, faces[0], faces[1], faces[3], normals, [normals_inds[0], normals_inds[1], normals_inds[3]]);
        _addFace(geometry, faceOffset, faces[1], faces[2], faces[3], normals, [normals_inds[1], normals_inds[2], normals_inds[3]]);
      } else {
        _addFace(geometry, faceOffset, faces[0], faces[1], faces[3]);
        _addFace(geometry, faceOffset, faces[1], faces[2], faces[3]);
      }

      if (uvsLine != null && uvsLine.length > 0) {
        _addUvs(geometry, uvs, uvsLine[0], uvsLine[1], uvsLine[3]);
        _addUvs(geometry, uvs, uvsLine[1], uvsLine[2], uvsLine[3]);
      }
    }
  }

  Future<Geometry> parse(String text) 
  {
    Geometry geo = new Geometry();
    
    vertices        = new List();
    normals         = new List();
    faceUvs         = new List();
    faces           = new List();
    faceVertexUvs   = new List<List>();
    
    var face_offset = 0;

    var lines = text.split('\n');
    
    lines.forEach((line) {
      line = line.trim();
      var result;

      if (!(line.length == 0 || line.startsWith('#'))) 
      {
        if ((result = vertex_pattern.firstMatch(line)) != null) {

          // ["v 1.0 2.0 3.0", "1.0", "2.0", "3.0"]
             vertices.add(new Vector3(double.parse(result[1]), double.parse(result[2]), double.parse(result[3])));

        } else if ((result = normal_pattern.firstMatch(line)) != null) {

          // ["vn 1.0 2.0 3.0", "1.0", "2.0", "3.0"]
             normals.add( new Vector3(double.parse(result[1]), double.parse(result[2]), double.parse(result[3])));

        } else if ((result = uv_pattern.firstMatch(line)) != null) {

          // ["vt 0.1 0.2", "0.1", "0.2"]
             faceUvs.add(new UV(double.parse(result[1]), double.parse(result[2])));

        } else if ((result = face_pattern1.firstMatch(line)) != null) {

          // ["f 1 2 3", "1", "2", "3", undefined]
          _handle_face_line(
               geo, face_offset, normals, faceUvs,
              [result[1], result[2], result[3], result[4]]
          );
        } else if ((result = face_pattern2.firstMatch(line)) != null) {

          // ["f 1/1 2/2 3/3", " 1/1", "1", "1", " 2/2", "2", "2", " 3/3", "3", "3", undefined, undefined, undefined]
          _handle_face_line(
              geo, face_offset, normals, faceUvs,
              [result[2], result[5], result[8], result[11]], //faces
              [result[3], result[6], result[9], result[12]] //uv
          );
        } else if ((result = face_pattern3.firstMatch(line)) != null) {

          // ["f 1/1/1 2/2/2 3/3/3", " 1/1/1", "1", "1", "1", " 2/2/2", "2", "2", "2", " 3/3/3", "3", "3", "3", undefined, undefined, undefined, undefined]
          _handle_face_line(
              geo, face_offset, normals, faceUvs,
              [result[2], result[6], result[10], result[14]], //faces
              [result[3], result[7], result[11], result[15]], //uv
              [result[4], result[8], result[12], result[16]] //normal
          );
        } else if ((result = face_pattern4.firstMatch(line)) != null) {

          // ["f 1//1 2//2 3//3", " 1//1", "1", "1", " 2//2", "2", "2", " 3//3", "3", "3", undefined, undefined, undefined]
          _handle_face_line(
               geo, face_offset, normals, faceUvs,
               [result[2], result[5], result[8], result[11]], //faces
               [], //uv
               [result[3], result[6], result[9], result[12]] //normal
          );
        } 
      }
    });
    
    //old code
//    faces = geo.faces;
//    faceVertexUvs = geo.faceVertexUvs;   
    
//    print(vertices.length);
//    print(normals.length);
//    print(faceUvs.length);
//    print(faceVertexUvs[0][0].length);
//    print(faces.length);
    
    //dodijeli geometriji
    geo.vertices = vertices;
    geo.normals = normals;
    geo.faceUvs = faceUvs;
    //nuliraj
    vertices = null;
    normals = null;
    faceUvs = null;
    
    //vrati rezultat
//    return geo;
    
    //wrap the geometry object into Future
    var completer = new Completer();    
    completer.complete(geo);    
    return completer.future;
    
  }
}