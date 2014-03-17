private static final int SCREEN_SIZE = 800;

private Delaunay delaunay = new Delaunay();
private boolean bRenderCC = true;

/*
 * Processing APIs
 */
void setup() {
  smooth(); 
}

void draw() {
  background(0);

  pushMatrix();
    delaunay.renderTriangles();
    if (bRenderCC) {
      //delaunay.renderCC();
    }
  popMatrix();
}

import android.view.MotionEvent;    // required import for fancy touch access
String touchEvent = "";    // string for touch event type
float pressure = 0.0;      // pressure and size variables
float pointerSize = 0.0;

// override the built-in method, getting data from it and passing the
// details on afterwards using the super.dispatchTouchEvent()
@Override
public boolean dispatchTouchEvent(MotionEvent event) {

  float x = event.getX();                              // get x/y coords of touch event
  float y = event.getY();
  
  int action = event.getActionMasked();          // get code for action
  pressure = event.getPressure();                // get pressure and size
  pointerSize = event.getSize();

  switch (action) {                              // let us know which action code shows up
  case MotionEvent.ACTION_DOWN:
    touchEvent = "DOWN";
    break;
  case MotionEvent.ACTION_UP:
    touchEvent = "UP";
    pressure = pointerSize = 0.0;                // when up, set pressure/size to 0
     delaunay.addPoint(x, y);
    //if (bRenderCC) {
    //  delaunay.computeCC();
    //}
    break;
  case MotionEvent.ACTION_MOVE:
    touchEvent = "MOVE";
    break;
  default:
    touchEvent = "OTHER (CODE " + action + ")";  // default text on other event
  }

  return super.dispatchTouchEvent(event);        // pass data along when done!
}

