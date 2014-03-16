private static final int SCREEN_SIZE = 800;
private static final int MAX_NUMBER_OF_POINTS = 6000;
private static final int MAX_NUMBER_OF_CORNERS = MAX_NUMBER_OF_POINTS*3;
private int nt = 0;
private int nv = 0;
private int nc = 0;

// circumcenters
private Point2D[] cc = new Point2D[MAX_NUMBER_OF_POINTS];
private boolean hasCC = false;
private boolean bRenderCC = true;
private float[] cr = new float[MAX_NUMBER_OF_POINTS];

// V Table
private int[] V = new int[MAX_NUMBER_OF_POINTS];

// G Table
private Point2D[] G = new Point2D[MAX_NUMBER_OF_POINTS];

// O-Table
private int[] O = new int[MAX_NUMBER_OF_POINTS];

// Corner-Table
private int[] C = new int[MAX_NUMBER_OF_CORNERS];

private int v(final int idx) {
  return V[idx];
}

private int o(final int idx) {
  return O[idx];
}

private int n(final int c) {
  if (c%3 == 2) {
    return c-2;
  }
  return c+1;
}

private int p(final int c) {
  if (c%3 == 0) {
    return c+2;
  }

  return c-1;
}

public static boolean isIntriangle(final int triIdx, final Point2D P) {
  final int c = triIdx*3;

  Point2D A = G[v(c)];
  Point2D B = G[v(n(c))];
  Point2D C = G[v(p(c))];
  return GEOM2D.isInTriangle(A,B,C,P);
}

// initialize G-table and V-table with the 2 triangles covering the entire display
private void initTriangles() {
  G[0] = new Point2D(0,0);
  G[1] = new Point2D(0,SCREEN_SIZE);
  G[2] = new Point2D(SCREEN_SIZE, SCREEN_SIZE);
  G[3] = new Point2D(SCREEN_SIZE, 0);

  nv = 4;

  V[0] = 0;
  V[1] = 1;
  V[2] = 2;
  V[3] = 2;
  V[4] = 3;
  V[5] = 0;  

  nt = 2;
  nc = 6;

  buildOTable();
}

private static class Triplet {
  private int a;
  private int b;
  private int c;
  
  public Triplet(final int a, final int b, final int c) {
    this.a = a;
    this.b = b;
    this.c = c;
  }
  
  public Triplet(final Triplet triplet) {
    this.a = triplet.a;
    this.b = triplet.b;
    this.c = triplet.c;
  }  
  
  boolean isLessThan(Triplet rhs)
  {
    if( a < rhs.a )
    {
      return true;
    }
    else if( a == rhs.a )
    {
      if( b < rhs.b )
      {
        return true;
      }
      else if( b == rhs.b )
      {
        if( c < rhs.c ) return true;
      }
      else
      {
        return false;
      }
    }
    return false;
  }
};


ArrayList concatenate(ArrayList left, Triplet val, ArrayList right)
{
  ArrayList ret = new ArrayList();
  for( int i = 0; i < left.size(); ++i )
    ret.add((Triplet)left.get(i));
  
  ret.add(val);
  
  for( int i = 0; i < right.size(); ++i )
    ret.add((Triplet)right.get(i));
    
  return ret;
}


ArrayList naiveQSort(ArrayList stuff)
{
  if( stuff.size() <= 1 ) return stuff;
  int pivotIdx = round(stuff.size()/2);
  Triplet pivot = (Triplet)stuff.get(pivotIdx);

  ArrayList left = new ArrayList();
  ArrayList right = new ArrayList();  

  for( int i = 0; i < stuff.size(); ++i )
  {
    if( i == pivotIdx ) continue;
    
    Triplet cur = (Triplet)stuff.get(i);
    if( cur.isLessThan(pivot) )
    {
      left.add(new Triplet(cur));
    }
    else
    {
      right.add(new Triplet(cur));
    }      
  }
  return concatenate(naiveQSort(left), pivot, naiveQSort(right));
}

public void buildOTable() {
  for( int i = 0; i < nc; ++i ) {
    O[i] = -1;
  }

  ArrayList vtriples = new ArrayList();
  for(int ii=0; ii<nc; ++ii)
  {
    // get Triplet
    int n1 = v(n(ii));
    int p1 = v(p(ii));
    
    vtriples.add(new Triplet(min(n1,p1), max(n1,p1), ii));
  }

  ArrayList sorted = new ArrayList();
  sorted = naiveQSort(vtriples);

  // just pair up the stuff
  for( int i = 0; i < nc-1; ++i )
  {
    Triplet t1 = (Triplet)sorted.get(i);
    Triplet t2 = (Triplet)sorted.get(i+1);
    if( t1.a == t2.a && t1.b == t2.b )
    {
      O[t1.c] = t2.c;
      O[t2.c] = t1.c;
      i+=1;
    }
  }
}


private void computeCC()
{
  hasCC = false;
  
  for( int i = 0; i < nt; ++i)
  {
    int c = i*3;
    cc[i] = circumCenter(G[v(c)],G[v(c+1)],G[v(c+2)]);
    cr[i] = (float)G[v(c)].disTo(cc[i]);
  }
  hasCC = true;
}

private void renderCC()
{
  if( !hasCC ) return;
  stroke(255,0,0);
  noFill();
  strokeWeight(1.0);
  for( int i = 3; i < nt; ++i)
  {
    stroke(0,0,255);
    fill(0,0,255);
    ellipse(cc[i].x, cc[i].y, 5,5);
    stroke(255,0,0);
    noFill();  
    ellipse(cc[i].x, cc[i].y, cr[i]*2, cr[i]*2);
  }
    
  stroke(0,0,0);
  noFill();
}

private Point2D midPoint2D( Point2D A, Point2D B )
{
  return new Point2D( (A.x + B.x)/2, (A.y + B.y)/2 );
}

private Point2D circumCenter(Point2D A, Point2D B, Point2D C)
{
  Point2D midAB = midPoint2D(A,B);
  Vector2D AB = new Vector2D(A,B);
  AB.left();
  AB.normalize();
  AB.scaleBy(-1);

  Point2D midBC = midPoint2D(B,C);
  Vector2D BC = new Vector2D(B,C);
  BC.left();
  BC.normalize();
  BC.scaleBy(-1);  

  float fact = 100;

  Point2D AA = new Point2D( midAB.x+AB.x*fact, midAB.y+AB.y*fact);
  Point2D BB = new Point2D( midAB.x-AB.x*fact, midAB.y-AB.y*fact);
  Point2D CC = new Point2D( midBC.x+BC.x*fact, midBC.y+BC.y*fact);
  Point2D DD = new Point2D( midBC.x-BC.x*fact, midBC.y-BC.y*fact);
  return GEOM2D.intersection(AA, BB, CC, DD);  
}

private boolean naiveCheck( float radius, Point2D cc, int c )
{
  int A = v(c);

  if( G[A].disTo(cc) < radius )
    return false;

  return true;
}

private boolean isDelaunay(int c)
{
 // $$$FIXME : reuse precomputed cc and cr
  Point2D center = circumCenter(G[v(c)], G[v(n(c))], G[v(p(c))]);
  float radius = (float)G[v(c)].disTo(center);
  return( naiveCheck(radius, center, o(c)) );
}

private void FlipCorner(int c)
{
  if( c == -1 )
    return;

  buildOTable();    

  if( o(c) == -1 ) // boundary, do nothing..
    return;

  if(!isDelaunay(c))
  {
    int opp = o(c);
    
    V[n(c)] = V[opp];    
    V[n(opp)] = V[c];

    buildOTable();
    FlipCorner(c);
    buildOTable();
    FlipCorner(n(opp));
  }
}


private void FixMesh(ArrayList l) {
  buildOTable();

  while(!l.isEmpty()) {
    int c = (Integer)l.get(0);
    FlipCorner(c);
    l.remove(0);
  }
}

private void addPoint2Ds(final int param, final float x, final float y) {
  G[nv] = new Point2D(x,y);
  ++nv;

  final int previousNumberOfTriangles = nt;
  for( int triIdx = 0; triIdx < previousNumberOfTriangles; ++triIdx ) {
    if (isIntriangle(triIdx, G[nv-1])) {
      final int A = triIdx*3;
      final int B = A+1;
      final int C = A+2;

      V[nt*3]   = v(B);
      V[nt*3+1] = v(C);
      V[nt*3+2] = nv-1;

      V[nt*3+3] = v(C);
      V[nt*3+4] = v(A);
      V[nt*3+5] = nv-1;

      V[C] = nv-1;
      
      ArrayList dirtyCorners = new ArrayList();
      final int d1 = C;
      final int d2 = nt*3+2;
      final int d3 = nt*3+5;
      dirtyCorners.add(d1);
      dirtyCorners.add(d2);
      dirtyCorners.add(d3);

      nt += 2;
      nc += 6;
      FixMesh(dirtyCorners);
      break;
    }
  }
}

private void drawTriangles() {
  noFill();
  strokeWeight(1.0);
  stroke(0,255,0);

  for( int i = 0; i < nt; ++i ) {
    int c = i*3;
    Point2D A = G[v(c)];
    Point2D B = G[v(n(c))];
    Point2D C = G[v(p(c))];
    triangle(A.x, A.y, B.x, B.y, C.x, C.y);
  }

  strokeWeight(5.0);
  for( int i = 0; i < nv; ++i ) {
    point(G[i].x, G[i].y);
  }
}

/*
 * Processing APIs
 */
void setup() {
  size(SCREEN_SIZE, SCREEN_SIZE);
  smooth(); 
  initTriangles();
}

void draw() {
  background(0);

  pushMatrix();
    drawTriangles();
    if( bRenderCC )
      renderCC();
  popMatrix();
}

void mouseClicked() {
  if (mouseButton == LEFT) {
    
    addPoint2Ds(1, mouseX, mouseY);
    
    if (bRenderCC) {
      computeCC();
    }    
    return;
  }

  if (mouseButton == RIGHT) {
    if (!bRenderCC) {
      computeCC();
    }
    bRenderCC = !bRenderCC;
  }
}

