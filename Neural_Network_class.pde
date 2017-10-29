class NeuralNetwork {
  Layer[] layers = {};                  //array of layers
  float[] arrayOfInputs = {};           //inputs of the neural net
  float[] arrayOfOutputs = {};          //outputs of the neural net
  float[][] networkWeights = {};        // TO DO matrix of the NN weights and function to set it at once


  NeuralNetwork() {
  }

  void addLayer(int ConnectionNum, int NeuronNum) {            //Function to add a Layer to the Neural Network
    layers = (Layer[]) append(layers, new Layer(ConnectionNum, NeuronNum));
  }

  int getLayerCount() {                                        //Function to get the number of layers
    return layers.length;
  }

  void setInputs(float[] tempInputs) {                         //Function to set the inputs of the neural network
    arrayOfInputs = tempInputs;
  }

  void setLayerInputs(float[] tempInputs, int layerIndex) {    //Function to set the inputs of a specific layer
    if (layerIndex > getLayerCount()-1) {
      println("NN Error: setLayerInputs: layerIndex=" + layerIndex + " exceeded limits= " + (getLayerCount()-1));
    } else {
      layers[layerIndex].setInputs(tempInputs);
    }
  }

  void setOutputs(float[] tempOutputs) {                 //Function to set the outputs of the neural network
    arrayOfOutputs = tempOutputs;
  }

  float[] getOutputs() {                               //Function to get the outputs
    return arrayOfOutputs;
  }

  void processInputsToOutputs(float[] tempInputs) {    //function to process inputs to outputs using all the layers
    setInputs(tempInputs);

    if (getLayerCount() > 0) {      //make sure that the number ofinputs matches the neuron connections of the first layer
      if (arrayOfInputs.length != layers[0].neurons[0].getConnectionCount()) {
        println("NN Error: processInputsToOutputs: The number of inputs do NOT match the NN");
        exit();
      } else {                                              // number of inputs is fine
        for (int i = 0; i < getLayerCount(); i++) {         //set inputs for the layers
          if (i==0) {
            setLayerInputs(arrayOfInputs, i);               //first layer get inputs from the NN
          } else {
            setLayerInputs(layers[i-1].layerOutputs, i);    //other layer get inputs from the previous one
          }
          layers[i].processInputsToOutputs();               //once inputs have been set, convert them to outputs
        }
        setOutputs(layers[getLayerCount()-1].layerOutputs);
      }
    } else {
      println("Error: There are no layers in this Neural Network");
      exit();
    }
  }
}
