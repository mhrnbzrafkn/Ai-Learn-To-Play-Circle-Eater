Game game; //<>//
ArrayList<NeuralNetwork> neuralNetworks;
int[] NeuralNetworksScores;

int[] layerSizes = {8, 10, 2};

int generationScore = 50;
int generationCounter = 0;

int populationCounter = 0;
int populationSize = 10;

int neuralNetworkIndex = 0;

int startTime;
float generationDuration = 10000;

void setup() {
  // Initial Width and Height
  size(800, 600);
  
  // Store the starting time
  startTime = millis();

  // Create game
  neuralNetworks = new ArrayList<NeuralNetwork>();
  for (int i = 0; i < populationSize; i++) {
    neuralNetworks.add(new NeuralNetwork(layerSizes));
  }
  NeuralNetworksScores = new int[populationSize];
  
  game = new Game(neuralNetworks.get(neuralNetworkIndex));
}

void draw() {
  // Calculate the elapsed time
  float passedTime = millis() - startTime;
  
  if (passedTime <= generationDuration) {
    var score = game.update(true);
    generationScore = score;
  }
  else if (passedTime > generationDuration && neuralNetworkIndex < populationSize) {
    // Record previous neural network values
    NeuralNetworksScores[neuralNetworkIndex] = generationScore;
    generationScore = 50;
    
    // Prepare new neural network
    game = new Game(neuralNetworks.get(neuralNetworkIndex));
    neuralNetworkIndex++;
    
    // Update pupulation counter
    generationCounter++;
    
    // Initial time again
    startTime = millis();
  }
  
  if (neuralNetworkIndex == populationSize) {
    // Update neural Network
    neuralNetworkIndex = 0;
    
    // Update generation counter
    generationCounter = 0;
    
    // Update population counter
    populationCounter++;
    
    // Transfer 4 best generations to next population
    int[] maxIndices = findMaxIndices(NeuralNetworksScores, 4);
    var newNeuralNetworks = new ArrayList<NeuralNetwork>();
    newNeuralNetworks.add(neuralNetworks.get(maxIndices[0]));
    newNeuralNetworks.add(neuralNetworks.get(maxIndices[1]));
    newNeuralNetworks.add(neuralNetworks.get(maxIndices[2]));
    newNeuralNetworks.add(neuralNetworks.get(maxIndices[3]));
    
    var newNeuralNetwork = neuralNetworks.get(maxIndices[0]).generateCopy();
    newNeuralNetwork.mutate(0.1);
    newNeuralNetwork.combine(neuralNetworks.get(maxIndices[1]));
    newNeuralNetworks.add(newNeuralNetwork);
    
    newNeuralNetwork = neuralNetworks.get(maxIndices[2]).generateCopy();
    newNeuralNetwork.mutate(0.1);
    newNeuralNetwork.combine(neuralNetworks.get(maxIndices[3]));
    newNeuralNetworks.add(newNeuralNetwork);
    
    newNeuralNetwork = neuralNetworks.get(maxIndices[0]).generateCopy();
    newNeuralNetwork.mutate(0.1);
    newNeuralNetwork.combine(neuralNetworks.get(maxIndices[3]));
    newNeuralNetworks.add(newNeuralNetwork);
    
    newNeuralNetwork = neuralNetworks.get(maxIndices[1]).generateCopy();
    newNeuralNetwork.mutate(0.1);
    newNeuralNetwork.combine(neuralNetworks.get(maxIndices[2]));
    newNeuralNetworks.add(newNeuralNetwork);
    
    newNeuralNetwork = new NeuralNetwork(layerSizes);
    newNeuralNetworks.add(newNeuralNetwork);
    
    newNeuralNetwork = new NeuralNetwork(layerSizes);
    newNeuralNetworks.add(newNeuralNetwork);
  }

  fill(0);
  textSize(20);
  textAlign(LEFT);

  text("Passed Time: " + passedTime / 1000, 10, 100);

  text("Population: " + populationCounter, 10, 60);

  text("Generation: " + generationCounter, 10, 80);
}

void updatePopulation(int[] bestNeuralNetworkIndexes) {
  
}

int[] findMaxIndices(int[] array, int count) {
  int[] maxIndices = new int[count];

  for (int i = 0; i < count; i++) {
    int maxIndex = 0;
    int maxValue = Integer.MIN_VALUE;

    for (int j = 0; j < array.length; j++) {
      if (array[j] > maxValue && !contains(maxIndices, j)) {
        maxIndex = j;
        maxValue = array[j];
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
