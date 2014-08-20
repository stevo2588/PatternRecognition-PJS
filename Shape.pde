// Stephen Aldriedge, 2013



// IMPORTANT: You probably won't need to modify anything in this file!!!

// Shape center is always at (0,0)
class Shape {
  Shape(PVector[] verts) {
    vertCount = verts.length;
    this.verts = verts;
  }

  private PVector[] verts;
  private int vertCount;

  int getVertCount() {
    return vertCount;
  }
  PVector getVert(int i) {
    return verts[i];
  }
}

// helper function
float angleBetween (PVector v1, PVector v2) {
  float a = atan2(v1.y, v1.x) - atan2(v2.y,v2.x);
  return a;
}

class TouchShape {
  Shape shape;
  boolean active;
  Touch[] touches;
  int count;
  int tolerance;
  PVector pos;
  PVector firstToSecond;
  PVector firstToPos;
  float rotAngle;

  float[] distToFirst;

  TouchShape(Shape s, int tol) {
    shape = s;
    active = false;
    count = s.vertCount;
    touches = new Touch[count];

    tolerance = tol;

    pos = new PVector(0,0);

    firstToSecond = PVector.sub(shape.getVert(0), shape.getVert(1));
    firstToPos = new PVector(-shape.getVert(0).x, -shape.getVert(0).y);

    rotAngle = 0;

    distToFirst = new float[count-1];
    for(int i=1; i<count; i++) {
      distToFirst[i-1] = shape.getVert(0).dist(shape.getVert(i));
    }
    
  }

  void updateTransform() {
    // TODO: fix so rotation is around pos
    PVector curFirstToSecond = new PVector(touches[1].offsetX - touches[0].offsetX,
                                           touches[1].offsetY - touches[0].offsetY);

    rotAngle = angleBetween(curFirstToSecond, firstToSecond);

    // update position
    pos.x = firstToPos.x + touches[0].offsetX;
    pos.y = firstToPos.y + touches[0].offsetY;
  }

  boolean tryPoints(ArrayList t) {
    int tSize = t.size();
    if(tSize < count) return false;

    int[] allPtIndex = new int[30];


    // for each point in t
    for(int i=0; i<tSize; i++) {
      ArrayList potential = new ArrayList();
      potential.add((Touch)t.get(i));
      ArrayList check = new ArrayList(t);
      PVector curPt = new PVector(((Touch)t.get(i)).offsetX, ((Touch)t.get(i)).offsetY);
      int tSize2 = tSize;
      // for each distance we are looking for
      for(int j=0; j<count-1; j++) {
        // check all distances to the current point
        for(int ptIndex=0; ptIndex < tSize2; ptIndex++) {
          // no need to check distance between current point and itself
          if(ptIndex == i) continue;
          
          float dist = curPt.dist(new PVector(((Touch)check.get(ptIndex)).offsetX,
                                              ((Touch)check.get(ptIndex)).offsetY));
          
          
          if((distToFirst[j] + tolerance < dist) ||
             (distToFirst[j] - tolerance > dist)) continue;
          
          potential.add((Touch)check.get(ptIndex));
          check.remove(ptIndex);
          ptIndex--;
          tSize2--;
            
        }
        
      }

      // if everything matched then set the touch array and return true
      if(potential.size() == count) {
        for(int m=0; m<count; m++) {
          touches[m] = (Touch)potential.get(m);
        }
        return true;
      }
    }

    return false;
  }

  void touchStart(ArrayList unassigned) {
    if(!active) {
      if(tryPoints(unassigned)) {
        active = true;
      }
    }
  }
  
  void touchMove(TouchEvent touchEvent) {
    // The only thing we need to do here (making the assumption that tangibles
    // can't have separately moving points) is update the transform (object position and
    // rotation)
    if(active) updateTransform();
  }

  void touchEnd(TouchEvent touchEvent) {
    if(!active) return;
    
    for(int i=0; i<count; i++) {
      for(int j=0; j<touchEvent.changedTouches.length; j++) {
        if( touchEvent.changedTouches[j] == touches[i] ) {
          active = false;
          return;
        }
      }
    }
  }

  void draw() {
    resetMatrix();
    translate(pos.x, pos.y);
    rotate(rotAngle);

    fill(0,255,255);
    ellipse(0, 0, 70, 70);
  }
}


