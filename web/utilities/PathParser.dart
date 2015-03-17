library PathParser;

import 'dart:async';
import 'package:vector_math/vector_math.dart';
import 'dart:html';

class PathParser {

     RegExp vertex_pattern = new RegExp(r"v( +[\d|\.|\+|\-|e]+)( +[\d|\.|\+|\-|e]+)( +[\d|\.|\+|\-|e]+)");
     RegExp normal_pattern = new RegExp(r"vn( +[\d|\.|\+|\-|e]+)( +[\d|\.|\+|\-|e]+)( +[\d|\.|\+|\-|e]+)");
     RegExp uv_pattern = new RegExp(r"vt( +[\d|\.|\+|\-|e]+)( +[\d|\.|\+|\-|e]+)");

     List<Vector3> _pathVertices;
     List<Vector3> _colors;
     List<Vector2> _uVs;
     List<Vector3> _normals;

     PathParser()
               : _pathVertices = new List<Vector3>(),
                 _colors = new List<Vector3>(),
                 _uVs = new List<Vector2>(),
                 _normals = new List<Vector3>();

     List<Vector3> get getVertices => _pathVertices;
     List<Vector3> get getColors => _colors;
     List<Vector2> get getUVS => _uVs;
     List<Vector3> get getNormals => _normals;

     Future load(url) => HttpRequest.request(url, responseType: "String").then((req) => _parse(req.response));

     _parse(String text) {
          var lines = text.split('\n');

          lines.forEach((line) {

               line = line.trim();
               var result;

               if (!(line.length == 0 || line.startsWith('#'))) {
                    if ((result = vertex_pattern.firstMatch(line)) != null) {
                         _pathVertices.add(new Vector3(double.parse(result[1]), double.parse(result[2]), double.parse(result[3])));
                    }

                    if ((result = normal_pattern.firstMatch(line)) != null) {
                         _normals.add(new Vector3(double.parse(result[1]), double.parse(result[2]), double.parse(result[3])));
                    }
                    
                    if ((result = uv_pattern.firstMatch(line)) != null) {
                         _uVs.add(new Vector2(double.parse(result[1]), double.parse(result[2])));
                    }
               }



          });
     }
     
     void resetVertices()
     {
          _pathVertices.clear();
     }
}
