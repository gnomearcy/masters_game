/**
 * Contains path values to object resources (such as geometry and texture data).
 * Performs deserialization of .obj files and construction of Object3D and Geometry objects.
 */
library ObjectManager;

import 'package:three/three.dart';
import 'package:vector_math/vector_math.dart';
import 'package:three/extras/image_utils.dart' as ImageUTILS;
import 'package:three/extras/scene_utils.dart' as SceneUtils;
import 'Parser.dart';
import 'dart:async';
import 'dart:collection';
import 'dart:html';

class ObjectManager
{
     final path_obj = "refactoring_objs/testiram_cijelu_traku_krivulja9.obj";
     final ship_obj = "";
     final track_obj = "refactoring_objs/testiram_cijelu_traku_traka9.obj";
     final obstacle_obj = "";
     final scoreItem_obj = "";
     
     final ship_texture = "";
     final track_texture = "refactoring_objs/combined_layout_test1_export.jpg";
     final obstacle_texture = "";
     final scoreItem_texture = "";
     
     int nekibroj;
     
     Path path;
     Object3D ship;
     Object3D track;
     Object3D obstacle;
     Object3D scoreItem;
     
     Parser parser;
     List resources;
     
     ObjectManager() 
     {
          parser = new Parser();
          resources = [];
          resources.add(path_obj);
          resources.add(track_obj);
     }
          
//     Future someFunction()
//     {
//          return Future.wait(resources.map((literal) => HttpRequest.request(literal, responseType: "String")))
//          .then((List<HttpRequest> responses) //sada tu imam obj fileove kao string
//          {
////               print("dobio sam http requestove " + responses.length.toString());
//               List<Object> rs = new List<Object>();
//               for(HttpRequest r in responses)
//               {
//                    rs.add(r.response);
//               }
//               
//               Future.wait(rs.map((response) => parser.parse(response)))
//               .then((List<Geometry> geometries)
//               {
//                 print(geometries.length);   
//                 print(geometries.elementAt(0).vertices.length);
//                 
//                 //kreiraj tube
//                 var curve = new SplineCurve3(geometries.elementAt(0).vertices);
//                 TubeGeometry tube = new TubeGeometry(curve, curve.points.length - 1, 1.0, 1, false, false);
//                 path = new Path(tube.binormals, tube.tangents.length, tube.path);
//                 
//                 //kreiraj track
////                 Texture tex = ImageUTILS.loadTexture(track_texture);
////                 MeshPhongMaterial track_material = new MeshPhongMaterial(map: tex);
////                 track = new Mesh(geometries.elementAt(1), track_material);
//                 
//                 nekibroj = geometries[0].verticesCount;
//               });
//          });
//     }
     
     Future init() => 
               
//           parser.load(track_obj)
//           .then((object)
//           {
//                Texture tex = ImageUTILS.loadTexture(track_texture);
//                MeshPhongMaterial track_material = new MeshPhongMaterial(map: tex);
//                track = new Mesh(object, track_material);
//           })
//           .whenComplete(()
//                {
//                parser.load(path_obj)
//                .then((object)
//                {                
//                     var curve = new SplineCurve3(object.vertices);
//                     TubeGeometry tube = new TubeGeometry(curve, curve.points.length - 1, 1.0, 1, false, false);
//                     
//                     path = new Path(tube.binormals, tube.tangents.length, tube.path);
//                     //curve, segments, radius, radiussegments, closed, debug
//     //                     path = new Mesh(new TubeGeometry(curve, curve.points.length - 1, 1.0, 1, false, false));  
//                });
//           });
               
          parser.load(path_obj)
                    .then((object)
                    {
                         var curve = new SplineCurve3(object.vertices);
                         TubeGeometry tube = new TubeGeometry(curve, curve.points.length - 1, 1.0, 1, false, false);
                         path = new Path(tube.binormals, tube.tangents.length, tube.path);
//                         curve, segments, radius, radiussegments, closed, debug
         //                     path = new Mesh(new TubeGeometry(curve, curve.points.length - 1, 1.0, 1, false, false)); 
                    });
//                    .whenComplete(()
//                    {
//                    parser.load(track_obj)
//                    .then((object)
//                    {
//                         Texture tex = ImageUTILS.loadTexture(track_texture);
//                         MeshPhongMaterial track_material = new MeshPhongMaterial(map: tex);
//                         track = new Mesh(object, track_material);
//                    });
//                    });
//                    .whenComplete(()
//                         {
//                         parser.load(track_obj)
//                         .then((object)
//                         {      
//                              
//                               
//                         });
//                    });
     
     handleGeometries(Object3D parent, List<Geometry> geometries)
     {
          //geometries[0] => path;
          var curve = new SplineCurve3(geometries[0].vertices);
          TubeGeometry tube = new TubeGeometry(curve, curve.points.length - 1, 1.0, 1, false, false);
          path = new Path(tube.binormals, tube.tangents.length, tube.path);
          
          //geometries[1] => track          
          Texture tex = ImageUTILS.loadTexture(track_texture);
          MeshPhongMaterial track_material = new MeshPhongMaterial(map: tex);
          track = new Mesh(geometries[1], track_material);
//          parent.add(track);
     }
     
     //next two functions are used by coremanager to get a new copy of items
     ScoreItem instantiateScoreItem(Geometry geometry)
     {
          //define material for score item here
          ScoreItem scoreItem = new ScoreItem(geometry);
          return scoreItem;    
     }
     
     Obstacle instantiateObstacle(Geometry geometry)
     {
          //define material for obstacle item here
          Obstacle obstacle = new Obstacle(geometry);
          return obstacle;
     }
}

class Path
{
     List<Vector3> binormals;
     int segments;
     SplineCurve3 curve;
     
     Path(this.binormals, this.segments, this.curve);
}

class Obstacle extends Mesh
{
     Obstacle(Geometry geometry, [Material material]) : super(geometry, material);
}

class ScoreItem extends Mesh
{
     ScoreItem(Geometry geometry, [Material material]) : super(geometry, material);
}