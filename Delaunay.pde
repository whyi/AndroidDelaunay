public class Delaunay {
  private static final int MAX_NUMBER_OF_POINTS = 6000;
  private static final int MAX_NUMBER_OF_CORNERS = MAX_NUMBER_OF_POINTS*3;

  private int nt = 0;
  private int nv = 0;
  private int nc = 0;
  
  // circumcenters
  private Point2D[] cc = new Point2D[MAX_NUMBER_OF_POINTS];
  private boolean hasCC = false;
  private float[] cr = new float[MAX_NUMBER_OF_POINTS];

  // V Table
  private int[] V = new int[MAX_NUMBER_OF_POINTS];
  
  // G Table
  private Point2D[] G = new Point2D[MAX_NUMBER_OF_POINTS];
  
  // O-Table
  private int[] O = new int[MAX_NUMBER_OF_POINTS];
  
  // Corner-Table
  private int[] C = new int[MAX_NUMBER_OF_CORNERS];

  public Delaunay() {}

  // initialize G-table and V-table with the 2 triangles covering the entire display
  public void initTriangles() {
    G[0] = new Point2D(0, 0);
    G[1] = new Point2D(0, height);
    G[2] = new Point2D(width, height);
    G[3] = new Point2D(width, 0);
  
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

  public boolean isIntriangle(final int triIdx, final Point2D P) {
    final int c = triIdx*3;
  
    Point2D A = G[v(c)];
    Point2D B = G[v(n(c))];
    Point2D C = G[v(p(c))];
    return GEOM2D.isInTriangle(A,B,C,P);
  }
  
  // O-table support
  private class Triplet {
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
    
    public boolean isLessThan(final Triplet rhs) {
      if (a < rhs.a) {
        return true;
      }
      else if (a == rhs.a) {
        if (b < rhs.b) {
          return true;
        }
        else if( b == rhs.b ) {
          if (c < rhs.c ) {
            return true;
          }
        }
        else {
          return false;
        }
      }
      return false;
    }
  }
  
  private ArrayList concatenate(final ArrayList left, final Triplet val, final ArrayList right) {
    ArrayList ret = new ArrayList();
  
    for (int i = 0; i < left.size(); ++i) {
      ret.add( (Triplet) left.get(i) );
    }
    
    ret.add(val);
    
    for (int i = 0; i < right.size(); ++i) {
      ret.add( (Triplet) right.get(i) );
    }
  
    return ret;
  }
  
  
  private ArrayList naiveQSort(ArrayList stuff) {
    if (stuff.isEmpty() || stuff.size() == 1) {
      return stuff;
    }
  
    final int nElements = stuff.size();
    final int pivotIdx = Math.round(nElements/2);
    final Triplet pivot = (Triplet) stuff.get(pivotIdx);
  
    ArrayList left = new ArrayList();
    ArrayList right = new ArrayList();  
  
    for (int i = 0; i < nElements; ++i) {
      if (i == pivotIdx) {
        continue;
      }
      
      Triplet cur = (Triplet) stuff.get(i);
      if (cur.isLessThan(pivot)) {
        left.add(new Triplet(cur));
      }
      else {
        right.add(new Triplet(cur));
      }      
    }
    return concatenate(naiveQSort(left), pivot, naiveQSort(right));
  }
  
  private void buildOTable() {
    for (int i = 0; i < nc; ++i) {
      O[i] = -1;
    }
  
    ArrayList vtriples = new ArrayList();
    for (int i = 0; i < nc; ++i) {
      final int n1 = v(n(i));
      final int p1 = v(p(i));
  
      vtriples.add(new Triplet(min(n1,p1), max(n1,p1), i));
    }
  
    ArrayList sorted = naiveQSort(vtriples);
  
    // just pair up the stuff
    for( int i = 0; i < nc-1; ++i ) {
      Triplet t1 = (Triplet) sorted.get(i);
      Triplet t2 = (Triplet) sorted.get(i+1);
      if (t1.a == t2.a && t1.b == t2.b) {
        O[t1.c] = t2.c;
        O[t2.c] = t1.c;
        ++i;
      }
    }
  }
  
  public void computeCC() {
    hasCC = false;
    
    for (int i = 0; i < nt; ++i) {
      final int c = i*3;
      cc[i] = GEOM2D.circumCenter(G[v(c)],G[v(c+1)],G[v(c+2)]);
      cr[i] = (float)G[v(c)].disTo(cc[i]);
    }
    hasCC = true;
  }

  private boolean naiveCheck(final float radius, final Point2D cc, final int c ) {
    final int A = v(c);
  
    if (G[A].disTo(cc) < radius) {
      return false;
    }
  
    return true;
  }
  
  private boolean isDelaunay(final int c) {
    // $$$FIXME : reuse precomputed cc and cr
    Point2D center = GEOM2D.circumCenter(G[v(c)], G[v(n(c))], G[v(p(c))]);
    final float radius = (float)G[v(c)].disTo(center);
    return naiveCheck(radius, center, o(c));
  }
  
  private void flipCorner(final int c) {
    if (-1 == c) {
      return;
    }
  
    buildOTable();    
  
    // boundary, do nothing.
    if (o(c) == -1) {
      return;
    }
  
    if (!isDelaunay(c)) {
      final int opp = o(c);
      
      V[n(c)] = V[opp];    
      V[n(opp)] = V[c];
  
      buildOTable();
      flipCorner(c);
  
      buildOTable();
      flipCorner(n(opp));
    }
  }
  
  private void FixMesh(final ArrayList l) {
    buildOTable();
  
    while (!l.isEmpty()) {
      int c = (Integer)l.get(0);
      flipCorner(c);
      l.remove(0);
    }
  }
  
  public void addPoint(final float x, final float y) {
    G[nv] = new Point2D(x,y);
    ++nv;
  
    final int previousNumberOfTriangles = nt;
    for (int triIdx = 0; triIdx < previousNumberOfTriangles; ++triIdx) {
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
  
  
  // rendering
  public void renderTriangles() {
    noFill();
    strokeWeight(1.0);
    stroke(0,255,0);
  
    for (int i = 0; i < nt; ++i) {
      final int c = i*3;
      Point2D A = G[v(c)];
      Point2D B = G[v(n(c))];
      Point2D C = G[v(p(c))];
      triangle(A.x, A.y, B.x, B.y, C.x, C.y);
    }
  
    strokeWeight(5.0);
    for (int i = 0; i < nv; ++i) {
      point(G[i].x, G[i].y);
    }
  }
  
  public void renderCC() {
    if (!hasCC) {
      return;
    }
    
    stroke(255,0,0);
    noFill();
    strokeWeight(1.0);
    for (int i = 3; i < nt; ++i) {
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
  
}
