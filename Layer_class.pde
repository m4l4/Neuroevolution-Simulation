class Layer {
  Neuron[] neurons = {};

  float[] layerWeights = {};

  float[] layerInputs = {};
  float[] layerOutputs = {};

  Layer(int ConnectionNum, int NeuronNum) {
    for (int i = 0; i < NeuronNum; i++) {
      Neuron tempNeuron = new Neuron(ConnectionNum);                        //create neuron
      addNeuron(tempNeuron);                                                //add it to the neuron array
      addLayerOutputs();                                                    //add an output for every neuron int the layer
      for (int j = 0; j < tempNeuron.connectionWeights.length; j++) {        //for every neuron retrive weights and bias
        layerWeights = (float[]) append(layerWeights, tempNeuron.connectionWeights[j]);
      }
    }
  }

  void addNeuron(Neuron xNeuron) {                 //Function to add an input or output Neuron to this Layer
    neurons = (Neuron[]) append(neurons, xNeuron);
  }

  int getNeuronCount() {                            //Function to get the number of neurons in this layer
    return neurons.length;
  }

  float[] getWeights() {                             //Function to get Weights and biases of the whole layer
    return layerWeights;
  }

  void addLayerOutputs() {                          //Function to increment the size of the actualOUTPUTs array by one.
    layerOutputs = (float[]) expand(layerOutputs, (layerOutputs.length+1));
  }

  void setWeights(float[] tempWeights) {            //function to set weights and bias for every neuron of the layer
    layerWeights = new float[0];                    //first we clear the layerWeights array


    for (int i= 0; i < tempWeights.length; i++) {                                                         //for every value of the temporary array...

      for (int j = 0; j < getNeuronCount(); j++) {                                                        //for every neuron of the layer...   
        neurons[j].connectionWeights = new float[0];                                                      //we clear the neuron Weights array

        for (int k = 0; k < neurons[j].getConnectionCount(); k++) {                                       //for every connection of the neuron...
          neurons[j].connections[k].setWeight(tempWeights[i]);                                            //set the connection weights
          layerWeights = (float[]) append(layerWeights, tempWeights[i]);                                  //move the value into the layer weights array
          neurons[j].connectionWeights = (float[]) append(neurons[j].connectionWeights, tempWeights[i]);  //move the value into the neuron weights array
          i++;                                                                                            // "i" must advance since the value has been already set
        }
        neurons[j].setBias(tempWeights[i]);                                                               //once we've finished with the connection we set the neuron bias      
        layerWeights = (float[]) append(layerWeights, tempWeights[i]);                                    //and move value to the layer weights array
        neurons[j].connectionWeights = (float[]) append(neurons[j].connectionWeights, tempWeights[i]);    //aswell to the neuron weights array
        i++;                                                                                              //once again "i" must advance to avoid reusing values
      }
    }
  }

  float[] getWeigths() {
    return layerWeights;
  }

  void setInputs(float[] tempInputs) {              //set inputs for this layer
    layerInputs = tempInputs;
  }

  void processInputsToOutputs() {                   //process all the inputs to output for the neurons in this layer    
    int neuronCount = getNeuronCount();

    if (neuronCount > 0) {                                                //check if there are neurons to process inputs
      if (layerInputs.length!=neurons[0].getConnectionCount()) {          //check if num of inputs match num of neurons
        println("Error in Layer: processInputsToOutputs: The number of inputs do NOT match the number of Neuron connections in this layer");
        exit();
      } else {
        for (int i=0; i<neuronCount; i++) {                                //calculate layer outputs
          layerOutputs[i]=neurons[i].getNeuronOutput(layerInputs);
        }
      }
    } else {
      println("Error in Layer: processInputsToOutputs: There are no Neurons in this layer");
      exit();
    }
  }
}
