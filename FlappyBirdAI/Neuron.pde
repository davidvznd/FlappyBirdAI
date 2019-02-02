//Neuron Class
//Inspired by Daniel Shiffman's Neural network from Week 9 Lab

public class Neuron {
  public float output;
  public ArrayList connections; 
  public boolean bias = false;

  // A regular Neuron
  public Neuron() {
    output = 0;
    // Using an arraylist to store list of connections to other neurons
    connections = new ArrayList();  
    bias = false;
  }

  // Constructor for a bias neuron
  public Neuron(int i) {
    output = i;
    connections = new ArrayList();
    bias = true;
  }

  // Function to calculate output of this neuron
  // Output is sum of all inputs*weight of connections
  // Depending on what neuron, it will apply an additional activation function
  public void calcOutput(int id) {
    if (bias) {
      // do nothing
    } else {
      float sum = 0;
      float bias = 0;
      for (int i = 0; i < connections.size(); i++) {
        Connection c = (Connection) connections.get(i);
        Neuron from = c.getFrom();
        Neuron to = c.getTo();
        if (to == this) {
          if (from.bias) {
            bias = from.getOutput()*c.getWeight();
          } else {
            sum += from.getOutput()*c.getWeight();
          }
        }
      }
      // Output is result of sigmoid function
      if (id == 2)
      {
        output = f(bias+sum);
      }
      // Hidden is just adding the sum.
      if(id == 1)
      {
        output = (bias+sum);
      }
    }
  }

  void addConnection(Connection c) {
    connections.add(c);
  }

  float getOutput() {
    return output;
  }

  // Sigmoid Function
  public float f(float x) {
    return 1.0f / (1.0f + (float) Math.exp(-x));
  }

  //returns an array of all connections to the current neuron.
  public ArrayList getConnections() {
    return connections;
  }
}