// Define Circle Class
class Circle {
  float X;
  float Y;
  int Radius;
  int Speed;
  int Type;

  Circle(float x, float y, int radius, int speed, int type) {
    this.X = x;
    this.Y = y;
    this.Radius = radius;
    this.Speed = speed;
    this.Type = type;
  }

  void move() {
    Y += Speed;
  }

  void display(int transparency) {
    if (Type == 0) {
      fill(0, 255, 0, transparency); // Green circle
    } else {
      fill(255, 0, 0, transparency); // Red circle
    }
    ellipse(X, Y, Radius, Radius);
  }

  boolean checkCollision(Rectangle rectangle) {
    if (Y + Radius > rectangle.Y && Y - Radius < rectangle.Y + rectangle.Height &&
      X + Radius > rectangle.X && X - Radius < rectangle.X + rectangle.Width) {
      return true;
    }
    return false;
  }

  boolean isOffScreen() {
    return Y - Radius > height;
  }
}
