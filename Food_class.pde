class Food {                    //not much to say about that
  PVector position;

  Food(float x, float y) {
    position = new PVector(x, y);
  }

  void run() {
    display();
  }  

  void display() {
    stroke(0);
    fill(200, 200, 0);
    ellipse(position.x, position.y, 10, 10);
  }
}
