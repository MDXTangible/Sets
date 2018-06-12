/**  Calibration - transform coordinates by translating and scaling
 
 Bob Fields 2011
 
 
 Code to calibrate for table by shifting and scaling 
 in X & Y directions so that projected images are registered with 
 physical objects.
 
 Assumes that the camera views a larger area thant the projection.
 Assumes there's no keystone, fisheye or other distortion (or at least it does no correction for this).
 
 1. place fiducials in the projected area - e.g. at the corners.
 2. change scale and offset to make projected blue squares match symbols.
 - Use the arrow keys to shift the symbols
 - Use x & y to shrink in x & y directions
 - Use X & Y to expand in x & y direction.
 3. offsets & scaling factors are displayed.
 
 4. make the squares bigger / smaller with +/-
 5. flip the whole thing left-to-right with f 
 
 */

static class Calibration {

  static PApplet app;
  static float xOffset=0;
  static float xScale=1;
  static float yOffset=0;
  static float yScale=1;
  static boolean flip=false;

  static int width;
  static int height;

  static void init(PApplet a) { 
    app = a;
    String lines[] = app.loadStrings("calibration.txt");
    if (lines !=null && lines.length == 5) {
      xOffset = float(lines[0]);
      yOffset = float(lines[1]);
      xScale = float(lines[2]);
      yScale = float(lines[3]);
      flip = boolean(lines[4]);
    }
  }

  void reset() {
    xOffset=0;
    xScale=1;
    yOffset=0;
    yScale=1;
    flip=false;
    saveDetails();
  }

  static void setSize(int w, int h) {
    width=w;
    height=h;
  }


  static int offsetJump=2;
  static float scaleJump=0.05;

  static float transformX(float x) { 
    // apply scale and offset to a value in the x dimension
    // use the flip flag to determine whether to reverse left-to-right
    float nx=x * xScale+xOffset;
    return(flip?width-nx:nx);
  }

  static float transformY(float y) { 
    // apply scale and offset to a value in the y dimension
    float ny= y * yScale+yOffset;
    return(ny);
  }

  static float scaleX(float x) { 
    // apply scale to a value in the x dimension
    // use the flip flag to determine whether to reverse left-to-right
    return (x * xScale);
  }

  static float scaleY(float y) { 
    // apply scale and offset to a value in the y dimension
    return (y * yScale);
  }

  static void print() { 
    println("x-off " + xOffset + " y-off " + yOffset + " x-scale " + xScale + " y-scale " + yScale );
  }

  static void saveDetails() {
    String[] strs = {
      xOffset+"", yOffset+"", xScale+"", yScale+"", flip+""
    };
    app.saveStrings("calibration.txt", strs);
  }

  static void keyPressed(int keyCode, char key) {
     if (keyCode==UP) { 
      yOffset-=offsetJump;
    }
    if (keyCode==DOWN) {  
      yOffset+=offsetJump;
    }
    if (keyCode==LEFT) { 
      xOffset-=offsetJump;
    }
    if (keyCode==RIGHT) { 
      xOffset+=offsetJump;
    }
    if (key=='x') { 
      xScale-=scaleJump;
    }
    if (key=='X') {  
      xScale+=scaleJump;
    }
    if (key=='y') { 
      yScale-=scaleJump;
    }
    if (key=='Y') { 
      yScale+=scaleJump;
    }
    if (key=='f') { 
      flip = !flip;
    }
    saveDetails();
  }
}