public class Network {

  // Layers
  InputNeuron[] input;
  HiddenNeuron[] hidden;
  OutputNeuron[] output;

  // Constructor makes the entire network based on number of inputs & number of neurons in hidden layer
  public Network(int inputs, int hiddentotal, int outputtotal) {
    //Input: 3+1, Hidden: 7+1, Output: 1 in our case
    input = new InputNeuron[inputs+1];  // Got to add a bias input
    hidden = new HiddenNeuron[hiddentotal+1]; // Got to add a bias input
    output = new OutputNeuron[outputtotal];

    //Input: 7 + 1, Hidden: 9+1, Output: 1
    // Make input neurons
    for (int i = 0; i < input.length-1; i++) {
      input[i] = new InputNeuron();
    }

    // Make hidden neurons
    for (int i = 0; i < hidden.length-1; i++) {
      hidden[i] = new HiddenNeuron();
    }

    // Make bias neurons
    input[input.length-1] = new InputNeuron(1);
    hidden[hidden.length-1] = new HiddenNeuron(1);

    // Make output neuron
    for (int i = 0; i < output.length; i++) {
      output[i] = new OutputNeuron();
    }

    // Connect input layer to hidden layer
    for (int i = 0; i < input.length; i++) {
      for (int j = 0; j < hidden.length; j++) {
        // Create the connection object and put it in both neurons
        Connection c = new Connection(input[i], hidden[j]);
        input[i].addConnection(c);
        hidden[j].addConnection(c);
      }
    }

    // Connect the hidden layer to the output neuron
    for (int i = 0; i < hidden.length; i++) {
      for (int j = 0; j < output.length; j++) {
        // Create the connection object and put it in both neurons
        Connection c = new Connection(hidden[i], output[j]);
        hidden[i].addConnection(c);
        output[j].addConnection(c);
      }
    }
  }

  //Send our inputs to hidden, then from hidden to output and return a value
  public float[] feedForward(float[] inputVals) {
    // Feed the input with an array of inputs
    for (int i = 0; i < inputVals.length; i++) {
      input[i].input(inputVals[i]);
    }

    // Have the hidden layer calculate its output
    for (int i = 0; i < hidden.length; i++) {
      hidden[i].calcOutput(1);
    }

    // Calculate the output of the output neuron, activation function used.
    for (int i = 0; i < output.length; i++) {
      output[i].calcOutput(2);
    }

    //Get output results into an array.
    float[] outputVals =  new float[output.length];
    for (int i = 0; i < output.length; i++) {
      outputVals[i] = output[i].getOutput();
    }

    // Return output
    return outputVals;
  }

}