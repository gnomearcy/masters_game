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
     static const String suffix = "_1.obj";
     final path_obj = "refactoring_objs/curve_final" + suffix;
     final ship_obj = "refactoring_objs/ship_final" + suffix;
     final track_obj = "refactoring_objs/corridor_final" + suffix;
     final obstacle_box_obj = "refactoring_objs/box_final" + suffix;
     final obstacle_barrel_obj = "refactoring_objs/barrel_final" + suffix;
     final scoreItem_obj = "refactoring_objs/scoreitem_final" + suffix;
     
//     final path_obj = "refactoring_objs/curve_test_sirine" + suffix;
//     final ship_obj = "refactoring_objs/ship_test_sirine_small" + suffix;
//     final track_obj = "refactoring_objs/corridor_test_sirine_fixed" + suffix;
//     final obstacle_box_obj = "refactoring_objs/obstacle_box" + suffix;
//     final obstacle_barrel_obj = "refactoring_objs/obstacle_barrel" + suffix;
//     final scoreItem_obj = "refactoring_objs/score_item" + suffix;
     
     final ship_texture = "refactoring_objs/ship_uv_layout_textured_1.png";
     final track_texture = "refactoring_objs/corridor_uv_layout_2048_1_textured_1.png";
     final asset_texture = "refactoring_objs/asset_uv_layout_2048_3_textured2.png";
     
     int nekibroj;
     bool useBasic = true;
//     Path path;
     int segments;
     Curve3D path;
     Object3D ship;
     Object3D track;
     Object3D obstacleBox;
     Object3D obstacleBarrel;
     Object3D scoreItem;
     
     Parser parser;
     List resources;
     List hitObjects = [];    //collision array
     
     double side = 0.2;
     PerspectiveCamera splineCamera;
     
     static const int OBSTACLE_BOX = 0;
     static const int OBSTACLE_BARREL = 1;
     static const int NR_OF_OBSTACLES = 2;
     
     ObjectManager() 
     {
          parser = new Parser();
          resources = [];
          resources.add(path_obj);
          resources.add(track_obj);
          resources.add(ship_obj);
          resources.add(obstacle_box_obj);
          resources.add(obstacle_barrel_obj);
          resources.add(scoreItem_obj);
     }       
     
     handleGeometries(Object3D parent, List<Geometry> geometries)
     {
          //geometries[0] => path;
          var curve = new ClosedSplineCurve3(geometries[0].vertices);
          TubeGeometry tube = new TubeGeometry(curve, curve.points.length - 1, 1.0, 1, false, false);
          segments = tube.segments.length;
          path = tube.path;
          
          //geometries[1] => track          
          Texture tex = ImageUTILS.loadTexture(track_texture);
          Material track_material;
          
          if(useBasic)
              track_material = new MeshBasicMaterial(map: tex);
          else
              track_material = new MeshPhongMaterial(map: tex);
          track = new Mesh(geometries[1], track_material);
//          track = new Mesh(geometries[1]);
          parent.add(track);
          
          //geometries[2] => ship
          double movingCam_fov = 75.0;
          double movingCam_near = 0.1;
          double movingCam_far = 5000.0;
//          Vector3 movingCam_pos = new Vector3(0.0, 0.2, 0.4 * 6.0); //parented to moving object
          Vector3 movingCam_pos = new Vector3(0.0, 0.5, 0.5);
          Vector3 movingCam_lookAt = new Vector3(0.0, 0.0, -0.8);
          
          //Following values test the obstacle box collision
//          Vector3 movingCam_pos = new Vector3(0.0, 0.4, -0.7);
//          Vector3 movingCam_lookAt = new Vector3(0.0, 0.0, -0.7);
          
          Vector3 spotlightFollower_lookAt = new Vector3.zero();
          Texture shipTex = ImageUTILS.loadTexture(ship_texture);
          
          Material ship_material;
          if(useBasic)
              ship_material = new MeshBasicMaterial(map: shipTex);
          else
              ship_material = new MeshPhongMaterial(map: shipTex);
//          MeshBasicMaterial ship_material = new MeshBasicMaterial(map: shipTex);
//          MeshPhongMaterial ship_material = new MeshPhongMaterial(map: shipTex);

          ship = new Mesh(geometries[2], ship_material);
          ship.geometry.computeBoundingBox();
          
          splineCamera = new PerspectiveCamera(movingCam_fov, window.innerWidth / window.innerHeight, movingCam_near, movingCam_far);
          splineCamera.position.setFrom(movingCam_pos);
          splineCamera.lookAt(movingCam_lookAt);
          PointLight pointlightFollower = new PointLight(0xffffff, intensity: 0.5, distance: 0.0);
//          pointlightFollower.position.setFrom(new Vector3(0.0, 5.0 / 2, 0.0)); //TODO extract variable
          pointlightFollower.position.setFrom(new Vector3(0.0, 0.0, 0.0)); //TODO extract variable
          pointlightFollower.lookAt(spotlightFollower_lookAt);
          ship.add(splineCamera);
          ship.add(pointlightFollower);          
          parent.add(ship);
          
          //global texture for assets
          Texture texAssets = ImageUTILS.loadTexture(asset_texture);
          
          //geometries[3] => obstacle box
          Material obstacleBoxMat;
           if(useBasic)
             obstacleBoxMat = new MeshBasicMaterial(map: texAssets);
           else
             obstacleBoxMat = new MeshPhongMaterial(map: texAssets);
//          MeshPhongMaterial obstacleBoxMat = new MeshPhongMaterial(map: texAssets);          
//          MeshBasicMaterial obstacleBoxMat = new MeshBasicMaterial(map: texAssets);
          obstacleBox = new Obstacle(geometries[3], obstacleBoxMat);
//          parent.add(obstacle_box);
          
          //geometries[4] => obstacle barrel
          Material obstacleBarrelMat;
           if(useBasic)
             obstacleBarrelMat = new MeshBasicMaterial(map: texAssets);
           else
             obstacleBarrelMat = new MeshPhongMaterial(map: texAssets);
//          MeshPhongMaterial obstacleBarrelMat = new MeshPhongMaterial(map: texAssets);
//          MeshBasicMaterial obstacleBarrelMat = new MeshBasicMaterial(map: texAssets);
          obstacleBarrel = new Obstacle(geometries[4], obstacleBarrelMat);
//          parent.add(obstacle_barrel);     
          
          //geometries[5] => score item
//          MeshPhongMaterial scoreItemMat = new MeshPhongMaterial(map: texAssets);
          Material scoreItemMat;
           if(useBasic)
             scoreItemMat = new MeshBasicMaterial(map: texAssets);
           else
             scoreItemMat = new MeshPhongMaterial(map: texAssets);
//          MeshBasicMaterial scoreItemMat = new MeshBasicMaterial(map: texAssets);

          scoreItem = new ScoreItem(geometries[5], scoreItemMat);
     }
     
     //next two functions are used by coremanager to get a new copy of items
     ScoreItem instantiateScoreItem()
     {
        return new ScoreItem
            (cloneGeometry(scoreItem.geometry), scoreItem.material);
     }
     
     Obstacle instantiateObstacle(int which)
     {
       switch(which)
       {
         case OBSTACLE_BOX:
           return new Obstacle(cloneGeometry(obstacleBox.geometry), scoreItem.material);
         case OBSTACLE_BARREL:
           return new Obstacle(cloneGeometry(obstacleBarrel.geometry), scoreItem.material);
       }
       
       return null;
     }
     
     Geometry cloneGeometry(Geometry geoToClone)
     {
       Geometry clonedGeometry = new Geometry();
       
       geoToClone.faces.forEach((e) {
         clonedGeometry.faces.add(e.clone());
         });
       
       geoToClone.vertices.forEach((e) {
         clonedGeometry.vertices.add(e.clone());
         });
       
       geoToClone.normals.forEach((e) {
         clonedGeometry.normals.add((e as Vector3).clone());
         });
       
       geoToClone.faceUvs.forEach((e) {
         clonedGeometry.faceUvs.add(e);
         });
       
       geoToClone.faceVertexUvs.forEach((faceVertexUvs) {
           faceVertexUvs.forEach((faceVertexUv) {
             clonedGeometry.faceVertexUvs[0].add(faceVertexUv);
           });
         });
       
       clonedGeometry.faces.forEach((e) {
           (e as Face3).normal = (e as Face3).vertexNormals.first;
         });
               
       return clonedGeometry;
     }
     
}

//class Path
//{
//     List<Vector3> binormals;
//     int segments;
//     ClosedSplineCurve3 curve;
//     
//     Path(this.binormals, this.segments, this.curve);
//}

/*
 * Obstacle / ScoreItem classes - wrappers around Mesh type to provide
 * specific types to differentiate in process of collision detection.
 */ 
  
class Obstacle extends Mesh
{
     Obstacle(Geometry geometry, [Material material]) : super(geometry, material);
}

class ScoreItem extends Mesh
{
     ScoreItem(Geometry geometry, [Material material]) : super(geometry, material);
}