class World {

  ArrayList<Food> foods;                   //plants array
  ArrayList<Eater> eaters;                 //creatures array
  ArrayList<Eater> eatersClones;           //clones array we will use to recover stats from dead creatures
  ArrayList<Eater> eatersMatingPool;       //selection pool we will use for reproduction

  float foodSpawnRate;                     
  float mutationRate;
  int r;

  World(int numE, int numF) {
    foodSpawnRate = 0.02;
    mutationRate = 0.01;
    foods = new ArrayList<Food>(); 
    eaters = new ArrayList<Eater>();
    eatersClones = new ArrayList<Eater>();
    eatersMatingPool = new ArrayList<Eater>();

    for (int i=0; i < numE; i++) {                                                        // populate the arraylist for eaters
      eaters.add(new Eater(random(0, width), random(0, height), new NeuralNetwork()));
    }

    r = eaters.get(0).r;
    for (int i=0; i < numF; i++) {                                                        // populate the arraylist for plants
      foods.add(new Food(random(r+r/2, width-(r+r/2)), random(r+r/2, height-(r+r/2))));   //to avoid generating out of reach food, we use creaure radius as reference
    }
  }

  void run() {                                       //since plants and creatures will be either added or removed during the simulation...
    for (int i = foods.size()-1; i >= 0; i--) {      //...we will check arrays backwards to avoid skipping elements.           
      Food f = foods.get(i);                                     
      f.run();
      if (foods.size() > numF*2) foods.remove(0);    // max plants num
    }

    for (int i = eaters.size()-1; i >= 0; i--) {                  
      Eater e = eaters.get(i);
      e.run();
      if (e.dead()) {
        eatersClones.add(e);                     //when a creature dies, we first move it int the clones array for later use
        eaters.remove(i);                        //than we remove it from the world
      } else {
        e.age ++;
      }
    }

    if (random(1) < foodSpawnRate) foods.add(new Food(random(r+r/2, width-(r+r/2)), random(r+r/2, height-(r+r/2))));    // plants will randomly spawn over time
  }

  void eaterSelection() {                             //function to prepare the mating pool for reproduction
    eatersMatingPool.clear();                         //first we clear the old mating pool
    float maxFitness = getEatersMaxFitness();         //we determine who's the best creature of the generation

    for (int i = 0; i < eatersClones.size(); i++) {                               //for every dead creature
      float fitnessNormal = map(eatersClones.get(i).age, 0, maxFitness, 0, 1);    //we normalize the fitness score between 0 and 1
      int n = (int) (fitnessNormal*100);                                          //multiply it by 100
      for (int j = 0; j < n; j++) {                                               //and add the clone to the pool as many times as it deserves.
        eatersMatingPool.add(eatersClones.get(i));                                //the better you are, the more chances you get to reproduce
      }
    }
  }

  void eatersReproduction() {                        //function to select parents and cross brain data
    float tempWeight;

    for (int i = 0; i < numE; i++) {                 
      eaters.add(new Eater(random(0, width), random(0, height), new NeuralNetwork())); //first we generate a random eater

      int m = int(random(eatersMatingPool.size()));          //choose two random parents from the mating pool
      int d = int(random(eatersMatingPool.size()));

      Eater mom = eatersMatingPool.get(m);                   //get them
      Eater dad = eatersMatingPool.get(d);

      for (int k = 0; k < mom.NN.getLayerCount(); k++) {     //for every layer of the brain...
        float[] momWeights = new float[0];                   //create 3 arrays to store weights and biases of the family
        float[] dadWeights = new float[0];
        float[] childWeights = new float[0];

        momWeights = mom.NN.layers[k].getWeigths();          //get mom and dad weights and biases
        dadWeights = dad.NN.layers[k].getWeigths();

        for (int j = 0; j < momWeights.length; j++) {                      //for every weights of the layer
          if (random(1) > 0.5)  tempWeight = momWeights[j];                //choose random between mom and dad
          else                  tempWeight = dadWeights[j];
          if (random(1) < mutationRate) tempWeight += random(-0.1, 0.1);   //apply chance of mutation
          tempWeight = constrain(tempWeight, -1, 1);                       //clamp new weight
          childWeights = (float[]) append(childWeights, tempWeight);       //add weight to the child weights and bias array
        }
        Eater e = eaters.get(i);                                           //take the random eater we've created at the start
        e.NN.layers[k].setWeights(childWeights);                           //set its brain with the new weights
      }
    }
    eatersClones.clear();                                                  //clear the clones array for the next generation
  }

  float getEatersMaxFitness() {                             //function to get the highest fitness score of the generation
    float record = 0;
    for (int i = 0; i < eatersClones.size(); i++) {
      if (eatersClones.get(i).age > record) {
        record = eatersClones.get(i).age;
      }
    }
    return record;
  }

  Eater getBestEater() {                                    //function to clone the best eater and store it across generations (actually unused)
    Eater bestEater = new Eater(0, 0, new NeuralNetwork());
    for (int i = 0; i < eatersClones.size(); i++) {
      if (eatersClones.get(i).age > bestEater.age) {
        bestEater = eatersClones.get(i);
      }
    }
    return bestEater;
  }

  ArrayList getFood() {
    return foods;
  }

  ArrayList getEater() {
    return eaters;
  }
} 
