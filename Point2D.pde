public static class Point2D {
  
  private float x, y;
  
  public Point2D(final float x, final float y) {
    this.x = x;
    this.y = y;
  }

  public float disTo(final Point2D rhs) {
    return (float) sqrt((rhs.x-x)*(rhs.x-x)+(rhs.y-y)*(rhs.y-y));
  }
  
  public String toString() {
    return "(" + x + "," + y + ")";
  }
}
