public class Ground {
  PVector position;
  PVector speed;
  PImage sprite;

  Ground(PVector pos, PVector spd)
  {
    position = pos;
    speed = spd;
    sprite = loadImage("ground.png");
  }

  void display()
  {
    image(sprite, position.x, position.y);
    image(sprite, position.x + 336, position.y);
    image(sprite, position.x + 672, position.y);
    if (position.x < -336)
    {
      position.x = 0;
    }
  }

  void checkCollision(Bird other)
  {
    Bird bird = other;
    //We only care about bird y collisions.
    if (bird.position.y + bird.birdHeight >= height-112 && bird.position.y <= height)
    {
      //println("in collision");
      bird.isAlive = false;
      bird.reference = obstacles.get(0);
      if (bird.position.x > bird.reference.position.x)
      {
        bird.reference = obstacles.get(1);
        if (bird.position.x > bird.reference.position.x)
        {
          bird.reference = obstacles.get(2);
        }
      }
    }
  }
}