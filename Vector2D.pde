public static class Vector2D extends PVector {

  public Vector2D(final Point2D a, final Point2D b) {
    super(b.x-a.x, b.y-a.y);
  }
  
  public Vector2D(final float x, final float y) {
    super(x, y);
  }
  
  public float dot(final Vector2D v) {
    return x*v.x + y*v.y;
  }
    
  public void left() {
    final float tmp = x;
    x = -y;
    y = tmp;
  }
  
  public void scaleBy(final float factor) {
    x*=factor;
    y*=factor;
  }
}
