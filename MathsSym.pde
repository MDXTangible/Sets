class MathsSym {
  int x, y;
  String text;
  int size=40;
  int rad=10;

  MathsSym() {
  }

  void draw() {

    pushStyle();
    stroke(255, 150, 150, 100);
    fill(20);
    
    textSize(15);
    textAlign(CENTER, CENTER);

    pushMatrix();
    translate(
      (int)Calibration.transformX(x), 
      (int)Calibration.transformY(y));

    rect(0, 0, 2*size, size, rad, rad, rad, rad);
    popMatrix();

    //fill(textCol);
   fill(255);
    text(text, (int)Calibration.transformX(x), 
      (int)Calibration.transformY(y));
    popStyle();
  }

  String toString() {
    return text;
  }

  boolean isName() {
    return (text=="A" || text == "B" || text == "C" || text == "D"|| text == "E");
  }
  boolean isBinOp() {
    return (text==UNION || text == INTER || text == DIFF);
  }  
  boolean isOpen() {
    return (text=="(");
  }  
  boolean isClose() {
    return (text==")");
  }
}
