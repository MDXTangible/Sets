// import the TUIO library
import TUIO.*;

import java.util.Comparator;
import java.util.Collections;
import java.util.HashSet;
import java.util.Iterator;

MathsSym m;

// declare a TuioProcessing client
TuioProcessing tuioClient;

HashMap<Integer, String> symbs= new HashMap();

// objects : FidID -> MathSym
HashMap<Integer, MathsSym> objects = new HashMap<Integer, MathsSym>();
ArrayList<MathsSym> symList = new ArrayList();


ArrayList<Expr> expressions;

int textPosY=100;
int textPosX1=650;
int textPosX2=300;
boolean drawObjs = false;


PFont f;
String buffer = "";



boolean changed=true;

void setup() {
  size (1350, 900);
  f = createFont("Arial", 16);



  Calibration.setSize(width, height);
  Calibration.init(this);

  textSize(TEXTSIZE);
  rectMode(CENTER);

  textAlign(CENTER, BOTTOM);


  symbs.put(11, UNION);
  symbs.put(12, INTER);
  symbs.put(10, DIFF);


  symbs.put(0, "A");
  symbs.put(1, "B");
  symbs.put(2, "C");
  symbs.put(3, "D");
  symbs.put(4, "E");

  symbs.put(5, "A");
  symbs.put(6, "B");
  symbs.put(7, "C");
  symbs.put(8, "D");
  symbs.put(9, "E");


  symbs.put(30, "("); // not used yet!
  symbs.put(31, ")");





  tuioClient  = new TuioProcessing(this);
}

synchronized void draw() {
  if (changed) { // only redraw if something has changed - should be much more efficient
    drawScreen();
    changed=false;
  }
}

void drawScreen() {
  background(50);

  textSize(24);
  text("TYPE AN EXPRESSION", 650, 300);
  textFont(f);  
  fill(255);  
  //text(stored, textPosX1 + 100, textPosY + 100);


  if (drawObjs) { // 
    for (MathsSym to : objects.values()) {
      to.draw();
    }
  }


  text(buffer, 200, 200);  

  if (expressions==null) {
    fill(255);
    text("Not a valid expression", textPosX1, textPosY);
  } else {
    if (expressions.isEmpty()) {
      text("Empty", textPosX1, textPosY);
    } else {

      // show expressions and work out locations of circles
      for (int i=0; i<expressions.size(); i++ ) {
        Expr e = expressions.get(i);
        //textAlign(CENTER, CENTER);

        textAlign(CENTER, BOTTOM);
        text(e.toString(), (int)((i +0.5)* width/expressions.size()), textPosY);
        e.calcCircles( (int)((i +0.5)* width/expressions.size()), height/2);
      }

      // draw all the circle fills
      for (int i =0; i<width; i++) {
        for (int j = 0; j<height; j++) {
          for (Expr e : expressions) {
            if (e.contains(i, j)) {
              point(i, j);
            }
          }
        }
      }

      // draw the circle outlines
      for (Expr e : expressions) {
        e.drawCircles();
      }
    }
  }
}

void Log(String s) {
  System.out.println(s);
}

void updateExpressions() {
  Parser p = new Parser();
  Log("----------------------");
  Log("Tokens: "+symList);
  expressions = p.parse(symList);
}


synchronized void addTuioObject(TuioObject obj) {
  int id = obj.getSymbolID();
  if (id==SHOWOBJS) {
    drawObjs=true;
    return;
  }
  String label = "X";
  if (symbs.containsKey(id)) {
    label = symbs.get(id);
  } 
  MathsSym o = new MathsSym();
  o.text=label;
  o.x=obj.getScreenX(width);
  o.y=obj.getScreenY(height);

  objects.put(id, o);
  symList.add(o);

  Collections.sort(symList, comp);
  updateExpressions();
  changed=true;
}
synchronized void updateTuioObject(TuioObject obj) {
  int id = obj.getSymbolID();
  if (objects.containsKey(id)) {
    MathsSym o = objects.get(id);

    o.x=obj.getScreenX(width);
    o.y=obj.getScreenY(height);

    //o.setAngle(obj.getAngle());
    changed=true;
  }

  Collections.sort(symList, comp);
  updateExpressions();
}

synchronized void removeTuioObject(TuioObject obj) {
  int id = obj.getSymbolID();
  if (id==SHOWOBJS) {
    drawObjs=false;
    return;
  }
  if (objects.containsKey(id)) {
    MathsSym o=objects.get(id);
    objects.remove(id);
    symList.remove(o);
  }
  updateExpressions();
  changed=true;
}

Comparator<MathsSym> comp = new Comparator<MathsSym>() {
  // Comparator object to compare two TuioObjects on the basis of their x position
  // Returns -1 if o1 left of o2; 0 if they have same x pos; 1 if o1 right of o2

  // allows us to sort objects left-to-right.
  public int compare(MathsSym o1, MathsSym o2) {
    if (o1.x<o2.x) { 
      return -1;
    } else if (o1.x>o2.x) { 
      return 1;
    } else { 
      return 0;
    }
  }
};




void keyPressed() {

  // Ignore 'special' keys that we don't care about
  if (keyCode == SHIFT || keyCode == UP || keyCode == DOWN) {
  } else
    if (keyCode == BACKSPACE ) {
      //println("BACKSPACE");
      if (buffer.length()>0) {
        buffer=buffer.substring(0, buffer.length()-1);
        changed=true;
      }
    } else
      if (key == ENTER) { 
        // Insert spaces around parentheses:
        buffer=buffer.replaceAll("\\(", " ( ").replaceAll("\\)", " ) ");
        
        // split with a reg exp to catch multiple whitespace characters:
        String[] splitString = buffer.split("\\s+");

        symList = new ArrayList();
        for (int i = 0; i < splitString.length; i++) {

          // Don't change case - the SHIFT ket now works
          String capText = splitString[i];
          MathsSym o = new MathsSym();

          /*
      switch(capText) {
           case "UNION": 
           o.text=UNION;
           break;
           case "N": 
           o.text=INTER;
           break;
           case "/": 
           o.text=DIFF;
           break;
           default:  
           o.text=capText;
           break;
           }*/

          o.text=capText;
          //o.x=200;
          //o.y=200;
          symList.add(o);
        }

        updateExpressions();
        changed=true;
        
        // Set the buffer to empty if we dom't want to be able to edit it:
        //buffer = "";
      } else {    
        buffer = buffer + key;
        changed=true;
      }

  Calibration.keyPressed(keyCode, key);
}
