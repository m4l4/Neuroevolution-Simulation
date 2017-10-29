class Eater {

  NeuralNetwork NN = new NeuralNetwork();
  float[] myInputs = {};

  PVector position;
  PVector velocity;
  PVector leftAntennaPos;
  PVector rightAntennaPos;

  int r;                   //radius of the creature
  float antennaLength;     //lenght of the antennas
  float antennaRadius;     //radius of the antennas 
  float age;               //age in this simulation represent the fitness of the creatures.
  float health;            //health value
  float maxHealth;         //health cap
  float speed;             
  float maxSpeed;
  float theta;             //angle of rotation
  float rotationSpeed;     //speed of rotation
  float maxForce;          

  boolean stucked;
  boolean displayBrain;

  Eater(float x, float y, NeuralNetwork NN_) {

    NN = NN_;                  //to initialize the neural network you have to decide how many layer it will have and how many neurons each layer will have

    NN.addLayer(4, 5);         //first layer we add determines the number of input neurons (4 in this case) and the number of neurons of the first hidden layer (5)
    NN.addLayer(5, 4);         //every subsequent layer defines how many connection it has (5) and the number of neurons in the layer (4)
    //since the outputs of a layer become the inputs of the next one...
    //...the number of connections MUST equal the number of neurons of the previous layer
    //the last layer you add determines how many outputs neuron you will have (4 in the example)
    //the constructor i used will initialize a neural net made of: 4 inputs, 1 hidden layer (with 5 neurons), and 4 outputs
    //you can keep adding as many layers and neurons you want, just be sure to check connections or you'll get an error.

    position = new PVector(x, y);    
    velocity = new PVector(0, 0);
    leftAntennaPos = new PVector(0, 0);
    rightAntennaPos = new PVector(0, 0);

    r = 20;
    antennaLength = r;
    antennaRadius = r/4;
    age = 0;
    maxHealth = 200;
    health = maxHealth/2;  
    speed = 0;
    maxSpeed = 4;
    maxForce = 0.5;
    theta = 0;
    rotationSpeed = 2;
    stucked = false;
    displayBrain = false;
  }

  void run() {    
    wrapAround();
    seek();    

    float healthLoss = map(speed, 0, maxSpeed, 0, maxSpeed*0.1);    //healthLoss depends on actual speed, the faster we move the more we consume.
    if (healthLoss < 0.2) healthLoss = 0.2;                         
    health -= healthLoss;

    display();
    if (displayBrain) displayNeuralNet();
  }

  void seek() {
    float newFoodDistance = 10000;                                  // initialize the food distance to a vey high value to avoid getting stuck with disappeared targets
    PVector closestFood = new PVector (random(0, 1), random(0, 1));

    ArrayList<Food> foods = world.getFood();                        // get the distance of every plant in the world
    for (int j = foods.size()-1; j >= 0; j--) {                     // since plants will be removed when eaten, we have to check the arraylist backwards to avoid skipping some of them
      PVector foodPosition = foods.get(j).position;
      float foodDistance = PVector.dist(position, foodPosition);

      if (foodDistance < newFoodDistance) {                      
        newFoodDistance = foodDistance;
        closestFood = foodPosition;
      }
      if (foodDistance < r/2) {                  // if we reach a plant         
        foods.remove(j);                         // remove it from the world
        health += 35;                            // enjoy the meal
      }
    }
    myInputs = new float[0];                                                      //reset inputs array
    //we will tringulate the position of the closest food source by using 3 neurons
    float leftAntennaDistance = PVector.dist(leftAntennaPos, closestFood);        //calculate food distance from left antenna
    myInputs = (float[]) append(myInputs, leftAntennaDistance);                   //set first input neuron
    float rightAntennaDistance = PVector.dist(leftAntennaPos, closestFood);       //calculate food distance from right antenna
    myInputs = (float[]) append(myInputs, rightAntennaDistance);                  //set second input neuron
    float bodyDistance = PVector.dist(position, closestFood);                     //calculate food distance from the body
    myInputs = (float[]) append(myInputs, bodyDistance);                          //set the third input neuron

    float hunger = map(health, 0, maxHealth, -10, 10);                            //the forth one is the "hunger" neuron, it maps current health...
    myInputs = (float[]) append(myInputs, hunger);                                //and inputs a negative value if below "maxHealth/2" or a positive one if above it.
    //that way the creature can "feel" hunger and fullness

    NN.processInputsToOutputs(myInputs);                                          //once we've set the inputs we process them
    //some neurons will be used as binary actuators, if they output > than 0.0 we will take it as a "yes"

    if (NN.arrayOfOutputs[0] > 0.0) theta += radians(rotationSpeed);              //if first output is > 0 rotate right
    if (NN.arrayOfOutputs[1] > 0.0) theta -= radians(rotationSpeed);              //if the second output is > 0 rotate left

    speed = map(NN.arrayOfOutputs[2], -1, 1, 0, maxSpeed);                        //third output is the "Thruster potentiometer" it gets mapped to determine speed value

//    checkCollision();                                                             //check if we're about to collide with other eaters

    if (NN.arrayOfOutputs[3] > 0.0 && stucked == false) {                         //4rth output is the "Thruster" if it output > 0 we move forward based on speed and heading
      velocity.x = speed*cos(theta);                                              //this modify vel.x and vel.y
      velocity.y = speed*sin(theta);                                              //based ont the actual angle
      position.add(velocity);
    }
  }

  void checkCollision() {
    int touchedEaters = 0;
    for (int i=0; i < world.eaters.size(); i++) {                    //check eaters array
      float minDist = (r/2) + (world.eaters.get(i).r/2);             //calculate minimumdistance based on eaters radius
      PVector eaterPos = world.eaters.get(i).position.copy();        //get eater position
      PVector eaterVel = world.eaters.get(i).velocity.copy();        //get eater velocity
      PVector eaterFuturePos = PVector.add(eaterPos, eaterVel);      //forecast eater future position
      PVector futurePos = PVector.add(position, velocity);           //forecast your future position
      float d = PVector.dist(futurePos, eaterFuturePos);                   //check if your movement will exceed minDist

      if (d < minDist && d > 0.1) {     //keep track of "future" touched eaters till the end of the array
        touchedEaters ++;               //d > 0.1 is there to avoid considering ourselves "another" eater
      }
    }
    if (touchedEaters > 0) {    //if we will touch something
      stucked = true;        //get stucked
    } else {              
      stucked = false;
    }
  }

  boolean dead() {                                    // defines death conditions
    if (health < 0.0 || health > maxHealth) {         // creatures will die if their health gets to 0 or if it reaches maxHealth treshold (starving and overeating)
      return true;
    } else {
      return false;
    }
  }

  void borders() {                                            //function to make edge borders
    position.x=constrain(position.x, r+r/2, width-r+r/2);     //limit position vector to screen size
    position.y=constrain(position.y, r+r/2, height-r+r/2);
  }

  void wrapAround() {                                         //make edges continuos
    if (position.x < -r) position.x = width+r;                //wrap borders
    if (position.y < -r) position.y = height+r;
    if (position.x > width+r) position.x = -r;
    if (position.y > height+r) position.y = -r;
  }

  void display() {
    float colour = 0;

    stroke(0);
    if (health < maxHealth/2) {                                //color of the creature changes based on it's health value
      colour = map(health, 0, maxHealth/2, 255, 0);            //an healty creature will show a red color (healty is between 0 and maxHealth)
      fill(255, colour, colour);                               //if it starves the color will fade to white
    } else {
      colour = map(health, maxHealth/2, maxHealth, 255, 0);    //if it eats too much the color will darken to black
      fill(colour, 0, 0);
    }


    pushMatrix();
    translate(position.x, position.y);
    rotate(theta);    
    ellipseMode(CENTER);  

    line(0, 0, r, -r/2);                 //left antenna 
    ellipse(r, -r/2, r/3, r/3);
    leftAntennaPos.x = screenX(r, -r/2);
    leftAntennaPos.y = screenY(r, -r/2);

    line(0, 0, r, r/2);                  //right antenna
    ellipse(r, r/2, r/3, r/3);
    rightAntennaPos.x = screenX(r, r/2);
    rightAntennaPos.y = screenY(r, r/2);

    ellipse(0, 0, r, r);                 //body of the creature
    popMatrix();
  }

  void displayNeuralNet() {                  //Function to display brain structure and activity, it automatically adapt dimensions to brain structure
    //click on a creature to display it

    float brainBoxWidth = width/4;                                      
    float brainBoxHeight = height/4;

    strokeWeight(1);
    stroke(175);
    fill(255, 175);
    rect(width-brainBoxWidth, 0, brainBoxWidth, brainBoxHeight);

    float r = 0;                                                         //radius of the neurons
    int biggestLayer = NN.layers[0].neurons[0].getConnectionCount();     //find which layer has more neurons (initialize with input layer size)
    int networkDepth = NN.getLayerCount()+1;                             //how many layer there are  (+1 is for the input layer)

    for (int i = 0; i < NN.getLayerCount(); i++) {                        //find which layer has more neurons
      if (NN.layers[i].getNeuronCount() > biggestLayer) biggestLayer = NN.layers[i].getNeuronCount();
    }

    float maxYdistance = (brainBoxHeight/biggestLayer+1);                  //define how much space you will have vertically and horizontally
    float maxXdistance = (brainBoxWidth/networkDepth+1);

    if (maxYdistance > maxXdistance) r = maxYdistance/5;                   //the smaller one determine radius of the neurons
    else                             r = maxXdistance/4;

    float xOffset = (brainBoxWidth/(networkDepth+1));                      // distance between layers
    float xPosition = width-xOffset; 


    for (int i = NN.getLayerCount()-1; i >= 0; i--) {                      // starting from the last layer we draw the network backward
      // we do it so because of the way we store weights and bias
      float nextYposition = 0;                                           
      float nextYoffset = 0;
      int connections = 0;
      float yOffset = brainBoxHeight/(NN.layers[i].getNeuronCount()+1);   //distance between neurons of the same layer
      float yPosition = yOffset;                                          //y position of the neuron

      ArrayList<Float> tempWeights = new ArrayList<Float>();              //since the weights array contains biases we will need to remove them
      float[] layerWeights = NN.layers[i].getWeights();                   //removing object is easier with arraylist so we first get a copy of the layerWeights array

      for (int n = 0; n < layerWeights.length; n++) {                     //and we then clone it into an arraylist
        tempWeights.add(layerWeights[n]);
      }


      for (int j = 0; j < NN.layers[i].getNeuronCount(); j++) {                           //for every neuron of the layer...

        if (i > 0) {
          nextYoffset = brainBoxHeight/(NN.layers[i-1].getNeuronCount()+1);               //calculate yposition of the next layers neurons
          connections = NN.layers[i-1].getNeuronCount();                                  //check how many connection we have to make with the next layer
        } else {     
          nextYoffset = brainBoxHeight/(NN.layers[0].neurons[0].getConnectionCount()+1);  //if we are at the last layer (layer[0] since we are going backward)
          connections = NN.layers[0].neurons[0].getConnectionCount();                     //we use its connections to draw the input layer
        }

        nextYposition = nextYoffset;                                          

        for (int k = 0; k < connections; k++) {                      //finally we draw the connections

          float tempStrokeWeight = 0;                                //strokeweight and color depend on the connection weight
          if (tempWeights.get(0) < 0.0) {                            //if the connection has a negative weight
            tempStrokeWeight = (1+ tempWeights.get(0)*-1.5);         //we draw it as it was positive
            stroke(255, 0, 0);                                       //but we draw it in red
          } else {
            tempStrokeWeight = (1+ tempWeights.get(0)*1.5);
            stroke(0);                                               //positive connections are drawn in black
          }
          float nextXposition = xPosition - xOffset;                 //keep track of the x offset

          strokeWeight(tempStrokeWeight);                            //set strokeweight
          line(xPosition, yPosition, nextXposition, nextYposition);  //draw the connection

          nextYposition += nextYoffset;                              //point at the next neuron
          tempWeights.remove(0);                                     //remove the used weight from the arraylist
        }

        if (i == NN.getLayerCount()-1) {                             //output neurons change based on their activity
          if (NN.arrayOfOutputs[j] > 0.0) fill(0);                   //black = active
          else                            fill(255);                 //white = inactive
        } else {
          float tempColor = 0;                                         //neuron color depends on its bias
          if (tempWeights.get(0) > 0.0) {                              //if bias is positive color goes from white to black (0 to 1)
            tempColor = map(tempWeights.get(0), 0, 1, 255, 0);        
            fill(tempColor);
          } else {                                                       //if bias is negative color goes from white to red (0 to -1)
            tempColor = map(tempWeights.get(0), -1, 0, 0, 255);
            fill(255, tempColor, tempColor);
          }
        }
        strokeWeight(1);
        stroke(0);
        ellipseMode(CENTER);
        ellipse(xPosition, yPosition, r, r);                         //once every connections has been drawn, we draw the neuron
        yPosition += yOffset;                                        //we move down a neuron
        tempWeights.remove(0);                                       //we remove the neuron bias from the weights arraylist
      }
      tempWeights.clear();                                           //once we've finished drawing a layer we clear the weights array
      xPosition -= xOffset;                                          //and we advance to the next x position

      if (i == 0) {                                                                 //once we've finished with the layer 0
        xPosition = (width-brainBoxWidth)+xOffset;                                  //reset position X and y
        yOffset = brainBoxHeight/(NN.layers[0].neurons[0].getConnectionCount()+1);  //calculate yOffset based on the inputs num
        yPosition = yOffset;

        for (int m = 0; m < NN.layers[0].neurons[0].getConnectionCount(); m++) {    //draw input neurons with different color
          fill(255, 175, 0);                                             
          ellipse(xPosition, yPosition, r, r);
          yPosition += yOffset;
        }
      }
    }
  }
}
