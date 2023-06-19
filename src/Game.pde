// Define GameController Class
public class Game {
  // Define Default Properties
  NeuralNetwork neuralNetwork;

  Rectangle rectangle;
  ArrayList<Circle> circles;

  int score;
  int greenCircleScore;
  int redCircleScore;
  int circleRadius;
  int speed;
  int circleSpeed;
  int rectangleSpeed;

  Game(NeuralNetwork initialNeuralNetwork) {
    // Initial values
    score = 50;
    greenCircleScore = 10;
    redCircleScore = -20;
    circleRadius = 25;

    speed = 10;
    circleSpeed = speed;
    rectangleSpeed = speed + 5;

    // Draw rectangle
    int rectWidth = 100;
    int rectHeight = 20;
    int rectX = width / 2 - rectWidth / 2;
    int rectY = height - rectHeight - 10;
    rectangle = new Rectangle(rectX, rectY, rectWidth, rectHeight, rectangleSpeed);

    // Initial circles list
    circles = new ArrayList<Circle>();

    // Initial neural network
    neuralNetwork = initialNeuralNetwork;
  }

  int update(boolean isShowable) {
    background(255);

    // Draw the rectangle
    if (isShowable) rectangle.display();

    // Draw all lines from the rectangle to the end of the screen
    if (isShowable) drawAllLines();

    // Generate circles
    GenerateCircle();

    // Update and display circles
    float nearestGreenDistance = 1000;
    float[] nearestCircles = new float[5];

    for (int i = circles.size() - 1; i >= 0; i--) {
      Circle circle = circles.get(i);
      circle.move();
      if (isShowable) circle.display();

      // Check Collision
      if (circle.checkCollision(rectangle)) {
        if (circle.Type == 0) {
          score += greenCircleScore;
        } else {
          score += redCircleScore;
        }
        circles.remove(i);
      } else if (circle.isOffScreen()) {
        if (circle.Type == 0) {
          score += redCircleScore;
        }
        circles.remove(i);
      }

      // Find circles on lines
      int circleLine = calculateCircleIsOnWhichLine(rectangle.X, rectangle.Y, int(circle.X), int(circle.Y), isShowable);

      nearestCircles = updateNearestCircles(nearestCircles, circleLine, circle);

      if (circle.Type == 0) { // Green circle
        float distance = dist(rectangle.X + rectangle.Width / 2, rectangle.Y + rectangle.Height / 2, circle.X, circle.Y);
        if (distance < nearestGreenDistance) {
          nearestGreenDistance = distance;
        }
      }
    }

    fill(0);
    textSize(20);
    textAlign(LEFT);

    // Move the rectangle
    // moveRectangle(data);
    double rectCenterX = rectangle.X + rectangle.Width / 2;
    double rectCenterY = rectangle.Y + rectangle.Height / 2;
    double nearestGreenCircle = nearestGreenDistance;
    var data = new double[] {
      rectCenterX,
      rectCenterY,
      nearestCircles[0],
      nearestCircles[1],
      nearestCircles[2],
      nearestCircles[3],
      nearestCircles[4],
      nearestGreenCircle
    };
    makeDecision(neuralNetwork, data, isShowable);

    // Display the score
    if (isShowable) text("Score: " + score, 10, 20);

    // Display the speed
    if (isShowable) text("Speed: " + circleSpeed, 10, 40);

    // Check if the score is less than zero and stop the game
    //if (score < 0) {
    //fill(0);
    //textSize(30);
    //textAlign(CENTER);
    //background(255);
    //text("Game Over!", width/2, height/2);
    //}

    return score;
  }

  void updateNeuralNetwork(NeuralNetwork newNeuralNetwork) {
    neuralNetwork = newNeuralNetwork;
  }

  private void drawAllLines() {
    drawLine(30);
    drawLine(60);
    drawLine(90);
    drawLine(120);
    drawLine(150);
  }

  private void drawLine(int angle) {
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

  private int calculateCircleIsOnWhichLine(int x0, int y0, int x, int y, boolean isShowable) {
    int rectCenterY0 = height - (y0 + rectangle.Height / 2);
    int rectCenterX0 = x0 + rectangle.Width / 2;
    int convertedX = x;
    int convertedY = height - y;
    float slop = float(convertedY - rectCenterY0) / float(convertedX - rectCenterX0);

    fill(0, 0, 255);
    int targetCircleWidth = 10;
    int targetCircleHeight = 10;

    float threshold = 0.2;

    // Find circles in angle 30
    if (abs(0.5773 - slop) < threshold) {
      if (isShowable) ellipse(x, y, targetCircleWidth, targetCircleHeight);
      return 30;
    }

    // Find circles in angle 60
    if (abs(1.7320 - slop) < threshold) {
      if (isShowable) ellipse(x, y, targetCircleWidth, targetCircleHeight);
      return 60;
    }

    // Find circles in angle 90
    if (abs(rectCenterX0 - convertedX) < circleRadius) {
      if (isShowable) ellipse(x, y, targetCircleWidth, targetCircleHeight);
      return 90;
    }

    // Find circles in angle 120
    if (abs(-1.7320 - slop) < threshold) {
      if (isShowable) ellipse(x, y, targetCircleWidth, targetCircleHeight);
      return 120;
    }

    // Find circles in angle 150
    if (abs(-0.5773 - slop) < threshold) {
      if (isShowable) ellipse(x, y, targetCircleWidth, targetCircleHeight);
      return 150;
    }

    return 0;
  }

  private float calculateDistance(int x1, int y1, int x2, int y2) {
    int realX1 = x1 + rectangle.Width / 2;
    int realY1 = height - (y1 + rectangle.Height / 2);
    int realX2 = x2 + rectangle.Width / 2;
    int realY2 = height - (y2 + rectangle.Height / 2);
    float distance = dist(realX1, realY1, realX2, realY2);
    return distance;
  }

  private float[] updateNearestCircles(float[] nearestCircles, int circleLine, Circle circle) {
    if (circleLine == 30) {
      float distance = calculateDistance(rectangle.X, rectangle.Y, int(circle.X), int(circle.Y));
      nearestCircles[0] = distance;
      if (circle.Type == 1) nearestCircles[0] = -nearestCircles[0];
    }

    if (circleLine == 60) {
      float distance = calculateDistance(rectangle.X, rectangle.Y, int(circle.X), int(circle.Y));
      nearestCircles[1] = distance;
      if (circle.Type == 1) nearestCircles[1] = -nearestCircles[1];
    }

    if (circleLine == 90) {
      float distance = calculateDistance(rectangle.X, rectangle.Y, int(circle.X), int(circle.Y));
      nearestCircles[2] = distance;
      if (circle.Type == 1) nearestCircles[2] = -nearestCircles[2];
    }

    if (circleLine == 120) {
      float distance = calculateDistance(rectangle.X, rectangle.Y, int(circle.X), int(circle.Y));
      nearestCircles[3] = distance;
      if (circle.Type == 1) nearestCircles[3] = -nearestCircles[3];
    }

    if (circleLine == 150) {
      float distance = calculateDistance(rectangle.X, rectangle.Y, int(circle.X), int(circle.Y));
      nearestCircles[4] = distance;
      if (circle.Type == 1) nearestCircles[4] = -nearestCircles[4];
    }

    return nearestCircles;
  }

  private void GenerateCircle() {
    if (frameCount % 30 == 0) {
      float circleX = random(width - circleRadius * 2) + circleRadius;
      float circleY = -circleRadius;
      int circleType = random(1) < 0.666 ? 1 : 0; // Randomly choose between red and green circle
      circles.add(new Circle(circleX, circleY, circleRadius, circleSpeed, circleType));
    }
  }

  private void moveRectangle() {
    if (keyPressed) {
      rectangle.move(keyCode, 0, width);
    }
  }

  private void makeDecision(NeuralNetwork neuralNetwork, double[] data, boolean isShowable) {
    int leftBoundary = 0;
    int rightBoundary = width;

    var output = neuralNetwork.feedForward(data);
    var decision = "Do Nothing";

    // var firstCondition = output[0] > 0.2 && output[1] < -0.2;
    if (output[0] < output[1] && data[0] > leftBoundary + rectangle.Width / 2) {
      rectangle.X -= rectangleSpeed;
      decision = "Go To Left";
    }

    // var secondCondition = output[0] < -0.2 && output[1] > 0.2;
    if (output[0] > output[1] && data[0] < rightBoundary - rectangle.Width / 2) {
      rectangle.X += rectangleSpeed;
      decision = "Go To Right";
    }

    // Print decision
    fill(0);
    textSize(20);
    textAlign(LEFT);
    if (isShowable) text("Score: " + decision, 10, 120);
  }
}
