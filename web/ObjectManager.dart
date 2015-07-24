library ObjectManager;
import 'package:three/three.dart';
import 'package:vector_math/vector_math.dart';
import 'package:three/extras/image_utils.dart' as ImageUTILS;
import 'dart:html';
import 'dart:math' show PI;

/**
* Contains path values to object resources (such as geometry and texture data).
* Performs deserialization of .obj files and construction of Object3D and Geometry objects.
*/
class ObjectManager
{
  static const String suffix = ".obj";
  final path_obj = "models/path" + suffix;
  final ship_obj = "models/ship" + suffix;
  final corridor_obj = "models/corridor" + suffix;
  final asset_box_obj = "models/box" + suffix;
  final asset_barrel_obj = "models/barrel" + suffix;
  final asset_score_item_obj = "models/score_item" + suffix;
  final ship_texture = "textures/ship.png";
  final assets_texture = "textures/assets.png";
  final corridor_texture = "textures/corridor.png";
  
  Curve3D path;
  Object3D ship;
  Object3D corridor;
  Object3D assetBox;
  Object3D assetBarrel;
  Object3D scoreItem;
  
  List resources;
  List assets = [];
  List assetHitStatus = [];
  PerspectiveCamera splineCamera;
  static const int ASSET_BOX = 0;
  static const int ASSET_BARREL = 1;
  static const int NR_OF_OBSTACLES = 2;
  
  ObjectManager()
  {
      resources = [];
      resources.add(path_obj);
      resources.add(corridor_obj);
      resources.add(ship_obj);
      resources.add(asset_box_obj);
      resources.add(asset_barrel_obj);
      resources.add(asset_score_item_obj);
  }
  
  handleGeometries(Object3D parent, List<Geometry> geometries)
  {
      //geometries[0] => path;
      var curve = new ClosedSplineCurve3(geometries[0].vertices);
      TubeGeometry tube = new TubeGeometry(curve, curve.points.length - 1, 1.0, 1, false, false);
      path = tube.path;

      //geometries[1] => corridor
      Texture tex = ImageUTILS.loadTexture(corridor_texture);
      corridor = new Mesh(geometries[1], new MeshBasicMaterial(map: tex));
      parent.add(corridor);

      //geometries[2] => ship
      double cameraFov = 75.0;
      double cameraNear = 0.1;
      double cameraFar = 5000.0;
      Vector3 cameraPosition = new Vector3(0.0, 0.5, 0.5);
      Vector3 cameraLookAt = new Vector3(0.0, 0.0, -0.8);
      Texture shipTex = ImageUTILS.loadTexture(ship_texture);
      ship = new Mesh(geometries[2], new MeshBasicMaterial(map: shipTex));
      ship.geometry.computeBoundingBox();
      splineCamera = new PerspectiveCamera(cameraFov,
                                           window.innerWidth / window.innerHeight, cameraNear, cameraFar);
      splineCamera.position.setFrom(cameraPosition);
      splineCamera.lookAt(cameraLookAt);
      PointLight pointlightFollower = new PointLight(0xffffff, intensity: 0.5, distance: 0.0);
      pointlightFollower.position.setFrom(new Vector3.zero()); //TODO extract variable
      pointlightFollower.lookAt(new Vector3.zero());
      ship.add(splineCamera);
      ship.add(pointlightFollower);
      ship.rotation.y = -90 * PI/180.0;
      parent.add(ship);

      //global texture for assets
      Texture texAssets = ImageUTILS.loadTexture(assets_texture);
      //geometries[3] => box
      assetBox = new Obstacle(geometries[3], new MeshBasicMaterial(map: texAssets));
      //geometries[4] => barrel
      assetBarrel = new Obstacle(geometries[4], new MeshBasicMaterial(map: texAssets));
      //geometries[5] => score_item
      scoreItem = new ScoreItem(geometries[5], new MeshBasicMaterial(map: texAssets));
    }
  
    ScoreItem instantiateScoreItem()
    {
      return new ScoreItem
        (cloneGeometry(scoreItem.geometry), scoreItem.material);
    }
  
    Obstacle instantiateObstacle(int which)
    {
      switch(which)
      {
        case ASSET_BOX:
        return new Obstacle(cloneGeometry(assetBox.geometry), assetBox.material);
        case ASSET_BARREL:
        return new Obstacle(cloneGeometry(assetBarrel.geometry), assetBarrel.material);
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
  
    resetAssetsState()
    {
      for (int i = 0; i < assets.length; i++)
      {
        (assets[i] as Mesh).visible = true;
        assetHitStatus[i] = false;
      }
    }
  
    updateAssetsState(int index)
    {
      (assets[index] as Mesh).visible = false;
      assetHitStatus[index] = true;
    }
  
    initHitStatus()
    {
      for(int i = 0; i < assets.length; i++)
      {
        assetHitStatus.add(false);
      }
    }
  
    getHitStatus(int index)
    {
      return assetHitStatus[index];
    }
}

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