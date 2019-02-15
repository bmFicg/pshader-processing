//readPixels with jogl support 


import com.jogamp.opengl.GL;
import com.jogamp.opengl.GL2ES2;

import com.jogamp.opengl.util.GLBuffers;
import java.nio.FloatBuffer;

void setup() {
  size(640, 360, P3D);
  noStroke();
}

void draw() {
  background(127, 255);

  //lights();
  pushMatrix();
  translate(width/2.0, height/2.0, -150.0);
  rotateY((frameCount*.1f+0.52)/PI);
  fill(25, 55, 254);
  box(150);
  popMatrix();

  PJOGL pgl = (PJOGL) beginPGL();  
  GL2ES2 gl = pgl.gl.getGL2ES2();
  FloatBuffer  cbuff = GLBuffers.newDirectFloatBuffer(new float[3]);
  gl.glReadPixels(mouseX, mouseY, 1, 1, GL.GL_RGB, GL.GL_FLOAT, cbuff);
  endPGL();

  fill(0, 255, 64, 225);
  textSize(18);
  textAlign(CENTER, BOTTOM);
  text(
    "r: "+(cbuff.get(0)*255)
    +"\ng:"+(cbuff.get(1)*255)
    +"\nb:"+(cbuff.get(2)*255), mouseX, mouseY);
  
  //
  //println("r:"+(cbuff.get(0)*255)+" g:"+(cbuff.get(1)*255)+" b:"+(cbuff.get(2)*255));
}
