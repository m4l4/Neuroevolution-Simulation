/*
Neuroevolution simulation
 created by Marco Perozziello  22/10/2017
 https://forum.processing.org/two/profile/39945/m4l4
 
 Credits to Daniel Shiffman from "The coding train" for his lessons
 5 moths ago i din't even knew how to draw a circle, he's done the rest.
 https://www.youtube.com/user/shiffman
 
 Credists to ScottC who created the Neural Net design that i've rearranged for my project.
 i'll refer to his blog for detailed explanation of his Neural Network
 http://arduinobasics.blogspot.com/p/arduinoprojects.html
 
 Also credits to the Processing community for helping me by answering all my noobish questions on the forum :)
 */

World world;

int time;
int generation;
int longestGeneration;
float oldestEater;
int bestGen;
int numE;
int numF;


void setup() {
  //  fullScreen();
  size(1280, 800);
  smooth();
  numE = 30;
  numF = 50;
  time = 0;
  generation = 0;
  longestGeneration = 0;
  oldestEater = 0;
  bestGen = 0;
  world = new World(numE, numF);
}


void draw() {
  background(255);
  if (world.eatersClones.size() < numE) {
    world.run();
    time += 1;
  } else {

    if (time > longestGeneration) longestGeneration = time;
    if (world.getEatersMaxFitness() > oldestEater) {
      oldestEater = world.getEatersMaxFitness();
      bestGen = generation;
    }

    time = 0;
    generation++;

    world.foods.clear();
    int r = world.eatersClones.get(0).r;
    for (int i=0; i < numF; i++) {                            
      world.foods.add(new Food(random(r+r/2, width-(r+r/2)), random(r+r/2, height-(r+r/2))));    //initialize food for the next gen
    }

    world.eaterSelection();
    world.eatersReproduction();
  }

  fill(0);                                                               // display some stats
  textSize(12);
  text("Generation #: " + (generation), 10, 18);
  text("Lifetime: " + (time), 10, 36);
  text("living Eaters: " + world.eaters.size(), 10, 54);
  text("Longest gen: " + longestGeneration, 10, 72);
  text("Oldest Eater: gen" +bestGen + " - " + oldestEater, 10, 90);


  if (mouseButton == LEFT) {
    for (int i = 0; i < world.eaters.size(); i++) {       // show brain structure and activity when you click on a creature
      world.eaters.get(i);
      if (mouseX >  world.eaters.get(i).position.x - world.eaters.get(i).r*2 && mouseX < world.eaters.get(i).position.x + world.eaters.get(i).r*2 && mouseY > world.eaters.get(i).position.y - world.eaters.get(i).r*2 && mouseY < world.eaters.get(i).position.y + world.eaters.get(i).r*2) {

        for (int j = 0; j < world.eaters.size(); j++) {
          world.eaters.get(j).displayBrain = false;
        }
        world.eaters.get(i).displayBrain = !world.eaters.get(i).displayBrain;
      }
    }
  }
}
