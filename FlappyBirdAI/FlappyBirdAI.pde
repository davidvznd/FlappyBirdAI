//Global Objects & Variables
Ground ground;
PImage background;

//Game Values
int totalGameDistance = 0;
int previousObstacle = 0;
float gravity = 0.5;
PVector obstacle_speed = new PVector(3, 0);
int generation = 0;

boolean toggle_display = true;

//Genetic Algorithm constants
float CROSS_THRESHOLD = 0.5f;
float MUTATION_RATE = 0.15f;

int populationSize = 100;
int gameOverBirds;
Bird player;

Bird GlobalElite;
int GlobalEliteFitness = 0;
int EliteFitness;

ArrayList<Obstacle> obstacles = new ArrayList<Obstacle>();
ArrayList<Bird> AllBirds = new ArrayList<Bird>(); 

void setup()
{
  size(540, 960);
  //construct all birds
  for (int i=0; i < populationSize; i++)
  {
    AllBirds.add(new Bird(new PVector(width/5, height/2 - 112)));
  }
  ground = new Ground(new PVector(0, height-112), new PVector(-5, 0));
  background = loadImage("background.png");
  obstacles.add(new Obstacle(new PVector(width, 0), obstacle_speed, previousObstacle));
  textSize(10);
  GlobalElite = AllBirds.get(0);
  frameRate(99999999);
}

void draw()
{
  //Debug stuff
  fill(0);
  if (toggle_display)
  {
    background(background);
    text("Distance: " + totalGameDistance, 20, 20);
    text("Generation: " + generation, 20, 40);
  }

  //text("Score: " + score, 20, 50);
  fill(255);
  gameOverBirds = 0;
  //Obstacle destructor
  for (int i = 0; i < obstacles.size(); i++)
  {
    Obstacle currentObs = obstacles.get(i);
    if (currentObs.position.x <= 30)
    {
      obstacles.remove(i);
    }
  }

  //All birds will be flying at the same time!
  for (int i=0; i < populationSize; i++)
  {
    Bird currentBird = AllBirds.get(i);
    if (currentBird.isAlive)
    {
      //what this does - gets array of inputs and feeds forward to bird brain, output is checked and an action is done
      float[] birdOutput = brainAction(i);
      //print(birdOutput[0] + "\n");
      //Same code as the UP key press.
      if (birdOutput[0] >= 0.75f)
      {
        PVector jump = new PVector(0, -100f);
        currentBird.applyForce(jump);
      }
      currentBird.reference = obstacles.get(0);

      //After this, check physics/collisions for current bird and update accordingly, update display and check if dead. Set a flag so that when a bird dies, their physics is over.
      for (int j = 0; j < obstacles.size(); j++)
      {
        Obstacle currentObs = obstacles.get(j);
        currentObs.checkCollision(currentBird);
      }

      AllBirds.get(i).update();
      AllBirds.get(i).applyForce(new PVector(0, gravity));

      //Check if player is hitting the ground, mark them dead if they are.
      ground.checkCollision(currentBird);

      if (!currentBird.isAlive)
      {
        if (currentBird.totalDistance != 0)
        {
          //do nothing
        } else
        {
          currentBird.totalDistance = totalGameDistance;
        }
      }
    } else
    {
      gameOverBirds += 1;
    }
  }
  //  print(gameOverBirds + "\n");
  for (int i = 0; i < obstacles.size(); i++)
  {
    Obstacle currentsObs = obstacles.get(i);
    currentsObs.update();
  }
  ground.position.add(-3, 0);
  totalGameDistance += 3;

  if (totalGameDistance%270 == 0)
  {
    //Spawn obstacles
    obstacles.add(new Obstacle(new PVector(width, 0), obstacle_speed, previousObstacle));
    Obstacle test = obstacles.get(obstacles.size()-1);
    previousObstacle = test.randomNumber;
  }

  if (toggle_display)
  {
    //Display code
    for (int i = 0; i < obstacles.size(); i++)
    {
      Obstacle currentObs = obstacles.get(i);
      currentObs.display(); //displaycomment
    }
    for (int i=0; i < populationSize; i++)
    {
      Bird currentBird = AllBirds.get(i);

      if (currentBird.isAlive)
      {
        currentBird.display();
      }
    }
    ground.display();
  } else
  {
    //Display code
    for (int i = 0; i < obstacles.size(); i++)
    {
      Obstacle currentObs = obstacles.get(i);
      //currentObs.display(); //displaycomment
    }
    for (int i=0; i < populationSize; i++)
    {
      Bird currentBird = AllBirds.get(i);

      if (currentBird.isAlive)
      {
        //currentBird.display();
      }
    }
    //ground.display();
  }

  //Check if we're at the end game
  if (gameOverBirds == populationSize)
  { 
    //print("Generation start: " + generation + "\n");
    //Find fitness calculations
    for (int i=0; i < populationSize; i++)
    {
      Bird currentBird = AllBirds.get(i);
      currentBird.fitness = (currentBird.totalDistance/10) * (1 +(currentBird.totalDistance/270));
      if (currentBird.totalDistance < 135)
      {
        currentBird.fitness = 1;
      }
    }
    //New generation to start, fitness applied to all birds already
    //Finding top 5 elites - put into an array to be added to the next generation.
    ArrayList<Bird> bestElites = new ArrayList<Bird>(); 

    //Find top 5 elites
    for (int i=0; i < populationSize; i++)
    {
      //initially grab first 5 birds.
      if (i < 5)
      {
        bestElites.add(AllBirds.get(i));
      } else
      {
        //Check if any of the birds in the elites is actually not an elite and replace them.
        for (int j = 0; j < bestElites.size(); j++)
        {
          if (AllBirds.get(i).fitness > bestElites.get(j).fitness)
          {
            Bird reference = AllBirds.get(i);
            bestElites.set(j, reference);
            break;
          }
        }
      }
    }

    //Gets the fittest elite.
    Bird Elite = AllBirds.get(0);
    for (int i=0; i < populationSize; i++)
    {
      if (AllBirds.get(i).fitness >= Elite.fitness)
      {
        Elite = AllBirds.get(i);
      }
    }
    EliteFitness = Elite.fitness;

    Bird referenceElite = Elite;
    if (GlobalEliteFitness < EliteFitness)
    {
      print("Generation: " + generation + "\n");
      print("GLOBAL: " +GlobalEliteFitness + "\n");
      print("SESSION: "+EliteFitness + "\n");
      GlobalEliteFitness = EliteFitness;
      print("NEW GLOBAL: " +GlobalEliteFitness + "\n\n");
      saveToFile(referenceElite);
    }

    //Generate Mating Pool basedon fitness of all birds
    ArrayList<Bird> matingPool = new ArrayList<Bird>();
    for (int i=0; i < populationSize; i++)
    {
      Bird sample = AllBirds.get(i);
      for (int j=0; j < (int) sample.fitness; j++)
      {
        matingPool.add(sample);
      }
    }

    //Start making the new generation - Consists of the top 5, 5 copies of the fittest, 80 from mating pool, and 10 random.
    for (int i=0; i < populationSize; i++)
    {
      if (i < 10)
      {
        //Add 10 copies of Elite
        AllBirds.set(i, referenceElite);
        AllBirds.get(i).applyMutation(MUTATION_RATE);
        continue;
      } else if (i <= 10 && i <40)
      {
        //crossover between elite parents
        int index1 = int(random(bestElites.size()-1));
        int index2 = int(random(bestElites.size()-1));
        int count = 0;
        while (index2 == index1 && count < 100)
        {
          index2 = int(random(bestElites.size()-1));
          count +=1;
        }
        Bird EliteParent1 = bestElites.get(index1);
        Bird EliteParent2 = bestElites.get(index2);

        int hiddenLength = 10;
        int hiddenConnections = 9;
        //For each connection, we will determine if we get Parent 1 or Parent 2 weight 
        //Since all conections can be accessed by iterating hidden neurons, we iterate through each one to update the brain of each slime.
        for (int j = 0; j < hiddenLength; j++)
        {
          //Get each connection of a hidden neuron, change the connection to either parent 1 or 2
          //Bird hidden beuron brain here.
          HiddenNeuron[] hidden = AllBirds.get(i).brain.hidden;
          for (int k = 0; k < hiddenConnections; k++)
          {
            //50% chance to get the weight of parent 1 or parent 2
            if (random(0, 1) > CROSS_THRESHOLD)
            {
              Connection pc = (Connection) EliteParent1.brain.hidden[j].connections.get(k);
              Connection c = (Connection) hidden[j].connections.get(k);
              c.weight = pc.weight;
            } else
            {
              Connection pc = (Connection) EliteParent2.brain.hidden[j].connections.get(k);
              Connection c = (Connection) hidden[j].connections.get(k);
              c.weight = pc.weight;
            }
          }
        }
        //All children are given a chance to mutate a connection.

        AllBirds.get(i).applyMutation(MUTATION_RATE);
        continue;
      } else if (i <=40 && i<95)
      {
        int index1 = int(random(matingPool.size()-1));
        int index2 = int(random(matingPool.size()-1));
        int count = 0;
        while (index2 == index1 && count < 100)
        {
          index2 = int(random(matingPool.size()-1));
        }
        //Set up the parents based on the mating pool and move on to crossover/mutation code.
        //Bird Parent1 = matingPool.get(int(random(matingPool.size()-1)));
        //Bird Parent2 = matingPool.get(int(random(matingPool.size()-1)));
        Bird Parent1 = matingPool.get(index1);
        Bird Parent2 = matingPool.get(index2);
        int hiddenLength = 10;
        int hiddenConnections = 9;
        //For each connection, we will determine if we get Parent 1 or Parent 2 weight 
        //Since all conections can be accessed by iterating hidden neurons, we iterate through each one to update the brain of each slime.
        for (int j = 0; j < hiddenLength; j++)
        {
          //Get each connection of a hidden neuron, change the connection to either parent 1 or 2
          //Bird hidden beuron brain here.
          HiddenNeuron[] hidden = AllBirds.get(i).brain.hidden;
          for (int k = 0; k < hiddenConnections; k++)
          {
            //50% chance to get the weight of parent 1 or parent 2
            if (random(0, 1) > CROSS_THRESHOLD)
            {
              Connection pc = (Connection) Parent1.brain.hidden[j].connections.get(k);
              Connection c = (Connection) hidden[j].connections.get(k);
              c.weight = pc.weight;
            } else
            {
              Connection pc = (Connection) Parent2.brain.hidden[j].connections.get(k);
              Connection c = (Connection) hidden[j].connections.get(k);
              c.weight = pc.weight;
            }
          }
        }
        AllBirds.get(i).applyMutation(MUTATION_RATE);
        continue;
      } else
      {
        AllBirds.set(i, bestElites.get((int)random(0, 5)));
        AllBirds.get(i).applyMutation(MUTATION_RATE);
        continue;
      }
    }
    //End - reset globals.
    StartNewGeneration();
  }
}

void StartNewGeneration()
{
  generation += 1;
  gameOverBirds = 0;
  totalGameDistance = 0;
  previousObstacle = 0;
  for (int i = 0; i < populationSize; i++)
  {
    Bird currentBird = AllBirds.get(i);
    currentBird.fitness = 0;
    currentBird.isAlive = true;
    currentBird.position.x = width/5;
    currentBird.position.y = height/2 - 112;
    currentBird.totalDistance = 0;
  }
  obstacles.clear();
  obstacles.add(new Obstacle(new PVector(width, 0), obstacle_speed, previousObstacle));
}

//Y-value of Bird, Y-speed, Distance from obstacle X, Distance from obstacle Y
float[] brainAction(int i)
{
  Bird currentBird = AllBirds.get(i);
  Obstacle targetObstacle = obstacles.get(0);
  if (currentBird.position.x > targetObstacle.position.x)
  {
    targetObstacle = obstacles.get(1);
    if (currentBird.position.x > targetObstacle.position.x)
    {
      targetObstacle = obstacles.get(2);
    }
  }
  //Here we'll use the id of bird.
  float[] oneInputNormal = new float[]{
    normaliseValue(currentBird.position.y, 0, height-112, 0, 1), 
    normaliseValue(currentBird.position.y+ currentBird.birdHeight, 0+ currentBird.birdHeight, height-112+ currentBird.birdHeight, 0, 1), 
    normaliseValue(currentBird.velocity.y, -10, 10, 0, 1), 
    normaliseValue(targetObstacle.position.x - (currentBird.position.x + currentBird.birdWidth/2), 0, width-(width/5), 0, 1), 
    normaliseValue(targetObstacle.position.y - (currentBird.position.y + currentBird.birdHeight/2), ((-1*height)/2), height/2, 0, 1), 
    normaliseValue(targetObstacle.position.x, 30, width, 0, 1), 
    normaliseValue(targetObstacle.position.y, 200, height-112-200, 0, 1)
  };

  float[] output = currentBird.brain.feedForward(oneInputNormal);
  return output;
}

//This will convert the value based on old range to new range
float normaliseValue(float value, float oldRangeLow, float oldRangeHigh, float newRangeLow, float newRangeHigh)
{
  //NewValue = (((newRangeHigh-newRangeLow)*(oldValue-oldRangeLow))/oldRangeHigh-oldRangeLow) + newRangeLow
  float newValue;
  float upper;
  float lower;
  upper = (newRangeHigh-newRangeLow)*(value-oldRangeLow);
  lower = oldRangeHigh-oldRangeLow;
  newValue = (upper/lower) + newRangeLow;
  return newValue;
}

//Save function for every 100th generation
void saveToFile(Bird elite) {
  //Saving to file
  String[] connectionsList1;
  String connectionData1="";

  // Have the hidden layer calculate its output
  for (int i = 0; i < elite.brain.hidden.length; i++) {
    //16 connections for hidden layer - 12 input + 3 output. We can get all the weights from the hidden layer.
    for (int j = 0; j < elite.brain.hidden[i].connections.size(); j++)
    {
      //We can grab connections weight like this.
      Connection c = (Connection) elite.brain.hidden[i].connections.get(j);
      //Concat to string along with a , in between each to create a list of connections to add to our game code.
      connectionData1 = connectionData1.concat(Float.toString(c.getWeight())+",");
    }
  }
  connectionsList1 = split(connectionData1, ",");
  //print("Connections - Generation" + generation +" - Fitness"+ GlobalElite.fitness + ".txt\n");
  saveStrings("Generation" + generation +"- Fitness"+ GlobalEliteFitness+ ".txt", connectionsList1);
}

void keyPressed()
{
  if (keyCode == UP)
  {
    if (player.isAlive)
    {
      PVector jump = new PVector(0, -100f);
      player.applyForce(jump);
    }
  }
  if (keyCode == DOWN)
  {
    toggle_display = !toggle_display;
  }
}