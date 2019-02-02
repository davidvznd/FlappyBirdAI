public class Obstacle {
  PVector position;
  public int randomNumber;
  PVector speed;
  int obstacleSize = 90;
  float offset = 0.5 * obstacleSize;
  int yUp;
  int yDown;
  //Add the two obstacles

  //Max height should be like height - 112 - some number
  //Min height should be like some number

  Obstacle(PVector pos, PVector oSpeed, int lastObs)
  {
    position = pos;
    if (lastObs == 0)
    {
      randomNumber = int(random(200, height-112-200));
    } else
    {
      randomNumber = int(random(200, height-112-200));
      while (randomNumber < lastObs + 75 && randomNumber > lastObs - 75 && lastObs != randomNumber)
      {
        randomNumber = int(random(200, height-112-200));
      }
    }
    //println(randomNumber + "\n");
    speed = oSpeed;
    yUp = randomNumber - 125;
    yDown = randomNumber +125;
    position.y = randomNumber;
  }

  void update()
  {
    position.x -= speed.x;
  }

  void display()
  {
    //line(position.x, position.y, position.x, position.y + height);
    //fill(255, 0, 0);
    ellipse(position.x, position.y, 5, 5);
    //ellipse(position.x, yDown, 10,10);
    //ellipse(position.x, yUp, 10, 10);
    rect(position.x - offset, 0, obstacleSize, yUp, 5);
    rect(position.x - offset, yDown, obstacleSize, height-yDown, 5);
  }

  void checkCollision(Bird bird)
  {
    //Check if player is colliding with one of the pipes
    if (bird.position.x + bird.birdWidth >= position.x - offset && bird.position.x <= position.x + offset && bird.position.y + bird.birdHeight >= yDown && bird.position.y <= height - 112)
    {
      bird.isAlive = false;
      bird.reference = this;
    }
    if (bird.position.x + bird.birdWidth >= position.x - offset && bird.position.x <= position.x + offset && bird.position.y + bird.birdHeight >= 0 && bird.position.y <= yUp)
    {
      bird.isAlive = false;
      bird.reference = this;
    }
  }
}