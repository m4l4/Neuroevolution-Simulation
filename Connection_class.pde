class Connection {
  float connEntry;           //raw input
  float weight;              //connection weight (-1 to 1)
  float connExit;            //processed output (raw * weight)

  Connection() {                       //This is the default constructor for an Connection
    randomiseWeight();
  }

  Connection(float tempWeight) {       //A custom weight for this Connection constructor
    setWeight(tempWeight);
  }

  void setWeight(float tempWeight) {   //Function to set the weight of this connection
    weight=tempWeight;
    weight = constrain(weight, -1, 1);
  }

  void randomiseWeight() {             //Function to randomise the weight of this connection
    setWeight(random(-1, 1));
  }

  float getWeight() {                   //function to get the weight of the connection
    return weight;
  }

  float calcConnExit(float tempInput) {  //function to process the input
    connEntry = tempInput;
    connExit = connEntry * weight;
    return connExit;
  }
}
