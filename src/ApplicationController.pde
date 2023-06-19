Game game; //<>//
HashMap<Integer, NeuralNetwork> neuralNetworks;
NeuralNetwork firstNeuralNetworks;
int[] NeuralNetworksScores;

int[] layerSizes = {8, 10, 2};

int generationScore = 50;
int GenerationCounter = 0;

int populationCounter = 0;

void setup() {
  // Initial Width and Height
  size(800, 600);

  // Create game
  neuralNetworks = new HashMap<Integer, NeuralNetwork>();
  for (int i = 0; i < 10; i++) {
    
  }
  NeuralNetworksScores = new int[10];

  firstNeuralNetworks = new NeuralNetwork(layerSizes);
  game = new Game(firstNeuralNetworks);
}

void draw() {
  float passedTime = millis();

  var score = game.update(true);

  if (score < 0) {
    // neuralNetworks.add(game.neuralNetwork);
    firstNeuralNetworks.mutate(0.1);
    GenerationCounter++;
  }

  if (GenerationCounter > 10) {
    NeuralNetwork newNeuralNetwork = new NeuralNetwork(layerSizes);
    firstNeuralNetworks.combine(newNeuralNetwork);

    GenerationCounter = 0;
    game.score = 50;
    populationCounter++;
  }

  fill(0);
  textSize(20);
  textAlign(LEFT);

  text("Passed Time: " + passedTime / 1000, 10, 100);

  text("Population: " + populationCounter, 10, 60);

  text("Mutation: " + GenerationCounter, 10, 80);
}
