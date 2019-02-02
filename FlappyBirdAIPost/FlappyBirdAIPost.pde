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

int populationSize = 1;
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
  float[][] brain2 = {
    {0.40511328, -0.06704599, 0.20196354, -0.37598664, -0.23714727, 0.00619942, 0.25514513, 0.439618, 0.4208293}, 
    {0.122258544, -0.2613986, -0.078053296, 0.26825494, 0.08004016, 0.13460118, 0.4391954, -0.2087267, -0.48516387}, 
    {0.32726192, 0.4691813, 0.19457287, 0.121953785, -0.3497014, 0.27769542, 0.15227097, -0.4550987, -0.029770255}, 
    {-0.49765027, -0.3857187, 0.43145806, -0.08396757, -0.3248071, -0.429716, 0.09705567, 0.38370824, -0.07925373}, 
    {-0.112240374, -0.19486201, 0.12168741, -0.42401958, -0.41799664, -0.25652802, -0.186014, -0.3404655, -0.22774726}, 
    {0.43520457, 0.3408816, -0.041585267, -0.30240798, -0.34024298, 0.43343425, -0.46272057, 0.054276466, 0.45230925}, 
    {-0.3443144, -0.2744987, 0.37409753, 0.49332434, 0.30150056, 0.34854347, 0.4429748, -0.4548607, -0.15106523}, 
    {0.12829125, -0.48642325, 0.18360752, -0.020363986, 0.2729146, -0.36367744, 0.07872081, 0.27331293, 0.38118124}, 
    {0.3505519, -0.28020316, 0.25923222, 0.08481139, 0.47526634, -0.17641765, -0.08485168, 0.23070091, 0.2572078}, 
    {0.031016946, 0.40849584, 0.32028162, -0.45910192, -0.21530235, -0.04061991, -0.36088085, -0.34648955, 0.25776625}
  };

  float[][] brain = {
    {-0.46544665, -0.22707534, 0.284876, -0.26284885, -0.024663746, 0.19065404, -0.016663611, -0.39870507, -0.28855246}, 
    {0.12098473, -0.12426716, 0.4074909, 0.020749152, -0.14438552, 0.3981688, -0.23507279, -0.022159576, 0.35973746}, 
    {-0.028475225, -0.0547179, 0.30141646, -0.1655879, 0.35666245, 0.019500196, 0.24401629, -0.30725825, -0.45377958}, 
    {-0.48803276, 0.24415672, 0.04567617, -0.03129512, -0.06655127, 0.14376533, 0.40076745, 0.35802966, -0.4941706}, 
    {0.29046822, 0.013762355, -0.42738235, 0.4010843, -0.14884108, 0.3823552, -0.1871742, -0.10805076, 0.10319722}, 
    {-0.26533204, 0.32357955, -0.064199984, 0.37844688, 0.32005817, 0.14137828, -0.4114139, 0.25119418, 0.06148857}, 
    {0.01323694, 0.1511873, -0.22530884, 0.4259743, -0.29509908, -0.44491506, -0.32461452, -0.49183422, -0.4818915}, 
    {0.26350075, -0.29416782, -0.15226877, 0.4918419, 0.2666149, -0.046059966, 0.15643328, -0.320243, -0.46176398}, 
    {0.044455647, 0.4248252, 0.45165288, -0.4532184, 0.08778852, 0.1804291, 0.000680208, -0.28599775, 0.31917107}, 
    {-0.48873174, -0.15457916, 0.04594642, 0.1374141, 0.41730583, -0.15746647, -0.10000831, 0.3274628, 0.47351497}

  };
  //construct all birds
  for (int i=0; i < populationSize; i++)
  {
    AllBirds.add(new Bird(new PVector(width/5, height/2 - 112)));
  }

  //link brain
  for (int i=0; i < populationSize; i++)
  {
    HiddenNeuron[] hiddenAI = AllBirds.get(i).brain.hidden;
    //Set the brain to our AI.
    for (int j = 0; j < hiddenAI.length; j++) {
      ArrayList<Connection> current = hiddenAI[j].connections;
      for (int k = 0; k < current.size(); k++)
      {
        current.get(k).weight = brain2[j][k];
      }
    }
  }
  ground = new Ground(new PVector(0, height-112), new PVector(-5, 0));
  background = loadImage("background.png");
  obstacles.add(new Obstacle(new PVector(width, 0), obstacle_speed, previousObstacle));
  textSize(10);
  frameRate(90);
}

void draw()
{
  //Debug stuff
  fill(0);
  if (toggle_display)
  {
    background(background);
    text("Distance: " + totalGameDistance, 20, 20);
  }

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
  //text("Dead: " + gameOverBirds, 20, 40);
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
  fill(0);
  textSize(100);
  text((totalGameDistance - width/4)/270, width/3, height/3);
  textSize(10);
  //Check if we're at the end game
  if (gameOverBirds == populationSize)
  { 
    print("Total distance of Loop " + generation + ": " + totalGameDistance + "\n");
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
    normaliseValue(currentBird.position.y, 0, height-112, 1, 0), 
    normaliseValue(currentBird.velocity.y, -12, 12, 0, 1), 
    normaliseValue(targetObstacle.position.x - currentBird.position.x, width/5, width, 0, 1), 
    normaliseValue(targetObstacle.position.y - currentBird.position.y, 200, height-112-200, 0, 1), 
    normaliseValue(targetObstacle.position.x, 30, width, 0, 1), 
    normaliseValue(targetObstacle.yDown, 300, height-112-200+100, 0, 1), 
    normaliseValue(targetObstacle.yUp, 100, height-112-200-100, 0, 1)
  };
  float[] oneInputStandard = new float[]{
    normaliseValue(currentBird.position.y, 0, height-112, 0, 1), 
    normaliseValue(currentBird.position.y+ currentBird.birdHeight, 0+ currentBird.birdHeight, height-112+ currentBird.birdHeight, 0, 1), 
    normaliseValue(currentBird.velocity.y, -10, 10, 0, 1), 
    normaliseValue(targetObstacle.position.x - (currentBird.position.x + currentBird.birdWidth/2), 0, width-(width/5), 0, 1), 
    normaliseValue(targetObstacle.position.y - (currentBird.position.y + currentBird.birdHeight/2), ((-1*height)/2), height/2, 0, 1), 
    normaliseValue(targetObstacle.position.x, 30, width, 0, 1), 
    normaliseValue(targetObstacle.position.y, 200, height-112-200, 0, 1)
  };


  float[] output = currentBird.brain.feedForward(oneInputStandard);
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