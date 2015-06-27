import 'package:three/three.dart' hide Path;
import 'package:vector_math/vector_math.dart';
import 'dart:math';
import 'ObjectManager.dart';

/**
 * Class used to generate Game obstacles and score items.
 */

class CoreManager
{
    //Fine tuning interface
    double Lref   = 20.0;
    double dtref  = 0.03;
    double dist   = 0.8;
    //defines a coefficient by which to expand (> 1.0) or compress (< 1.0) bounding boxes of obstacle items
    double obstacleBoxSquish  = 0.5;
    //defines a coefficient by which to expand (> 1.0) or compress (< 1.0) bounding boxes of scoreItem items
    double scoreItemBoxSquish = 0.9;
    //valid t values for scoreitem/obstacle horizontal position  
    List globalTs = [];
    //maximum vertical offset from middle (binormal multiplier)
    double strafeOffset; 
    
    ObjectManager objM;
    Object3D parent;
    Random random; 
    CoreManager();
    List vertPositions = [0, 1, 2, 3];

   /**From three.dart/extras/core/curve.daat - getUtoTmapping quote:
    * "// less likely to overflow, though probably not issue here
    *  // JS doesn't really have integers, all numbers are floats."
    * 
    * In some cases, getUtoTmapping produced "i" value for which the 
    * arcLengths[] array exceeded its length thus throwing the OutOfBoundsException,
    * which explaing the quote. 
    * 
    * Not sure if this fix affects JS, but it affects Dartium.    
    */     
   int bugFix = 1;
   
   generate(Object3D pp, ObjectManager m, double s)
   {
        objM = m;
        parent = pp;
        strafeOffset = s;
        
        random = new Random(new DateTime.now().millisecondsSinceEpoch);
        double L = objM.path.length; 
        double dt = (Lref * dtref / L);

        double sum = 0.0; 
        double t = 0.0;
        t += dt;

        Vector3 previous = objM.path.getPoint(t);           

        while (t <= 1.0 + dt)
        {
             Vector3 current = objM.path.getPoint(t);

             double diff = current.absoluteError(previous);

             sum = sum + diff;

             if (sum >= dist) 
             {
                  globalTs.add(t);
                  sum = 0.0;
             }

             previous.setFrom(current.clone());
             t += dt;
        }

      int patchSize;    //3/4/5
      int voidSize;     //0/1/2/3
      int ignoreFirstN  = 5; 
      int ignoreLastN   = 2; 
      int currentT      = 0 + ignoreFirstN;
      int totalT        = globalTs.length - bugFix - ignoreLastN; 

      int previousVertPos = random.nextInt(4);
      int nextVertPos;

      while (currentT < totalT) 
      {
         voidSize = random.nextInt(4);
         
         if(currentT + voidSize > totalT)
         {
              break;
         }
         
         nextVertPos = generateNextVerticalIndex(previousVertPos, voidSize);
         
         if (voidSize != 0) 
         {
              generateVoidData(previousVertPos, nextVertPos, globalTs.sublist(currentT, currentT + voidSize), voidSize);
              currentT += voidSize; //pomakni se udesno
         }
         
         patchSize = random.nextInt(3) + 3;
         
         if(currentT + patchSize > totalT)
         {
              break;
         }         
         
         generatePatchData(nextVertPos, globalTs.sublist(currentT, currentT + patchSize), patchSize);
         currentT += patchSize;
         
         previousVertPos = nextVertPos;
      }     
      
      parent.updateMatrixWorld(force: true);
      objM.initHitStatus(); 
  }

   /**
    * Used in [generateItemPosition] to retrieve value of a 
    * binormal vector on a curve.
    * [t] - value in range [0.0, 1.0] where 0.0 represents the start
    * of the curve and 1.0 the end.
    */
   Vector3 getBinormal(double t)
   {
      Vector3 tangent = objM.path.getTangentAt(t);
      Vector3 normal = new Vector3(0.0, 1.0, 0.0);
      Vector3 binormal = new Vector3.zero();
      binormal = normal.clone().crossInto(tangent, binormal);
      binormal.normalize().scale(strafeOffset);
      
      return binormal;
   }

   /**
    * Generates score and obstacle item positions for the patch field.
    * [reserved] is used in calculating positions for score items and to flag
    * the reserved position for obstacle items.
    * [subTs] array of valid "t" values for the horizontal position.
    * [patchSize] value to switch on for different number of obstacles.
    * [subTs.length] is equal to [patchSize].
    */
   void generatePatchData(int reserved, List subTs, int patchSize)
   {
      //Add score items in a horizontal patch at same position on each T
      for(double t in subTs)
      {
         addScoreItem(generateItemPosition(t, reserved, reserved));
      }
      
      if(patchSize == 3)
      {
         if(random.nextInt(2) == 0)
              return;
         else
         {
            int whichT = random.nextInt(3); 
            Positions p = generateVerticalPositions(reserved);
            addObstacle(generateItemPosition(subTs[whichT], p._last, p._next));
         }
      }
      
      if(patchSize == 4)          
      {
         int whichT = random.nextInt(4);          
         Positions p = generateVerticalPositions(reserved);
         addObstacle(generateItemPosition(subTs[whichT], p._last, p._next));
      }
      
      if(patchSize == 5)
      {
         int whichT = random.nextInt(5);          
         Positions p = generateVerticalPositions(reserved);
         addObstacle(generateItemPosition(subTs[whichT], p._last, p._next));
         subTs.removeAt(whichT);
         
         if(random.nextInt(2) == 0)
         {
            return;
         }
         else
         {
            int whichT = random.nextInt(4);
            Positions p = generateVerticalPositions(reserved);
            addObstacle(generateItemPosition(subTs[whichT], p._last, p._next));
         }                 
      }
   }

   /**
    * Used to add obstacles to patch field.
    * [reserved] value represents the vertical position at
    * which the obstacles can not live for the current patch field.
    */
   Positions generateVerticalPositions(int reserved)
   {
        List temp = vertPositions.toList();
        temp.remove(reserved);
        
        int lastPosition;
        int nextPosition;
        
        int rnd = random.nextInt(temp.length);
        int generated = temp[rnd]; 
        
        if(generated > reserved)
        {
             lastPosition = reserved + 1;
             nextPosition = temp.last;
        }
        else
        {
             lastPosition = temp.first;
             nextPosition = reserved - 1;
        }
        
        return new Positions(lastPosition, nextPosition);     
   }

   /**
    * Depending on the [voidSize], instantiate new obstacle items.
    * Obstacle horizontal position is determined from [subTs] elements.
    * Obstacle vertical position is calculated from the vertical alignment
    * of score items of the trailing and following patch field, namely
    * [previous] and [next].
    */
   void generateVoidData(int previous, int next, List subTs, int voidSize) 
   { 
      if(voidSize == 0)
      {
          return;
      }
      
      if(voidSize == 1)
      {
          if(random.nextInt(2) == 0)
          {
             return;
          }
          else
          {
             addObstacle(generateItemPosition(subTs[0], previous, next));  
          }         
      }
      
      if(voidSize == 2)
      {
          int whichT = random.nextInt(2); 
          addObstacle(generateItemPosition(subTs[whichT], previous, next));
      }
      
      if(voidSize == 3)
      {
          int whichT = random.nextInt(3);
          addObstacle(generateItemPosition(subTs[whichT], previous, next));
          if(random.nextInt(2) == 0)
          {
             return;
          }
          else
          {
             subTs.removeAt(whichT);
             int rnd = random.nextInt(2);
             addObstacle(generateItemPosition(subTs[rnd], vertPositions.first, vertPositions.last));
          }
      }
   }

   void generateBoundingBox(Mesh mesh)
   {
      double coeff;
      
      if(mesh is ScoreItem)
        coeff = scoreItemBoxSquish;
      if(mesh is Obstacle)
        coeff = obstacleBoxSquish;
      
      mesh.geometry.boundingBox = new BoundingBox.fromObject(mesh);
      
      Vector3 min = mesh.geometry.boundingBox.min;
      Vector3 max = mesh.geometry.boundingBox.max;
      Vector3 center = mesh.geometry.boundingBox.center.clone();
      min.setFrom(min.sub(center).scale(coeff).add(center).clone());
      max.setFrom(max.sub(center).scale(coeff).add(center).clone());
   }
   
   void addScoreItem(Vector3 position)
   {
      ScoreItem scoreItemMesh = objM.instantiateScoreItem();
      scoreItemMesh.position.setFrom(position);    
      
      generateBoundingBox(scoreItemMesh);
      parent.add(scoreItemMesh);
      objM.assets.add(scoreItemMesh);
   }

   void addObstacle(Vector3 position)
   {
      int whichObstacle = random.nextInt(ObjectManager.NR_OF_OBSTACLES);
      int rotation = random.nextInt(360);
      Obstacle obstacleMesh = objM.instantiateObstacle(whichObstacle);
      obstacleMesh.position.setFrom(position);  
      obstacleMesh.rotation.y = rotation * PI / 360.0;
      generateBoundingBox(obstacleMesh);
      parent.add(obstacleMesh);
      objM.assets.add(obstacleMesh);
   }

   /**
    * Computes the final position of an score or obstacle item.
    * [t] - vertical position
    * [previous] - previous horizontal position
    * [next] - next horizontal position
    */
   Vector3 generateItemPosition(double t, int previous, int next)
   {
      double percent = generateVerticalPercentage(previous, next);
      double binormalScale = percent <= 0.5 ? (1 - percent * 2.0) : (2.0 * (percent - 0.5));
      
      Vector3 binormal = getBinormal(t);
      binormal = percent > 0.5 ? binormal.negate() : binormal;
      binormal.scale(binormalScale);
      
      Vector3 position = objM.path.getPoint(t);
      Vector3 finalPosition = binormal + position;
      
      return finalPosition;      
   }

   /**
    * The graph:
    * 0 ----------------------- ^ - 0%
    * 1 ----------------------- |
    * 2 ----------------------- |
    * 3 ----------------------- v - 100%
    * 
    * Numbers [0-3] represent all possible vertical indices for an item.
    * Given two such numbers, calculate the possible range (in %) for the items' vertical position.  
    */
   double generateVerticalPercentage(int first, int second)
   {
      double max = 0.9;
      double min = 0.1;
      double third = (max - min) / 3;
      
      double lowerBound;
      double upperBound;          
      double result;
      
      if(first == second)
      {
           result = min + first * third; 
      }
      else if((first - second).abs() == 3)
      {
           lowerBound = min;
           upperBound = max;
           result = generateRandomDoubleBounds(lowerBound, upperBound);
      }
      else
      {
           int lower = first < second ? first : second;
           int higher = first > second ? first : second;
           
           lowerBound = lower * third + min;
           upperBound = higher * third + min;
           
           result = generateRandomDoubleBounds(lowerBound, upperBound);
      }
      
      return result;
   }

   /**Returns a double number expressed as a percentage in interval [0.0, 100.0]
    * [lower] is a number in range [0.0, 1.0];
    * [higher] is a number in range [0.0, 1.0];
    */
   double generateRandomDoubleBounds(double lower, double higher)
   {
      return (generateRandomDoubleBoundsPercentage(lower,higher)) / 100.0;
   }

   /**Returns a double number expressed in interval [0.0, 1.0]
    * [lower] is a number in range [0.0, 1.0];
    * [higher] is a number in range [0.0, 1.0];
    */
   double generateRandomDoubleBoundsPercentage(double lower, double higher)
   {
      return random.nextInt(((higher + 0.01 - lower) * 100).toInt()) + (lower*100);
   }

   /**Returns an int number expressed in interval [0, 100]
    * [lower] is a number in range [0, 100];
    * [higher] is a number in range [0, 100];
    */
   int generateRandomIntBounds(int lower, int higher)
   {
      return random.nextInt((higher + 1) - lower) + lower;
   }

   /**
    * Given the [previous] vertical index of a patch field score items
    * and the [voidSize] of the following void field, calculate the new
    * vertical index for the following patch field score items.
    */
   int generateNextVerticalIndex(int previous, int voidSize) 
   {
      if (voidSize > 1) 
      {
         return random.nextInt(4);
      }
      else 
      {
         int deviate = voidSize + 1;
         int lowerBound;
         int upperBound;

         upperBound = ((previous + deviate) >= 3) ? 3 : previous + deviate;
         lowerBound = ((previous - deviate) < 0) ? 0 : previous - deviate;

         return generateRandomIntBounds(lowerBound, upperBound);
      }
   }
}

class Positions
{
     int _last;
     int _next;
     
     Positions(this._last, this._next);
}