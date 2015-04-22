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
     final path_obj = "refactoring_objs/testiram_cijelu_traku_krivulja11.obj";
     final ship_obj = "";
     final track_obj = "refactoring_objs/testiram_cijelu_traku_traka11.obj";
     final obstacle_obj = "";
     final scoreItem_obj = "";
     
     final ship_texture = "refactoring_objs/crate.png";
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
     
     double side = 0.4;
     PerspectiveCamera splineCamera;
     
     ObjectManager() 
     {
          parser = new Parser();
          resources = [];
          resources.add(path_obj);
          resources.add(track_obj);
     }       
     
     handleGeometries(Object3D parent, List<Geometry> geometries)
     {
          //geometries[0] => path;
          var curve = new ClosedSplineCurve3(geometries[0].vertices);
          TubeGeometry tube = new TubeGeometry(curve, curve.points.length - 1, 1.0, 1, false, false);
          path = new Path(tube.binormals, tube.tangents.length, tube.path);
          
          //geometries[1] => track          
          Texture tex = ImageUTILS.loadTexture(track_texture);
          MeshPhongMaterial track_material = new MeshPhongMaterial(map: tex);
          track = new Mesh(geometries[1], track_material);
          parent.add(track);
          
          //movingObject
          double movingCam_fov = 75.0;
          double movingCam_near = 0.1;
          double movingCam_far = 5000.0;
          Vector3 movingCam_pos = new Vector3(0.0, side, side * 6.0); //parented to moving object
          Vector3 movingCam_lookAt = new Vector3.zero();
          Vector3 spotlightFollower_lookAt = new Vector3.zero();
          
          Texture t = ImageUTILS.loadTexture(ship_texture);
          ship = new Mesh(new CubeGeometry(side, side, side), new MeshBasicMaterial(map: t));
          
          splineCamera = new PerspectiveCamera(movingCam_fov, window.innerWidth / window.innerHeight, movingCam_near, movingCam_far);
          splineCamera.position.setFrom(movingCam_pos);
          splineCamera.lookAt(movingCam_lookAt);
          PointLight pointlightFollower = new PointLight(0xffffff, intensity: 0.5, distance: 0.0);
          pointlightFollower.position.setFrom(new Vector3(0.0, side / 2, 0.0));
          pointlightFollower.lookAt(spotlightFollower_lookAt);
          ship.add(splineCamera);
          ship.add(pointlightFollower);
          parent.add(ship);
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
     ClosedSplineCurve3 curve;
     
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