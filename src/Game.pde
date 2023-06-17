// Define Rectanle Class
class Rectangle {
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

  void display() {
    if (Type == 0) {
      fill(0, 255, 0); // Green circle
    } else {
      fill(255, 0, 0); // Red circle
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

// Define Default Properties
Rectangle rectangle;
ArrayList<Circle> circles;
int InitialScore;
int greenCircleScore;
int redCircleScore;
int circleRadius;
int speed;
int circleSpeed;
int rectangleSpeed;

void setup() {
  // Initial values
  InitialScore = 50;
  greenCircleScore = 10;
  redCircleScore = -20;
  circleRadius = 25;
  
  speed = 5;
  circleSpeed = speed;
  rectangleSpeed = speed + 5;
  
  // Initial Width and Height
  size(800, 600);
  
  // Draw rectangle
  int rectWidth = 100;
  int rectHeight = 20;
  int rectX = width / 2 - rectWidth / 2;
  int rectY = height - rectHeight - 10;
  rectangle = new Rectangle(rectX, rectY, rectWidth, rectHeight, rectangleSpeed);
  
  // Initial circles list
  circles = new ArrayList<Circle>();
}

void draw() {
  background(255);
  
  // Draw the rectangle
  rectangle.display();
  
  // Draw all lines from the rectangle to the end of the screen
  // drawAllLines();
  
  // Move the rectangle
  if (keyPressed) {
    rectangle.move(keyCode, 0, width);
  }
  
  // Generate circles
  if (frameCount % 50 == 0) {
    float circleX = random(width - circleRadius * 2) + circleRadius;
    float circleY = -circleRadius;
    int circleType = random(1) < 0.666 ? 1 : 0; // Randomly choose between red and green circle
    circles.add(new Circle(circleX, circleY, circleRadius, circleSpeed, circleType));
  }
  
  // Update and display circles
  float nearestGreenDistance = 1000;
  float[] nearestCircles = new float[5];
  
  for (int i = circles.size() - 1; i >= 0; i--) {
    Circle circle = circles.get(i);
    circle.move();
    circle.display();
    
    int circleOnLine = checkIsCircleOnLine(rectangle.X, rectangle.Y, int(circle.X), int(circle.Y));
    
    if (circleOnLine == 30) {
      float distance = calculateDistance(rectangle.X, rectangle.Y, int(circle.X), int(circle.Y));
      nearestCircles[0] = distance;
    }
    
    if (circleOnLine == 60) {
      float distance = calculateDistance(rectangle.X, rectangle.Y, int(circle.X), int(circle.Y));
      nearestCircles[1] = distance;
    }
    
    if (circleOnLine == 90) {
      float distance = calculateDistance(rectangle.X, rectangle.Y, int(circle.X), int(circle.Y));
      nearestCircles[2] = distance;
    }
    
    if (circleOnLine == 120) {
      float distance = calculateDistance(rectangle.X, rectangle.Y, int(circle.X), int(circle.Y));
      nearestCircles[3] = distance;
    }
    
    if (circleOnLine == 150) {
      float distance = calculateDistance(rectangle.X, rectangle.Y, int(circle.X), int(circle.Y));
      nearestCircles[4] = distance;
    }
    
    if (circle.Type == 0) { // Green circle
      float distance = dist(rectangle.X + rectangle.Width / 2, rectangle.Y + rectangle.Height / 2, circle.X, circle.Y);
      if (distance < nearestGreenDistance) {
        nearestGreenDistance = distance;
      }
    }
    
    if (circle.checkCollision(rectangle)) {
      if (circle.Type == 0) {
        InitialScore += greenCircleScore;
      } else {
        InitialScore += redCircleScore;
      }
      circles.remove(i);
    } else if (circle.isOffScreen()) {
      if (circle.Type == 0) {
        InitialScore += redCircleScore;
      }
      circles.remove(i);
    }
  }
  
  fill(0);
  textSize(20);
  textAlign(LEFT);
  
  // Display the score
  text("Score: " + InitialScore, 10, 20);
  
  // Display the speed
  text("Speed: " + circleSpeed, 10, 40);
  
  // Check if the score is less than zero and stop the game
  if (InitialScore < 0) {
    fill(0);
    textSize(30);
    textAlign(CENTER);
    background(255);
    text("Game Over!", width/2, height/2);
  }
}

void drawAllLines() {
  drawLine(30);
  drawLine(60);
  drawLine(90);
  drawLine(120);
  drawLine(150);
}

void drawLine(int angle) {
  if (angle < 90 && angle > 0) {
    float rectCenterX = rectangle.X + rectangle.Width / 2;
    float rectCenterY = rectangle.Y;
    float lineAngle = radians(angle);
    float x = width - rectCenterX;
    float L = x / cos(lineAngle);
    float lineEndY = L * sin(lineAngle);
    line(rectCenterX, rectCenterY, rectCenterX + x, rectCenterY - lineEndY);
    ellipse(rectCenterX + x, rectCenterY - lineEndY, 10, 10);
  } else if (angle > 90 && angle < 180) {
    float rectCenterX = rectangle.X + rectangle.Width / 2;
    float rectCenterY = rectangle.Y;
    float lineAngle = radians(-angle);
    float x = rectCenterX;
    float L = x / cos(lineAngle);
    float lineEndY = L * sin(lineAngle);
    line(rectCenterX, rectCenterY, 0, rectCenterY - lineEndY);
    ellipse(0, rectCenterY - lineEndY, 10, 10);
  } else if (angle == 90) {
    line(rectangle.X + rectangle.Width / 2, rectangle.Y, rectangle.X + rectangle.Width / 2, 0);
    ellipse(rectangle.X + rectangle.Width / 2, 0, 10, 10);
  }
}

int checkIsCircleOnLine(int x0, int y0, int x, int y) {
  int rectCenterY0 = height - (y0 + rectangle.Height / 2);
  int rectCenterX0 = x0 + rectangle.Width / 2;
  int convertedX = x;
  int convertedY = height - y;
  float slop = float(convertedY - rectCenterY0) / float(convertedX - rectCenterX0);
  
  fill(0, 0, 255);
  int targetCircleWidth = 10;
  int targetCircleHeight = 10;
  
  // Find circles in angle 30
  if (abs(0.5773 - slop) < 0.05) {
    ellipse(x, y, targetCircleWidth, targetCircleHeight);
    return 30;
  }
  
  // Find circles in angle 60
  if (abs(1.7320 - slop) < 0.1) {
    ellipse(x, y, targetCircleWidth, targetCircleHeight);
    return 60;
  }
  
  // Find circles in angle 90
  if (abs(rectCenterX0 - convertedX) < circleRadius) {
    ellipse(x, y, targetCircleWidth, targetCircleHeight);
    return 90;
  }
  
  // Find circles in angle 120
  if (abs(-1.7320 - slop) < 0.1) {
    ellipse(x, y, targetCircleWidth, targetCircleHeight);
    return 120;
  }
  
  // Find circles in angle 150
  if (abs(-0.5773 - slop) < 0.05) {
    ellipse(x, y, targetCircleWidth, targetCircleHeight);
    return 150;
  }
  
  return 0;
}

float calculateDistance(int x1, int y1, int x2, int y2) {
  int realX1 = x1 + rectangle.Width / 2;
  int realY1 = height - (y1 + rectangle.Height / 2);
  int realX2 = x2 + rectangle.Width / 2;
  int realY2 = height - (y2 + rectangle.Height / 2);
  float distance = dist(realX1, realY1, realX2, realY2);
  return distance;
}
