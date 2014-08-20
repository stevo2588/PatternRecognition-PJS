// Stephen Aldriedge, 2013

int windowWidth = 960;
int windowHeight = 630;

String debugmsg = "";


// FOR DEBUGGING PURPOSES: If you need to run this on your computer to check for errors and
// such, uncomment the DEBUG code below. Make sure to leave it commented when you are running
// the code on a mobile device.
/*
//------------------ DEBUG BEGIN -------------------------------------------------------------
class Touch {
	Touch(int x, int y) {
		offsetX = x;
		offsetY = y;
	}
	Touch(float x, float y) {
		offsetX = (int)x;
		offsetY = (int)y;
	}

	int offsetX, offsetY;
}
class TouchEvent {
	TouchEvent(Touch[] t) {
		touches = t;
		changedTouches = t;
	}

	Touch[] touches;
	Touch[] changedTouches;
}

PVector[] pts;
TouchEvent te;

void touchSimulateSetup() {
	pts = new PVector[3];
	pts[0] = new PVector(-57, -12);
	pts[1] = new PVector(-10, 42);
	pts[2] = new PVector(68, -30);
}

void mousePressed() {
	Touch[] simTouchPts = new Touch[3];
	simTouchPts[0] = new Touch(pts[0].x+mouseX, pts[0].y+mouseY);
	simTouchPts[1] = new Touch(pts[1].x+mouseX, pts[1].y+mouseY);
	simTouchPts[2] = new Touch(pts[2].x+mouseX, pts[2].y+mouseY);
	te = new TouchEvent(simTouchPts);

	touchStart(te);
}

void mouseDragged() {
	//debugmsg = str(mouseX);
	te.touches[0].offsetX = (int)pts[0].x+mouseX;
	te.touches[0].offsetY = (int)pts[0].y+mouseY;
	te.touches[1].offsetX = (int)pts[1].x+mouseX;
	te.touches[1].offsetY = (int)pts[1].y+mouseY;
	te.touches[2].offsetX = (int)pts[2].x+mouseX;
	te.touches[2].offsetY = (int)pts[2].y+mouseY;
	te.changedTouches = te.touches;
	touchMove(te);
}

void mouseReleased() {
	te.changedTouches = te.touches;
	te.touches = new Touch[0];
	touchEnd(te);
}
//----------------- DEBUG END ----------------------------------------------------------------
*/

PFont f;

ArrayList tShapes;
ArrayList unassigned; // ArrayList to hold unassigned touches

//--------------- Derive your own class from TouchShape class ------------------
class MyObject extends TouchShape {
	MyObject(Shape s, int tol) {
		super(s,tol);
	}
	// create your own draw method here
	void draw() {
		resetMatrix();
		translate(pos.x, pos.y);
		rotate(rotAngle);

		// draw shape here
		fill(0,255,255);
		strokeWeight(10);
		stroke(0,255,255);
		line(0, 30, 0, -100);
		ellipse(0, 30, 70, 70);
		fill(255,0,0);
		ellipse(-20, 30, 20, 20);
		ellipse(20, 30, 20, 20);
	}
}
/*
class MyObject2 extends TouchShape {
	MyObject2(Shape s, int tol) {
		super(s,tol);
	}
	// create your own draw method here
	void draw() {
		resetMatrix();
		translate(pos.x, pos.y);
		rotate(rotAngle);

		// draw shape here
		fill(255,0,0);
		strokeWeight(10);
		stroke(255,0,0);
		line(0, 30, 0, -100);
		ellipse(0, 30, 70, 70);
		fill(0,255,255);
		ellipse(-20, 30, 20, 20);
		ellipse(20, 30, 20, 20);
	}
}
*/

//----------------- SETUP ----------------------------------
void setup() {

	//---------- DEBUG ---------------------
	//touchSimulateSetup();
	//---------- DEBUG END -----------------

	size( windowWidth , windowHeight );
	background( 0 );
	f = createFont("Arial",16,true);
	
	smooth();
	tShapes = new ArrayList();
	unassigned = new ArrayList();

	//-------------- Create shapes to use -----------------------
	PVector[] shVerts01 = new PVector[3];
	shVerts01[0] = new PVector(-57, -12);
	shVerts01[1] = new PVector(-10, 42);
	shVerts01[2] = new PVector(68, -30);

	PVector[] shVerts02 = new PVector[1];
	shVerts02[0] = new PVector(0,0);


	//--------------- Register shapes --------------------------
	registerShape(new MyObject(new Shape(shVerts01), 8));
	//registerShape(new MyObject2(new Shape(shVerts02), 8));
}

//------------------- DRAW ----------------------------------------
void draw() {
	background( 0 );
	
	pushMatrix();

	int shSize = tShapes.size();
	for(int i=0; i<shSize; i++) {
		if(((TouchShape)tShapes.get(i)).active) {
			((TouchShape)tShapes.get(i)).draw();
		}
	}

	popMatrix();

	textFont(f,36);
	fill(255);
	text("dbg: " + debugmsg, 10, windowHeight-30);
	debugmsg = "";
}

// register shapes to use
void registerShape(TouchShape ts) {
	tShapes.add(ts);
}

void showPatternCoordinates(TouchEvent touchEvent) {
	int touchCount = touchEvent.touches.length;

	//calculate central pt
	int xTotal=0, yTotal=0;
	for(int i=0; i<touchCount; i++) {
		Touch curTouch = touchEvent.touches[i];
		xTotal += curTouch.offsetX;
		yTotal += curTouch.offsetY;
	}

	PVector centralPt = new PVector(xTotal/touchCount, yTotal/touchCount);


	for(int i=0; i<touchCount; i++) {
		Touch curTouch = touchEvent.touches[i];
		debugmsg += "(" + str(curTouch.offsetX - (int)centralPt.x) + "," +
		                  str(curTouch.offsetY - (int)centralPt.y) + ") ";
	}
}

void touchStart(TouchEvent touchEvent) {
	// Uncomment this if you want to see the coordinates of your pattern
	//showPatternCoordinates(touchEvent);

	for(int i=0; i<touchEvent.changedTouches.length; i++) {
		unassigned.add( touchEvent.changedTouches[i] );
	}


	int shSize = tShapes.size();
	for(int i=0; i<shSize; i++) {
		TouchShape curShape = (TouchShape)tShapes.get(i);
		// skip shapes that are already active
		if(curShape.active) continue;

		// notify it of a touchMove event
		curShape.touchStart(unassigned);
		// if shape became active
		if(curShape.active) {
			// remove its touches from the unassigned list
			for(int j=0; j<curShape.count; j++) {
				unassigned.remove(curShape.touches[j]);
			}
		}
	}


}

// respond to multitouch events
void touchMove(TouchEvent touchEvent) {

	int shSize = tShapes.size();
	for(int i=0; i<shSize; i++) {
		// notify it of a touchMove event
		((TouchShape)tShapes.get(i)).touchMove(touchEvent);
	}
}

void touchEnd(TouchEvent touchEvent) {
	int removeCount = touchEvent.changedTouches.length;

	// see if the lifted touches were in the unassigned list
	for(int i=0; i<touchEvent.changedTouches.length; i++) {
		if(unassigned.contains(touchEvent.changedTouches[i])) {
			unassigned.remove(touchEvent.changedTouches[i]);
			removeCount--;
		}
	}

	if( removeCount == 0 ) return;

	int shSize = tShapes.size();
	for(int i=0; i<shSize; i++) {
		// notify it of a touchEnd event
		((TouchShape)tShapes.get(i)).touchEnd(touchEvent);
	}
}


