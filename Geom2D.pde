// utility class to provide 2D Geometry operations
public static final class GEOM2D {
  private GEOM2D() {}
  
  public static float dot(final Vector2D v1, final Vector2D v2) {
    return v1.dot(v2);
  }
  
  // result is the Z component of 3D cross
  public static float cross2D(final Vector2D U, final Vector2D V) {
    return U.x*V.y - U.y*V.x;
  }
  
  public static boolean isLeftTurn(final Point2D A, final Point2D B, final Point2D C) {
    if (cross2D(new Vector2D(A,B), new Vector2D(B,C)) > 0) {
      return true;
    }
  
    return false;
  }
   
  public static boolean isInTriangle(final Point2D A, final Point2D B, final Point2D C, final Point2D P) {
    if (isLeftTurn(A,B,P) == isLeftTurn(B,C,P) &&
        isLeftTurn(A,B,P) == isLeftTurn(C,A,P)) {
      return true;
    }
  
    return false;
  }
  
  public static Point2D intersection(Point2D S, Point2D SE, Point2D Q, Point2D QE) {
    Vector2D T = new Vector2D(S, SE);
    Vector2D N = new Vector2D(Q, QE);
    N.normalize();
    N.left();
    Vector2D QS = new Vector2D(Q, S);
    
    float QS_dot_N = dot(QS,N);
    float T_dot_N = dot(T,N);
    float t = -QS_dot_N/T_dot_N;
    T.scaleBy(t);
    return new Point2D(S.x+T.x,S.y+T.y);
  }
}
