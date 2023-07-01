public class Game {
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
    neuralNetwork = initialNeuralNetwork;

    // Initial values
    score = 20;
    greenCircleScore = 10;
    // redCircleScore = -20;
    circleRadius = 25;

    speed = 10;
    circleSpeed = speed;
    rectangleSpeed = speed * 3;

    // Draw rectangle
    int rectWidth = 100;
    int rectHeight = 20;
    // int randomX = int(random(0 + rectWidth / 2, width - rectWidth / 2));
    //int rectX = randomX;
    int rectX = width / 2 - rectWidth / 2;
    int rectY = height - rectHeight - 10;
    rectangle = new Rectangle(rectX, rectY, rectWidth, rectHeight, rectangleSpeed);

    // Initial circles list
    circles = new ArrayList<Circle>();
  }

  public int Update() {
    // background(255);

    // Move the rectangle
    //if (keyPressed) {
    //  rectangle.move(keyCode, 0, width);
    //}

    // Generate circles
    if (frameCount % 50 == 0) {
      float circleX = random(width - circleRadius * 2) + circleRadius;
      float circleY = -circleRadius;
      // int circleType = random(1) < 0.666 ? 1 : 0; // Randomly choose between red and green circle
      int circleType = 0;
      circles.add(new Circle(circleX, circleY, circleRadius, circleSpeed, circleType));
    }

    float nearestGreenDistance = 1000;
    float[] nearestCircles = new float[5];

    for (int i = circles.size() - 1; i >= 0; i--) {
      Circle circle = circles.get(i);
      circle.move();

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
          score += greenCircleScore;
        } else {
          score += redCircleScore;
          // neuralNetwork.mutate(0.1);
        }
        circles.remove(i);
      } else if (circle.isOffScreen()) {
        if (circle.Type == 0) {
          score -= greenCircleScore;
          // neuralNetwork.mutate(0.1);
        }
        circles.remove(i);
      }
    }

    int rectangleCenterX = rectangle.X + rectangle.Width / 2;
    var data = new double[] {
      rectangleCenterX,
      nearestCircles[0],
      nearestCircles[1],
      nearestCircles[2],
      nearestCircles[3],
      nearestCircles[4],
      nearestGreenDistance
    };
    makeDecision(neuralNetwork, data);

    return score;
  }

  public void display(int transparency) {
    if (score > 0) {
      fill(0, transparency);
      rectangle.display();
      fill(255);
      textSize(20);
      textAlign(CENTER);
      text(score, rectangle.X + rectangle.Width / 2, rectangle.Y + rectangle.Height);

      for (int i = circles.size() - 1; i >= 0; i--) {
        Circle circle = circles.get(i);
        circle.display(transparency);
      }
    }
  }

  private void makeDecision(NeuralNetwork neuralNetwork, double[] data) {
    int leftBoundary = 0;
    int rightBoundary = width;

    var output = neuralNetwork.feedForward(data);
    // var decision = "Do Nothing";

    // var firstCondition = output[0] > 0.6 && output[1] < 0.4;
    var firstCondition = output[0] < output[1];
    // var firstCondition = output[0] < -0.666 && output[1] > 0.666;
    // var firstCondition = output[0] < 0 && output[1] > 0;
    // firstCondition = output[0] < 0.4;
    if (firstCondition && data[0] > leftBoundary + rectangle.Width / 2) {
      // rectangle.X -= rectangleSpeed;
      var step = (output[1] - output[0]) * 100;
      rectangle.X -= step;
      // decision = "Go To Left";
    }

    // var secondCondition = output[0] < 0.4 && output[1] > 0.6;
    var secondCondition = output[0] > output[1];
    // var secondCondition = output[0] > 0.666 && output[1] < -0.666;
    // var secondCondition = output[0] > 0 && output[1] < 0;
    // var secondCondition = output[0] > 0.6;
    if (secondCondition && data[0] < rightBoundary - rectangle.Width) {
      //rectangle.X += rectangleSpeed;
      var step = (output[0] - output[1]) * 100;
      rectangle.X += step;
      // decision = "Go To Right";
    }
  }

  private int checkIsCircleOnLine(int x0, int y0, int x, int y) {
    int rectCenterY0 = height - (y0 + rectangle.Height / 2);
    int rectCenterX0 = x0 + rectangle.Width / 2;
    int convertedX = x;
    int convertedY = height - y;
    float slop = float(convertedY - rectCenterY0) / float(convertedX - rectCenterX0);

    fill(0, 0, 255);
    int targetCircleWidth = 10;
    int targetCircleHeight = 10;
    
    float threshold = 0.5;

    // Find circles in angle 30
    if (abs(0.5773 - slop) < threshold) {
      // ellipse(x, y, targetCircleWidth, targetCircleHeight);
      return 30;
    }

    // Find circles in angle 60
    if (abs(1.7320 - slop) < threshold) {
      // ellipse(x, y, targetCircleWidth, targetCircleHeight);
      return 60;
    }

    // Find circles in angle 90
    if (abs(rectCenterX0 - convertedX) < rectangle.Width - circleRadius) {
      // ellipse(x, y, targetCircleWidth, targetCircleHeight);
      return 90;
    }

    // Find circles in angle 120
    if (abs(-1.7320 - slop) < threshold) {
      // ellipse(x, y, targetCircleWidth, targetCircleHeight);
      return 120;
    }

    // Find circles in angle 150
    if (abs(-0.5773 - slop) < threshold) {
      // ellipse(x, y, targetCircleWidth, targetCircleHeight);
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
}
