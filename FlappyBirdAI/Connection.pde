// Connection class that links the two neurons.
// Inspired by Daniel Shiffman's XOR code in Week 9
public class Connection {

    private Neuron from;     // Connection goes from. . .
    private Neuron to;       // To. . .
    public float weight;   // Weight of the connection. . .

    // Constructor  builds a connection with a random weight
    public Connection(Neuron a_, Neuron b_) {
        from = a_;
        to = b_;
        weight = (float) random(-1,1);
    }
    
    // In case I want to set the weights manually, using this for testing
    public Connection(Neuron a_, Neuron b_, float w) {
        from = a_;
        to = b_;
        weight = w;
    }

    public Neuron getFrom() {
        return from;
    }
    
    public Neuron getTo() {
        return to;
    }  
    
    public float getWeight() {
        return weight;
    }


}