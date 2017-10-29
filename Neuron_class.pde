class Neuron {
  Connection[] connections={};              //array of connections
  float[] connectionWeights = {};           //array of connections weights

  float bias;
  float neuronInput;
  float neuronOutput;

  Neuron(int ConnectionNum) {                //constructor with random bias and connection weights
    randomiseBias();
    for (int i = 0; i < ConnectionNum; i++) {
      Connection conn = new Connection();
      addConnection(conn);
      float tempWeight = conn.getWeight();
      connectionWeights = (float[]) append(connectionWeights, tempWeight);  //populate the weights array
    }
    connectionWeights = (float[]) append(connectionWeights, bias);          //append the bias to the weights array
  }

  void addConnection(Connection conn) {                                     //Function to add a Connection to this neuron
    connections = (Connection[]) append(connections, conn);
  }

  int getConnectionCount() {                // Function to return the number of connections associated with this neuron.
    return connections.length;
  }

  void setBias(float tempBias) {            //Function to set the bias of this Neron
    bias = tempBias;
  }

  void randomiseBias() {                     //Function to randomise the bias of this Neuron
    setBias(random(-1, 1));
  }

  float getNeuronOutput(float[] connEntryValues) {            //Function to convert the inputValue to an outputValue
    if (connEntryValues.length!=getConnectionCount()) {       //Make sure that the number of connEntryValues matches the number of connections
      println("Neuron Error: getNeuronOutput() : Wrong number of connEntryValues");
      exit();
    }

    neuronInput = 0;                                                 // clear the previous input

    for (int i = 0; i < getConnectionCount(); i++) {                  // sum weighted inputs for all connections
      neuronInput += connections[i].calcConnExit(connEntryValues[i]);
    }

    neuronInput += bias;                           //add the bias
    neuronOutput = ActivateTanh(neuronInput);        //pass the sum into the activation function
    return neuronOutput;                           //return output
  }

  float ActivateTanh(float x) {                                    //Activation function
    float activatedValue = (2 / (1 + exp(-1 * (x*2)))) -1;         //TanH (hyperbolic tangent) returns -1 to 1
    return activatedValue;
  }
}
