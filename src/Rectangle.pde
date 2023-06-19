// Define Rectanle Class
public class Rectangle {
  int Width;
  int Height;
  int X;
  int Y;
  int Speed;

  Rectangle(int x, int y, int w, int h, int speed) {
    this.Width = w;
    this.Height = h;
    this.Speed = speed;
    this.X = x;
    this.Y = y;
  }

  void move(int keyCode, int leftBoundary, int rightBoundary) {
    if (keyCode == LEFT && X > leftBoundary) {
      X -= Speed;
    } else if (keyCode == RIGHT && X < rightBoundary - Width) {
      X += Speed;
    }
  }

  void display() {
    rect(X, Y, Width, Height);
  }
}
