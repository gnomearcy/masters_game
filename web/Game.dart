library Game;

import 'package:three/three.dart';
import 'package:vector_math/vector_math.dart' hide Ray;

import 'dart:html';
import 'dart:async';
import 'dart:math';
import 'dart:core';

import 'Parser.dart';
import 'Keyboard.dart';
import 'HUDManager.dart';
import 'CoreManager.dart';
import 'TimeManager.dart';
import 'ObjectManager.dart';

Scene scene;
Parser parser;
Keyboard keyboard;
HUDManager hudManager;
CoreManager coreManager;
TimeManager timeManager;
WebGLRenderer renderer;
ObjectManager objectManager;

Matrix4 lookAtMatrix      = new Matrix4.identity();
Vector3 normalObject      = new Vector3(0.0, 1.0, 0.0); 
Vector3 tangentObject     = new Vector3.zero();
Vector3 positionObject    = new Vector3.zero();
Vector3 binormalObject    = new Vector3.zero();

//Gameplay
const countdownLength     = 4050;
int score                 = 0;
int health                = 3;
int previousTime          = 0;
int currentTime           = 0;
int elapsedTime           = 0;
int threshhold            = 250; 
int assetRotationDt       = 2;
bool countdownFinished    = false;
bool isStartVisible       = true;
bool isGameOver           = false;
bool isTimerRunning       = false;
bool isNewLap             = false;
double t                  = 0.0;
double strafe             = 0.6;
double radToDeg           = PI / 180.0;
double strafeDt           = strafe / 15.0;
double strafeMin          = -strafe;
double strafeMax          = strafe;
double currentStrafe      = 0.0;
double previousTimerTime  = 0.0;
double currentTimerTime   = 0.0;

void main() 
{
    initObjects();
    initDivs();
    
    var string_literals = objectManager.resources;
  
    Future
    .wait(string_literals.map(
      (literal) => HttpRequest.request(literal, responseType: "String")))
    .then((List<HttpRequest> responses) 
    {
      List<Object> rs = new List<Object>();
  
      for (HttpRequest r in responses) 
      {
        rs.add(r.response);
      }

      Future
      .wait(rs.map((response) => parser.parse(response)))
      .then((List<Geometry> geometries) 
      {
        objectManager.handleGeometries(scene, geometries);
        coreManager.generate(scene, objectManager, strafe);
        gameLoop(0);
      });
  });
}



gameLoop(num time) 
{
    if(countdownFinished)
    {
      if(!timeManager.isRunning)
      {
        timeManager.toggle();
      }
       
       if(!isGameOver)
       {
          update();
          collision();
       }     
    }
     
    renderer.render(
        scene, objectManager.splineCamera);
  
    window.requestAnimationFrame(gameLoop);
}

update() 
{
    t = timeManager.getCurrentTime();
    currentTimerTime = t;
    
    if(currentTimerTime < previousTimerTime)
    {
      isNewLap = true;
    }
    
    previousTimerTime = currentTimerTime;
    
    if(isNewLap)
    {
      objectManager.resetAssetsState();
      isNewLap = false;
    }
    
    currentTime = new DateTime.now().millisecondsSinceEpoch;
    elapsedTime = currentTime - previousTime;
    previousTime = currentTime;
    
    double percentage = elapsedTime / threshhold;
    double toMove = percentage * strafe;
      
    if(!(keyboard.isPressed(KeyCode.D) && keyboard.isPressed(KeyCode.A)))
    {
      if(keyboard.isPressed(KeyCode.A))
      {
        if(currentStrafe + toMove > strafe)
          currentStrafe = strafe;
        else
          currentStrafe += toMove;
      }
      
      if(keyboard.isPressed(KeyCode.D))
      {
        if(currentStrafe - toMove < -strafe)
          currentStrafe = -strafe;
        else
          currentStrafe -= toMove;
      }
    }
  
    positionObject = objectManager.path.getPointAt(t);
    tangentObject = -objectManager.path.getTangentAt(t);
    Vector3 eye = tangentObject.clone().normalize().add(positionObject);
  
    lookAtMatrix = makeLookAt(lookAtMatrix, eye, positionObject, normalObject);
    objectManager.ship.rotation = calcEulerFromRotationMatrix(lookAtMatrix);
  
    binormalObject = new Vector3.zero();
    binormalObject = normalObject
        .clone()
        .normalize()
        .crossInto(-tangentObject, binormalObject);
    
    binormalObject.multiply(new Vector3(currentStrafe, 0.0, currentStrafe));
    objectManager.ship.position.setFrom(positionObject.add(binormalObject));
    objectManager.ship.geometry.boundingBox =
        new BoundingBox.fromObject(objectManager.ship);
    
    scene.children.forEach((child)
    {
      if(child.runtimeType == ScoreItem)
      {
        (child as ScoreItem).rotation.y += assetRotationDt * radToDeg;
      }
    });
}

collision() 
{
    Mesh asset;
  
    for (int i = 0; i < objectManager.assets.length; i++) 
    {
      asset = objectManager.assets[i];
  
      if (asset.geometry.boundingBox
          .isIntersectionBox(objectManager.ship.geometry.boundingBox) && !objectManager.getHitStatus(i)) 
      {
        if (asset is ScoreItem)
        {
          hudManager.updateScore(++score);
        }
        if (asset is Obstacle) 
        {
          health--;
          if(health == 0)
          {
            isGameOver = true;
          }
          
          hudManager.updateHealth(health);
        }
        objectManager.updateAssetsState(i);
      }
    }
}

initDivs()
{
    hudManager.start.onClick.listen((event)
    {
        print("Starting countdown...");
        if(isStartVisible)
        {
          isStartVisible = false;
          const d = const Duration(milliseconds: countdownLength);
          new Timer.periodic(d, (Timer t) 
          {
            print("Stopping countdown!");
            t.cancel();
            countdownFinished = true; 
            isStartVisible = true;
          });
          
          hudManager.countdown();
        }
    });
    
    hudManager.tryAgain.onClick.listen((event)
    {
        resetGameState();
    });
}

initObjects() 
{
    scene         = new Scene();
    parser        = new Parser();
    keyboard      = new Keyboard();
    hudManager    = new HUDManager();
    coreManager   = new CoreManager();
    timeManager   = new TimeManager(forceStart: false);
    objectManager = new ObjectManager();
  
    renderer = new WebGLRenderer(antialias: true);
    renderer.setClearColor(new Color(0xf0f0f0), 1.0);
    renderer.setSize(window.innerWidth, window.innerHeight);
    renderer.domElement.id = "renderer";
    document.body.append(renderer.domElement);
}
resetGameState()
{
    objectManager.ship.rotation.y = -90 * PI/180.0;
    objectManager.ship.position.setFrom(new Vector3.zero());
    
    hudManager.reset();
    timeManager.reset();
    objectManager.resetAssetsState();
    
    score             = 0;
    health            = 3;    
    currentStrafe     = 0.0;
    
    currentTime       = 0;
    previousTime      = 0;
    currentTimerTime  = 0.0;
    previousTimerTime = 0.0;
    
    isNewLap          = false;
    isGameOver        = false;
    countdownFinished = false;
}