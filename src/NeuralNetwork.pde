import java.util.Arrays;
import java.util.Random;

public class NeuralNetwork {
  private int numLayers;
  private int[] layerSizes;
  private double[][][] weights;
  private double[][] biases;
  private Random random;

  public NeuralNetwork(int[] layerSizes) {
    this.numLayers = layerSizes.length;
    this.layerSizes = layerSizes;
    this.random = new Random();

    initializeWeights();
    initializeBiases();
  }

  private void initializeWeights() {
    weights = new double[numLayers - 1][][];
    for (int i = 0; i < numLayers - 1; i++) {
      int currentLayerSize = layerSizes[i];
      int nextLayerSize = layerSizes[i + 1];
      weights[i] = new double[nextLayerSize][currentLayerSize];

      for (int j = 0; j < nextLayerSize; j++) {
        for (int k = 0; k < currentLayerSize; k++) {
          weights[i][j][k] = (random.nextDouble() * 2) - 1;
        }
      }
    }
  }

  private void initializeBiases() {
    biases = new double[numLayers - 1][];
    for (int i = 0; i < numLayers - 1; i++) {
      int nextLayerSize = layerSizes[i + 1];
      biases[i] = new double[nextLayerSize];

      for (int j = 0; j < nextLayerSize; j++) {
        biases[i][j] = (random.nextDouble() * 2) - 1;
      }
    }
  }

  public double[] feedForward(double[] input) {
    double[] activations = input;
    for (int i = 0; i < numLayers - 1; i++) {
      double[] weightedSum = new double[layerSizes[i + 1]];

      for (int j = 0; j < layerSizes[i + 1]; j++) {
        for (int k = 0; k < layerSizes[i]; k++) {
          weightedSum[j] += weights[i][j][k] * activations[k];
        }
        weightedSum[j] += biases[i][j];
      }

      activations = sigmoid(weightedSum);
    }
    return activations;
  }

  private double[] sigmoid(double[] values) {
    double[] result = new double[values.length];
    for (int i = 0; i < values.length; i++) {
      result[i] = 1 / (1 + Math.exp(-values[i]));
    }
    return result;
  }

  public void backpropagate(double[] input, double[] targetOutput, double learningRate) {
    // Step 1: Perform a feedforward pass
    double[][] activations = new double[numLayers][];
    activations[0] = input;

    double[][] weightedSums = new double[numLayers - 1][];

    for (int i = 0; i < numLayers - 1; i++) {
      weightedSums[i] = new double[layerSizes[i + 1]];

      for (int j = 0; j < layerSizes[i + 1]; j++) {
        for (int k = 0; k < layerSizes[i]; k++) {
          weightedSums[i][j] += weights[i][j][k] * activations[i][k];
        }

        weightedSums[i][j] += biases[i][j];
      }

      activations[i + 1] = sigmoid(weightedSums[i]);
    }

    // Step 2: Calculate the output layer error
    double[] output = activations[numLayers - 1];
    double[] outputError = new double[layerSizes[numLayers - 1]];

    for (int i = 0; i < layerSizes[numLayers - 1]; i++) {
      double activation = output[i];
      outputError[i] = (targetOutput[i] - activation) * activation * (1 - activation);
    }

    // Step 3: Backpropagate the error
    double[][][] weightGradients = new double[numLayers - 1][][];
    double[][] biasGradients = new double[numLayers - 1][];

    for (int i = numLayers - 2; i >= 0; i--) {
      weightGradients[i] = new double[layerSizes[i + 1]][layerSizes[i]];
      biasGradients[i] = new double[layerSizes[i + 1]];

      for (int j = 0; j < layerSizes[i + 1]; j++) {
        double delta = outputError[j];
        double activation = activations[i + 1][j];
        double gradient = delta * activation * (1 - activation);

        for (int k = 0; k < layerSizes[i]; k++) {
          weightGradients[i][j][k] = learningRate * gradient * activations[i][k];
        }

        biasGradients[i][j] = learningRate * gradient;
      }

      double[] nextLayerError = new double[layerSizes[i]];

      for (int j = 0; j < layerSizes[i]; j++) {
        double sum = 0;
        for (int k = 0; k < layerSizes[i + 1]; k++) {
          sum += weights[i][k][j] * outputError[k];
        }

        double activation = activations[i][j];
        nextLayerError[j] = sum * activation * (1 - activation);
      }

      outputError = nextLayerError;
    }

    // Step 4: Update weights and biases
    for (int i = 0; i < numLayers - 1; i++) {
      for (int j = 0; j < layerSizes[i + 1]; j++) {
        for (int k = 0; k < layerSizes[i]; k++) {
          weights[i][j][k] += weightGradients[i][j][k];
        }

        biases[i][j] += biasGradients[i][j];
      }
    }
  }

  public void mutate(double mutationRate) {
    for (int i = 0; i < numLayers - 1; i++) {
      for (int j = 0; j < layerSizes[i + 1]; j++) {
        for (int k = 0; k < layerSizes[i]; k++) {
          if (random.nextDouble() < mutationRate) {
            weights[i][j][k] += random.nextGaussian() * 0.1; // Adjust the mutation strength as needed
          }
        }
        if (random.nextDouble() < mutationRate) {
          biases[i][j] += random.nextGaussian() * 0.1; // Adjust the mutation strength as needed
        }
      }
    }
  }

  public void combine(NeuralNetwork partner) {
    for (int i = 0; i < numLayers - 1; i++) {
      for (int j = 0; j < layerSizes[i + 1]; j++) {
        for (int k = 0; k < layerSizes[i]; k++) {
          if (random.nextBoolean()) {
            weights[i][j][k] = partner.weights[i][j][k];
          }
        }
        if (random.nextBoolean()) {
          biases[i][j] = partner.biases[i][j];
        }
      }
    }
  }

  public NeuralNetwork generateCopy() {
    NeuralNetwork copy = new NeuralNetwork(layerSizes);

    // Copy weights
    for (int i = 0; i < numLayers - 1; i++) {
      for (int j = 0; j < layerSizes[i + 1]; j++) {
        System.arraycopy(weights[i][j], 0, copy.weights[i][j], 0, layerSizes[i]);
      }
    }

    // Copy biases
    for (int i = 0; i < numLayers - 1; i++) {
      System.arraycopy(biases[i], 0, copy.biases[i], 0, layerSizes[i + 1]);
    }

    return copy;
  }


  public void printWeights() {
    for (int i = 0; i < numLayers - 1; i++) {
      System.out.println("Layer " + i + " to " + (i + 1) + " weights:");
      for (int j = 0; j < layerSizes[i + 1]; j++) {
        System.out.println(Arrays.toString(weights[i][j]));
      }
      System.out.println();
    }
  }

  public void printBiases() {
    for (int i = 0; i < numLayers - 1; i++) {
      System.out.println("Layer " + i + " to " + (i + 1) + " biases:");
      System.out.println(Arrays.toString(biases[i]));
      System.out.println();
    }
  }
}
