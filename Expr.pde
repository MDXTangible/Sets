// -------------------------------------------------------------
abstract class Expr {

  // Expr = BinExpr | NameExpr | ( Expr ) | ... 
  // BinExpr = Expr Op Expr
  // NameExpr = A | B | ....

  // Op = union | intersect | diff | ...

  // plus: Unary ops? Empty
  
  // More complex: things with bool vals - subset? member?

  MathsSym sym; 

  abstract String toString();

  boolean isBinExpr() {
    return false;
  } 
  boolean isNameExpr() {
    return false;
  }
  boolean isComplete() {
    return true;
  }

  abstract boolean contains(int x, int y);

  void calcCircles(int x, int y) {
    ArrayList<NameExpr> ns = getNamesList();

    switch(ns.size()) {
    case 0: 
      break;
    case 1: 
      ns.get(0).setLoc(x, y); 
      break;
    case 2: 
      ns.get(0).setLoc(x-cOffset, y);  
      ns.get(1).setLoc(x+cOffset, y); 
      break;

    case 3: 
      ns.get(0).setLoc(x, y-cOffset);  
      ns.get(1).setLoc(x-cOffset, y+cOffset); 
      ns.get(2).setLoc(x+cOffset, y+cOffset); 
      break;
    case 4: // what to do here?
      break;
    }
  }

  void drawCircles() {
    ArrayList<NameExpr> ns = getNamesList();

    for (NameExpr e : ns) {
      e.drawCircle();
    }
  }

  abstract HashSet<NameExpr> getNames();

  ArrayList<NameExpr> getNamesList() {
    HashSet<NameExpr> s=getNames();
    ArrayList<NameExpr>  l = new ArrayList(s);

    Collections.sort(l);
    return l;
  }
}


// -------------------------------------------------------------

class NameExpr extends Expr implements Comparable {
  String name="";

  int xLoc, yLoc; // Location of the circle for this name

  int compareTo(Object o) {
    return name.compareTo(((NameExpr)o).name);
  }
  boolean equals(Object o) {
    //Log("EQ: "+ this + " == "+o);
    if (o.getClass() == this.getClass()) {
      //Log("Y");
      return (name.equals(((NameExpr)o).name));
    }
    return super.equals(o);
  }

  int hashCode() {
    return name.hashCode();
  }

  String toString() {
    return name;
  }
  
  HashSet<NameExpr> getNames() {
    Log("HS with: "+ this);
    HashSet a =  new HashSet();
    a.add(this);
    return a;
  }

  void setLoc(int x, int y) {
    xLoc=x; // record where we're drawing this!
    yLoc=y;
  }

  void drawCircle() {
    pushStyle();
    ellipseMode(CENTER);
    textAlign(CENTER, CENTER);

    noFill();
    stroke(255);
    ellipse(xLoc, yLoc, cRad, cRad);
    text(name, xLoc, yLoc-10);
    popStyle();
  }

  boolean contains(int x, int y) {
    return (2* dist(x, y, xLoc, yLoc)) < cRad;
  }
}

// -------------------------------------------------------------
class BinExpr extends Expr {
  Expr left;
  String op;
  Expr right;

  String toString() {

    String r = (right==null)?"null":right.toString();
    return "(" + left.toString() + 
      " " + op + " " + 
      r+")";
  }
  boolean isBinExpr() {
    return true;
  }
  boolean isComplete() {
    return (left!=null && op !=null && right !=null);
  }

  HashSet<NameExpr> getNames() {
    HashSet<NameExpr> a =  new HashSet<NameExpr>();
    Log ("L :"+left + " R: "+right);
    if (left != null) {
      Log(" LS: "+left.getNames());
      a.addAll(left.getNames());
    }
    if (right != null) {
      a.addAll(right.getNames());
      Log(" RS: "+right.getNames());
    }


    Log(" All: "+a);
    return a;
  }

  boolean contains(int x, int y) {
    boolean r=false;
    if (isComplete()) {
      switch (op) {
      case UNION:
        r = left.contains(x, y) || right.contains(x, y) ;
        break;
      case INTER:
        r = left.contains(x, y) && right.contains(x, y) ;
        break;
      case DIFF:
        r = left.contains(x, y) && !right.contains(x, y) ;
        break;
      }
    }
    return r;
  }
}
