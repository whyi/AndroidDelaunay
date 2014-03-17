private static final int SCREEN_SIZE = 800;

private Delaunay delaunay = new Delaunay();
private boolean bRenderCC = true;

/*
 * Processing APIs
 */
void setup() {
  size(SCREEN_SIZE, SCREEN_SIZE);
  smooth(); 
}

void draw() {
  background(0);

  pushMatrix();
    delaunay.renderTriangles();
    if (bRenderCC) {
      delaunay.renderCC();
    }
  popMatrix();
}

void mouseClicked() {
  if (mouseButton == LEFT) {    
    delaunay.addPoint(mouseX, mouseY);
    
    if (bRenderCC) {
      delaunay.computeCC();
    }    
    return;
  }

  if (mouseButton == RIGHT) {
    if (!bRenderCC) {
      delaunay.computeCC();
    }
    bRenderCC = !bRenderCC;
  }
}

