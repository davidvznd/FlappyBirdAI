public class Bird implements Cloneable {
  boolean isAlive;
  PVector position;
  PVector velocity;
  PVector acceleration;
  PImage sprite;
  int birdHeight = 30;
  int birdWidth = 40;
  int totalDistance = 0;
  int fitness = 0;
  Network brain = new Network(7, 9, 1);
  
  Obstacle reference;

  Bird(PVector pos)
  {
    position = pos;
    sprite = loadImage("bird.png");
    acceleration = new PVector(0, 0);
    velocity = new PVector(0, 0);
    isAlive = true;
  }

  void update()
  {
    velocity.add(acceleration);
    velocity.y = constrain(velocity.y, -9, 9);
    //println(velocity.y + "\n");
    if (position.y + velocity.y <= 0)
    {
      position.y = 0;
    } else
    {
      position.add(velocity);
    }

    acceleration.mult(0);
  }

  void display()
  {
    //image(sprite, position.x, position.y, birdWidth, birdHeight);
    rect(position.x, position.y, 40, 30);
    //image(sprite, position.x, position.y, birdWidth, birdHeight);
  }

  // Newton’s second law, applies forces when we need to.
  void applyForce(PVector force) {
    PVector f = PVector.div(force, 1);
    acceleration.add(f);
  }

  //Mutation function.
  public void applyMutation(float mutation_rate)
  {
    //Hidden layer contains all connections so we iterate through each hidden node
    for (int i = 0; i < 10; i++)
    {
      //6 total connections each neuron - both input (7+1) and output (1).
      for (int j = 0; j < 9; j++)
      {
        float chance = random(0, 1);
        // 5% chance to mutate a connection
        if (chance <= mutation_rate)
        {
          Connection c = (Connection)brain.hidden[i].connections.get(j);
          //Change the connection from -1 to 1
          c.weight = random(-0.5, 0.5);
          break;
        }
      }
    }
  }
}