int[] layerSizes = {4, 5, 2}; //<>//
ArrayList<NeuralNetwork> neuralNetworks;
ArrayList<Integer> generationScores;
int maxPopulationScore = 0;
int maxPopulationIndex = 0;

ArrayList<Game> gameGenerations;
int numberOfGenerations = 100;

int startTime = 0;
int maxPopulationTime = 50000;
float generationDuration = 10000;

int populationCounter = 0;

int initialScore = 20;

void setup() {
  // Initial Width and Height
  size(800, 600);

  gameGenerations = new ArrayList<Game>();
  neuralNetworks = new ArrayList<NeuralNetwork>();
  generationScores = new ArrayList<Integer>();

  for (int i = 0; i < numberOfGenerations; i++) {
    var newNeuralNetwork = new NeuralNetwork(layerSizes);
    neuralNetworks.add(newNeuralNetwork);
    gameGenerations.add(new Game(newNeuralNetwork));
  }

  background(255);
  for (int i = 0; i < numberOfGenerations; i++) {
    var game = gameGenerations.get(i);
    var score = game.Update();
    if (score > maxPopulationScore) {
      maxPopulationScore = score;
      maxPopulationIndex = i;
    }
    generationScores.add(score);
  }
}

void draw() {
  background(255);

  // Calculate the elapsed time
  float passedTime = millis() - startTime;

  var numberOfPositiveScores = countNegativeScores(generationScores);

  // showNeuralNetwork(neuralNetworks.get(maxPopulationIndex));

  if (numberOfPositiveScores > 0) {
    for (int i = 0; i < numberOfGenerations; i++) {
      var game = gameGenerations.get(i);
      var score = 0;
      score = game.Update();
      // game.display(25);
      if (score > maxPopulationScore) {
        maxPopulationScore = score;
        maxPopulationIndex = i;
      }
      var oldScore = generationScores.get(i);
      generationScores.set(i, oldScore + score);
    }
    gameGenerations.get(maxPopulationIndex).display(255);
  }
  if (numberOfPositiveScores == 0 || passedTime > maxPopulationTime) {
    // Initial time again
    startTime = millis();

    // Transfer 4 best generations to next population
    int[] maxIndices = findMaxIndices(generationScores, numberOfGenerations / 4);
    gameGenerations = new ArrayList<Game>();
    var newNeuralNetworks = new ArrayList<NeuralNetwork>();

    for (int i = 0; i < (numberOfGenerations / 4) - 1; i+=2) {
      for (int j = 0; j < maxIndices.length - 1; j+=2) {
        int firstIndex = maxIndices[j];
        var firstNeuralNetworkParent = neuralNetworks.get(firstIndex);
        newNeuralNetworks.add(firstNeuralNetworkParent);
        gameGenerations.add(new Game(firstNeuralNetworkParent));
        var firstOldScore = generationScores.get(firstIndex);
        generationScores.set(i, firstOldScore);

        int secondIndex = maxIndices[j + 1];
        var secondNeuralNetworkParent = neuralNetworks.get(secondIndex);
        secondNeuralNetworkParent.combine(firstNeuralNetworkParent);
        newNeuralNetworks.add(secondNeuralNetworkParent);
        gameGenerations.add(new Game(secondNeuralNetworkParent));
        var secondOldScore = generationScores.get(firstIndex);
        generationScores.set(i + 1, secondOldScore);
      }
    }

    // Completing list of generations
    for (int i = numberOfGenerations / 2; i < numberOfGenerations; i++) {
      var newNeuralNetwork = new NeuralNetwork(layerSizes);
      newNeuralNetworks.add(newNeuralNetwork);
      gameGenerations.add(new Game(newNeuralNetwork));
      generationScores.set(i, initialScore);
    }

    populationCounter++;
    maxPopulationScore = 0;
    neuralNetworks = newNeuralNetworks;

    // generationScores = new int[numberOfGenerations];
    // for (int i = 0; i < numberOfGenerations; i++) {
    //   generationScores[i] = initialScore;
    // }
  }

  fill(0);
  textSize(20);
  textAlign(LEFT);

  text("Passed Time: " + passedTime / 1000, 10, 20);

  text("Population: " + populationCounter, 10, 40);

  text("Alive Generations: " + numberOfPositiveScores, 10, 60);

  text("Max Population Score: " + maxPopulationScore, 10, 80);

  // println("----- ----- ----- -----");
  // println(generationScores);
}

int[] findMaxIndices(ArrayList<Integer> array, int count) {
  int[] maxIndices = new int[count];

  for (int i = 0; i < count; i++) {
    int maxIndex = 0;
    int maxValue = Integer.MIN_VALUE;

    for (int j = 0; j < array.size(); j++) {
      if (array.get(j) > maxValue && !contains(maxIndices, j)) {
        maxIndex = j;
        maxValue = array.get(j);
      }
    }

    maxIndices[i] = maxIndex;
  }

  return maxIndices;
}

boolean contains(int[] array, int value) {
  for (int i = 0; i < array.length; i++) {
    if (array[i] == value) {
      return true;
    }
  }
  return false;
}

int countNegativeScores(ArrayList<Integer> scores) {
  int numberOfPositiveScores = 0;

  for (int i = 0; i < scores.size(); i++) {
    if (scores.get(i) > 0) {
      numberOfPositiveScores++;
    }
  }

  return numberOfPositiveScores;
}
